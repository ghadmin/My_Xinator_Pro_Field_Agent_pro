import 'dart:developer';
import 'dart:async';
import 'dart:io' show Platform;
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/location_model.dart';
import 'models/location_tracking_status.dart';
import 'location_sync_manager.dart';
import 'device_info_service.dart';

/// Main service for managing background location tracking
/// Coordinates between native platform services and Flutter application logic
class LocationTrackingService {
  static final LocationTrackingService _instance = LocationTrackingService._internal();
  factory LocationTrackingService() => _instance;

  LocationTrackingService._internal();

  final LocationSyncManager _syncManager = LocationSyncManager();

  // Platform channel for native communication
  static const MethodChannel _platformChannel = MethodChannel('com.myserviceforce.myxinatorprofieldagentpro/location');
  static const EventChannel _locationEventChannel = EventChannel('com.myserviceforce.myxinatorprofieldagentpro/location_events');

  // Stream controllers for location updates
  final StreamController<LocationModel> _locationUpdateController = StreamController<LocationModel>.broadcast();
  final StreamController<LocationTrackingStatus> _statusController = StreamController<LocationTrackingStatus>.broadcast();

  // Polling timer for Android location data
  Timer? _locationPollingTimer;

  // Subscription to the native event channel (iOS pushes updates; Android polls)
  StreamSubscription<dynamic>? _nativeEventSubscription;

  // User data - Simplified for FaProTrack
  String? _currentCompanyId;
  int? _currentResourceId;
  String? _currentDeviceId;

  // State
  LocationTrackingStatus _currentStatus = LocationTrackingStatus.stopped;
  bool _isInitialized = false;
  bool _isTracking = false;

  // Streams
  Stream<LocationModel> get locationUpdates => _locationUpdateController.stream;
  Stream<LocationTrackingStatus> get statusUpdates => _statusController.stream;

  LocationTrackingStatus get currentStatus => _currentStatus;
  bool get isTracking => _isTracking;
  bool get isInitialized => _isInitialized;

  /// Initialize the location tracking service
  Future<void> initialize({
    required String companyId,
    int? resourceId,
  }) async {
    if (_isInitialized) {
      // Already initialized (e.g. user switched without logout) — refresh the
      // ids instead of returning, so we never track under stale/empty data.
      log('⚠️ LocationTrackingService already initialized, refreshing user data');
      _currentCompanyId = companyId;
      _currentResourceId = resourceId ?? _currentResourceId;
      await _syncManager.initialize(_currentResourceId.toString());
      return;
    }

    log('🚀 Initializing LocationTrackingService for company: $companyId');

    // Store user data (simplified for FaProTrack)
    _currentCompanyId = companyId;
    _currentResourceId = resourceId ?? 00; // Use provided or default to 55

    // Initialize sync manager with resourceId instead of userId
    await _syncManager.initialize(_currentResourceId.toString());

    // Check if tracking was previously enabled (after app restart)
    final prefs = await SharedPreferences.getInstance();
    final wasTrackingEnabled = prefs.getBool('location_tracking_enabled') ?? false;

    if (wasTrackingEnabled) {
      log('📱 Tracking was enabled before, restoring state');

      // Mark as initialized BEFORE calling startTracking
      _isInitialized = true;
      log('✅ LocationTrackingService initialized (auto-restore mode)');

      await _updateStatus(LocationTrackingStatus.starting);
      await startTracking(autoRestore: true);
    } else {
      log('📱 No previous tracking state found');
      await _updateStatus(LocationTrackingStatus.stopped);

      // Mark as initialized for non-tracking cases
      _isInitialized = true;
      log('✅ LocationTrackingService initialized (standby mode)');
    }
  }

