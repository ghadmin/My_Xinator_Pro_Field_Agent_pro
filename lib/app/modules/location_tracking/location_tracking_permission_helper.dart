import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

/// Helper class for handling location tracking permissions with proper UI dialogs
class LocationTrackingPermissionHelper {
  /// Check and request all necessary permissions with user-friendly dialogs
  static Future<bool> checkAndRequestPermissions(BuildContext context) async {
    // Check current permission status
    final permissionsStatus = await _checkAllPermissions();

    if (permissionsStatus['allGranted'] == true) {
      return true;
    }

    // Show permission dialog
    return await _showPermissionDialog(context, permissionsStatus);
  }

  /// Check all permission statuses
  static Future<Map<String, bool>> _checkAllPermissions() async {
    final locationPermission = await Permission.location.status;
    final locationAlwaysPermission = await Permission.locationAlways.status;
    final notificationPermission = await Permission.notification.status;

    // Check if location service is enabled
    final isLocationEnabled = await Geolocator.isLocationServiceEnabled();

    return {
      'location': locationPermission.isGranted,
      'locationAlways': locationAlwaysPermission.isGranted,
      'notification': notificationPermission.isGranted,
      'locationServiceEnabled': isLocationEnabled,
      'allGranted': locationPermission.isGranted &&
          (await _isAndroid() ? locationAlwaysPermission.isGranted : true) &&
          notificationPermission.isGranted &&
          isLocationEnabled,
    };
  }

  /// Show permission request dialog with explanations
  static Future<bool> _showPermissionDialog(
    BuildContext context,
    Map<String, bool> status,
  ) async {
    final isAndroid = await _isAndroid();
    final showNotificationPermission =
        isAndroid && await _isAndroid13OrHigher();

    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.location_on, color: Colors.blue),
                SizedBox(width: 8),
                Text('Location Permissions Required'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Location tracking requires the following permissions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),

                  // Location permission
                  _buildPermissionItem(
                    'Location Access',
                    status['location'] == true,
                    'Required to get your GPS location',
                  ),

                  if (isAndroid) ...[
                    _buildPermissionItem(
                      'Background Location',
                      status['locationAlways'] == true,
                      'Required to track location when app is closed',
                    ),
                  ],

                  // Notification permission
                  if (showNotificationPermission)
                    _buildPermissionItem(
                      'Notifications',
                      status['notification'] == true,
                      'Required to show tracking status',
                    ),

                  // Location service
                  _buildPermissionItem(
                    'GPS Service',
                    status['locationServiceEnabled'] == true,
                    'Required to access device location',
                  ),

                  SizedBox(height: 16),
                  Text(
                    'These permissions are necessary for the field agent location tracking feature to work properly.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop(true);
                  await _requestAllPermissions(context);
                },
                child: Text('Grant Permissions'),
              ),
            ],
          ),
        ) ??
        false;
  }

  /// Build individual permission item
  static Widget _buildPermissionItem(
      String title, bool granted, String description) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            granted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: granted ? Colors.green : Colors.grey,
            size: 20,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Request all permissions
  static Future<bool> _requestAllPermissions(BuildContext context) async {
    try {
      // Request location permission
      final locationPermission = await Permission.location.request();
      if (!locationPermission.isGranted) {
        _showOpenSettingsDialog(context, 'Location');
        return false;
      }

      // For Android, request background location
      if (await _isAndroid()) {
        final locationAlwaysPermission =
            await Permission.locationAlways.request();
        if (!locationAlwaysPermission.isGranted) {
          _showOpenSettingsDialog(context, 'Background Location');
          return false;
        }

        // Request notification permission for Android 13+
        if (await _isAndroid13OrHigher()) {
          final notificationPermission =
              await Permission.notification.request();
          if (!notificationPermission.isGranted) {
            _showOpenSettingsDialog(context, 'Notifications');
            return false;
          }
        }
      }

      // Check if location service is enabled
      final isLocationEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationEnabled) {
        _showEnableLocationDialog(context);
        return false;
      }

      return true;
    } catch (e) {
      print('Error requesting permissions: $e');
      return false;
    }
  }

  /// Show dialog to open app settings
  static void _showOpenSettingsDialog(
      BuildContext context, String permissionType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permissionType Permission Required'),
        content: Text(
          'Please enable $permissionType permission in app settings to use location tracking.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Show dialog to enable location service
  static void _showEnableLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enable Location Service'),
        content: Text(
          'Please enable your device location service (GPS) to use location tracking.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator.openLocationSettings();
            },
            child: Text('Enable Location'),
          ),
        ],
      ),
    );
  }

  /// Check if device is Android
  static Future<bool> _isAndroid() async {
    return false; // Will be implemented with device_info
  }

  /// Check if device is Android 13 or higher
  static Future<bool> _isAndroid13OrHigher() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt >= 33;
    } catch (e) {
      return false;
    }
  }

  /// Show comprehensive permission status
  static Widget buildPermissionStatusCard(BuildContext context) {
    return FutureBuilder<Map<String, bool>>(
      future: _checkAllPermissions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        final status = snapshot.data!;
        final allGranted = status['allGranted'] == true;

        return Card(
          color: allGranted ? Colors.green.shade50 : Colors.orange.shade50,
          child: ListTile(
            leading: Icon(
              allGranted ? Icons.check_circle : Icons.warning,
              color: allGranted ? Colors.green : Colors.orange,
            ),
            title: Text('Location Permissions'),
            subtitle: Text(
              allGranted
                  ? 'All permissions granted'
                  : 'Some permissions missing',
            ),
            trailing: !allGranted
                ? ElevatedButton(
                    onPressed: () => checkAndRequestPermissions(context),
                    child: Text('Fix'),
                  )
                : Icon(Icons.done, color: Colors.green),
          ),
        );
      },
    );
  }
}
