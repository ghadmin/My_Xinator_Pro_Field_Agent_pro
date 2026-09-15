import 'dart:convert';

/// FaProTrack GPS location point model
/// Matches the FaProTrack API specification exactly
class FaProTrackLocation {
  final String companyId;
  final int resourceId;
  final String deviceId;
  final double latitude;
  final double longitude;
  final String recordedAt; // UTC ISO-8601 format
  final double accuracy;
  final double speed;
  final double heading;
  final double altitude;
  final int batteryLevel;
  final String networkType;

  FaProTrackLocation({
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
  });

  /// Create from JSON (for API responses)
  factory FaProTrackLocation.fromJson(Map<String, dynamic> json) {
    return FaProTrackLocation(
      companyId: json['companyId'] as String,
      resourceId: json['resourceId'] as int,
      deviceId: json['deviceId'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      recordedAt: json['recordedAt'] as String,
      accuracy: (json['accuracy'] as num).toDouble(),
      speed: (json['speed'] as num).toDouble(),
      heading: (json['heading'] as num).toDouble(),
      altitude: (json['altitude'] as num).toDouble(),
      batteryLevel: json['batteryLevel'] as int,
      networkType: json['networkType'] as String,
    );
  }

  /// Convert to JSON for FaProTrack API request
  Map<String, dynamic> toJson() {
    return {
      'companyId': companyId,
      'resourceId': resourceId,
      'deviceId': deviceId,
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
  }

  /// Validate location data before sending to API
  /// Returns true if location meets FaProTrack requirements
  bool isValid() {
    // Latitude must be between -90 and 90
    if (latitude < -90 || latitude > 90) {
      return false;
    }

    // Longitude must be between -180 and 180
    if (longitude < -180 || longitude > 180) {
      return false;
    }

    // Reject null island (0,0) unless it's genuinely valid
    if (latitude == 0 && longitude == 0) {
      return false;
    }

    // Negative values that should be positive
    if (accuracy < 0) return false;
    if (speed < 0) return false;

    // Battery level should be reasonable
    if (batteryLevel < 0 || batteryLevel > 100) {
      return false;
    }

    // Basic timestamp validation (shouldn't be too far in future/past)
    try {
      final timestamp = DateTime.parse(recordedAt);
      final now = DateTime.now().toUtc();
      final diff = now.difference(timestamp);

      // More than 1 day in future
      if (diff.isNegative && diff.abs() > const Duration(days: 1)) {
        return false;
      }

      // Before 2020
      if (timestamp.isBefore(DateTime(2020))) {
        return false;
      }
    } catch (e) {
      return false; // Invalid timestamp format
    }

    return true;
  }

  /// Create a copy with updated fields
  FaProTrackLocation copyWith({
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
    return FaProTrackLocation(
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
    return 'FaProTrackLocation(companyId: $companyId, resourceId: $resourceId, '
           'lat: ${latitude.toStringAsFixed(6)}, lng: ${longitude.toStringAsFixed(6)}, '
           'accuracy: ${accuracy.toStringAsFixed(1)}m, speed: ${speed.toStringAsFixed(1)}m/s, '
           'battery: $batteryLevel%, network: $networkType, time: $recordedAt)';
  }
}

/// Point format for batch upload to FaProTrack API
class FaProTrackPoint {
  final double latitude;
  final double longitude;
  final String recordedAt;
  final double accuracy;
  final double speed;
  final double heading;
  final double altitude;
  final int batteryLevel;
  final String networkType;

  FaProTrackPoint({
    required this.latitude,
    required this.longitude,
    required this.recordedAt,
    required this.accuracy,
    required this.speed,
    required this.heading,
    required this.altitude,
    required this.batteryLevel,
    required this.networkType,
  });

  Map<String, dynamic> toJson() {
    return {
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
  }

  factory FaProTrackPoint.fromFaProTrackLocation(FaProTrackLocation location) {
    return FaProTrackPoint(
      latitude: location.latitude,
      longitude: location.longitude,
      recordedAt: location.recordedAt,
      accuracy: location.accuracy,
      speed: location.speed,
      heading: location.heading,
      altitude: location.altitude,
      batteryLevel: location.batteryLevel,
      networkType: location.networkType,
    );
  }
}

/// FaProTrack API request model
class FaProTrackRequest {
  final String companyId;
  final int resourceId;
  final String? deviceId; // Optional - applies to the whole batch
  final List<FaProTrackPoint> points;

  FaProTrackRequest({
    required this.companyId,
    required this.resourceId,
    this.deviceId, // Optional parameter
    required this.points,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    final json = {
      'companyId': companyId,
      'resourceId': resourceId,
      'points': points.map((p) => p.toJson()).toList(),
    };

    // Only include deviceId if it's provided
    if (deviceId != null && deviceId!.isNotEmpty) {
      json['deviceId'] = deviceId!;
    }

    return json;
  }

  /// Create request from list of FaProTrack locations
  factory FaProTrackRequest.fromLocations({
    required String companyId,
    required int resourceId,
    String? deviceId, // Optional
    required List<FaProTrackLocation> locations,
  }) {
    return FaProTrackRequest(
      companyId: companyId,
      resourceId: resourceId,
      deviceId: deviceId,
      points: locations.map((loc) => FaProTrackPoint.fromFaProTrackLocation(loc)).toList(),
    );
  }
}

/// FaProTrack API response model
class FaProTrackResponse {
  final bool success;
  final int received;
  final int stored;
  final int duplicates;
  final int rejected;
  final List<String> errors;

  FaProTrackResponse({
    required this.success,
    required this.received,
    required this.stored,
    required this.duplicates,
    required this.rejected,
    required this.errors,
  });

  /// Create from API response JSON
  factory FaProTrackResponse.fromJson(Map<String, dynamic> json) {
    return FaProTrackResponse(
      success: json['success'] as bool? ?? false,
      received: json['received'] as int? ?? 0,
      stored: json['stored'] as int? ?? 0,
      duplicates: json['duplicates'] as int? ?? 0,
      rejected: json['rejected'] as int? ?? 0,
      errors: (json['errors'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  /// Check if the operation was completely successful
  bool get isCompletelySuccessful =>
      success && rejected == 0 && errors.isEmpty;

  /// Check if there were any rejected points
  bool get hasRejections => rejected > 0;

  /// Check if response is valid
  bool get isValid => success || errors.isNotEmpty;

  @override
  String toString() {
    return 'FaProTrackResponse(success: $success, received: $received, '
           'stored: $stored, duplicates: $duplicates, rejected: $rejected, '
           'errors: ${errors.length})';
  }
}