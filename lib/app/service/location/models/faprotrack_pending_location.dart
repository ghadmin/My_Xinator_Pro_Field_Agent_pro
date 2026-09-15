import 'package:hive/hive.dart';
import 'faprotrack_location_model.dart';

part 'faprotrack_pending_location.g.dart';

/// Pending location for offline queue
/// Stores FaProTrack locations locally until they can be uploaded
@HiveType(typeId: 19)
class FaProTrackPendingLocation {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String companyId;

  @HiveField(2)
  final int resourceId;

  @HiveField(3)
  final String deviceId;

  @HiveField(4)
  final double latitude;

  @HiveField(5)
  final double longitude;

  @HiveField(6)
  final String recordedAt;

  @HiveField(7)
  final double accuracy;

  @HiveField(8)
  final double speed;

  @HiveField(9)
  final double heading;

  @HiveField(10)
  final double altitude;

  @HiveField(11)
  final int batteryLevel;

  @HiveField(12)
  final String networkType;

  @HiveField(13)
  final DateTime queuedAt;

  @HiveField(14)
  final int retryCount;

  @HiveField(15)
  final DateTime lastRetryAt;

  FaProTrackPendingLocation({
    required this.id,
    required this.companyId,
    required this.resourceId,
    required this.deviceId,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    required this.accuracy,
    required this.speed,
    required this.heading,
    required this.altitude,
    required this.batteryLevel,
    required this.networkType,
    required this.queuedAt,
    required this.retryCount,
    required this.lastRetryAt,
  });

  /// Create from FaProTrackLocation
  factory FaProTrackPendingLocation.fromLocation(FaProTrackLocation location) {
    return FaProTrackPendingLocation(
      id: _generateId(location.resourceId, location.recordedAt),
      companyId: location.companyId,
      resourceId: location.resourceId,
      deviceId: location.deviceId,
      latitude: location.latitude,
      longitude: location.longitude,
      recordedAt: location.recordedAt,
      accuracy: location.accuracy,
      speed: location.speed.abs(),
      heading: location.heading,
      altitude: location.altitude,
      batteryLevel: location.batteryLevel,
      networkType: location.networkType,
      queuedAt: DateTime.now().toUtc(),
      retryCount: 0,
      lastRetryAt: DateTime.now().toUtc(),
    );
  }

  /// Generate unique ID for pending location
  static String _generateId(int resourceId, String recordedAt) {
    return '${resourceId}_$recordedAt';
  }

  /// Convert back to FaProTrackLocation for upload
  FaProTrackLocation toLocation() {
    return FaProTrackLocation(
      companyId: companyId,
      resourceId: resourceId,
      deviceId: deviceId,
      latitude: latitude,
      longitude: longitude,
      recordedAt: recordedAt,
      accuracy: accuracy,
      speed: speed,
      heading: heading,
      altitude: altitude,
      batteryLevel: batteryLevel,
      networkType: networkType,
    );
  }

  /// Check if this location has exceeded max retry attempts
  bool get hasExceededMaxRetries => retryCount >= 5;

  /// Check if location is too old (more than 7 days)
  bool get isTooOld {
    final age = DateTime.now().toUtc().difference(queuedAt);
    return age > const Duration(days: 7);
  }

  /// Increment retry count and update last retry time
  FaProTrackPendingLocation incrementRetry() {
    return FaProTrackPendingLocation(
      id: id,
      companyId: companyId,
      resourceId: resourceId,
      deviceId: deviceId,
      latitude: latitude,
      longitude: longitude,
      recordedAt: recordedAt,
      accuracy: accuracy,
      speed: speed,
      heading: heading,
      altitude: altitude,
      batteryLevel: batteryLevel,
      networkType: networkType,
      queuedAt: queuedAt,
      retryCount: retryCount + 1,
      lastRetryAt: DateTime.now().toUtc(),
    );
  }

  /// Validate pending location before upload
  bool isValid() {
    // Use the same validation as FaProTrackLocation
    if (latitude < -90 || latitude > 90) return false;
    if (longitude < -180 || longitude > 180) return false;
    if (latitude == 0 && longitude == 0) return false;
    if (accuracy < 0) return false;
    if (speed < 0) return false;
    if (batteryLevel < 0 || batteryLevel > 100) return false;

    try {
      final timestamp = DateTime.parse(recordedAt);
      final now = DateTime.now().toUtc();
      final diff = now.difference(timestamp);

      if (diff.isNegative && diff.abs() > const Duration(days: 1)) {
        return false;
      }

      if (timestamp.isBefore(DateTime(2020))) {
        return false;
      }
    } catch (e) {
      return false;
    }

    return true;
  }

  @override
  String toString() {
    return 'FaProTrackPendingLocation(id: $id, companyId: $companyId, resourceId: $resourceId, '
           'lat: ${latitude.toStringAsFixed(6)}, lng: ${longitude.toStringAsFixed(6)}, '
           'queuedAt: ${queuedAt.toIso8601String()}, retries: $retryCount)';
  }
}