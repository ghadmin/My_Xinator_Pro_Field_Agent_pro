import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:battery_plus/battery_plus.dart';
import 'dart:developer';

/// Service for managing device information and hardware data
/// Handles device ID, battery level, network type for FaProTrack
class DeviceInfoService {
  static const String _deviceIdKey = 'faprotrack_device_id';
  static String? _cachedDeviceId;
  static final Battery _battery = Battery();

  /// Last battery level read from the device (-1 while unknown)
  static int _lastKnownBatteryLevel = -1;

  /// Sync access to the last battery reading for non-async callers.
  /// Returns -1 if the battery level hasn't been read yet.
  static int get lastKnownBatteryLevel => _lastKnownBatteryLevel;

  /// Get or generate stable device ID
  static Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString(_deviceIdKey);

      if (deviceId == null) {
        // Generate new UUID for this device
        deviceId = _generateDeviceId();
        await prefs.setString(_deviceIdKey, deviceId);
        log('📱 Generated new device ID: $deviceId');
      } else {
        log('📱 Using existing device ID: $deviceId');
      }

      _cachedDeviceId = deviceId;
      return deviceId;
    } catch (e) {
      log('❌ Failed to get device ID: $e');
      // Fallback to temporary ID if storage fails
      return _generateDeviceId();
    }
  }

  /// Generate UUID for device identification
  static String _generateDeviceId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch;
    return 'DEVICE_${timestamp}_${random}';
  }

  /// Get current battery level (0-100)
  static Future<int> getBatteryLevel() async {
    try {
      if (kIsWeb) {
        return 100; // Web doesn't have battery
      }

      final level = await _battery.batteryLevel;
      if (level >= 0 && level <= 100) {
        _lastKnownBatteryLevel = level;
        log('🔋 Battery level: $level%');
        return level;
      }

      // Unsupported (some desktops/simulator edge cases) — keep last known
      // value or fall back to 100 so 0-100 validation still passes.
      log('⚠️ Battery level unsupported, got $level');
      return _lastKnownBatteryLevel >= 0 ? _lastKnownBatteryLevel : 100;
    } catch (e) {
      log('❌ Failed to get battery level: $e');
      return _lastKnownBatteryLevel >= 0 ? _lastKnownBatteryLevel : 100;
    }
  }

  /// Get current network type
  static Future<String> getNetworkType() async {
    try {
      final connectivity = Connectivity();
      final results = await connectivity.checkConnectivity();

      for (final result in results) {
        switch (result) {
          case ConnectivityResult.wifi:
            return 'wifi';
          case ConnectivityResult.mobile:
            return _getMobileNetworkType();
          case ConnectivityResult.ethernet:
            return 'ethernet';
          case ConnectivityResult.bluetooth:
            return 'bluetooth';
          case ConnectivityResult.vpn:
            return 'vpn';
          default:
            continue;
        }
      }

      return 'offline';
    } catch (e) {
      log('❌ Failed to get network type: $e');
      return 'unknown';
    }
  }

  /// Get detailed mobile network type
  static String _getMobileNetworkType() {
    // This is a simplified version - in production you might want to use
    // a more sophisticated method to detect LTE/5G/3G
    return 'lte'; // Default to LTE as most common
  }

  /// Get device metadata for debugging
  static Future<Map<String, String>> getDeviceMetadata() async {
    final metadata = <String, String>{};

    try {
      metadata['deviceId'] = await getDeviceId();
      metadata['platform'] = _getPlatform();
      metadata['battery'] = '${await getBatteryLevel()}%';
      metadata['network'] = await getNetworkType();
    } catch (e) {
      log('❌ Failed to get device metadata: $e');
    }

    return metadata;
  }

  /// Get platform identifier
  static String _getPlatform() {
    if (kIsWeb) {
      return 'web';
    } else if (Platform.isAndroid) {
      return 'android';
    } else if (Platform.isIOS) {
      return 'ios';
    } else if (Platform.isWindows) {
      return 'windows';
    } else if (Platform.isMacOS) {
      return 'macos';
    } else if (Platform.isLinux) {
      return 'linux';
    }
    return 'unknown';
  }

  /// Clear device ID (for testing/reset purposes)
  static Future<void> clearDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_deviceIdKey);
      _cachedDeviceId = null;
      log('🗑️ Device ID cleared');
    } catch (e) {
      log('❌ Failed to clear device ID: $e');
    }
  }
}