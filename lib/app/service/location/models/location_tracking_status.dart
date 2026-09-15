/// Location tracking status enumeration
/// Defines all possible states of the location tracking system
enum LocationTrackingStatus {
  /// Tracking is completely stopped
  stopped,

  /// Tracking is being initialized
  starting,

  /// Actively tracking locations
  tracking,

  /// No internet connection, locations are being queued
  offline,

  /// API is returning errors, locations are being queued
  apiError,

  /// Locations have not been synced for more than 10 minutes
  stale,

  /// Location permission denied by user
  permissionDenied,

  /// GPS/Location services are disabled on device
  gpsDisabled,

  /// Tracking was stopped by user (logout)
  stoppedByUser,
}

extension LocationTrackingStatusExtension on LocationTrackingStatus {
  /// Human-readable status message
  String get displayName {
    switch (this) {
      case LocationTrackingStatus.stopped:
        return 'Stopped';
      case LocationTrackingStatus.starting:
        return 'Starting...';
      case LocationTrackingStatus.tracking:
        return 'Active';
      case LocationTrackingStatus.offline:
        return 'Offline - Queueing';
      case LocationTrackingStatus.apiError:
        return 'API Error - Retrying';
      case LocationTrackingStatus.stale:
        return 'Not Syncing';
      case LocationTrackingStatus.permissionDenied:
        return 'Permission Denied';
      case LocationTrackingStatus.gpsDisabled:
        return 'GPS Disabled';
      case LocationTrackingStatus.stoppedByUser:
        return 'Stopped';
    }
  }

  /// Whether tracking is currently active (even with issues)
  bool get isActive {
    return this == LocationTrackingStatus.tracking ||
           this == LocationTrackingStatus.offline ||
           this == LocationTrackingStatus.apiError ||
           this == LocationTrackingStatus.stale;
  }

  /// Whether the status indicates an error condition
  bool get isError {
    return this == LocationTrackingStatus.offline ||
           this == LocationTrackingStatus.apiError ||
           this == LocationTrackingStatus.stale ||
           this == LocationTrackingStatus.permissionDenied ||
           this == LocationTrackingStatus.gpsDisabled;
  }
}