import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Color;
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ──────────────────────────────────────────────────────────
  // Notification channel constants
  // ──────────────────────────────────────────────────────────
  static const String _reminderChannelId = 'hydration_reminder';
  static const String _reminderChannelName = 'Hydration Reminders';
  static const String _reminderChannelDesc =
      'Regular reminders to drink water throughout the day';

  static const String _immediateChannelId = 'water_intake';
  static const String _immediateChannelName = 'Water Intake Alerts';
  static const String _immediateChannelDesc =
      'Goal achievements and progress updates';

  // ──────────────────────────────────────────────────────────
  // Fun, engaging notification messages (shuffled each time)
  // ──────────────────────────────────────────────────────────
  static const List<Map<String, String>> _funMessages = [
    {
      'title': 'Water you waiting for? 💧',
      'body': 'Take a sip and keep your hydration stats high!',
    },
    {
      'title': 'Hydrate or Diedrate! 💀',
      'body':
          'Just kidding, but seriously, your body needs some H2O right now.',
    },
    {
      'title': 'Incoming call: Your Skin! 📞',
      'body': 'It wants a fresh glass of water. Shine bright! ✨',
    },
    {
      'title': 'Lubricate the machine! 🤖',
      'body': 'Time to add some liquid gold (water!) to the system.',
    },
    {
      'title': 'Gulp gulp gulp! 🍾',
      'body': 'Your water bottle is feeling lonely. Show it some love!',
    },
    {
      'title': 'Organ party! 🎉',
      'body':
          'Your kidneys are throwing a celebration, and water is the guest of honor!',
    },
    {
      'title': 'H2O = Life Energy 🔋',
      'body': 'Zero calories, 100% power-up. Recharge your battery now!',
    },
    {
      'title': 'Green with envy 🌿',
      'body': "Don't let your house plants be more hydrated than you are.",
    },
    {
      'title': 'Level Up! 🎮',
      'body': 'Drink a cup of water to boost your focus and energy stats.',
    },
    {
      'title': 'Paging Dr. Hydration 🩺',
      'body': 'Your prescription is ready: 250 ml of refreshing cold water.',
    },
    {
      'title': 'Be like water, my friend 🌊',
      'body': 'Keep flowing. Take a nice, big gulp of water.',
    },
    {
      'title': 'Organ Hug! 🧸',
      'body': 'Think of a glass of water as a refreshing hug for your body.',
    },
    {
      'title': '10% Cooler 😎',
      'body': 'Scientific fact: Drinking water makes you look and feel cooler.',
    },
    {
      'title': 'Drink & Shine 💎',
      'body': 'Keep your brain sharp and your body active. Sip time!',
    },
    {
      'title': 'Stay fine, hydrate! 🏆',
      'body': 'Hydrate like a champion today and crush your goals!',
    },
    {
      'title': 'Your brain is thirsty 🧠',
      'body':
          '75% of your brain is water. Feed the genius — drink up right now!',
    },
    {
      'title': 'Sip happens! 😄',
      'body': "Life's better when you're hydrated. Go grab a glass!",
    },
    {
      'title': 'You vs. Dehydration 🥊',
      'body': "Round 1: DRINK. You're winning this fight. Let's go!",
    },
    {
      'title': 'Aqua Alert 🚨',
      'body': "Your hydration levels are dropping. Emergency sip required!",
    },
    {
      'title': 'Freshness loading... 💦',
      'body': 'Add water to complete the refresh cycle. 100% hydration ahead!',
    },
  ];

  // ──────────────────────────────────────────────────────────
  // Initialization
  // ──────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;

    // Skip notifications on web/desktop — not supported
    if (kIsWeb) {
      _initialized = true;
      return;
    }

    try {
      // 1. Initialize timezones
      tz.initializeTimeZones();
      try {
        final String timeZoneName = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint('NotificationService: timezone set to $timeZoneName');
      } catch (e) {
        debugPrint(
            'NotificationService: timezone failed ($e), falling back to UTC');
        tz.setLocalLocation(tz.UTC);
      }

      // 2. Request runtime permissions
      await _requestPermissions();

      // 3. Configure Android notification channel (high importance + vibration + LED)
      final androidChannel = AndroidNotificationChannel(
        _reminderChannelId,
        _reminderChannelName,
        description: _reminderChannelDesc,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
        enableLights: true,
        ledColor: const Color.fromARGB(255, 0, 150, 255),
        showBadge: true,
      );

      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(androidChannel);
        debugPrint('NotificationService: Android channel created');
      }

      // 4. Initialize the plugin
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
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
      debugPrint('NotificationService: initialized successfully');
    } catch (e, stackTrace) {
      debugPrint(
          'NotificationService: initialization error — $e\n$stackTrace');
    }
  }

  // ──────────────────────────────────────────────────────────
  // Permission handling
  // ──────────────────────────────────────────────────────────

  Future<void> _requestPermissions() async {
    if (kIsWeb || !Platform.isAndroid) return;

    try {
      // POST_NOTIFICATIONS (Android 13 / API 33+)
      final notifStatus = await Permission.notification.request();
      debugPrint(
          'NotificationService: POST_NOTIFICATIONS = ${notifStatus.name}');

      if (notifStatus.isPermanentlyDenied) {
        debugPrint(
            'NotificationService: notification permission permanently denied — opening settings');
        await openAppSettings();
        return;
      }

      // SCHEDULE_EXACT_ALARM (Android 12 / API 31+)
      // Some OEMs (e.g., Xiaomi, Samsung) restrict this; we request it gracefully.
      try {
        final exactAlarmStatus =
            await Permission.scheduleExactAlarm.request();
        debugPrint(
            'NotificationService: SCHEDULE_EXACT_ALARM = ${exactAlarmStatus.name}');
      } catch (_) {
        // Permission not available on older APIs — safe to ignore
        debugPrint(
            'NotificationService: SCHEDULE_EXACT_ALARM not available on this API level');
      }
    } catch (e) {
      debugPrint('NotificationService: permission error — $e');
    }
  }

  // ──────────────────────────────────────────────────────────
  // Notification details builders
  // ──────────────────────────────────────────────────────────

  /// Full-featured Android notification details for reminders
  static AndroidNotificationDetails _androidReminderDetails() {
    return AndroidNotificationDetails(
      _reminderChannelId,
      _reminderChannelName,
      channelDescription: _reminderChannelDesc,
      importance: Importance.max,
      priority: Priority.max,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 200, 500]),
      enableLights: true,
      ledColor: const Color.fromARGB(255, 0, 150, 255),
      ledOnMs: 1000,
      ledOffMs: 500,
      autoCancel: true,
      // Ensures the notification appears on lock screen
      visibility: NotificationVisibility.public,
      // Wake the screen when notification fires
      fullScreenIntent: false,
    );
  }

  /// Lighter Android notification details for immediate/goal alerts
  static AndroidNotificationDetails _androidImmediateDetails() {
    return const AndroidNotificationDetails(
      _immediateChannelId,
      _immediateChannelName,
      channelDescription: _immediateChannelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      autoCancel: true,
      visibility: NotificationVisibility.public,
    );
  }

  static const DarwinNotificationDetails _iosDetails =
      DarwinNotificationDetails(
    sound: 'default.wav',
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  // ──────────────────────────────────────────────────────────
  // Scheduling helpers
  // ──────────────────────────────────────────────────────────

  /// Schedule with exact alarm if permitted, fall back to inexact automatically.
  /// This is the key to compatibility across strict OEM devices (Xiaomi, Oppo, etc.)
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    DateTimeComponents? matchDateTimeComponents,
    String? payload,
  }) async {
    final notifDetails = NotificationDetails(
      android: _androidReminderDetails(),
      iOS: _iosDetails,
    );

    // Try exact alarm first (most reliable, requires USE_EXACT_ALARM or SCHEDULE_EXACT_ALARM)
    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notifDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
        payload: payload,
      );
      debugPrint(
          'NotificationService: exact alarm scheduled (id=$id) for $scheduledDate');
      return;
    } catch (e) {
      debugPrint(
          'NotificationService: exact alarm failed (id=$id) — $e. Falling back to inexact.');
    }

    // Fallback: inexact alarm — works on ALL devices even without exact alarm permission
    try {
      await _notifications.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        notifDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: matchDateTimeComponents,
        payload: payload,
      );
      debugPrint(
          'NotificationService: inexact alarm scheduled (id=$id) for $scheduledDate');
    } catch (e) {
      debugPrint(
          'NotificationService: both scheduling modes failed (id=$id) — $e');
    }
  }

  // ──────────────────────────────────────────────────────────
  // Public API
  // ──────────────────────────────────────────────────────────

  /// Schedule a single daily repeating reminder at [hour]:[minute].
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
    String title = 'Hydration Reminder',
    String body = 'Time to drink some water! 💧',
  }) async {
    await _scheduleNotification(
      id: 0,
      title: title,
      body: body,
      scheduledDate: _nextInstanceOfTime(hour, minute),
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint('NotificationService: daily reminder scheduled at $hour:$minute');
  }

  /// Schedule multiple reminders throughout the day.
  /// Each reminder gets a unique fun message (shuffled for variety).
  Future<void> scheduleMultipleReminders(
      List<Map<String, int>> times) async {
    await cancelAllReminders();

    // Shuffle for variety — each reminder gets a different message
    final messageList = List<Map<String, String>>.from(_funMessages)..shuffle();

    for (int i = 0; i < times.length; i++) {
      final time = times[i];
      final message = messageList[i % messageList.length];

      await _scheduleNotification(
        id: i,
        title: message['title']!,
        body: message['body']!,
        scheduledDate:
            _nextInstanceOfTime(time['hour']!, time['minute']!),
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    debugPrint(
        'NotificationService: ${times.length} reminders scheduled');
  }

  /// Schedule hourly reminders between [startHour] and [endHour].
  Future<void> scheduleHourlyReminders({
    int startHour = 8,
    int endHour = 22,
  }) async {
    final List<Map<String, int>> times = [];
    for (int hour = startHour; hour <= endHour; hour++) {
      times.add({'hour': hour, 'minute': 0});
    }
    await scheduleMultipleReminders(times);
  }

  /// Show an immediate (non-scheduled) notification right now.
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      final notifDetails = NotificationDetails(
        android: _androidImmediateDetails(),
        iOS: _iosDetails,
      );

      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        notifDetails,
        payload: payload,
      );
      debugPrint('NotificationService: immediate notification shown — $title');
    } catch (e) {
      debugPrint('NotificationService: showNotification error — $e');
    }
  }

  /// Show a fun goal-achieved notification.
  Future<void> showGoalAchievedNotification(
      double intake, double goal) async {
    const funGoalMessages = [
      'You did it! Fully hydrated and ready to conquer the world! 🌊🏆',
      'Goal crushed! Your body is officially floating in pure goodness! 🎉💧',
      '100% Hydrated! You are officially a hydration superstar! 🌟💦',
      'Mission Accomplished! Hydration level maximum! 🚀🔋',
      'You absolute legend! Daily water goal SMASHED! 💪🌊',
    ];
    final body =
        funGoalMessages[DateTime.now().second % funGoalMessages.length];
    await showNotification(
      title: '🎉 Goal Achieved!',
      body: body,
      payload: 'goal_achieved',
    );
  }

  /// Show a water intake progress notification.
  Future<void> showProgressNotification(
      double intake, double goal) async {
    final percentage = (intake / goal * 100).toStringAsFixed(0);
    await showNotification(
      title: 'Water Intake Progress 💧',
      body:
          "You've consumed ${intake.toStringAsFixed(0)} ml today ($percentage% of your goal)",
      payload: 'progress_update',
    );
  }

  /// Cancel all scheduled reminders.
  Future<void> cancelAllReminders() async {
    try {
      await _notifications.cancelAll();
      debugPrint('NotificationService: all reminders cancelled');
    } catch (e) {
      debugPrint('NotificationService: cancelAll error — $e');
    }
  }

  /// Cancel a specific reminder by ID.
  Future<void> cancelReminder(int id) async {
    try {
      await _notifications.cancel(id);
      debugPrint('NotificationService: reminder $id cancelled');
    } catch (e) {
      debugPrint('NotificationService: cancel($id) error — $e');
    }
  }

  /// Returns true if notification permission is granted.
  Future<bool> areNotificationsEnabled() async {
    try {
      if (kIsWeb) return false;
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (e) {
      debugPrint('NotificationService: areNotificationsEnabled error — $e');
      return false;
    }
  }

  /// Returns true if exact alarm permission is granted (Android 12+).
  Future<bool> canScheduleExactAlarms() async {
    try {
      if (kIsWeb || !Platform.isAndroid) return false;
      final androidPlugin =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin == null) return false;
      return await androidPlugin.canScheduleExactNotifications() ?? false;
    } catch (e) {
      debugPrint('NotificationService: canScheduleExactAlarms error — $e');
      return false;
    }
  }

  /// List all currently pending scheduled notifications (for debugging).
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('NotificationService: getPendingNotifications error — $e');
      return [];
    }
  }

  /// Fire a test notification immediately to verify the setup.
  Future<void> testNotification() async {
    await showNotification(
      title: '✅ Notification Test',
      body: 'Aqua Log notifications are working on your device!',
    );
  }

  // ──────────────────────────────────────────────────────────
  // Private helpers
  // ──────────────────────────────────────────────────────────

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint(
        'NotificationService: tapped — id=${response.id}, payload=${response.payload}');
  }

  /// Returns the next occurrence of [hour]:[minute] in local time.
  /// If that time has already passed today, schedules for tomorrow.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    return scheduled;
  }
}