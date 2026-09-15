import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../config/theme/dark_theme_colors.dart';
import '../../../../config/theme/light_theme_colors.dart';
import '../../../components/global-widgets/my_status_dialog.dart';
import '../../../service/location/models/location_model.dart';
import '../../../service/location/models/location_tracking_status.dart';
import '../../../service/location/location_tracking_service.dart';
import '../../../data/local/my_shared_pref.dart';
import '../../appointment/controllers/appointment_controller.dart';

/// GetX controller for managing location tracking state and UI
/// Provides reactive state management for location tracking features
class LocationTrackingController extends GetxController
    with WidgetsBindingObserver {
  // Services
  final LocationTrackingService _locationService = LocationTrackingService();

  // Reactive state
  final Rx<LocationTrackingStatus> trackingStatus =
      LocationTrackingStatus.stopped.obs;
  final RxBool isTrackingEnabled = false.obs;
  final RxBool hasPermissions = false.obs;
  final RxBool isInternetConnected = true.obs;
  final Rx<LocationModel?> currentLocation = Rx<LocationModel?>(null);
  final Rx<DateTime?> lastLocationTime = Rx<DateTime?>(null);
  final Rx<DateTime?> lastSuccessfulSync = Rx<DateTime?>(null);
  final RxInt pendingLocationCount = 0.obs;
  final RxInt consecutiveFailures = 0.obs;
  final RxString errorMessage = ''.obs;

  // Stream subscriptions
  StreamSubscription<LocationModel>? _locationSubscription;
  StreamSubscription<LocationTrackingStatus>? _statusSubscription;

  /// Set when the user is sent to OS settings in the middle of a start
  /// attempt, so tracking auto-starts when they come back — the user should
  /// only ever toggle once.
  bool _pendingSettingsReturn = false;

  // User data (FIXED: Updated to match service requirements)
  String? _currentCompanyId;
  int? _currentResourceId;
  String? _currentUsername;
  String? _currentEmail;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _initializeFromPreferences();
  }

  @override
  void onReady() {
    super.onReady();
    _checkPermissions();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _locationSubscription?.cancel();
    _statusSubscription?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && _pendingSettingsReturn) {
      _pendingSettingsReturn = false;
      _resumeTrackingStartAfterSettings();
    }
  }

  /// The user was sent to OS settings in the middle of starting tracking.
  /// If they granted what was missing there, finish starting tracking now so
  /// they don't have to toggle a second time.
  Future<void> _resumeTrackingStartAfterSettings() async {
    final permission = await Permission.location.status;
    final isGpsOn = await Geolocator.isLocationServiceEnabled();

    if (!permission.isGranted || !isGpsOn) {
      log('ℹ️ Returned from settings without the required permissions');
      errorMessage.value =
          'Location permission is still off. Toggle tracking to try again.';
      return;
    }

    log('✅ Permissions granted in settings, resuming tracking start...');
    await startTracking();
  }

  /// Initialize location tracking after user login
  Future<void> initializeTracking() async {
    try {
      log('🚀 Initializing location tracking...');

      // FIXED: Get correct user data from preferences
      final companyId = MySharedPref.getCompanyID();
      final username = MySharedPref.getUserName();
      final email = MySharedPref.getEmail();

      // Resource id: prefer the loaded appointment list, fall back to the
      // stored resource_id so tracking can start before the API returns
      int? resourceId;
      if (Get.isRegistered<AppointmentController>()) {
        final apptC = Get.find<AppointmentController>();
        if (apptC.appointments.isNotEmpty) {
          resourceId = apptC.appointments.first.resource?.id;
        }
      }
      resourceId ??= MySharedPref.getResourceID();

      if (companyId == null || companyId.isEmpty || resourceId == null) {
        log('❌ Company or resource information not available');
        errorMessage.value = 'Company or resource information not available';
        return;
      }

      // FIXED: Store user data correctly
      _currentCompanyId = companyId;
      _currentResourceId = resourceId;
      _currentUsername = username;
      _currentEmail = email;

      // FIXED: Initialize location service with correct parameters
      log('🔧 Initializing location service...');
      await _locationService.initialize(
        companyId: companyId,
        resourceId: _currentResourceId,
      );

      // Subscribe to streams
      log('📡 Setting up stream subscriptions...');
      _subscribeToStreams();

      // Check if tracking was previously enabled
      if (_locationService.isTracking) {
        log('✅ Tracking was previously enabled, restoring state');
        isTrackingEnabled.value = true;
        trackingStatus.value = _locationService.currentStatus;
      } else {
        log('ℹ️ Tracking was not previously enabled');
      }

      log('✅ Location tracking initialization complete');

      // Debug: Verify service state after initialization
      log('🔍 [DEBUG] Service state check:');
      log('🔍 [DEBUG] - Is Initialized: ${_locationService.isInitialized}');
      log('🔍 [DEBUG] - Is Tracking: ${_locationService.isTracking}');
      log('🔍 [DEBUG] - Current Status: ${_locationService.currentStatus}');
    } catch (e, stackTrace) {
      log('❌ Failed to initialize tracking: $e');
      errorMessage.value = 'Failed to initialize tracking: $e';
      print('Error initializing tracking: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Start location tracking
  Future<void> startTracking() async {
    try {
      log('🚀 [CONTROLLER] Starting location tracking...');
      errorMessage.value = '';
      isTrackingEnabled.value = false; // Reset to false initially

      // Step 1: Check if service is initialized
      if (!_locationService.isInitialized) {
        log('⚠️ [CONTROLLER] Service not initialized, initializing first...');
        await initializeTracking();
        if (!_locationService.isInitialized) {
          log('❌ [CONTROLLER] Initialization failed (missing company/resource info)');
          errorMessage.value =
              'Unable to initialize tracking: company/resource info missing';
          return;
        }
        log('✅ [CONTROLLER] Service initialized');
      }

      // Step 2: Check and request permissions
      log('🔐 [CONTROLLER] Checking permissions...');
      final hasPermissions = await _checkPermissionsWithDialog();
      if (!hasPermissions) {
        log('❌ [CONTROLLER] Permissions not granted');
        errorMessage.value =
            'Location permissions required. Please enable them in settings.';
        return;
      }
      log('✅ [CONTROLLER] Permissions granted');

      // Step 3: Check if location service is enabled
      log('📱 [CONTROLLER] Checking location service...');
      final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationEnabled) {
        log('❌ [CONTROLLER] Location service disabled');
        errorMessage.value =
            'Please enable your device location service (GPS).';
        return;
      }
      log('✅ [CONTROLLER] Location service enabled');

      // Step 4: Start the location tracking service
      log('🚀 [CONTROLLER] Starting location tracking service...');
      await _locationService.startTracking();

      // Step 5: Verify service actually started successfully
      await Future.delayed(Duration(seconds: 2)); // Give service time to start
      log('🔍 [CONTROLLER] Verifying service started...');

      if (_locationService.isTracking &&
          _locationService.currentStatus == LocationTrackingStatus.tracking) {
        isTrackingEnabled.value = true;
        await MySharedPref.setTrackingEnabled(true);
        log('✅ [CONTROLLER] Location tracking started successfully');
        log(
          '🔍 [CONTROLLER] Final state - Tracking: ${isTrackingEnabled.value}, Status: ${_locationService.currentStatus}',
        );
      } else {
        log('❌ [CONTROLLER] Service failed to start properly');
        log(
          '🔍 [CONTROLLER] Current state - IsTracking: ${_locationService.isTracking}, Status: ${_locationService.currentStatus}',
        );
        errorMessage.value =
            'Failed to start tracking. Service status: ${_locationService.currentStatus}';
      }
    } catch (e, stackTrace) {
      log('❌ [CONTROLLER] Failed to start tracking: $e');
      errorMessage.value = 'Failed to start tracking: $e';
      isTrackingEnabled.value = false; // Ensure UI shows correct state
      print('Error starting tracking: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Check permissions with automatic requests and user-friendly dialogs
  Future<bool> _checkPermissionsWithDialog() async {
    try {
      log('🔐 Starting permission request process...');

      // Step 1: Check current permission status
      final locationPermission = await Permission.location.status;
      final isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();

      log('📍 Current location permission: $locationPermission');
      log('📱 Location service enabled: $isLocationServiceEnabled');

      // Step 2: Show permission dialog if needed
      if (locationPermission != PermissionStatus.granted ||
          !isLocationServiceEnabled) {
        log('🎯 Showing permission request dialog to user...');
        final shouldProceed = await _showPermissionRequestDialog(
          locationPermission == PermissionStatus.granted,
          isLocationServiceEnabled,
        );

        if (!shouldProceed) {
          log('❌ User cancelled permission request');
          errorMessage.value = 'Location permissions are required for tracking';
          return false;
        }

        log(
          '✅ User approved permission request, requesting permissions now...',
        );
      } else {
        log(
          '✅ Permissions already granted, requesting additional permissions...',
        );
      }

      // Step 3: Request location permission
      final locationPermissionResult = await Permission.location.request();
      log(
        '📍 Location permission result: ${locationPermissionResult.isGranted ? "GRANTED" : "DENIED"}',
      );

      if (!locationPermissionResult.isGranted) {
        log('❌ Location permission denied');
        await _showPermissionDeniedDialog('Location');
        errorMessage.value =
            'Location permission denied. Please enable in app settings.';
        return false;
      }

      // Step 4: Request background location (Android and iOS — iOS needs
      // "Allow All the Time" for tracking to continue when the app is
      // backgrounded, even with the location background mode declared)
      if (GetPlatform.isAndroid || GetPlatform.isIOS) {
        log('📱 Requesting background location permission...');
        final backgroundPermission = await Permission.locationAlways.request();
        log(
          '📍 Background location permission result: ${backgroundPermission.isGranted ? "GRANTED" : "DENIED"}',
        );

        if (!backgroundPermission.isGranted) {
          // Background location not granted, but foreground tracking might still work
          log(
            '⚠️ Background location permission not granted, foreground tracking may work',
          );
          await _showBackgroundLocationWarning();
        }
      }

      // Step 5: Request notification permission for Android 13+
      if (GetPlatform.isAndroid) {
        log('📱 Android: Requesting notification permission...');
        final notificationPermission = await Permission.notification.request();
        log(
          '📍 Notification permission result: ${notificationPermission.isGranted ? "GRANTED" : "DENIED"}',
        );

        if (!notificationPermission.isGranted) {
          log('⚠️ Notification permission not granted');
        }
      }

      // Step 6: Check location service again
      final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationEnabled) {
        log('❌ Location service still disabled');
        await _showLocationServiceDisabledDialog();
        errorMessage.value =
            'Please enable your device location service (GPS).';
        return false;
      }

      log('✅ All permissions granted successfully');
      return true;
    } catch (e) {
      log('❌ Error checking permissions: $e');
      print('Error checking permissions: $e');
      return false;
    }
  }

  /// Show permission request dialog to user
  Future<bool> _showPermissionRequestDialog(
    bool hasLocationPermission,
    bool isLocationServiceEnabled,
  ) async {
    return await MyStatusDialog.show(
      barrierDismissible: false,
      severity: DialogSeverity.info,
      icon: Icons.location_on_outlined,
      title: 'Location Permission Required',
      message: 'Location tracking needs the following permissions to work properly:',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildPermissionStatusItem(
            'Location Access',
            hasLocationPermission,
            'Required to get your GPS location',
          ),
          _buildPermissionStatusItem(
            'GPS Service',
            isLocationServiceEnabled,
            'Required to access device location',
          ),
          if (GetPlatform.isAndroid)
            _buildPermissionStatusItem(
              'Background Location',
              false,
              'Required to track when app is closed',
            ),
          const SizedBox(height: 12),
          _buildPermissionsInfoBox(),
        ],
      ),
      primaryLabel: 'Continue',
      secondaryLabel: 'Cancel',
    );
  }

  /// Build a themed permission status row shown in the permission dialog.
  Widget _buildPermissionStatusItem(
    String title,
    bool granted,
    String description,
  ) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surface = isDark ? DarkThemeColors.surfaceColor : LightThemeColors.surfaceColor;
        final textPrimary = isDark ? DarkThemeColors.textPrimary : LightThemeColors.textPrimary;
        final textSecondary = isDark ? DarkThemeColors.textSecondary : LightThemeColors.textSecondary;
        final statusColor = granted
            ? (isDark ? DarkThemeColors.successColor : LightThemeColors.successColor)
            : (isDark ? DarkThemeColors.warningColor : LightThemeColors.warningColor);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                granted ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
                color: statusColor,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build the "Why do we need this?" info box for the permission dialog.
  Widget _buildPermissionsInfoBox() {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surface = isDark ? DarkThemeColors.surfaceColor : LightThemeColors.surfaceColor;
        final accent = isDark ? DarkThemeColors.infoColor : LightThemeColors.infoColor;
        final textSecondary = isDark ? DarkThemeColors.textSecondary : LightThemeColors.textSecondary;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, size: 16, color: accent),
                  const SizedBox(width: 6),
                  Text(
                    'Why do we need this?',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• Track your location for field management\n'
                '• Provide accurate location data to your team\n'
                '• Continue tracking even when the app is closed',
                style: TextStyle(fontSize: 12, height: 1.5, color: textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Show permission denied dialog
  Future<void> _showPermissionDeniedDialog(String permissionType) async {
    // No public API exists to jump straight to an app's location permission
    // page, so open the app settings screen and tell the user the exact taps
    // from there.
    final String whereToTap = GetPlatform.isIOS
        ? 'Then select "Location" and allow access.'
        : 'Then tap "Permissions" and allow location access there.';
    await MyStatusDialog.show(
      severity: DialogSeverity.error,
      title: '$permissionType Permission Required',
      message: 'Location tracking requires the $permissionType permission. '
          'Please enable it in your device settings to continue. $whereToTap',
      primaryLabel: 'Open App Settings',
      onPrimary: () {
        _pendingSettingsReturn = true;
        openAppSettings();
      },
      secondaryLabel: 'Cancel',
      barrierDismissible: false,
    );
  }

  /// Show background location warning dialog
  Future<void> _showBackgroundLocationWarning() async {
    final String howToEnable = GetPlatform.isIOS
        ? 'Set "Location" to "Always" in App Settings.'
        : 'In App Settings, tap "Permissions" → "Location" → "Allow all the time".';
    await MyStatusDialog.show(
      severity: DialogSeverity.warning,
      title: 'Background Location Not Granted',
      message: 'Background location permission was not granted. The app will '
          'only track your location while it is open. For continuous tracking, '
          '$howToEnable',
      primaryLabel: 'Open App Settings',
      onPrimary: openAppSettings,
      secondaryLabel: 'I Understand',
      barrierDismissible: false,
    );
  }

  /// Show location service disabled dialog
  Future<void> _showLocationServiceDisabledDialog() async {
    await MyStatusDialog.show(
      severity: DialogSeverity.error,
      icon: Icons.location_disabled_rounded,
      title: 'Location Service Disabled',
      message: 'Please enable your device location service (GPS) to use location tracking.',
      primaryLabel: 'Enable Location',
      onPrimary: () {
        _pendingSettingsReturn = true;
        Geolocator.openLocationSettings();
      },
      secondaryLabel: 'Cancel',
      barrierDismissible: false,
    );
  }

  /// Stop location tracking
  Future<void> stopTracking() async {
    try {
      log('🛑 Stopping location tracking...');
      errorMessage.value = '';

      await _locationService.stopTracking();
      isTrackingEnabled.value = false;
      await MySharedPref.setTrackingEnabled(false);

      log('✅ Location tracking stopped successfully');

      // Note: The tracking state is cleared by the location service
    } catch (e, stackTrace) {
      log('❌ Failed to stop tracking: $e');
      errorMessage.value = 'Failed to stop tracking: $e';
      print('Error stopping tracking: $e');
      print('Stack trace: $stackTrace');
    }
  }

  /// Toggle location tracking
  Future<void> toggleTracking() async {
    log('🔄 Toggle tracking requested (current: ${isTrackingEnabled.value})');

    if (isTrackingEnabled.value) {
      await stopTracking();
    } else {
      await startTracking();
    }
  }

  /// Manually retry starting tracking if auto-start failed
  Future<void> retryStartTracking() async {
    try {
      log('🔄 Manual retry of location tracking start...');
      errorMessage.value = '';

      // startTracking() self-initializes from preferences if needed
      await startTracking();
    } catch (e, stackTrace) {
      log('❌ Manual retry failed: $e');
      errorMessage.value = 'Failed to start tracking: $e';
      print('Stack trace: $stackTrace');
    }
  }

  /// Request location permissions
  Future<bool> requestPermissions() async {
    try {
      // Check current permission status
      final locationPermission = await Permission.location.status;
      final isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();

      final hasPerms = locationPermission.isGranted && isLocationServiceEnabled;
      hasPermissions.value = hasPerms;

      if (!hasPerms) {
        // Permissions will be requested when tracking starts
        errorMessage.value =
            'Permissions will be requested when you start tracking';
      }

      return hasPerms;
    } catch (e) {
      errorMessage.value = 'Failed to check permissions: $e';
      return false;
    }
  }

  /// Refresh status and statistics
  Future<void> refreshStatus() async {
    try {
      // Update status
      trackingStatus.value = _locationService.currentStatus;
      isTrackingEnabled.value = _locationService.isTracking;

      // Get sync statistics
      final stats = await _locationService.getSyncStats();
      lastSuccessfulSync.value = stats.lastSuccessfulSync;
      pendingLocationCount.value = stats.pendingCount;
      consecutiveFailures.value = stats.consecutiveFailures;

      // Check permissions
      await _checkPermissions();
    } catch (e) {
      errorMessage.value = 'Failed to refresh status: $e';
    }
  }

  /// Get detailed statistics
  Future<LocationTrackingStats> getDetailedStats() async {
    final stats = await _locationService.getSyncStats();

    return LocationTrackingStats(
      isTracking: isTrackingEnabled.value,
      status: trackingStatus.value,
      currentLocation: currentLocation.value,
      lastLocationTime: lastLocationTime.value,
      lastSuccessfulSync: lastSuccessfulSync.value,
      pendingCount: stats.pendingCount,
      consecutiveFailures: stats.consecutiveFailures,
      isProcessing: stats.isProcessing,
      timeSinceLastSync: stats.timeSinceLastSync,
      isStale: stats.isStale,
    );
  }

  /// Clear user data (called on logout)
  Future<void> clearUserData() async {
    await _locationService.clearUserData();

    // Reset state
    trackingStatus.value = LocationTrackingStatus.stopped;
    isTrackingEnabled.value = false;
    currentLocation.value = null;
    lastLocationTime.value = null;
    lastSuccessfulSync.value = null;
    pendingLocationCount.value = 0;
    consecutiveFailures.value = 0;
    errorMessage.value = '';

    // FIXED: Clear all user data fields including resourceId
    _currentCompanyId = null;
    _currentResourceId = null;
    _currentUsername = null;
    _currentEmail = null;
  }

  /// Update user information (for user switching)
  Future<void> updateUserInformation() async {
    // FIXED: Get correct data from preferences
    final companyId = MySharedPref.getCompanyID();
    final username = MySharedPref.getUserName();
    final email = MySharedPref.getEmail();

    final apptC = Get.find<AppointmentController>();

    // FIXED: Check for companyId and resourceId (not userId)
    if (companyId != null && apptC.appointments.isNotEmpty) {
      await _locationService.updateUserInformation(
        companyId: companyId,
        resourceId: apptC.appointments.first.resource!.id,
      );

      // Update stored user data
      _currentCompanyId = companyId;
      _currentResourceId = apptC.appointments.first.resource!.id;
      _currentUsername = username ?? '';
      _currentEmail = email ?? '';
    }
  }

  // Private methods

  void _initializeFromPreferences() async {
    await MySharedPref.init();
    // The location service will handle loading the previous tracking state
  }

  Future<void> _checkPermissions() async {
    // Check current permission status directly
    final locationPermission = await Permission.location.status;
    final isLocationServiceEnabled =
        await Geolocator.isLocationServiceEnabled();

    final hasPerms = locationPermission.isGranted && isLocationServiceEnabled;
    hasPermissions.value = hasPerms;
  }

  void _subscribeToStreams() {
    log('🔄 Subscribing to location tracking streams...');

    // Subscribe to location updates
    _locationSubscription = _locationService.locationUpdates.listen((location) {
      log(
        '📍 Location update received: ${location.latitude}, ${location.longitude}, accuracy: ${location.accuracy}m',
      );
      currentLocation.value = location;
      lastLocationTime.value = location.recordedAt.isNotEmpty
          ? DateTime.parse(location.recordedAt).toLocal()
          : DateTime.now();
    });

    log('✅ Subscribed to location updates stream');

    // Subscribe to status updates
    _statusSubscription = _locationService.statusUpdates.listen((status) {
      log('📊 Status update: ${status}');
      trackingStatus.value = status;
    });

    log('✅ Subscribed to status updates stream');
  }
}

/// Detailed statistics model
class LocationTrackingStats {
  final bool isTracking;
  final LocationTrackingStatus status;
  final LocationModel? currentLocation;
  final DateTime? lastLocationTime;
  final DateTime? lastSuccessfulSync;
  final int pendingCount;
  final int consecutiveFailures;
  final bool isProcessing;
  final Duration? timeSinceLastSync;
  final bool isStale;

  LocationTrackingStats({
    required this.isTracking,
    required this.status,
    this.currentLocation,
    this.lastLocationTime,
    this.lastSuccessfulSync,
    required this.pendingCount,
    required this.consecutiveFailures,
    required this.isProcessing,
    this.timeSinceLastSync,
    required this.isStale,
  });

  /// Get formatted status text
  String get statusText {
    if (!isTracking) return 'Not Tracking';

    switch (status) {
      case LocationTrackingStatus.tracking:
        return 'Active';
      case LocationTrackingStatus.offline:
        return 'Offline - Queueing';
      case LocationTrackingStatus.stale:
        return 'Not Syncing';
      case LocationTrackingStatus.apiError:
        return 'API Error';
      default:
        return status.displayName;
    }
  }

  /// Get formatted time since last sync
  String get timeSinceLastSyncText {
    if (timeSinceLastSync == null) return 'Never';

    final minutes = timeSinceLastSync!.inMinutes;
    if (minutes < 60) return '$minutes min';

    final hours = timeSinceLastSync!.inHours;
    if (hours < 24) return '$hours hour${hours > 1 ? 's' : ''}';

    final days = timeSinceLastSync!.inDays;
    return '$days day${days > 1 ? 's' : ''}';
  }

  /// Check if everything is working well
  bool get isHealthy {
    return isTracking &&
        !isStale &&
        consecutiveFailures < 3 &&
        pendingCount < 10;
  }
}
