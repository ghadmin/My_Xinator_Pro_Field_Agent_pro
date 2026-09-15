import 'dart:developer';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'models/location_model.dart';
import 'location_storage_service.dart';
import 'location_api_service.dart';
import 'location_notification_service.dart';

/// Manages location synchronization with retry logic and offline queue handling
class LocationSyncManager {
  final LocationStorageService _storageService = LocationStorageService();
  final LocationApiService _apiService = LocationApiService();
  final LocationNotificationService _notificationService = LocationNotificationService();

  Timer? _syncTimer;
  Timer? _staleCheckTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  // Constants for sync behavior
  static const Duration _syncInterval = Duration(minutes: 1);
  static const Duration _staleCheckInterval = Duration(minutes: 2);
  static const Duration _staleWarningThreshold = Duration(minutes: 10);
  static const Duration _staleCriticalThreshold = Duration(minutes: 30);
  static const Duration _notificationCooldown = Duration(minutes: 30);

  DateTime? _lastStaleNotification;
  bool _isProcessingQueue = false;
  String? _currentUserId;

  /// Initialize the sync manager
  Future<void> initialize(String userId) async {
    _currentUserId = userId;
    await _storageService.initialize();
    await _notificationService.initialize();

    log('🔄 LocationSyncManager initialized for user: $userId');
  }

  /// Start sync manager (begin processing queue and monitoring)
  Future<void> start() async {
    if (_currentUserId == null) {
      log('⚠️ Cannot start sync manager: No user ID set');
      return;
    }

    log('🚀 Starting LocationSyncManager');

    // Start periodic sync timer
    _syncTimer = Timer.periodic(_syncInterval, (_) => _processPendingLocations());

    // Start stale check timer
    _staleCheckTimer = Timer.periodic(_staleCheckInterval, (_) => _checkStaleSync());

    // Monitor connectivity changes
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((_) => _onConnectivityChanged());

    // Process any existing pending locations
    await _processPendingLocations();

    // Check if we're already stale
    await _checkStaleSync();
  }

  /// Stop sync manager
  Future<void> stop() async {
    log('🛑 Stopping LocationSyncManager');

    _syncTimer?.cancel();
    _staleCheckTimer?.cancel();
    await _connectivitySubscription?.cancel();

    _syncTimer = null;
    _staleCheckTimer = null;
    _connectivitySubscription = null;
    _isProcessingQueue = false;
  }

  /// Sync a new location immediately
  Future<LocationSyncResult> syncLocation(LocationModel location) async {
    log('📍 Syncing new location immediately');

    try {
      final result = await _apiService.sendLocation(location);

      if (result.success) {
        await _onSuccessfulSync(location);
        return LocationSyncResult.success();
      } else {
        await _onFailedSync(location, result);
        return LocationSyncResult.failure(result.failureType, result.errorMessage);
      }
    } catch (e, stackTrace) {
      log('❌ Error syncing location: $e');
      log('Stack trace: $stackTrace');
      await _onFailedSync(location, null);
      return LocationSyncResult.failure(null, e.toString());
    }
  }

  /// Process all pending locations in the queue
  Future<void> _processPendingLocations() async {
    if (_isProcessingQueue) {
      log('⏳ Queue processing already in progress, skipping');
      return;
    }

    _isProcessingQueue = true;

    try {
      log('🔄 Processing pending locations queue');

      // Clean up old locations first
      final cleanedCount = await _storageService.cleanupOldLocations();
      if (cleanedCount > 0) {
        log('🧹 Cleaned up $cleanedCount old/expired locations');
      }

      // Get pending locations for current user
      final pendingLocations = await _storageService.getPendingLocations(
        _currentUserId ?? '',
      );

      if (pendingLocations.isEmpty) {
        log('✅ No pending locations to process');
        return;
      }

      log('📦 Found ${pendingLocations.length} pending locations');

      // Process locations sequentially to avoid overwhelming the server
      for (final pendingLocation in pendingLocations) {
        final location = pendingLocation.toLocationModel();

        try {
          final result = await _apiService.sendLocation(location);

          if (result.success) {
            // Remove from queue on success
            await _storageService.removePendingLocation(pendingLocation.id);
            await _onSuccessfulSync(location);
            log('✅ Successfully uploaded pending location: ${pendingLocation.id}');
          } else if (!result.shouldRetry) {
            // Remove from queue if error is not retryable (auth, validation)
            await _storageService.removePendingLocation(pendingLocation.id);
            log('⚠️ Removed non-retryable location: ${pendingLocation.id} - ${result.errorMessage}');
          } else {
            // Increment retry count for retryable errors
            if (pendingLocation.hasExceededMaxRetries) {
              await _storageService.removePendingLocation(pendingLocation.id);
              log('⚠️ Removed location with too many retries: ${pendingLocation.id}');
            } else {
              await _storageService.updateRetryCount(pendingLocation.id, pendingLocation.retryCount + 1);
              log('⏳ Incremented retry count for: ${pendingLocation.id}');
            }
          }
        } catch (e) {
          log('❌ Error processing pending location ${pendingLocation.id}: $e');
          // Will retry in next cycle
        }

        // Small delay between uploads to avoid rate limiting
        await Future.delayed(const Duration(milliseconds: 500));
      }

      log('🏁 Finished processing queue');
    } finally {
      _isProcessingQueue = false;
    }
  }

