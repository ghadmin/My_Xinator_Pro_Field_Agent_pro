import 'package:hive_flutter/hive_flutter.dart';
import 'models/faprotrack_pending_location.dart';
import 'models/faprotrack_location_model.dart';

/// Service for managing FaProTrack offline queue using Hive
class FaProTrackStorageService {
  static const String _pendingLocationsBoxName = 'faprotrack_pending_locations';
  static const String _trackingStatusBoxName = 'faprotrack_tracking_status';

  late Box<FaProTrackPendingLocation> _pendingLocationsBox;
  late Box _trackingStatusBox;

  bool _isInitialized = false;

  /// Initialize the storage service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Adapters are registered centrally in HiveAdapters.registerAll()

      // Open boxes
      _pendingLocationsBox = await Hive.openBox<FaProTrackPendingLocation>(
        _pendingLocationsBoxName,
      );
      _trackingStatusBox = await Hive.openBox(_trackingStatusBoxName);

      _isInitialized = true;
      print('✅ FaProTrack storage service initialized');
    } catch (e) {
      print('❌ Failed to initialize FaProTrack storage: $e');
      rethrow;
    }
  }

  /// Add a location to the pending queue
  Future<void> queueLocation(FaProTrackLocation location) async {
    _ensureInitialized();

    try {
      final pendingLocation = FaProTrackPendingLocation.fromLocation(location);
      await _pendingLocationsBox.put(pendingLocation.id, pendingLocation);
      print('📦 Location queued: ${pendingLocation.id}');
    } catch (e) {
      print('❌ Failed to queue location: $e');
    }
  }

  /// Get all pending locations for a specific technician (by resourceId)
  Future<List<FaProTrackPendingLocation>> getPendingLocations(int resourceId) async {
    _ensureInitialized();

    try {
      final allLocations = _pendingLocationsBox.values.toList();
      return allLocations.where((loc) => loc.resourceId == resourceId).toList();
    } catch (e) {
      print('❌ Failed to get pending locations: $e');
      return [];
    }
  }

  /// Get all pending locations (all technicians)
  Future<List<FaProTrackPendingLocation>> getAllPendingLocations() async {
    _ensureInitialized();

    try {
      return _pendingLocationsBox.values.toList();
    } catch (e) {
      print('❌ Failed to get all pending locations: $e');
      return [];
    }
  }

  /// Get count of pending locations for specific technician
  Future<int> getPendingCount(int resourceId) async {
    final locations = await getPendingLocations(resourceId);
    return locations.length;
  }

  /// Remove a pending location after successful upload
  Future<void> removePendingLocation(String id) async {
    _ensureInitialized();

    try {
      await _pendingLocationsBox.delete(id);
      print('🗑️ Location removed from queue: $id');
    } catch (e) {
      print('❌ Failed to remove location: $e');
    }
  }

  /// Update retry count for a pending location
  Future<void> updateRetryCount(String id, int newRetryCount) async {
    _ensureInitialized();

    try {
      final location = _pendingLocationsBox.get(id);
      if (location != null) {
        final updatedLocation = location.incrementRetry();
        await _pendingLocationsBox.put(id, updatedLocation);
        print('🔄 Updated retry count for $id: $newRetryCount');
      }
    } catch (e) {
      print('❌ Failed to update retry count: $e');
    }
  }

  /// Clear all pending locations for a specific technician
  Future<void> clearUserPendingLocations(int resourceId) async {
    _ensureInitialized();

    try {
      final keysToRemove = <String>[];
      for (final key in _pendingLocationsBox.keys) {
        final location = _pendingLocationsBox.get(key);
        if (location?.resourceId == resourceId) {
          keysToRemove.add(key);
        }
      }

      for (final key in keysToRemove) {
        await _pendingLocationsBox.delete(key);
      }

      print('🗑️ Cleared $keysToRemove.length locations for technician $resourceId');
    } catch (e) {
      print('❌ Failed to clear user locations: $e');
    }
  }

  /// Clear all pending locations
  Future<void> clearAllPendingLocations() async {
    _ensureInitialized();

    try {
      final count = _pendingLocationsBox.length;
      await _pendingLocationsBox.clear();
      print('🗑️ Cleared all $count pending locations');
    } catch (e) {
      print('❌ Failed to clear all locations: $e');
    }
  }

  /// Clean up old or exceeded retry locations
  Future<int> cleanupOldLocations() async {
    _ensureInitialized();

    try {
      final keysToRemove = <String>[];

      for (final location in _pendingLocationsBox.values) {
        if (location.isTooOld || location.hasExceededMaxRetries) {
          keysToRemove.add(location.id);
        }
      }

      for (final key in keysToRemove) {
        await _pendingLocationsBox.delete(key);
      }

      if (keysToRemove.isNotEmpty) {
        print('🧹 Cleaned up ${keysToRemove.length} old/expired locations');
      }

      return keysToRemove.length;
    } catch (e) {
      print('❌ Failed to cleanup old locations: $e');
      return 0;
    }
  }

  /// Tracking status management methods
  Future<void> setLastSuccessfulSync(DateTime timestamp) async {
    _ensureInitialized();
    await _trackingStatusBox.put('last_successful_sync', timestamp.toIso8601String());
  }

  Future<DateTime?> getLastSuccessfulSync() async {
    _ensureInitialized();
    final timestamp = _trackingStatusBox.get('last_successful_sync');
    if (timestamp != null) {
      return DateTime.parse(timestamp as String);
    }
    return null;
  }

  Future<void> setLastFailureTime(DateTime timestamp) async {
    _ensureInitialized();
    await _trackingStatusBox.put('last_failure_time', timestamp.toIso8601String());
  }

  Future<DateTime?> getLastFailureTime() async {
    _ensureInitialized();
    final timestamp = _trackingStatusBox.get('last_failure_time');
    if (timestamp != null) {
      return DateTime.parse(timestamp as String);
    }
    return null;
  }

  Future<void> setConsecutiveFailures(int count) async {
    _ensureInitialized();
    await _trackingStatusBox.put('consecutive_failures', count);
  }

  Future<int> getConsecutiveFailures() async {
    _ensureInitialized();
    return _trackingStatusBox.get('consecutive_failures', defaultValue: 0) as int;
  }

  Future<void> setTrackingEnabled(bool enabled) async {
    _ensureInitialized();
    await _trackingStatusBox.put('tracking_enabled', enabled);
  }

  Future<bool> isTrackingEnabled() async {
    _ensureInitialized();
    return _trackingStatusBox.get('tracking_enabled', defaultValue: false) as bool;
  }

  /// Clear all tracking status
  Future<void> clearTrackingStatus() async {
    _ensureInitialized();
    await _trackingStatusBox.clear();
  }

  /// Clear all sync state for current user
  Future<void> clearUserState(int resourceId) async {
    await clearUserPendingLocations(resourceId);
    // Note: Don't clear tracking status as it's global, not user-specific
  }

  /// Get statistics about pending queue
  Future<Map<String, int>> getQueueStats() async {
    _ensureInitialized();

    try {
      final allLocations = _pendingLocationsBox.values.toList();
      final total = allLocations.length;

      // Group by resourceId
      final Map<int, int> byResource = {};
      for (final loc in allLocations) {
        byResource[loc.resourceId] = (byResource[loc.resourceId] ?? 0) + 1;
      }

      // Count old locations
      final old = allLocations.where((loc) => loc.isTooOld).length;

      // Count high retry locations
      final highRetry = allLocations.where((loc) => loc.hasExceededMaxRetries).length;

      return {
        'total': total,
        'by_technicians': byResource.length,
        'old': old,
        'high_retry': highRetry,
      };
    } catch (e) {
      print('❌ Failed to get queue stats: $e');
      return {};
    }
  }

  /// Ensure service is initialized
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('FaProTrackStorageService not initialized. Call initialize() first.');
    }
  }

  /// Close storage service
  Future<void> close() async {
    if (_isInitialized) {
      await _pendingLocationsBox.close();
      await _trackingStatusBox.close();
      _isInitialized = false;
      print('✅ FaProTrack storage service closed');
    }
  }
}