import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../constants/app_constants.dart';

/// Service for handling local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Initialize notification service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      final result = await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _isInitialized = result ?? false;
      return _isInitialized;
    } catch (e) {
      return false;
    }
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    // Navigate to specific screen based on payload
    final payload = response.payload;
    if (payload != null) {
      // TODO: Navigate based on payload
      // e.g., Navigate to habit detail screen
    }
  }

  /// Request notification permissions (iOS)
  Future<bool> requestPermissions() async {
    if (!_isInitialized) await initialize();

    final result = await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    return result ?? true; // Android doesn't need runtime permission request
  }

  /// Schedule daily notification at specific time
  Future<void> scheduleDailyNotification({
    required int hour,
    required int minute,
    String? title,
    String? body,
    bool skipWeekends = false,
  }) async {
    if (!_isInitialized) await initialize();

    await cancelAllNotifications();

    final notificationTitle = title ?? 'Time to check your habits! 🎯';
    final notificationBody = body ?? 'Complete today\'s habits to keep your streak going';

    if (skipWeekends) {
      // Schedule for weekdays only (Monday to Friday)
      for (int day = DateTime.monday; day <= DateTime.friday; day++) {
        await _scheduleDayOfWeekNotification(
          id: day,
          day: day,
          hour: hour,
          minute: minute,
          title: notificationTitle,
          body: notificationBody,
        );
      }
    } else {
      // Schedule for every day
      await _scheduleDailyNotificationAtTime(
        hour: hour,
        minute: minute,
        title: notificationTitle,
        body: notificationBody,
      );
    }
  }

  /// Schedule notification for specific day of week
  Future<void> _scheduleDayOfWeekNotification({
    required int id,
    required int day,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Adjust to next occurrence of the specified day
    while (scheduledDate.weekday != day || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Schedule daily notification at specific time
  Future<void> _scheduleDailyNotificationAtTime({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
      AppConstants.defaultNotificationId,
      title,
      body,
      scheduledDate,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Show immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isInitialized) await initialize();

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      _notificationDetails(),
      payload: payload,
    );
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    if (!_isInitialized) await initialize();

    // Check platform-specific settings
    final androidImpl = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImpl != null) {
      final enabled = await androidImpl.areNotificationsEnabled();
      return enabled ?? false;
    }

    // For iOS, assume enabled if initialized
    return _isInitialized;
  }

  /// Notification details for all platforms
  NotificationDetails _notificationDetails() {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  /// Test notification (for debugging)
  Future<void> sendTestNotification() async {
    await showNotification(
      title: 'Test Notification',
      body: 'This is a test notification from Habit Tracker',
    );
  }
}
