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

    final androidImplementation = notificationPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
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

  // --- CLEAN INTEGRATED CANCELLATION METHOD ---
  // --- UPDATE THIS METHOD IN YOUR NOTIFICATION_SERVICE.DART ---
  Future<void> cancelNotification(int id) async {
    try {
      // FIX: Change from cancel(id) to cancel(id: id)
      await notificationPlugin.cancel(id: id);
      print('Notification with ID $id cancelled successfully.');
    } catch (e) {
      print('Error cancelling notification: $e');
    }
  } // <-- ADDED MISSING CLASS CLOSING BRACE
}
