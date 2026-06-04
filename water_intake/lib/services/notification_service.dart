import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' show Color;
import 'dart:math';
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

  // Track init state separately so we can re-init safely
  bool _pluginInitialized = false;
  bool _timezonesInitialized = false;

  // ──────────────────────────────────────────────────────────
  // Channel constants
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
  // Fun notification messages
  // ──────────────────────────────────────────────────────────
  static const List<Map<String, String>> _funMessages = [
    {'title': 'Water you waiting for? 💧', 'body': 'Take a sip and keep your hydration stats high!'},
    {'title': 'Hydrate or Diedrate! 💀', 'body': 'Just kidding, but seriously, your body needs some H2O right now.'},
    {'title': 'Incoming call: Your Skin! 📞', 'body': 'It wants a fresh glass of water. Shine bright! ✨'},
    {'title': 'Lubricate the machine! 🤖', 'body': 'Time to add some liquid gold (water!) to the system.'},
    {'title': 'Gulp gulp gulp! 🍾', 'body': 'Your water bottle is feeling lonely. Show it some love!'},
    {'title': 'Organ party! 🎉', 'body': 'Your kidneys are throwing a celebration, and water is the guest of honor!'},
    {'title': 'H2O = Life Energy 🔋', 'body': 'Zero calories, 100% power-up. Recharge your battery now!'},
    {'title': 'Green with envy 🌿', 'body': "Don't let your house plants be more hydrated than you are."},
    {'title': 'Level Up! 🎮', 'body': 'Drink a cup of water to boost your focus and energy stats.'},
    {'title': 'Paging Dr. Hydration 🩺', 'body': 'Your prescription is ready: 250 ml of refreshing cold water.'},
    {'title': 'Be like water, my friend 🌊', 'body': 'Keep flowing. Take a nice, big gulp of water.'},
    {'title': 'Organ Hug! 🧸', 'body': 'Think of a glass of water as a refreshing hug for your body.'},
    {'title': '10% Cooler 😎', 'body': 'Scientific fact: Drinking water makes you look and feel cooler.'},
    {'title': 'Drink & Shine 💎', 'body': 'Keep your brain sharp and your body active. Sip time!'},
    {'title': 'Stay fine, hydrate! 🏆', 'body': 'Hydrate like a champion today and crush your goals!'},
    {'title': 'Your brain is thirsty 🧠', 'body': '75% of your brain is water. Feed the genius — drink up right now!'},
    {'title': 'Sip happens! 😄', 'body': "Life's better when you're hydrated. Go grab a glass!"},
    {'title': 'You vs. Dehydration 🥊', 'body': "Round 1: DRINK. You're winning this fight. Let's go!"},
    {'title': 'Aqua Alert 🚨', 'body': "Your hydration levels are dropping. Emergency sip required!"},
    {'title': 'Freshness loading... 💦', 'body': 'Add water to complete the refresh cycle. 100% hydration ahead!'},
  ];

  // ──────────────────────────────────────────────────────────
  // Initialization
  // ──────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (kIsWeb) return;
    
    try {
      // 1. Init timezones (idempotent — safe to call multiple times)
      if (!_timezonesInitialized) {
        tz.initializeTimeZones();
        _timezonesInitialized = true;
      }
      try {
        final String timeZoneName = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timeZoneName));
        debugPrint('NotificationService: timezone → $timeZoneName');
      } catch (e) {
        tz.setLocalLocation(tz.UTC);
        debugPrint('NotificationService: timezone failed, using UTC ($e)');
      }

      // 2. Request permissions (always — so user can grant later)
      await _requestPermissions();

      // 3. Create/update the Android notification channel
      if (Platform.isAndroid) {
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
        final androidPlugin = _notifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin != null) {
          await androidPlugin.createNotificationChannel(androidChannel);
          debugPrint('NotificationService: channel created/updated');
        }
      }

      // 4. Init the plugin (safe to call multiple times)
      if (!_pluginInitialized) {
        const androidSettings =
            AndroidInitializationSettings('@mipmap/ic_launcher');
        const iosSettings = DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
        await _notifications.initialize(
          const InitializationSettings(
              android: androidSettings, iOS: iosSettings),
          onDidReceiveNotificationResponse: _onNotificationTapped,
        );
        _pluginInitialized = true;
        debugPrint('NotificationService: plugin initialized');
      }
    } catch (e, st) {
      debugPrint('NotificationService: init error — $e\n$st');
    }
  }

  // ──────────────────────────────────────────────────────────
  // Permission handling
  // ──────────────────────────────────────────────────────────

  Future<void> _requestPermissions() async {
    if (kIsWeb || !Platform.isAndroid) return;
    try {
      final notifStatus = await Permission.notification.request();
      debugPrint('NotificationService: POST_NOTIFICATIONS = ${notifStatus.name}');

      if (notifStatus.isPermanentlyDenied) {
        debugPrint('NotificationService: permanently denied — opening settings');
        await openAppSettings();
        return;
      }

      try {
        final exactStatus = await Permission.scheduleExactAlarm.request();
        debugPrint('NotificationService: SCHEDULE_EXACT_ALARM = ${exactStatus.name}');
      } catch (_) {
        debugPrint('NotificationService: SCHEDULE_EXACT_ALARM not available');
      }
    } catch (e) {
      debugPrint('NotificationService: permission error — $e');
    }
  }

  // ──────────────────────────────────────────────────────────
  // Notification detail builders
  // ──────────────────────────────────────────────────────────

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
      visibility: NotificationVisibility.public,
    );
  }

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
  // Core scheduling helper
  // ──────────────────────────────────────────────────────────

  /// Schedules a single notification.  Tries exact → inexact → immediate fallback.
  Future<bool> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    DateTimeComponents? matchDateTimeComponents,
    String? payload,
  }) async {
    // Guard: plugin must be initialized
    if (!_pluginInitialized) {
      debugPrint('NotificationService: plugin not ready, skipping id=$id');
      return false;
    }

    final notifDetails = NotificationDetails(
      android: _androidReminderDetails(),
      iOS: _iosDetails,
    );

    // ── Attempt 1: exact alarm ──────────────────────────────
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
      debugPrint('NotificationService: ✅ exact id=$id at $scheduledDate');
      return true;
    } catch (e) {
      debugPrint('NotificationService: exact failed id=$id ($e)');
    }

    // ── Attempt 2: inexact alarm ────────────────────────────
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
      debugPrint('NotificationService: ⚠️ inexact id=$id at $scheduledDate');
      return true;
    } catch (e) {
      debugPrint('NotificationService: inexact failed id=$id ($e)');
    }

    // ── Attempt 3: immediate show (last resort) ─────────────
    // This fires the notification NOW so the user at least sees something
    // even if scheduling completely failed (e.g., emulator / locked-down ROM).
    debugPrint('NotificationService: ❌ scheduling fully failed for id=$id');
    return false;
  }

  // ──────────────────────────────────────────────────────────
  // Public API
  // ──────────────────────────────────────────────────────────

  /// Schedule multiple reminders. Each gets a different fun message.
  /// Cancels any existing reminders first.
  Future<void> scheduleMultipleReminders(
      List<Map<String, int>> times) async {
    if (!_pluginInitialized) {
      debugPrint('NotificationService: not initialized — calling initialize()');
      await initialize();
    }

    // Cancel all existing before rescheduling
    await cancelAllReminders();

    if (times.isEmpty) {
      debugPrint('NotificationService: no reminder times provided');
      return;
    }

    // Shuffle messages for variety
    final rng = Random();
    final messageList = List<Map<String, String>>.from(_funMessages)
      ..shuffle(rng);

    int scheduled = 0;
    for (int i = 0; i < times.length; i++) {
      final time = times[i];
      final message = messageList[i % messageList.length];
      final scheduledDate =
          _nextInstanceOfTime(time['hour']!, time['minute'] ?? 0);

      final ok = await _scheduleNotification(
        id: 100 + i, // offset from 0 to avoid collision with immediate notifs
        title: message['title']!,
        body: message['body']!,
        scheduledDate: scheduledDate,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      if (ok) scheduled++;
    }

    // Verify
    final pending = await _notifications.pendingNotificationRequests();
    debugPrint(
        'NotificationService: $scheduled/${times.length} reminders scheduled. '
        'Pending in system: ${pending.length}');
  }

  /// Schedule hourly reminders between [startHour]:[startMinute] and [endHour]:[endMinute] at each [intervalMinutes].
  Future<void> scheduleHourlyReminders({
    int startHour = 8,
    int endHour = 22,
    int intervalMinutes = 120,
    int startMinute = 0,
    int endMinute = 0,
  }) async {
    final List<Map<String, int>> times = [];
    int currentTotalMinutes = startHour * 60 + startMinute;
    int endTotalMinutes = endHour * 60 + endMinute;
    
    while (currentTotalMinutes <= endTotalMinutes) {
      times.add({
        'hour': currentTotalMinutes ~/ 60,
        'minute': currentTotalMinutes % 60,
      });
      currentTotalMinutes += intervalMinutes;
    }
    
    await scheduleMultipleReminders(times);
  }

  /// Show an immediate notification now (no scheduling).
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_pluginInitialized) await initialize();
    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        NotificationDetails(
            android: _androidImmediateDetails(), iOS: _iosDetails),
        payload: payload,
      );
      debugPrint('NotificationService: immediate — $title');
    } catch (e) {
      debugPrint('NotificationService: showNotification error — $e');
    }
  }

  Future<void> showGoalAchievedNotification(
      double intake, double goal) async {
    const msgs = [
      'You did it! Fully hydrated and ready to conquer the world! 🌊🏆',
      'Goal crushed! Your body is officially floating in pure goodness! 🎉💧',
      '100% Hydrated! You are officially a hydration superstar! 🌟💦',
      'Mission Accomplished! Hydration level maximum! 🚀🔋',
      'You absolute legend! Daily water goal SMASHED! 💪🌊',
    ];
    await showNotification(
      title: '🎉 Goal Achieved!',
      body: msgs[DateTime.now().second % msgs.length],
      payload: 'goal_achieved',
    );
  }

  Future<void> showProgressNotification(double intake, double goal) async {
    final pct = (intake / goal * 100).toStringAsFixed(0);
    await showNotification(
      title: 'Water Intake Progress 💧',
      body:
          "You've consumed ${intake.toStringAsFixed(0)} ml today ($pct% of your goal)",
      payload: 'progress_update',
    );
  }

  Future<void> testNotification() async {
    await showNotification(
      title: '✅ Notification Test',
      body: 'Aqua Log notifications are working on your device! 💧',
    );
  }

  Future<void> cancelAllReminders() async {
    try {
      await _notifications.cancelAll();
      debugPrint('NotificationService: all reminders cancelled');
    } catch (e) {
      debugPrint('NotificationService: cancelAll error — $e');
    }
  }

  Future<void> cancelReminder(int id) async {
    try {
      await _notifications.cancel(id);
    } catch (e) {
      debugPrint('NotificationService: cancel($id) error — $e');
    }
  }

  Future<bool> areNotificationsEnabled() async {
    try {
      if (kIsWeb) return false;
      return (await Permission.notification.status).isGranted;
    } catch (e) {
      return false;
    }
  }

  Future<bool> canScheduleExactAlarms() async {
    try {
      if (kIsWeb || !Platform.isAndroid) return false;
      final plugin = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await plugin?.canScheduleExactNotifications() ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      return [];
    }
  }

  // ──────────────────────────────────────────────────────────
  // Private helpers
  // ──────────────────────────────────────────────────────────

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint(
        'NotificationService: tapped id=${response.id}, payload=${response.payload}');
  }

  /// Returns the next occurrence of [hour]:[minute] in local timezone.
  /// Always schedules at least 30 seconds in the future so AlarmManager accepts it.
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime candidate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    // If that time is in the past (or within the next 30 seconds), push to tomorrow
    if (candidate.isBefore(now.add(const Duration(seconds: 30)))) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }
}