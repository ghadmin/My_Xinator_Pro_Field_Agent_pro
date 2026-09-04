import Foundation
import CoreLocation
import Flutter

/**
 * iOS Location Manager for background location tracking
 * Handles CoreLocation setup and communicates with Flutter
 */
class LocationManager: NSObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    private var flutterEventChannel: FlutterEventChannel?
    private var eventSink: FlutterEventSink?

    // User data
    private var companyId: String?
    private var userId: String?
    private var username: String?
    private var email: String?

    // Location settings
    private let distanceFilter: CLLocationDistance = 100.0 // 100 meters
    private let desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters

    // Channel names
    private static let channelName = "com.myserviceforce.myxinatorprofieldagentpro/location_events"
    private static let methodName = "startLocationTracking"

    override init() {
        super.init()
        setupLocationManager()
    }

    // MARK: - Setup

    private func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self

        // Configure for background tracking
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.distanceFilter = distanceFilter
        locationManager?.desiredAccuracy = desiredAccuracy

        NSLog("📍 LocationManager initialized")
    }

    // MARK: - Public Methods

    func startTracking(messenger: FlutterBinaryMessenger, companyId: String, userId: String, username: String, email: String) {
        NSLog("🚀 Starting location tracking for user: \(username)")

        // Store user data
        self.companyId = companyId
        self.userId = userId
        self.username = username
        self.email = email

        // Setup event channel for location updates
        setupEventChannel(messenger: messenger)

        // Check permission status
        let status = CLLocationManager.authorizationStatus()

        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            startLocationUpdates()
        case .notDetermined:
            locationManager?.requestAlwaysAuthorization()
        case .denied, .restricted:
            NSLog("❌ Location permission denied or restricted")
            sendErrorEvent("Location permission denied")
        @unknown default:
            NSLog("⚠️ Unknown authorization status")
            sendErrorEvent("Unknown authorization status")
        }
    }

    func stopTracking() {
        NSLog("🛑 Stopping location tracking")

        locationManager?.stopUpdatingLocation()
        eventSink?.end()
        eventSink = nil

        // Clear user data
        companyId = nil
        userId = nil
        username = nil
        email = nil

        NSLog("✅ Location tracking stopped")
    }

    // MARK: - Event Channel Setup

    private func setupEventChannel(messenger: FlutterBinaryMessenger) {
        flutterEventChannel = FlutterEventChannel(name: Self.channelName, binaryMessenger: messenger)
        flutterEventChannel?.setStreamHandler(self)
        NSLog("📡 Event channel set up")
    }

    // MARK: - Location Updates

    private func startLocationUpdates() {
        locationManager?.startUpdatingLocation()
        NSLog("✅ Location updates started")
    }

    // MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        NSLog("📍 Location received: \(location.coordinate.latitude), \(location.coordinate.longitude), accuracy: \(location.horizontalAccuracy)m")

        // Send location to Flutter
        sendLocationEvent(location: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("❌ Location manager failed: \(error.localizedDescription)")
        sendErrorEvent(error.localizedDescription)
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            NSLog("✅ Location permission granted")
            startLocationUpdates()
        case .denied, .restricted:
            NSLog("❌ Location permission denied or restricted")
            sendErrorEvent("Location permission denied")
        case .notDetermined:
            NSLog("⏳ Location permission not determined")
        @unknown default:
            NSLog("⚠️ Unknown authorization status")
        }
    }

    // MARK: - Event Sending

    private func sendLocationEvent(location: CLLocation) {
        guard let eventSink = eventSink else {
            NSLog("⚠️ Event sink is nil, cannot send location")
            return
        }

        let locationData: [String: Any] = [
            "company_id": companyId ?? "",
            "user_id": userId ?? "",
            "username": username ?? "",
            "email": email ?? "",
            "latitude": location.coordinate.latitude,
            "longitude": location.coordinate.longitude,
            "accuracy": location.horizontalAccuracy,
            "timestamp": location.timestamp.timeIntervalSince1970 * 1000, // Convert to milliseconds
            "altitude": location.altitude,
            "speed": location.speed,
            "course": location.course
        ]

        eventSink(locationData)
        NSLog("📤 Location event sent to Flutter")
    }

    private func sendErrorEvent(_ errorMessage: String) {
        guard let eventSink = eventSink else {
            NSLog("⚠️ Event sink is nil, cannot send error")
            return
        }

        let errorData: [String: Any] = [
            "error": true,
            "message": errorMessage
        ]

        eventSink(errorData)
        NSLog("📤 Error event sent to Flutter: \(errorMessage)")
    }
}

// MARK: - FlutterStreamHandler

extension LocationManager: FlutterStreamHandler {
    func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        NSLog("📡 Event channel listener attached")
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        NSLog("📡 Event channel listener detached")
        return nil
    }
}