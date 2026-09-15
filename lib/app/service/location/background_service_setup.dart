import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Background service configuration and setup
/// Handles the initialization and configuration of the native background service
class BackgroundServiceSetup {
  static const String _channelId = "location_tracking_channel";

  /// Initialize and configure the background service
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        onStart: _onStart,
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: _channelId,
        initialNotificationTitle: 'Location Tracking',
        initialNotificationContent: 'Initializing location tracking...',
        foregroundServiceNotificationId: 2001,
        foregroundServiceTypes: [AndroidForegroundType.location],
      ),
    );

    debugPrint('✅ Background service configured');
  }

  /// Start the background service
  static Future<void> startService() async {
    final service = FlutterBackgroundService();
    await service.startService();
    debugPrint('🚀 Background service started');
  }

  /// Stop the background service
  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke('stopService');
    debugPrint('🛑 Background service stop command sent');
  }

  /// Check if service is running
  static Future<bool> isServiceRunning() async {
    final service = FlutterBackgroundService();
    return await service.isRunning();
  }

  /// Service start callback (runs on both platforms)
  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
    debugPrint('🎯 Background service onStart called');

    // Set up communication handler
    service.on('setUserdata').listen((event) {
      debugPrint('📱 Received user data: $event');
    });

    service.on('stopService').listen((event) {
      debugPrint('🛑 Received stop service command');
      service.stopSelf();
    });

    // Bring service to foreground
    if (service is AndroidServiceInstance) {
      service.setAsForegroundService();
    }

    // Keep service alive with periodic timer
    Timer.periodic(Duration(seconds: 5), (timer) async {
      // Update notification with current status
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? 'Field Agent';
      final lastLocation = prefs.getString('last_location_time');

      if (service is AndroidServiceInstance) {
        service.setForegroundNotificationInfo(
          title: 'Location Tracking - $username',
          content: lastLocation != null
              ? 'Last update: $lastLocation'
              : 'Waiting for location...',
        );
      }
    });
  }

  /// iOS background callback
  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    debugPrint('🍎 iOS background callback');
    return true; // Return true to keep background task alive
  }

  /// Send data from native to Flutter
  static void sendDataToFlutter(Map<String, dynamic> data) {
    final service = FlutterBackgroundService();
    service.invoke('locationUpdate', data);
  }

  /// Invoke method from Flutter to native
  static void invokeMethod(String method, [Map<String, dynamic>? data]) {
    final service = FlutterBackgroundService();
    service.invoke(method, data);
  }
}