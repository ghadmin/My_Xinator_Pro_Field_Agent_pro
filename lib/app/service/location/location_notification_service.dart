import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Service for showing local notifications about location tracking status
class LocationNotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // Notification IDs
  static const int _staleWarningId = 1001;
  static const int _staleCriticalId = 1002;
  static const int _syncRestoredId = 1003;
  static const int _trackingStartedId = 1004;
  static const int _trackingStoppedId = 1005;

  // Notification channel IDs
  static const String _channelId = 'location_tracking_channel';
  static const String _channelName = 'Location Tracking';
  static const String _channelDescription = 'Notifications for location tracking status';

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(settings: 
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );  

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      ledColor: null, // Use default
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _isInitialized = true;
    log('📱 LocationNotificationService initialized');
  }

  /// Show warning notification when location hasn't synced for 10+ minutes
  Future<void> showStaleLocationWarning(Duration timeSinceSync) async {
    _ensureInitialized();

    const String title = 'Location Not Syncing';
    final String body = 'Your location has not been synced for '
        '${_formatDuration(timeSinceSync)}. Please check your internet connection.';

    await _showNotification(
      id: _staleWarningId,
      title: title,
      body: body,
      importance: Importance.high,
      priority: Priority.high,
    );
  }

  /// Show critical notification when location hasn't synced for 30+ minutes
  Future<void> showCriticalLocationStale(Duration timeSinceSync) async {
    _ensureInitialized();

    const String title = 'Location Sync Problem';
    final String body = 'Your location has not been synced for '
        '${_formatDuration(timeSinceSync)}. This may affect your field tracking.';

    await _showNotification(
      id: _staleCriticalId,
      title: title,
      body: body,
      importance: Importance.max,
      priority: Priority.max,
    );
  }

  /// Show notification when sync is restored after being stale
  Future<void> showSyncRestored() async {
    _ensureInitialized();

    const String title = 'Location Syncing Restored';
    const String body = 'Your location is being synced again.';

    await _showNotification(
      id: _syncRestoredId,
      title: title,
      body: body,
      importance: Importance.high,
      priority: Priority.high,
    );
  }

  /// Show notification when tracking starts
  Future<void> showTrackingStarted() async {
    _ensureInitialized();

    const String title = 'Location Tracking Started';
    const String body = 'Your location is now being tracked in the background.';

    await _showNotification(
      id: _trackingStartedId,
      title: title,
      body: body,
      importance: Importance.high,
      priority: Priority.high,
    );
  }

  /// Show notification when tracking stops
  Future<void> showTrackingStopped() async {
    _ensureInitialized();

    const String title = 'Location Tracking Stopped';
    const String body = 'Your location is no longer being tracked.';

    await _showNotification(
      id: _trackingStoppedId,
      title: title,
      body: body,
      importance: Importance.low,
      priority: Priority.low,
    );
  }

  /// Cancel all location tracking notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
    log('📱 All location tracking notifications cancelled');
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id:id);
  }

  /// Show notification helper method
  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    Importance importance = Importance.high,
    Priority priority = Priority.high,
  }) async {
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: importance,
        priority: priority,
        showWhen: true,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _notificationsPlugin.show(
     id: id,
     title: title,
    body:  body,
      
    );

    log('📱 Notification shown: $title');
  }

  /// Handle notification tap
  void _onNotificationTap(NotificationResponse response) {
    log('📱 Notification tapped: ${response.payload}');
    // TODO: Navigate to appropriate screen when notification is tapped
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (minutes > 0) {
        return '$hours hour${hours > 1 ? 's' : ''} and $minutes minute${minutes > 1 ? 's' : ''}';
      }
      return '$hours hour${hours > 1 ? 's' : ''}';
    } else {
      final minutes = duration.inMinutes;
      return '$minutes minute${minutes > 1 ? 's' : ''}';
    }
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'LocationNotificationService is not initialized. Call initialize() first.'
      );
    }
  }

  /// Check if notifications are permitted
  Future<bool> areNotificationsPermitted() async {
    _ensureInitialized();

    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Android 13+ requires explicit permission
      final result = await androidPlugin.areNotificationsEnabled();
      return result ?? true;
    }

    return true;
  }

  /// Request notification permissions (especially for Android 13+)
  Future<bool> requestPermissions() async {
    _ensureInitialized();

    final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final result = await androidPlugin.requestNotificationsPermission();
      return result ?? true;
    }

    return true;
  }
}