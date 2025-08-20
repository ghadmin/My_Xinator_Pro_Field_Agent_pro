import UIKit
import Flutter
import ThreeDS_SDK //Replace with actual module name if different
import Foundation
import os.log

 // Replace with actual module name if different

@main
class AppDelegate: FlutterAppDelegate {

    // Instance of your 3DS manager
    private let threeDSManager = ThreeDSManager()

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        // Setup the 3DS service (required before initialization)
        threeDSManager.setup()

        // Get the Flutter view controller
        let controller: FlutterViewController = window?.rootViewController as! FlutterViewController

        // Create a MethodChannel with a unique name
        let channel = FlutterMethodChannel(
            name: "com.yourcompany.payment/3ds",
            binaryMessenger: controller.binaryMessenger
        )

        // Set up method call handler
        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            self?.handleMethodCall(call: call, result: result)
        }

        // Register any Flutter plugins
        GeneratedPluginRegistrant.register(with: self)

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    // MARK: - Handle Method Calls
    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize3DS":
            initialize3DS(result: result)
        default:
            result(FlutterMethodNotImplemented) // Method not found
        }
    }

    // MARK: - Initialize 3DS SDK
    private func initialize3DS(result: @escaping FlutterResult) {
        threeDSManager.initializeSDK(
            successHandler: {
                // Success: return null (no error)
                result(nil)
            },
            errorHandler: { errorMessage in
                result(
                    FlutterError(
                        code: "3DS_INIT_FAILED",
                        message: "3D Secure SDK initialization failed",
                        details: errorMessage
                    )
                )
            }
        )
    }
}
// Define closure types (must be function types for @escaping)
typealias InitializationCompleteHandler = () -> Void
typealias ErrorHandler = (String) -> Void

class ThreeDSManager {
    private var threeDS2Service: ThreeDS2Service?

    // MARK: - Initialize the 3DS SDK
    func initializeSDK(successHandler: @escaping InitializationCompleteHandler,
                       errorHandler: @escaping ErrorHandler) {
        do {
            os_log(
                "Initializing 3DS SDK...calling SbgoPny5U0Gs401i")
            // Step 1: Create and configure the ConfigurationBuilder
            let configBuilder = ConfigurationBuilder()
            try configBuilder.api(key: "SbgoPny5U0Gs401i") // Replace with real key
            let configParameters = configBuilder.configParameters()

            // Step 2: Create UI Customization
            let uiCustomization = try createUICustomization()

            // Step 3: Initialize the service on a background queue
            DispatchQueue.global(qos: .background).async { [weak self] in
                // Safely unwrap threeDS2Service
                guard let self = self, let service = self.threeDS2Service else {
                    DispatchQueue.main.async {
                        errorHandler("3DS SDK service is not initialized.")
                    }
                    return
                }

                // Perform initialization
                service.initialize(
                    configParameters,
                    locale: nil,
                    uiCustomizationMap: [
                        "DEFAULT": uiCustomization,
                        "DARK": uiCustomization
                    ],
                    success: {
                        DispatchQueue.main.async {
                            successHandler()
                        }
                    },
                    failure: { error in
                        DispatchQueue.main.async {
                            errorHandler(error.localizedDescription)
                        }
                    }
                )
            }
        } catch let error as NSError {
            print("hridoy vai")
            // Handle configuration/build errors
            errorHandler(error.localizedDescription)
        }
    }

    // MARK: - UI Customization (Example)
    private func createUICustomization() throws -> UiCustomization {
        // Replace with actual customization logic based on your SDK
        // Example:
        return UiCustomization()
    }

    // MARK: - Setup (Call this early, e.g., in AppDelegate)
    func setup() {
        self.threeDS2Service = ThreeDS2ServiceSDK() // Initialize the service
        // Optional: Configure logging, theme, etc.
    }
}
