import CoreLocation
import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var locationManager: LocationManager?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    setupLocationChannels(engineBridge.pluginRegistry)
  }

  /// Wires the location tracking method channel (same contract as Android's MainActivity)
  private func setupLocationChannels(_ registry: FlutterPluginRegistry) {
    guard let registrar = registry.registrar(forPlugin: "LocationTrackingPlugin") else {
      NSLog("⚠️ Failed to create plugin registrar for location tracking")
      return
    }
    let messenger = registrar.messenger()

    let channel = FlutterMethodChannel(
      name: "com.myserviceforce.myxinatorprofieldagentpro/location",
      binaryMessenger: messenger
    )
    channel.setMethodCallHandler { [weak self] call, result in
      switch call.method {
      case "startLocationService":
        guard let args = call.arguments as? [String: Any],
              let companyId = args["company_id"] as? String,
              let userId = args["user_id"] as? String else {
          result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required arguments", details: nil))
          return
        }
        NSLog("🚀 iOS startLocationService for user: \(userId)")
        let manager = self?.locationManager ?? LocationManager()
        self?.locationManager = manager
        manager.startTracking(
          messenger: messenger,
          companyId: companyId,
          userId: userId,
          username: args["username"] as? String ?? "",
          email: args["email"] as? String ?? ""
        )
        result(nil)

      case "stopLocationService":
        self?.locationManager?.stopTracking()
        result(nil)

      case "checkPermissions":
        let status = CLLocationManager().authorizationStatus
        result(status == .authorizedAlways || status == .authorizedWhenInUse)

      case "getLastLocationData", "clearLocationData":
        // Android-only polling API; iOS pushes via the event channel instead
        result(nil)

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
