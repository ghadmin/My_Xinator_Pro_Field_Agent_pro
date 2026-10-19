//
//  XplorPayTapToPayPlugin.swift
//  Runner
//
//  Flutter bridge for the Clearent SDK's Tap to Pay on iPhone flow (Apple
//  Proximity Reader, no external hardware).
//
//  This lives in Swift — unlike the VP3300 plugin (XplorPayPlugin.m, Obj-C) —
//  because the Tap to Pay API (ClearentUIManager, PaymentInfo,
//  TapToPayDeviceSupportResult) is only exposed through the framework's Swift
//  module interface; the generated Obj-C header does not declare it (verified
//  against tag 4.0.182).
//
//  Channels:
//    - MethodChannel "xplorpay/tap_to_pay"
//    - EventChannel  "xplorpay/tap_to_pay/events"
//
//  Minimum iOS for Tap to Pay is 15.4 (project targets 15.0), so every SDK
//  call is gated with #available(iOS 15.4, *).
//
//  Card data never leaves the Secure Element; this plugin only ever sees
//  gateway responses and error types. Nothing is NSLogged.
//

import Flutter
import UIKit
import ClearentIdtechIOSFramework

@objc public class XplorPayTapToPayPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var methodChannel: FlutterMethodChannel?
  private var eventChannel: FlutterEventChannel?
  private var eventSink: FlutterEventSink?

  /// Forwards the SDK's transaction outcome (set as ClearentWrapper.shared.delegate).
  private let listener = TransactionListener()

  /// Config from the last `initialize` so SDK calls can self-heal if needed.
  private var baseUrl: String?
  private var apiKey: String?
  private var publicKey: String?
  private var softwareType: String?
  private var softwareTypeVersion: String?

  // MARK: - FlutterPlugin

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = XplorPayTapToPayPlugin()
    instance.methodChannel = FlutterMethodChannel(
      name: "xplorpay/tap_to_pay", binaryMessenger: registrar.messenger())
    instance.eventChannel = FlutterEventChannel(
      name: "xplorpay/tap_to_pay/events", binaryMessenger: registrar.messenger())
    instance.eventChannel?.setStreamHandler(instance)
    registrar.addMethodCallDelegate(instance, channel: instance.methodChannel!)
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    // Engine is going away; drop the sink so late delegate callbacks don't
    // touch a dead channel.
    eventSink = nil
    eventChannel = nil
    methodChannel = nil
  }

  // MARK: - FlutterStreamHandler

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink)
    -> FlutterError? {
    eventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    eventSink = nil
    return nil
  }

  // MARK: - Method channel

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    // Method channel handlers always arrive on the platform main thread; the
    // Clearent SDK API is @MainActor-isolated, so bridge the isolation here.
    MainActor.assumeIsolated {
      self.handleOnMain(call, result: result)
    }
  }

  @MainActor
  private func handleOnMain(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]

    switch call.method {
    case "isSupported":
      if #available(iOS 15.4, *) {
        result(ClearentUIManager.shared.isTapToPaySupported)
      } else {
        result(false)
      }

    case "verifySupport":
      // Hardware check first — this variant needs no SDK configuration.
      guard #available(iOS 15.4, *) else {
        result(Self.support(false, message: "Tap to Pay requires iOS 15.4 or later"))
        return
      }
      let hardware = ClearentUIManager.shared.verifyTapToPayDeviceSupport()
      if !hardware.isSupported {
        result(Self.support(false, message: hardware.errorMessage))
        return
      }
      // The completion variant additionally probes the host-app entitlement
      // through ProximityReader's readerIdentifier, which needs SDK config
      // and throws/traps inside the SDK while the entitlement is missing.
      // TODO(entitlement): once Apple approves Proximity Reader Payment
      // Acceptance, replace the line below with:
      //   ClearentUIManager.shared.verifyTapToPayDeviceSupport { support in
      //     result(Self.support(support.isSupported, message: support.errorMessage))
      //   }
      result(Self.support(true, message: nil))

    case "initialize":
      baseUrl = args["baseUrl"] as? String
      apiKey = args["apiKey"] as? String
      publicKey = args["publicKey"] as? String
      softwareType = args["softwareType"] as? String
      softwareTypeVersion = args["softwareTypeVersion"] as? String
      if let problem = ensureSdkInitialized() {
        result(problem)
      } else {
        result(true)
      }

    case "prepare":
      // Pre-warm the reader session; safe to call repeatedly (docs).
      if let problem = ensureSdkInitialized() {
        result(problem)
        return
      }
      guard #available(iOS 15.4, *) else {
        result(Self.flutterErrorMessage("Tap to Pay requires iOS 15.4 or later"))
        return
      }
      let paymentInfo = Self.paymentInfo(from: args)
      let forceRefresh = (args["forceRefreshToken"] as? Bool) ?? false
      ClearentUIManager.shared.prepareTapToPay(
        paymentInfo: paymentInfo, forceRefreshToken: forceRefresh
      ) { error in
        if let error {
          result(Self.flutterError(error))
        } else {
          result(true)
        }
      }

    case "isAccountLinked":
      guard #available(iOS 15.4, *) else {
        result(false)
        return
      }
      // Reads terminal settings — needs configuration; false otherwise.
      if ensureSdkInitialized() != nil {
        result(false)
        return
      }
      ClearentUIManager.shared.isAccountLinked { linked, _ in
        result(linked)
      }

    case "linkAccount":
      // Presents Apple's terms sheet; a successful link starts reader
      // preparation automatically (docs). Keep outside the payment path.
      guard #available(iOS 15.4, *) else {
        result(Self.flutterErrorMessage("Tap to Pay requires iOS 15.4 or later"))
        return
      }
      guard let presenter = Self.presenterViewController() else {
        result(Self.flutterErrorMessage("No view controller available to present the terms sheet"))
        return
      }
      ClearentUIManager.shared.linkAccount { error in
        if let error {
          result(Self.flutterError(error))
        } else {
          result(true)
        }
      }
      // The SDK presents its own terms sheet from the current context; nothing
      // further to do here.

    case "presentPayment":
      // SDK owns the full-screen flow (preparing → Apple tap sheet →
      // authorizing → success/error). Outcome arrives via the `transaction`
      // and `closed` events, not this method result.
      if let problem = ensureSdkInitialized() {
        result(problem)
        return
      }
      guard #available(iOS 15.4, *) else {
        result(Self.flutterErrorMessage("Tap to Pay requires iOS 15.4 or later"))
        return
      }
      guard let presenter = Self.presenterViewController() else {
        result(Self.flutterErrorMessage("No view controller available to present Tap to Pay"))
        return
      }
      let paymentInfo = Self.paymentInfo(from: args)
      let nav = ClearentUIManager.shared.tapToPayViewController(
        paymentInfo: paymentInfo
      ) { [weak self] error in
        // UI dismissed via Done/Cancel — not a sale verdict (docs).
        self?.emit([
          "event": "closed",
          "error": error.map { Self.errorName($0) } ?? NSNull(),
        ])
      }
      nav.modalPresentationStyle = .fullScreen
      presenter.present(nav, animated: true)
      result(true)

    case "invalidateSession":
      if #available(iOS 15.4, *) {
        ClearentUIManager.shared.invalidateTapToPaySession()
      }
      result(true)

    case "osDeprecationDate":
      if #available(iOS 15.4, *) {
        let date = ClearentUIManager.shared.tapToPayOSVersionDeprecationDate
        result(date.map { ISO8601DateFormatter().string(from: $0) } ?? NSNull())
      } else {
        result(NSNull())
      }

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - SDK setup

  /// (Re)initializes ClearentUIManager when configuration is missing or has
  /// changed. Returns nil when the SDK is ready. Also installs the
  /// transaction listener that reports sale outcomes to Dart.
  @MainActor
  private func ensureSdkInitialized() -> FlutterError? {
    guard let baseUrl, !baseUrl.isEmpty, let apiKey, !apiKey.isEmpty else {
      return FlutterError(
        code: "TAP_TO_PAY_NO_API_AUTHENTICATION",
        message: "Call initialize(baseUrl, apiKey) first",
        details: nil)
    }
    if ClearentUIManager.configuration?.baseURL == baseUrl { return nil }

    let config = ClearentUIManagerConfiguration(
      baseURL: baseUrl,
      apiKey: apiKey,
      publicKey: publicKey,
      enableEnhancedMessaging: false,
      signatureEnabled: false,  // Tap to Pay never captures signatures (docs)
      softwareType: softwareType,
      softwareTypeVersion: softwareTypeVersion
    )
    ClearentUIManager.shared.initialize(with: config)
    UIFont.loadFonts()
    ClearentWrapper.shared.delegate = listener
    listener.onTransaction = { [weak self] response, error in
      self?.emitTransaction(response: response, error: error)
    }
    return nil
  }

  // MARK: - Event helpers

  private func emit(_ payload: [String: Any]) {
    DispatchQueue.main.async {
      self.eventSink?(payload)
    }
  }

  private func emitTransaction(response: TransactionResponse?, error: ClearentError?) {
    var json: Any = NSNull()
    if let response, let data = try? JSONEncoder().encode(response),
      let obj = try? JSONSerialization.jsonObject(with: data) {
      json = obj
    }
    emit([
      "event": "transaction",
      "response": json,
      "error": error.map { Self.errorName($0) } ?? NSNull(),
    ])
  }

  // MARK: - Static mappers

  private static func support(_ isSupported: Bool, message: String?) -> [String: Any] {
    ["isSupported": isSupported, "errorMessage": message ?? NSNull()]
  }

  private static func paymentInfo(from args: [String: Any]) -> PaymentInfo {
    PaymentInfo(
      amount: (args["amount"] as? NSNumber)?.doubleValue ?? 0,
      customerID: args["customerID"] as? String,
      invoice: args["invoice"] as? String,
      orderID: args["orderID"] as? String,
      billing: nil,
      shipping: nil,
      softwareType: args["softwareType"] as? String,
      softwareTypeVersion: args["softwareTypeVersion"] as? String,
      webAuth: nil
    )
  }

  private static func errorName(_ error: ClearentError) -> String {
    switch error.type {
    case .cancelledByUser: return "cancelledByUser"
    case .noAPIAuthentication: return "noAPIAuthentication"
    case .baseURLNotProvided: return "baseURLNotProvided"
    case .offlineModeEncryptionKeyNotProvided: return "offlineModeEncryptionKeyNotProvided"
    case .httpError: return "httpError"
    case .gatewayDeclined: return "gatewayDeclined"
    case .connectivityError: return "connectivityError"
    case .missingToken: return "missingToken"
    case .missingSignatureImage: return "missingSignatureImage"
    case .missingData: return "missingData"
    case ClearentErrorType.none: return "none"
    default: return "unknown(\(error.type.rawValue))"
    }
  }

  private static func flutterError(_ error: ClearentError) -> FlutterError {
    var details: [String: Any] = ["type": errorName(error)]
    // ClearentError is Codable; when the SDK built it from a gateway response
    // the encoded form carries the gateway's own error fields (errorMessage,
    // resultCode, ...) — the only hint of WHY e.g. the Tap to Pay session
    // token came back missing. localizedDescription is always Apple's generic
    // "ClearentError error 1." text (no CustomNSError conformance).
    if let data = try? JSONEncoder().encode(error),
      let obj = try? JSONSerialization.jsonObject(with: data) {
      details["gateway"] = obj
    }
    return FlutterError(
      code: "TAP_TO_PAY_\(errorName(error).uppercased())",
      message: error.localizedDescription,
      details: details
    )
  }

  private static func flutterErrorMessage(_ message: String) -> FlutterError {
    FlutterError(code: "TAP_TO_PAY_ERROR", message: message, details: nil)
  }

  private static func presenterViewController() -> UIViewController? {
    var root: UIViewController?
    for scene in UIApplication.shared.connectedScenes {
      if let windowScene = scene as? UIWindowScene {
        root = windowScene.keyWindow?.rootViewController
        if root != nil { break }
      }
    }
    if root == nil {
      root = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController
    }
    var top = root
    while let presented = top?.presentedViewController {
      top = presented
    }
    return top
  }
}

