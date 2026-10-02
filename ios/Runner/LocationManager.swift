import Foundation
import CoreLocation
import UserNotifications
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

    // Tracking state
    private var isTrackingRequested = false
    private var lastLocation: CLLocation?
    private var lastSentDate: Date?
    private var heartbeatTimer: Timer?
    private var trackingNotificationTimer: Timer?

    /// True when the user has granted usable location permission
    private var isAuthorized: Bool {
        let status = locationManager?.authorizationStatus ?? CLLocationManager().authorizationStatus
        return status == .authorizedAlways || status == .authorizedWhenInUse
    }

    // Location settings
    private let distanceFilter: CLLocationDistance = 200.0 // send when moved 200m from last delivered fix
    private let desiredAccuracy: CLLocationAccuracy = kCLLocationAccuracyHundredMeters

    // Heartbeat: while stationary (no 200m movement) CoreLocation delivers
    // nothing, so re-send the last known location after this long instead.
    private let heartbeatInterval: TimeInterval = 1800 // 30 minutes
    private let heartbeatCheckInterval: TimeInterval = 60

    // Channel names
    private static let channelName = "com.myserviceforce.myxinatorprofieldagentpro/location_events"
    private static let methodName = "startLocationTracking"

    // Persistent "tracking active" notification. iOS has no un-dismissable
    // notification like Android's foreground service, so the closest
    // equivalent is a silent local notification kept alive in Notification
    // Center while tracking runs (see startTrackingNotification()).
    private static let trackingNotificationId = "location_tracking_active"
    private static let trackingNotificationRefreshInterval: TimeInterval = 30

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
        locationManager?.showsBackgroundLocationIndicator = true // blue pill while tracking runs
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
        isTrackingRequested = true

        // Keep the server updated even when the device is stationary
        startHeartbeatTimer()

        // Keep a "tracking active" notification in Notification Center
        startTrackingNotification()

        // Setup event channel for location updates
        setupEventChannel(messenger: messenger)

        // Check permission status
        let status = locationManager?.authorizationStatus ?? CLLocationManager().authorizationStatus

        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            // Updates start when Flutter attaches to the event channel (onListen),
            // so the first (often cached) fix is never dropped.
            break
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

        isTrackingRequested = false
        stopHeartbeatTimer()
        stopTrackingNotification()
        lastSentDate = nil
        locationManager?.stopUpdatingLocation()
        eventSink?(FlutterEndOfEventStream)
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
        lastLocation = location

        // Send location to Flutter
        sendLocationEvent(location: location)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        NSLog("❌ Location manager failed: \(error.localizedDescription)")
        sendErrorEvent(error.localizedDescription)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            NSLog("✅ Location permission granted")
            // Only start GPS when tracking was actually requested; onListen
            // handles the start if Flutter has not attached to the channel yet
            if isTrackingRequested, eventSink != nil {
                startLocationUpdates()
            }
        case .denied, .restricted:
            NSLog("❌ Location permission denied or restricted")
            if isTrackingRequested {
                sendErrorEvent("Location permission denied")
            }
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
            "heading": location.course // Dart contract reads "heading" (Android parity)
        ]

        eventSink(locationData)
        lastSentDate = Date()
        NSLog("📤 Location event sent to Flutter")

        // Keep the notification-bar indicator truthful: bump "last update"
        // like Android's foreground service does. Same identifier replaces
        // the delivered copy in place — no duplicate entries.
        postTrackingNotification(immediate: true)
    }

    // MARK: - Stationary Heartbeat

    private func startHeartbeatTimer() {
        stopHeartbeatTimer()
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: heartbeatCheckInterval, repeats: true) { [weak self] _ in
            self?.checkHeartbeat()
        }
        NSLog("💓 Heartbeat armed: re-send every \(Int(heartbeatInterval / 60)) min while stationary")
    }

    private func stopHeartbeatTimer() {
        heartbeatTimer?.invalidate()
        heartbeatTimer = nil
    }

    private func checkHeartbeat() {
        guard isTrackingRequested, let last = lastLocation else { return }

        let elapsed = Date().timeIntervalSince(lastSentDate ?? .distantPast)
        guard elapsed >= heartbeatInterval else { return }

        NSLog("💓 Heartbeat: stationary for \(Int(elapsed / 60)) min, re-sending last known location")
        sendLocationEvent(location: last)
    }

    // MARK: - Persistent Tracking Notification

    /// Mirrors Android's ongoing foreground-service notification as closely as
    /// iOS allows. A repeating system trigger is deliberately avoided: it would
    /// keep re-posting forever after a force-quit, when tracking is dead. Instead
    /// a refresh timer re-posts only while this process (and tracking) is alive,
    /// so a notification the user swiped away returns within
    /// [trackingNotificationRefreshInterval] and one stale entry at most
    /// survives a force-quit. Posted with .passive interruption level — silent,
    /// no banner, no screen wake. Never touches UNUserNotificationCenter.delegate
    /// (flutter_local_notifications owns it).
    private func startTrackingNotification() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert]) { [weak self] granted, error in
            if let error = error {
                NSLog("⚠️ Notification authorization request failed: \(error.localizedDescription)")
                return
            }
            guard granted else {
                NSLog("⚠️ Notification permission denied — tracking status notification unavailable")
                return
            }
            DispatchQueue.main.async {
                self?.postTrackingNotification()
                self?.startTrackingNotificationTimer()
            }
        }
    }

    private func startTrackingNotificationTimer() {
        stopTrackingNotificationTimer()
        trackingNotificationTimer = Timer.scheduledTimer(withTimeInterval: Self.trackingNotificationRefreshInterval, repeats: true) { [weak self] _ in
            self?.ensureTrackingNotificationPresent()
        }
    }

    private func stopTrackingNotificationTimer() {
        trackingNotificationTimer?.invalidate()
        trackingNotificationTimer = nil
    }

    /// Re-post only when neither a pending nor a delivered copy exists, so an
    /// already-visible notification is never cleared and re-added (which would
    /// make it blink in Notification Center).
    private func ensureTrackingNotificationPresent() {
        guard isTrackingRequested else { return }
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { pending in
            if pending.contains(where: { $0.identifier == Self.trackingNotificationId }) { return }
            center.getDeliveredNotifications { delivered in
                if delivered.contains(where: { $0.request.identifier == Self.trackingNotificationId }) { return }
                self.postTrackingNotification()
            }
        }
    }

    private func postTrackingNotification(immediate: Bool = false) {
        let content = UNMutableNotificationContent()
        content.title = "Field Agent - Location Tracking"

        // Body mirrors Android's foreground-service notification: once a fix
        // has been delivered, show when it was last sent so the user can see
        // from the notification bar that location is actively being sent.
        if let sent = lastSentDate {
            let time = Self.notificationTimeFormatter.string(from: sent)
            content.body = "Location is being sent — last update \(time)"
        } else {
            content.body = "Your location is being tracked"
        }

<<<<<<< HEAD
        // Shown in place of the body when iOS masks preview content (lock
        // screen with previews hidden), instead of a bare "Notification".
        // Removed from UNNotificationContent in the iOS 27 SDK (Xcode 27 /
        // Swift 6.4), so only compile it against older SDKs.
        #if !compiler(>=6.4)
        content.hiddenPreviewsBodyPlaceholder = "Location is being sent"
        #endif

=======
>>>>>>> refs/remotes/origin/main
        content.sound = nil
        content.interruptionLevel = .passive // silent: NC entry only, no banner/sound/screen wake

        let trigger: UNNotificationTrigger? = immediate
            ? nil // replaces a delivered copy right away when refreshing after a send
            : UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: Self.trackingNotificationId, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                NSLog("⚠️ Failed to schedule tracking notification: \(error.localizedDescription)")
            } else {
                NSLog("🔔 Tracking status notification posted")
            }
        }
    }

    private static let notificationTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter
    }()

    private func stopTrackingNotification() {
        stopTrackingNotificationTimer()
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [Self.trackingNotificationId])
        center.removeDeliveredNotifications(withIdentifiers: [Self.trackingNotificationId])
        NSLog("🔕 Tracking status notification removed")
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

        // Flutter is listening: safe to start GPS now so the first
        // (often cached) fix reaches Dart instead of being dropped
        if isTrackingRequested, isAuthorized {
            startLocationUpdates()

            // Flush the last known fix so stationary devices still report
            if let last = lastLocation {
                NSLog("📤 Flushing last known location to Flutter")
                sendLocationEvent(location: last)
            }
        }
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        eventSink = nil
        NSLog("📡 Event channel listener detached")
        return nil
    }
}