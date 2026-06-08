import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final notificationPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  factory NotificationService() => _instance;
  NotificationService._internal();

  bool get isInitialized => _isInitialized;

  Future<void> initializeNotification() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await notificationPlugin.initialize(settings: settings);

    // Resolve the Android implementation to request runtime permissions
    final androidImplementation = notificationPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      // 1. Request standard notification permissions (Android 13+)
      await androidImplementation.requestNotificationsPermission();

      // 2. --- ADD THIS TO PREVENT CRASHES ON ANDROID 12+ ---
      // Request permission to fire exact alarms for task deadlines
      await androidImplementation.requestExactAlarmsPermission();
    }

    _isInitialized = true;
    print('Notification service initialized');
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'channelId',
        'channelName',
        channelDescription: 'App notifications',
        importance: Importance.max,
        priority: Priority.high,
        showProgress: false,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  Future<void> scheduleTaskExpiryNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    // Prevent scheduling if the deadline has already passed
    if (scheduledTime.isBefore(DateTime.now())) return;

    try {
      await notificationPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tz.TZDateTime.from(scheduledTime, tz.local),
        notificationDetails: _notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dateAndTime,
      );
      print('Notification successfully scheduled for $title at $scheduledTime');
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }
}