// MARK: - ClearentWrapperProtocol listener

/// Receives the SDK's transaction outcome. All protocol methods are required;
/// only `didFinishTransaction` carries data this integration needs.
private final class TransactionListener: ClearentWrapperProtocol {
  var onTransaction: ((TransactionResponse?, ClearentError?) -> Void)?

  func didFinishTransaction(response: TransactionResponse?, error: ClearentError?) {
    onTransaction?(response, error)
  }

  func didStartPairing() {}
  func didFinishPairing() {}
  func didReceiveSignalStrength() {}
  func didFindReaders(readers: [ReaderInfo]) {}
  func deviceDidDisconnect() {}
  func startedReaderConnection(with reader: ReaderInfo) {}
  func didFindRecentlyUsedReaders(readers: [ReaderInfo]) {}
  func didBeginContinuousSearching() {}
  func didEncounteredGeneralError() {}
  func didAcceptOfflineTransaction(status: TransactionStoreStatus) async {}
  func didFinishedSignatureUploadWith(response: SignatureResponse?, error: ClearentError?) async {}
  func didFinishedSendingReceipt(response: ReceiptResponse?, error: ClearentError?) async {}
  func didAcceptOfflineSignature(status: TransactionStoreStatus, transactionID: String) async {}
  func didAcceptOfflineEmail(transactionID: String) async {}
  func userActionNeeded(action: UserAction) {}
  func showEncryptionWarning() {}
}
