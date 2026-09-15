import 'package:hive_flutter/hive_flutter.dart';
import 'models/pending_location_model.dart';
import 'models/location_model.dart';

/// Service for managing offline location queue using Hive
class LocationStorageService {
  static const String _pendingLocationsBoxName = 'pending_locations';
  static const String _trackingStatusBoxName = 'tracking_status';

  late Box<PendingLocationModel> _pendingLocationsBox;
  late Box _trackingStatusBox;

  bool _isInitialized = false;

  /// Initialize the storage service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Adapters are registered centrally in HiveAdapters.registerAll()

    // Open boxes
    _pendingLocationsBox = await Hive.openBox<PendingLocationModel>(
      _pendingLocationsBoxName,
    );
    _trackingStatusBox = await Hive.openBox(_trackingStatusBoxName);

    _isInitialized = true;
  }

  /// Add a location to the pending queue
  Future<void> queueLocation(LocationModel location) async {
    _ensureInitialized();

    final pendingLocation = PendingLocationModel.fromLocationModel(location);
    await _pendingLocationsBox.put(pendingLocation.id, pendingLocation);
  }

  /// Get all pending locations for a specific user
  Future<List<PendingLocationModel>> getPendingLocations(String userId) async {
    _ensureInitialized();

    final allLocations = _pendingLocationsBox.values.toList();
    return allLocations.where((loc) => loc.user_id == userId).toList();
  }

  /// Get all pending locations (all users)
  Future<List<PendingLocationModel>> getAllPendingLocations() async {
    _ensureInitialized();
    return _pendingLocationsBox.values.toList();
  }

  /// Remove a pending location after successful upload
  Future<void> removePendingLocation(String id) async {
    _ensureInitialized();
    await _pendingLocationsBox.delete(id);
  }

  /// Clear all pending locations for a specific user
  Future<void> clearUserPendingLocations(String userId) async {
    _ensureInitialized();

    final keysToRemove = _pendingLocationsBox.keys
        .where((key) {
          final location = _pendingLocationsBox.get(key);
          return location?.user_id == userId;
        })
        .toList();

    for (final key in keysToRemove) {
      await _pendingLocationsBox.delete(key);
    }
  }

  /// Clear all pending locations
  Future<void> clearAllPendingLocations() async {
    _ensureInitialized();
    await _pendingLocationsBox.clear();
  }

  /// Clean up old or exceeded retry locations
  Future<int> cleanupOldLocations() async {
    _ensureInitialized();

    final keysToRemove = <String>[];

    for (final location in _pendingLocationsBox.values) {
      if (location.isTooOld || location.hasExceededMaxRetries) {
        keysToRemove.add(location.id);
      }
    }

    for (final key in keysToRemove) {
      await _pendingLocationsBox.delete(key);
    }

    return keysToRemove.length;
  }

  /// Get the count of pending locations for a user
  Future<int> getPendingCount(String userId) async {
    _ensureInitialized();

    return _pendingLocationsBox.values
        .where((loc) => loc.user_id == userId)
        .length;
  }

  /// Update retry count for a pending location
  Future<void> updateRetryCount(String id, int newRetryCount) async {
    _ensureInitialized();

    final location = _pendingLocationsBox.get(id);
    if (location != null) {
      await _pendingLocationsBox.put(id, location.incrementRetry());
    }
  }

  // Tracking status persistence methods

  /// Save tracking enabled state
  Future<void> setTrackingEnabled(bool enabled) async {
    _ensureInitialized();
    await _trackingStatusBox.put('tracking_enabled', enabled);
  }

  /// Get tracking enabled state
  bool getTrackingEnabled() {
    _ensureInitialized();
    return _trackingStatusBox.get('tracking_enabled', defaultValue: false);
  }

  /// Save last successful API sync time
  Future<void> setLastSuccessfulSync(DateTime time) async {
    _ensureInitialized();
    await _trackingStatusBox.put('last_successful_sync', time.toIso8601String());
  }

  /// Get last successful API sync time
  DateTime? getLastSuccessfulSync() {
    _ensureInitialized();
    final syncStr = _trackingStatusBox.get('last_successful_sync');
    if (syncStr != null) {
      return DateTime.parse(syncStr as String);
    }
    return null;
  }

  /// Save last API failure time
  Future<void> setLastFailureTime(DateTime time) async {
    _ensureInitialized();
    await _trackingStatusBox.put('last_failure_time', time.toIso8601String());
  }

  /// Get last API failure time
  DateTime? getLastFailureTime() {
    _ensureInitialized();
    final failureStr = _trackingStatusBox.get('last_failure_time');
    if (failureStr != null) {
      return DateTime.parse(failureStr as String);
    }
    return null;
  }

  /// Save consecutive failures count
  Future<void> setConsecutiveFailures(int count) async {
    _ensureInitialized();
    await _trackingStatusBox.put('consecutive_failures', count);
  }

  /// Get consecutive failures count
  int getConsecutiveFailures() {
    _ensureInitialized();
    return _trackingStatusBox.get('consecutive_failures', defaultValue: 0);
  }

  /// Save tracking started time
  Future<void> setTrackingStartedAt(DateTime time) async {
    _ensureInitialized();
    await _trackingStatusBox.put('tracking_started_at', time.toIso8601String());
  }

  /// Get tracking started time
  DateTime? getTrackingStartedAt() {
    _ensureInitialized();
    final startedStr = _trackingStatusBox.get('tracking_started_at');
    if (startedStr != null) {
      return DateTime.parse(startedStr as String);
    }
    return null;
  }

  /// Clear all tracking status
  Future<void> clearTrackingStatus() async {
    _ensureInitialized();
    await _trackingStatusBox.clear();
  }

  /// Close all boxes
  Future<void> close() async {
    if (!_isInitialized) return;

    await _pendingLocationsBox.close();
    await _trackingStatusBox.close();
    _isInitialized = false;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('LocationStorageService is not initialized. Call initialize() first.');
    }
  }

  /// Get storage statistics
  Future<Map<String, dynamic>> getStatistics() async {
    _ensureInitialized();

    return {
      'total_pending_locations': _pendingLocationsBox.length,
      'tracking_enabled': getTrackingEnabled(),
      'last_successful_sync': getLastSuccessfulSync()?.toIso8601String(),
      'last_failure_time': getLastFailureTime()?.toIso8601String(),
      'consecutive_failures': getConsecutiveFailures(),
      'tracking_started_at': getTrackingStartedAt()?.toIso8601String(),
    };
  }
}