import Flutter
import UIKit

#if canImport(ClearentIdtechIOSFramework)
import ClearentIdtechIOSFramework
#endif

@objc public class XplorPayTapToPayPlugin: NSObject, FlutterPlugin, FlutterStreamHandler {
  private var methodChannel: FlutterMethodChannel?
  private var eventChannel: FlutterEventChannel?
  private var eventSink: FlutterEventSink?

  // State management
  private var baseUrl: String?
  private var apiKey: String?
  private var merchantId: String?
  private var publicKey: String?
  private var softwareType: String?
  private var softwareTypeVersion: String?

  // Pending payment result coordination (guarantees exactly-once completion)
  private let paymentCoordinator = PendingPaymentResultCoordinator()

  #if canImport(ClearentIdtechIOSFramework)
  private let listener = InternalTransactionListener()
  #endif

  // MARK: - FlutterPlugin Registration

  public static func register(with registrar: FlutterPluginRegistrar) {
    let instance = XplorPayTapToPayPlugin()
    instance.methodChannel = FlutterMethodChannel(
      name: "com.xceleran.tapToPay/tap_to_pay",
      binaryMessenger: registrar.messenger()
    )
    instance.eventChannel = FlutterEventChannel(
      name: "com.xceleran.tapToPay/tap_to_pay/events",
      binaryMessenger: registrar.messenger()
    )
    instance.eventChannel?.setStreamHandler(instance)
    registrar.addMethodCallDelegate(instance, channel: instance.methodChannel!)
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    eventSink = nil
    eventChannel?.setStreamHandler(nil)
    eventChannel = nil
    methodChannel?.setMethodCallHandler(nil)
    methodChannel = nil
    paymentCoordinator.reset()
  }