  /// Start location tracking
  Future<void> startTracking({bool autoRestore = false}) async {
    // 🔧 FIX: Allow auto-restore to bypass initialization check
    if (!_isInitialized && !autoRestore) {
      throw StateError('LocationTrackingService must be initialized first');
    }

    if (_isTracking) {
      log('⚠️ [SERVICE] Location tracking is already active');
      return;
    }

    log('🚀 [SERVICE] Starting location tracking${autoRestore ? ' (auto-restore)' : ''}');

    try {
      await _updateStatus(LocationTrackingStatus.starting);

      // NOTE: Permissions and location service checks are done by the controller
      // We skip redundant checks here to avoid double dialogs and errors

      log('🚀 [SERVICE] Starting native background service...');
      try {
        // Start native background service
        await _startNativeBackgroundService();
        log('✅ [SERVICE] Native background service started');
        _listenToNativeLocationEvents();
      } catch (e) {
        log('❌ [SERVICE] Failed to start native background service: $e');
        await _updateStatus(LocationTrackingStatus.stopped);
        throw StateError('Failed to start native location service: $e');
      }

      log('🚀 [SERVICE] Starting sync manager...');
      try {
        // Start sync manager
        await _syncManager.start();
        log('✅ [SERVICE] Sync manager started');
      } catch (e) {
        log('❌ [SERVICE] Failed to start sync manager: $e');
        await _updateStatus(LocationTrackingStatus.stopped);
        throw StateError('Failed to start sync manager: $e');
      }

      // Start location polling for Android
      if (Platform.isAndroid) {
        log('🔄 [SERVICE] Starting location polling for Android');
        _startLocationPolling();
        log('✅ [SERVICE] Location polling started');
      }

      // Save tracking state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('location_tracking_enabled', true);
      log('✅ [SERVICE] Tracking state saved to preferences');

      _isTracking = true;
      await _updateStatus(LocationTrackingStatus.tracking);

      log('✅ [SERVICE] Location tracking started successfully');
      log('🔍 [SERVICE] Final state - IsTracking: $_isTracking, Status: $_currentStatus');

      // Show notification only if not auto-restore
      if (!autoRestore) {
        // TODO: Show tracking started notification
      }

    } catch (e, stackTrace) {
      log('❌ [SERVICE] Error starting location tracking: $e');
      log('❌ [SERVICE] Stack trace: $stackTrace');
      _isTracking = false;
      await _updateStatus(LocationTrackingStatus.stopped);
      rethrow;
    }
  }

  /// Stop location tracking
  Future<void> stopTracking() async {
    if (!_isTracking) {
      log('⚠️ Location tracking is not active');
      return;
    }

    log('🛑 Stopping location tracking');

    try {
      // Stop location polling if active
      _stopLocationPolling();

      // Detach from the native event channel
      _nativeEventSubscription?.cancel();
      _nativeEventSubscription = null;

      // Stop sync manager
      await _syncManager.stop();

      // Stop native background service
      await _stopNativeBackgroundService();

      // Clear tracking state
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('location_tracking_enabled', false);

      _isTracking = false;
      await _updateStatus(LocationTrackingStatus.stopped);

      log('✅ Location tracking stopped successfully');

      // TODO: Show tracking stopped notification

    } catch (e, stackTrace) {
      log('❌ Error stopping location tracking: $e');
      log('Stack trace: $stackTrace');
    }
  }

  /// Listen to native location events pushed over the event channel.
  /// iOS (LocationManager) sends maps; Android (MainActivity) sends JSON strings.
  void _listenToNativeLocationEvents() {
    _nativeEventSubscription?.cancel();
    _nativeEventSubscription = _locationEventChannel.receiveBroadcastStream().listen(
      (event) {
        try {
          if (event == null) return;

          Map<String, dynamic> data;
          if (event is String) {
            data = Map<String, dynamic>.from(json.decode(event));
          } else if (event is Map) {
            data = Map<String, dynamic>.from(event);
          } else {
            log('⚠️ Unexpected event channel payload type: ${event.runtimeType}');
            return;
          }

          handleLocationUpdate(data);
        } catch (e) {
          log('❌ Error handling native location event: $e');
        }
      },
      onError: (e) {
        log('❌ Location event channel error: $e');
      },
    );
    log('📡 Listening to native location event channel');
  }