  /// Handle successful sync
  Future<void> _onSuccessfulSync(LocationModel location) async {
    final now = DateTime.now();
    await _storageService.setLastSuccessfulSync(now);
    await _storageService.setConsecutiveFailures(0);

    // Check if we were previously stale and show "restored" notification
    final lastFailure = _storageService.getLastFailureTime();
    if (lastFailure != null && now.difference(lastFailure) > _staleWarningThreshold) {
      await _showSyncRestoredNotification();
    }
  }

  /// Handle failed sync
  Future<void> _onFailedSync(LocationModel location, LocationApiResult? result) async {
    // Add to pending queue
    await _storageService.queueLocation(location);

    final now = DateTime.now();
    await _storageService.setLastFailureTime(now);

    final consecutiveFailures = _storageService.getConsecutiveFailures() + 1;
    await _storageService.setConsecutiveFailures(consecutiveFailures);

    log('❌ Location sync failed, queued for retry (attempt $consecutiveFailures)');
  }

  /// Check if sync is stale and show notification if needed
  Future<void> _checkStaleSync() async {
    final lastSync = _storageService.getLastSuccessfulSync();
    if (lastSync == null) {
      log('⚠️ No successful sync recorded yet');
      return;
    }

    final now = DateTime.now();
    final timeSinceSync = now.difference(lastSync);

    if (timeSinceSync > _staleCriticalThreshold) {
      await _showCriticalStaleNotification(timeSinceSync);
    } else if (timeSinceSync > _staleWarningThreshold) {
      await _showStaleNotification(timeSinceSync);
    } else {
      log('✅ Sync is healthy (${timeSinceSync.inMinutes} minutes since last sync)');
    }
  }

  /// Show stale warning notification
  Future<void> _showStaleNotification(Duration timeSinceSync) async {
    // Check cooldown
    if (_lastStaleNotification != null &&
        DateTime.now().difference(_lastStaleNotification!) < _notificationCooldown) {
      log('⏳ Stale notification cooldown active, skipping');
      return;
    }

    await _notificationService.showStaleLocationWarning(timeSinceSync);
    _lastStaleNotification = DateTime.now();
  }

  /// Show critical stale notification
  Future<void> _showCriticalStaleNotification(Duration timeSinceSync) async {
    // Check cooldown
    if (_lastStaleNotification != null &&
        DateTime.now().difference(_lastStaleNotification!) < _notificationCooldown) {
      log('⏳ Critical stale notification cooldown active, skipping');
      return;
    }

    await _notificationService.showCriticalLocationStale(timeSinceSync);
    _lastStaleNotification = DateTime.now();
  }

  /// Show sync restored notification
  Future<void> _showSyncRestoredNotification() async {
    await _notificationService.showSyncRestored();
  }

  /// Handle connectivity change
  Future<void> _onConnectivityChanged() async {
    log('🌐 Connectivity changed, checking connection...');

    final connectivity = await Connectivity().checkConnectivity();
    final hasConnection = connectivity.any((result) =>
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.ethernet ||
      result == ConnectivityResult.vpn
    );

    if (hasConnection) {
      log('🌐 Internet connection restored, processing queue');
      await _processPendingLocations();
    } else {
      log('🌐 No internet connection');
    }
  }

  /// Get current sync statistics
  Future<LocationSyncStats> getStats() async {
    final lastSync = _storageService.getLastSuccessfulSync();
    final pendingCount = await _storageService.getPendingCount(_currentUserId ?? '');
    final consecutiveFailures = _storageService.getConsecutiveFailures();

    return LocationSyncStats(
      lastSuccessfulSync: lastSync,
      pendingCount: pendingCount,
      consecutiveFailures: consecutiveFailures,
      isProcessing: _isProcessingQueue,
    );
  }

  /// Clear all sync state (called on logout and user switch)
  Future<void> clearUserState() async {
    // Clear everything on the device, not just the bound user's rows — no
    // queued location may survive a logout, even if the manager was never
    // initialized in this session.
    await _storageService.initialize();
    await _storageService.clearAllPendingLocations();
    await _storageService.clearTrackingStatus();

    _currentUserId = null;

    log('🗑️ Cleared all location sync state');
  }

  /// Update current user ID
  void updateUser(String userId) {
    _currentUserId = userId;
    log('🔄 Updated sync manager user ID to: $userId');
  }

  /// Dispose resources
  Future<void> dispose() async {
    await stop();
    await _storageService.close();
  }
}

/// Result of location sync operation
class LocationSyncResult {
  final bool success;
  final LocationApiFailureType? failureType;
  final String? errorMessage;

  LocationSyncResult._({required this.success, this.failureType, this.errorMessage});

  factory LocationSyncResult.success() {
    return LocationSyncResult._(success: true);
  }

  factory LocationSyncResult.failure(LocationApiFailureType? type, String? message) {
    return LocationSyncResult._(
      success: false,
      failureType: type,
      errorMessage: message,
    );
  }
}

/// Sync statistics
class LocationSyncStats {
  final DateTime? lastSuccessfulSync;
  final int pendingCount;
  final int consecutiveFailures;
  final bool isProcessing;

  LocationSyncStats({
    required this.lastSuccessfulSync,
    required this.pendingCount,
    required this.consecutiveFailures,
    required this.isProcessing,
  });

  Duration? get timeSinceLastSync {
    if (lastSuccessfulSync == null) return null;
    return DateTime.now().difference(lastSuccessfulSync!);
  }

  bool get isStale {
    if (lastSuccessfulSync == null) return true;
    return timeSinceLastSync! > const Duration(minutes: 10);
  }
}