  // MARK: - FlutterStreamHandler

  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }

  // MARK: - Method Channel Handler

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    Task { @MainActor [weak self] in
      guard let self = self else { return }
      self.handleOnMainThread(call: call, result: result)
    }
  }

  @MainActor private func handleOnMainThread(call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any] ?? [:]

    switch call.method {
    case "isSupported":
      handleIsSupported(result: result)

    case "verifySupport":
      handleVerifySupport(result: result)

    case "initialize":
      handleInitialize(args: args, result: result)

    case "processPayment":
      handleProcessPayment(args: args, result: result)

    case "prepare":
      handlePrepare(args: args, result: result)

    case "isAccountLinked":
      handleIsAccountLinked(result: result)

    case "linkAccount":
      handleLinkAccount(result: result)

    case "invalidateSession":
      handleInvalidateSession(result: result)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: - Implementation Details

  @MainActor private func handleIsSupported(result: @escaping FlutterResult) {
    #if canImport(ClearentIdtechIOSFramework)
    if #available(iOS 16.0, *) {
      result(ClearentUIManager.shared.isTapToPaySupported)
    } else {
      result(false)
    }
    #else
    result(false)
    #endif
  }

  @MainActor private func handleVerifySupport(result: @escaping FlutterResult) {
    guard #available(iOS 16.0, *) else {
      result([
        "isSupported": false,
        "errorMessage": "Apple Tap to Pay on iPhone requires iOS 16.0 or later."
      ])
      return
    }

    #if canImport(ClearentIdtechIOSFramework)
    // CRASH GUARD: the completion-based variant traps inside the SDK when it
    // runs before initialize (nil force-unwrap of ClearentUIManager's config).
    guard let baseUrl = self.baseUrl, !baseUrl.isEmpty,
          let apiKey = self.apiKey, !apiKey.isEmpty else {
      result([
        "isSupported": false,
        "errorMessage": "SDK is not initialized. Call initialize() first."
      ])
      return
    }

    logStage("verifySupport", "requested")
    // The completion-based variant checks device support AND the host app's
    // ProximityReader entitlement. The synchronous variant checks hardware only,
    // so it cannot detect a missing entitlement.
    ClearentUIManager.shared.verifyTapToPayDeviceSupport { support in
      DispatchQueue.main.async {
        self.logStage(
          "verifySupport",
          "isSupported=\(support.isSupported) hasMessage=\(support.errorMessage != nil)"
        )
        result([
          "isSupported": support.isSupported,
          "errorMessage": support.errorMessage
        ])
      }
    }
    #else
    result([
      "isSupported": false,
      "errorMessage": "ClearentIdtechIOSFramework is not linked in host project."
    ])
    #endif
  }

  @MainActor private func handleInitialize(args: [String: Any], result: @escaping FlutterResult) {
    guard let apiKey = args["apiKey"] as? String, !apiKey.isEmpty else {
      result(FlutterError(
        code: "INVALID_ARGUMENTS",
        message: "Missing or empty required parameter: 'apiKey'",
        details: nil
      ))
      return
    }

    self.apiKey = apiKey
    // Optional and retained for bridge compatibility only: the installed SDK
    // authenticates via `apiKey` (web auth is not exposed by this plugin), so
    // this value is not forwarded into ClearentUIManagerConfiguration.
    self.merchantId = args["merchantId"] as? String
    self.baseUrl = args["baseUrl"] as? String ?? "https://gateway-int.clearent.net"
    self.publicKey = args["publicKey"] as? String
    self.softwareType = args["softwareType"] as? String ?? "Flutter-XplorPayTapToPay"
    self.softwareTypeVersion = args["softwareTypeVersion"] as? String ?? "1.0.0"

    #if canImport(ClearentIdtechIOSFramework)
    let config = ClearentUIManagerConfiguration(
      baseURL: self.baseUrl!,
      apiKey: self.apiKey!,
      publicKey: self.publicKey,
      enableEnhancedMessaging: false,
      signatureEnabled: false,
      softwareType: self.softwareType,
      softwareTypeVersion: self.softwareTypeVersion
    )

    ClearentUIManager.shared.initialize(with: config)
    UIFont.loadFonts()

    ClearentWrapper.shared.delegate = listener
    listener.onTransactionFinished = { [weak self] response, error in
      self?.handleTransactionOutcome(response: response, error: error)
    }

    logStage(
      "initialize",
      "apiKeyPresent=true merchantIdPresent=\(self.merchantId != nil) publicKeyPresent=\(self.publicKey != nil)"
    )
    result(true)
    #else
    result(FlutterError(
      code: "FRAMEWORK_MISSING",
      message: "ClearentIdtechIOSFrameworkPod is not installed. Please check your Podfile.",
      details: nil
    ))
    #endif
  }

  @MainActor private func handleProcessPayment(args: [String: Any], result: @escaping FlutterResult) {
    guard #available(iOS 16.0, *) else {
      result(FlutterError(
        code: "UNSUPPORTED_OS_VERSION",
        message: "Tap to Pay requires iOS 16.0 or later.",
        details: nil
      ))
      return
    }

    #if canImport(ClearentIdtechIOSFramework)
    guard let baseUrl = self.baseUrl, !baseUrl.isEmpty, let apiKey = self.apiKey, !apiKey.isEmpty else {
      result(FlutterError(
        code: "NOT_INITIALIZED",
        message: "SDK is not initialized. Please call initialize() first.",
        details: nil
      ))
      return
    }

    guard let presenter = Self.findTopViewController() else {
      result(FlutterError(
        code: "NO_VIEW_CONTROLLER",
        message: "Could not find a valid UIViewController to present Tap to Pay.",
        details: nil
      ))
      return
    }

    // Enforce a single in-flight payment session at the bridge level before any
    // asynchronous work begins. Disabling the Flutter pay button alone is not
    // sufficient protection.
    guard self.paymentCoordinator.begin(result) else {
      result(FlutterError(
        code: "PAYMENT_IN_PROGRESS",
        message: "A Tap to Pay payment is already in progress. Wait for the current payment to finish before starting another.",
        details: nil
      ))
      return
    }

    let amount = (args["amount"] as? NSNumber)?.doubleValue ?? 0.0
    let currencyCode = args["currencyCode"] as? String ?? "USD"

    let paymentInfo = PaymentInfo(
      amount: amount,
      customerID: args["customerId"] as? String,
      invoice: args["invoice"] as? String,
      orderID: args["orderId"] as? String,
      billing: nil,
      shipping: nil,
      softwareType: (args["softwareType"] as? String) ?? self.softwareType,
      softwareTypeVersion: (args["softwareTypeVersion"] as? String) ?? self.softwareTypeVersion,
      webAuth: nil
    )

    logStage("processPayment", "presenting amount=\(amount) currency=\(currencyCode)")

    let tapToPayVC = ClearentUIManager.shared.tapToPayViewController(paymentInfo: paymentInfo) { [weak self] error in
      guard let self = self else { return }

      // UI was dismissed via Done or Cancel. Dismissal alone never indicates
      // sale success or failure, so if no transaction verdict arrived first the
      // pending invocation is completed as cancelled — exactly once.
      self.logStage("processPayment", "sheetDismissed")
      self.emitEvent([
        "event": "closed",
        "error": error.map { Self.formatErrorName($0) } ?? NSNull()
      ])

      let cancelledDict: [String: Any] = [
        "status": "cancelled",
        "errorMessage": error?.localizedDescription ?? "Tap to Pay sheet dismissed by user.",
        "amount": amount,
        "currencyCode": currencyCode
      ]
      // No-op when the transaction verdict already completed this invocation.
      self.paymentCoordinator.complete(with: cancelledDict)
    }

    tapToPayVC.modalPresentationStyle = .fullScreen
    presenter.present(tapToPayVC, animated: true)
    #else
    result(FlutterError(
      code: "FRAMEWORK_MISSING",
      message: "ClearentIdtechIOSFrameworkPod is not installed. Please check your Podfile.",
      details: nil
    ))
    #endif
  }

  @MainActor private func handlePrepare(args: [String: Any], result: @escaping FlutterResult) {
    guard #available(iOS 16.0, *) else {
      result(FlutterError(
        code: "UNSUPPORTED_OS_VERSION",
        message: "Tap to Pay requires iOS 16.0 or later.",
        details: nil
      ))
      return
    }

    #if canImport(ClearentIdtechIOSFramework)
    let amount = (args["amount"] as? NSNumber)?.doubleValue ?? 0.0
    let forceRefresh = (args["forceRefreshToken"] as? Bool) ?? false

    let paymentInfo = PaymentInfo(
      amount: amount,
      customerID: nil,
      invoice: nil,
      orderID: nil,
      billing: nil,
      shipping: nil,
      softwareType: (args["softwareType"] as? String) ?? self.softwareType,
      softwareTypeVersion: (args["softwareTypeVersion"] as? String) ?? self.softwareTypeVersion,
      webAuth: nil
    )

    ClearentUIManager.shared.prepareTapToPay(paymentInfo: paymentInfo, forceRefreshToken: forceRefresh) { error in
      DispatchQueue.main.async {
        self.logStage("prepare", error == nil ? "completed" : "failed")
        if let error = error {
          result(FlutterError(
            code: "PREPARE_FAILED",
            message: error.localizedDescription,
            details: [
              "type": Self.formatErrorName(error),
              // ClearentError exposes only `type`; localizedDescription is
              // generic NSError bridging noise, but the resultCode helps
              // diagnose gateway-side failures (e.g. missingData = 9).
              "gateway": "\(error.localizedDescription) (resultCode: \(error.type.rawValue))"
            ]
          ))
        } else {
          result(true)
        }
      }
    }
    #else
    result(FlutterError(
      code: "FRAMEWORK_MISSING",
      message: "ClearentIdtechIOSFramework is missing.",
      details: nil
    ))
    #endif
  }

  @MainActor private func handleIsAccountLinked(result: @escaping FlutterResult) {
    #if canImport(ClearentIdtechIOSFramework)
    if #available(iOS 16.0, *) {
      ClearentUIManager.shared.isAccountLinked { linked, _ in
        DispatchQueue.main.async {
          result(linked)
        }
      }
    } else {
      result(false)
    }
    #else
    result(false)
    #endif
  }

  @MainActor private func handleLinkAccount(result: @escaping FlutterResult) {
    guard #available(iOS 16.0, *) else {
      result(FlutterError(
        code: "UNSUPPORTED_OS_VERSION",
        message: "Tap to Pay requires iOS 16.0 or later.",
        details: nil
      ))
      return
    }

    #if canImport(ClearentIdtechIOSFramework)
    logStage("linkAccount", "requested")
    ClearentUIManager.shared.linkAccount { error in
      DispatchQueue.main.async {
        self.logStage("linkAccount", error == nil ? "completed" : "failed")
        if let error = error {
          result(FlutterError(
            code: "LINK_ACCOUNT_FAILED",
            message: error.localizedDescription,
            details: [
              "type": Self.formatErrorName(error),
              "gateway": "\(error.localizedDescription) (resultCode: \(error.type.rawValue))"
            ]
          ))
        } else {
          result(true)
        }
      }
    }
    #else
    result(FlutterError(
      code: "FRAMEWORK_MISSING",
      message: "ClearentIdtechIOSFramework is missing.",
      details: nil
    ))
    #endif
  }

  @MainActor private func handleInvalidateSession(result: @escaping FlutterResult) {
    #if canImport(ClearentIdtechIOSFramework)
    if #available(iOS 16.0, *) {
      ClearentUIManager.shared.invalidateTapToPaySession()
    }
    result(true)
    #else
    result(true)
    #endif
  }

  // MARK: - Transaction Callback & Formatting

  #if canImport(ClearentIdtechIOSFramework)
  private func handleTransactionOutcome(response: TransactionResponse?, error: ClearentError?) {
    var rawJson: [String: Any]? = nil
    if let response = response,
       let data = try? JSONEncoder().encode(response),
       let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
      rawJson = jsonObject
    }

    // Determine status & payload
    let errorType = error?.type
    let status = TapToPayTransactionOutcome.statusString(
      responsePresent: response != nil,
      errorPresent: error != nil,
      errorIsCancelledByUser: errorType == .cancelledByUser,
      errorIsGatewayDeclined: errorType == .gatewayDeclined
    )
    let transactionId = rawJson?["id"] as? String ?? rawJson?["transaction-id"] as? String
    let authCode = rawJson?["authorization-code"] as? String ?? rawJson?["auth-code"] as? String
    var errorMessage = error?.localizedDescription ?? rawJson?["display-message"] as? String
    if response == nil && error == nil {
      // Neither a verdict nor an error: report as unknown instead of
      // misclassifying, and never auto-retry an ambiguous outcome.
      errorMessage = errorMessage ??
        "Unknown transaction outcome reported by the SDK. Reconcile with the gateway before attempting another charge."
    }

    logStage(
      "transactionOutcome",
      "status=\(status) hasTransactionId=\(transactionId != nil) hasAuthCode=\(authCode != nil)"
    )

    var resultMap: [String: Any] = [
      "status": status,
      "errorMessage": errorMessage ?? NSNull(),
      "rawResponse": rawJson ?? [:]
    ]

    if let transactionId = transactionId {
      resultMap["transactionId"] = transactionId
    }
    if let authCode = authCode {
      resultMap["authCode"] = authCode
    }

    // Emit event stream item
    emitEvent([
      "event": "transaction",
      "result": resultMap,
      "response": rawJson ?? NSNull(),
      "error": error.map { Self.formatErrorName($0) } ?? NSNull()
    ])

    // Complete the pending processPayment call exactly once, if one is waiting.
    // Duplicate or late SDK callbacks find nothing pending and are ignored.
    paymentCoordinator.complete(with: resultMap)
  }

  private static func formatErrorName(_ error: ClearentError) -> String {
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
  #endif

  // MARK: - Sanitized Diagnostics

  /// DEBUG-only lifecycle logging. Never pass credentials, card data, session
  /// tokens, or raw gateway payloads into this helper.
  private func logStage(_ stage: String, _ detail: String? = nil) {
    #if DEBUG
    if let detail = detail {
      print("[XplorPayTapToPay] \(stage): \(detail)")
    } else {
      print("[XplorPayTapToPay] \(stage)")
    }
    #endif
  }

  private func emitEvent(_ dict: [String: Any]) {
    DispatchQueue.main.async { [weak self] in
      self?.eventSink?(dict)
    }
  }

  // MARK: - View Controller Hierarchy Helper

  @MainActor private static func findTopViewController() -> UIViewController? {
    var root: UIViewController?
    for scene in UIApplication.shared.connectedScenes {
      if let windowScene = scene as? UIWindowScene {
        root = windowScene.windows.first(where: { $0.isKeyWindow })?.rootViewController
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

// MARK: - ClearentWrapperProtocol Delegation

#if canImport(ClearentIdtechIOSFramework)
private final class InternalTransactionListener: ClearentWrapperProtocol {
  var onTransactionFinished: ((TransactionResponse?, ClearentError?) -> Void)?

  func didFinishTransaction(response: TransactionResponse?, error: ClearentError?) {
    onTransactionFinished?(response, error)
  }

  // Required ClearentWrapperProtocol methods
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
#endif

// MARK: - Bridge State Coordination

/// Coordinates exactly-once completion of an in-flight `processPayment`
/// invocation. All access must occur on the main thread.
///
/// `public` so the example app's Swift test target can exercise it without
/// `@testable` module testability; it is not part of the Flutter-facing Dart
/// contract.
public final class PendingPaymentResultCoordinator {
  private var pending: FlutterResult?

  public init() {}

  /// Whether a payment invocation is currently awaiting a result.
  public var isPending: Bool { pending != nil }

  /// Registers a new invocation. Returns `false` when another invocation is
  /// already in flight; the caller must then respond with `PAYMENT_IN_PROGRESS`.
  @discardableResult
  public func begin(_ result: @escaping FlutterResult) -> Bool {
    guard pending == nil else { return false }
    pending = result
    return true
  }

  /// Completes the pending invocation at most once. Returns `true` when the
  /// completion was delivered, `false` when nothing was pending (for example a
  /// duplicate or late SDK callback).
  @discardableResult
  public func complete(with value: Any?) -> Bool {
    guard let pending = pending else { return false }
    self.pending = nil
    pending(value)
    return true
  }

  /// Drops the pending invocation without completing it (used on engine detach).
  public func reset() {
    pending = nil
  }
}

// MARK: - Transaction Outcome Mapping

/// Pure mapping between the SDK's `didFinishTransaction` inputs and the
/// bridge's status strings. Kept free of SDK types so it can be unit tested.
public enum TapToPayTransactionOutcome {
  /// - Returns: `"approved"`, `"declined"`, `"cancelled"`, `"error"`, or
  ///   `"unknown"`. An outcome with neither a response nor an error is reported
  ///   as `"unknown"` so hosts never mistake it for a decline or an approval.
  public static func statusString(
    responsePresent: Bool,
    errorPresent: Bool,
    errorIsCancelledByUser: Bool,
    errorIsGatewayDeclined: Bool
  ) -> String {
    if errorPresent {
      if errorIsCancelledByUser { return "cancelled" }
      if errorIsGatewayDeclined { return "declined" }
      return "error"
    }
    if responsePresent { return "approved" }
    return "unknown"
  }
}