  /// Handle incoming location update from native service
  Future<void> handleLocationUpdate(Map<String, dynamic> locationData) async {
    try {
      log('📍 Received location update from native service');

      // Create location model with GPS metadata
      final location = LocationModel(
        companyId: _currentCompanyId ?? '',
        resourceId: _currentResourceId ?? 55, // Use current resourceId or default to 55
        deviceId: _currentDeviceId ?? '', // Use device ID if available
        latitude: (locationData['latitude'] as num?)?.toDouble() ?? 0.0,
        longitude: (locationData['longitude'] as num?)?.toDouble() ?? 0.0,
        recordedAt: locationData['timestamp'] is DateTime
            ? (locationData['timestamp'] as DateTime).toUtc().toIso8601String()
            : locationData['timestamp'] is num
                ? DateTime.fromMillisecondsSinceEpoch((locationData['timestamp'] as num).toInt())
                    .toUtc()
                    .toIso8601String()
                : DateTime.now().toUtc().toIso8601String(),
        accuracy: (locationData['accuracy'] as num?)?.toDouble() ?? 0.0,
        speed: (locationData['speed'] as num?)?.toDouble() ?? 0.0,
        heading: (locationData['heading'] as num?)?.toDouble() ?? 0.0,
        altitude: (locationData['altitude'] as num?)?.toDouble() ?? 0.0,
        batteryLevel: await DeviceInfoService.getBatteryLevel(),
        networkType: 'lte', // Static for now
      );

      // Validate location
      if (!location.isValid()) {
        log('⚠️ Invalid location data, skipping');
        return;
      }

      // Add to stream for UI listeners
      _locationUpdateController.add(location);

      // Sync to server
      await _syncManager.syncLocation(location);

    } catch (e, stackTrace) {
      log('❌ Error handling location update: $e');
      log('Stack trace: $stackTrace');
    }
  }

  /// Start native background service
  Future<void> _startNativeBackgroundService() async {
    log('🚀 Starting native Android location service...');

    try {
      // Start the native LocationForegroundService
      await _platformChannel.invokeMethod('startLocationService', {
        'company_id': _currentCompanyId,
        'user_id': _currentResourceId.toString(), // resourceId as string
        'username': 'Technician $_currentResourceId',
        'email': '', // Not used in FaProTrack
      });

      log('✅ Native location service started successfully');
    } catch (e) {
      log('❌ Failed to start native location service: $e');
      rethrow;
    }
  }

  /// Stop native background service
  Future<void> _stopNativeBackgroundService() async {
    log('🛑 Stopping native Android location service...');

    try {
      // Stop the native LocationForegroundService
      await _platformChannel.invokeMethod('stopLocationService');

      log('✅ Native location service stopped successfully');
    } catch (e) {
      log('❌ Failed to stop native location service: $e');
    }
  }

  /// Update tracking status
  Future<void> _updateStatus(LocationTrackingStatus newStatus) async {
    if (_currentStatus != newStatus) {
      _currentStatus = newStatus;
      _statusController.add(newStatus);
      log('📊 Status updated: ${newStatus.displayName}');
    }
  }

  /// Get current sync statistics
  Future<LocationSyncStats> getSyncStats() async {
    return await _syncManager.getStats();
  }

  /// Clear all user data (called on logout)
  Future<void> clearUserData() async {
    log('🗑️ Clearing user data');

    // Stop tracking if active
    if (_isTracking) {
      await stopTracking();
    }

    // Clear sync manager state
    await _syncManager.clearUserState();

    // Clear location data cached on the native side (Android SharedPreferences)
    try {
      await _platformChannel.invokeMethod('clearLocationData');
    } catch (e) {
      log('⚠️ Failed to clear native location data: $e');
    }

    // Clear user data (simplified for FaProTrack)
    _currentCompanyId = null;
    _currentResourceId = null;
    _currentDeviceId = null;

    // Drop the initialized flag so the next login re-initializes with fresh
    // company/resource ids — this is an app-lifetime singleton, so leaving it
    // true would make initialize() early-return and tracking would start with
    // a null company_id.
    _isInitialized = false;

    // Clear preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('location_tracking_enabled');

    log('✅ User data cleared');
  }

