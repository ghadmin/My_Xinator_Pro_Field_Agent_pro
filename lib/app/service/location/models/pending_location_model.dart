import 'package:hive/hive.dart';
import 'location_model.dart';
import '../device_info_service.dart';

part 'pending_location_model.g.dart';

/// Represents a location that is waiting to be uploaded to the API
/// Stored in Hive for offline queue management
@HiveType(typeId: 18)
class PendingLocationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String companyId;

  @HiveField(2)
  final String userId;

  @HiveField(3)
  final String username;

  @HiveField(4)
  final String email;

  @HiveField(5)
  final double latitude;

  @HiveField(6)
  final double longitude;

  @HiveField(7)
  final double accuracy;

  @HiveField(8)
  final DateTime locationTimestamp;

  @HiveField(9)
  final DateTime queuedAt;

  @HiveField(10)
  final int retryCount;

  PendingLocationModel({
    required this.id,
    required this.companyId,
    required this.userId,
    required this.username,
    required this.email,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.locationTimestamp,
    required this.queuedAt,
    this.retryCount = 0,
  });

  /// Create PendingLocationModel from LocationModel
  factory PendingLocationModel.fromLocationModel(LocationModel location) {
    return PendingLocationModel(
      id: _generateId(location.resourceId, location.recordedAt),
      companyId: location.companyId,
      userId: location.resourceId.toString(), // Convert int resourceId to string for storage
      username: '', // Not used in new model
      email: '', // Not used in new model
      latitude: location.latitude,
      longitude: location.longitude,
      accuracy: location.accuracy,
      locationTimestamp: DateTime.tryParse(location.recordedAt) ?? DateTime.now(),
      queuedAt: DateTime.now(),
      retryCount: 0,
    );
  }

  /// Convert to LocationModel for API upload
  LocationModel toLocationModel() {
    return LocationModel(
      companyId: companyId,
      resourceId: int.tryParse(userId) ?? 55,
      deviceId: '', // Will be filled by caller
      latitude: latitude,
      longitude: longitude,
      recordedAt: locationTimestamp.toIso8601String(),
      accuracy: accuracy,
      speed: 0.0, // Not stored in old model
      heading: 0.0, // Not stored in old model
      altitude: 0.0, // Not stored in old model
      // Legacy queue doesn't store battery; report the last reading taken
      // while tracking was active (falls back to 100 before the first read).
      batteryLevel: DeviceInfoService.lastKnownBatteryLevel >= 0
          ? DeviceInfoService.lastKnownBatteryLevel
          : 100,
      networkType: 'lte', // Static for now
    );
  }

  /// Increment retry count
  PendingLocationModel incrementRetry() {
    return PendingLocationModel(
      id: id,
      companyId: companyId,
      userId: userId,
      username: username,
      email: email,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      locationTimestamp: locationTimestamp,
      queuedAt: queuedAt,
      retryCount: retryCount + 1,
    );
  }

  /// Check if this location has exceeded maximum retry attempts
  bool get hasExceededMaxRetries => retryCount >= 5;

  /// Check if this location is too old to be relevant (> 24 hours)
  bool get isTooOld {
    const maxAge = Duration(hours: 24);
    return DateTime.now().difference(queuedAt) > maxAge;
  }

  /// Generate unique ID for pending location
  static String _generateId(int resourceId, String recordedAt) {
    return '${resourceId}_$recordedAt';
  }

  @override
  String toString() {
    return 'PendingLocationModel(id: $id, companyId: $companyId, userId: $userId, '
        'retryCount: $retryCount, queuedAt: ${queuedAt.toIso8601String()}';
  }
}
