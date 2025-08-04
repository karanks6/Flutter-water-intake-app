import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Initialize notifications
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Request permissions
      await _requestPermissions();

      // Initialize plugin
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      _initialized = true;
      print('Notifications initialized successfully');
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  // Request notification permissions
  Future<void> _requestPermissions() async {
    try {
      // Request notification permission
      final status = await Permission.notification.request();
      
      if (status.isDenied) {
        print('Notification permission denied');
      } else if (status.isGranted) {
        print('Notification permission granted');
      }

      // For Android 13+, request post notifications permission
      if (status.isPermanentlyDenied) {
        print('Notification permission permanently denied');
        await openAppSettings();
      }
    } catch (e) {
      print('Error requesting permissions: $e');
    }
  }

  // Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');
    // Handle notification tap - could navigate to specific screen
  }

  // Schedule daily hydration reminder
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    String title = 'Hydration Reminder',
    String body = 'Time to drink some water! 💧',
  }) async {
    try {
      await _notifications.zonedSchedule(
        0, // Notification ID
        title,
        body,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'hydration_reminder',
            'Hydration Reminders',
            channelDescription: 'Daily reminders to drink water',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default.wav',
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        //uiLocalNotificationDateInterpretation:
          //  UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      print('Daily reminder scheduled for $hour:$minute');
    } catch (e) {
      print('Error scheduling daily reminder: $e');
    }
  }

  // Schedule multiple reminders throughout the day
  Future<void> scheduleMultipleReminders(List<Map<String, int>> times) async {
    try {
      // Cancel existing reminders
      await cancelAllReminders();
      for (int i = 0; i < times.length; i++) {
        final time = times[i];
        await _notifications.zonedSchedule(
          i, // Unique ID for each reminder
          'Hydration Reminder',
          'Don\'t forget to drink water! 💧',
          _nextInstanceOfTime(time['hour']!, time['minute']!),
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'hydration_reminder',
              'Hydration Reminders',
              channelDescription: 'Regular reminders to drink water',
              importance: Importance.high,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: DarwinNotificationDetails(
              sound: 'default.wav',
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

         // uiLocalNotificationDateInterpretation:
              //UILocalNotificationDateInterpretation.absoluteTime,
              
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
      print('Multiple reminders scheduled: ${times.length} reminders');
    } catch (e) {
      print('Error scheduling multiple reminders: $e');
    }
  }

  // Schedule hourly reminders during active hours
  Future<void> scheduleHourlyReminders({
    int startHour = 8,
    int endHour = 22,
  }) async {
    List<Map<String, int>> times = [];
    
    for (int hour = startHour; hour <= endHour; hour++) {
      times.add({'hour': hour, 'minute': 0});
    }
    
    await scheduleMultipleReminders(times);
  }

  // Show immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const notificationDetails = NotificationDetails(
        android: AndroidNotificationDetails(
          'water_intake',
          'Water Intake',
          channelDescription: 'Water intake notifications',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        notificationDetails,
        payload: payload,
      );
      print('Notification shown: $title');
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  // Show goal achievement notification
  Future<void> showGoalAchievedNotification(double intake, double goal) async {
    await showNotification(
      title: '🎉 Goal Achieved!',
      body: 'Great job! You\'ve reached your daily water intake goal of ${goal.toStringAsFixed(0)} ml!',
      payload: 'goal_achieved',
    );
  }

  // Show progress notification
  Future<void> showProgressNotification(double intake, double goal) async {
    final percentage = (intake / goal * 100).toStringAsFixed(0);
    await showNotification(
      title: 'Water Intake Progress',
      body: 'You\'ve consumed ${intake.toStringAsFixed(0)} ml today ($percentage% of your goal)',
      payload: 'progress_update',
    );
  }

  // Cancel all reminders
  Future<void> cancelAllReminders() async {
    try {
      await _notifications.cancelAll();
      print('All reminders cancelled');
    } catch (e) {
      print('Error cancelling reminders: $e');
    }
  }

  // Cancel specific reminder
  Future<void> cancelReminder(int id) async {
    try {
      await _notifications.cancel(id);
      print('Reminder $id cancelled');
    } catch (e) {
      print('Error cancelling reminder $id: $e');
    }
  }

  // Get next instance of specified time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking notification status: $e');
      return false;
    }
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      print('Error getting pending notifications: $e');
      return [];
    }
  }

  // Test notification
  Future<void> testNotification() async {
    await showNotification(
      title: 'Test Notification',
      body: 'This is a test notification to verify everything is working!',
    );
  }
}