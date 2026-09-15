import '../device_info_service.dart';

/// Represents a single location data point for FaProTrack API
/// Updated to match FaProTrack API specification
class LocationModel {
  final String companyId;
  final int resourceId; // Using static 55 for now, will be updated later
  final String deviceId; // Optional device ID
  final double latitude;
  final double longitude;
  final String recordedAt; // GPS timestamp (FaProTrack format)
  final double accuracy;
  final double speed; // GPS metadata from geolocator
  final double heading; // GPS metadata from geolocator
  final double altitude; // GPS metadata from geolocator
  final int batteryLevel; // Real reading via battery_plus
  final String networkType; // Static for now

  LocationModel({
    required this.companyId,
    required this.resourceId,
    required this.deviceId,
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    required this.accuracy,
    required double speed,
    required this.heading,
    required this.altitude,
    required this.batteryLevel,
    required this.networkType,
  }) : speed = speed.abs(); // GPS can report negative speed; never store it

  /// Create LocationModel from JSON
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      companyId: json['companyId'] as String,
      resourceId: json['resourceId'] as int,
      deviceId: json['deviceId'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      recordedAt: json['recordedAt'] as String,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
      heading: (json['heading'] as num?)?.toDouble() ?? 0.0,
      altitude: (json['altitude'] as num?)?.toDouble() ?? 0.0,
      batteryLevel: json['batteryLevel'] as int? ?? 100,
      networkType: json['networkType'] as String? ?? 'unknown',
    );
  }

  /// Convert to JSON for FaProTrack API request
  Map<String, dynamic> toJson() {
    final json = {
      'companyId': companyId,
      'resourceId': resourceId,
      'latitude': latitude,
      'longitude': longitude,
      'recordedAt': recordedAt,
      'accuracy': accuracy,
      'speed': speed,
      'heading': heading,
      'altitude': altitude,
      'batteryLevel': batteryLevel,
      'networkType': networkType,
    };

    // Only include deviceId if provided (optional field)
    if (deviceId.isNotEmpty) {
      json['deviceId'] = deviceId;
    }

    return json;
  }

  /// Create LocationModel from geolocator Position
  factory LocationModel.fromPosition(
    Map<String, dynamic> position, {
    required String companyId,
    required int resourceId,
    required String deviceId,
  }) {
    return LocationModel(
      companyId: companyId,
      resourceId: resourceId,
      deviceId: deviceId,
      latitude: position['latitude'] as double,
      longitude: position['longitude'] as double,
      accuracy: position['accuracy'] as double? ?? 0.0,
      speed: (position['speed'] as num?)?.toDouble() ?? 0.0,
      heading: (position['heading'] as num?)?.toDouble() ?? 0.0,
      altitude: (position['altitude'] as num?)?.toDouble() ?? 0.0,
      recordedAt: position['timestamp'] is DateTime
          ? (position['timestamp'] as DateTime).toUtc().toIso8601String()
          : DateTime.parse(position['timestamp'] as String).toUtc().toIso8601String(),
      batteryLevel: DeviceInfoService.lastKnownBatteryLevel >= 0
          ? DeviceInfoService.lastKnownBatteryLevel
          : 100,
      networkType: 'lte', // Static for now
    );
  }

  /// Validate location data
  /// Returns true if location is valid and should be sent to API
  bool isValid() {
    // Latitude must be between -90 and 90
    if (latitude < -90 || latitude > 90) {
      return false;
    }

    // Longitude must be between -180 and 180
    if (longitude < -180 || longitude > 180) {
      return false;
    }

    // Don't reject based on accuracy - let server decide
    // Only reject obviously invalid data
    if (latitude == 0 && longitude == 0) {
      return false;
    }

    return true;
  }

  /// Create a copy with updated fields
  LocationModel copyWith({
    String? companyId,
    int? resourceId,
    String? deviceId,
    double? latitude,
    double? longitude,
    String? recordedAt,
    double? accuracy,
    double? speed,
    double? heading,
    double? altitude,
    int? batteryLevel,
    String? networkType,
  }) {
    return LocationModel(
      companyId: companyId ?? this.companyId,
      resourceId: resourceId ?? this.resourceId,
      deviceId: deviceId ?? this.deviceId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      recordedAt: recordedAt ?? this.recordedAt,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      altitude: altitude ?? this.altitude,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      networkType: networkType ?? this.networkType,
    );
  }

  @override
  String toString() {
    return 'LocationModel(companyId: $companyId, resourceId: $resourceId, '
           'lat: $latitude, lng: $longitude, accuracy: ${accuracy.toStringAsFixed(1)}m, '
           'speed: ${speed.toStringAsFixed(1)}m/s, heading: ${heading.toStringAsFixed(1)}°, '
           'altitude: ${altitude.toStringAsFixed(1)}m, battery: $batteryLevel%, network: $networkType, '
           'time: $recordedAt';
  }
}