  /// Update user information (for resource switching)
  Future<void> updateUserInformation({
    required String companyId,
    int? resourceId,
  }) async {
    log('🔄 Updating tracking information for company: $companyId, resourceId: $resourceId');

    // Stop current tracking
    if (_isTracking) {
      await stopTracking();
    }

    // Clear previous user state
    await _syncManager.clearUserState();

    // Update data
    _currentCompanyId = companyId;
    _currentResourceId = resourceId ?? 55;

    log('✅ Tracking information updated');
  }

  /// Start location polling for Android
  void _startLocationPolling() {
    log('🔄 Starting location polling for Android');

    _locationPollingTimer = Timer.periodic(Duration(seconds: 10), (timer) async {
      if (!_isTracking) {
        log('⚠️ Polling: Tracking not active, canceling timer');
        timer.cancel();
        return;
      }

      try {
        log('🔍 [POLL] Attempting to get location data from native service...');
        // Poll for location data from native Android service
        final result = await _platformChannel.invokeMethod('getLastLocationData');
        log('🔍 [POLL] Platform channel result: ${result != null ? "DATA RECEIVED" : "NULL"}');

        if (result != null && result is String && result.isNotEmpty) {
          log('📦 [POLL] Got location data: ${result.length} characters');
          // Process the location data
          await _processNativeLocationData(result);
        } else {
          log('⚠️ [POLL] No location data available (result: $result)');
        }
      } catch (e) {
        log('❌ [POLL] Error polling location data: $e');
      }
    });
  }

  /// Stop location polling
  void _stopLocationPolling() {
    log('🛑 Stopping location polling');
    _locationPollingTimer?.cancel();
    _locationPollingTimer = null;
  }

  /// Process location data from native Android service
  Future<void> _processNativeLocationData(String locationDataJson) async {
    try {
      // Decode the base64 encoded location data
      final decoded = base64.decode(locationDataJson);
      final jsonString = utf8.decode(decoded);

      // Parse JSON and create location model
      final locationData = Map<String, dynamic>.from(json.decode(jsonString));

      final location = LocationModel(
        companyId: locationData['company_id'] as String? ?? _currentCompanyId ?? '',
        resourceId: _currentResourceId ?? 55, // Use current resourceId
        deviceId: _currentDeviceId ?? '',
        latitude: (locationData['latitude'] as num).toDouble(),
        longitude: (locationData['longitude'] as num).toDouble(),
        recordedAt: locationData['timestamp'] is String
            ? locationData['timestamp']
            : DateTime.fromMillisecondsSinceEpoch(locationData['timestamp'] as int).toUtc().toIso8601String(),
        accuracy: (locationData['accuracy'] as num?)?.toDouble() ?? 0.0,
        speed: (locationData['speed'] as num?)?.toDouble() ?? 0.0,
        heading: (locationData['heading'] as num?)?.toDouble() ?? 0.0,
        altitude: (locationData['altitude'] as num?)?.toDouble() ?? 0.0,
        batteryLevel: await DeviceInfoService.getBatteryLevel(),
        networkType: 'lte', // Static for now
      );

      // Validate and process location
      if (location.isValid()) {
        log('📍 Valid location from native service: ${location.latitude}, ${location.longitude}');

        // Add to stream for UI listeners
        _locationUpdateController.add(location);

        // Sync to server
        await _syncManager.syncLocation(location);

        // Clear the processed location data
        await _platformChannel.invokeMethod('clearLocationData');
      } else {
        log('⚠️ Invalid location from native service, skipping');
      }

    } catch (e, stackTrace) {
      log('❌ Error processing native location data: $e');
      log('Stack trace: $stackTrace');
    }
  }

  /// Dispose resources
  Future<void> dispose() async {
    log('🧹 Disposing LocationTrackingService');

    _stopLocationPolling();

    await _syncManager.dispose();

    _locationUpdateController.close();
    _statusController.close();

    _isInitialized = false;
  }
}