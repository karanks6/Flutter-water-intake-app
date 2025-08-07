import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/intake_entry.dart';
import '../services/notification_service.dart';


class IntakeProvider with ChangeNotifier {
  List<IntakeEntry> _entries = [];
  double _dailyTarget = 2000.0; // Default 2L
  bool _notificationsEnabled = true;
  int _reminderStartHour = 8;
  int _reminderEndHour = 22;
  int _reminderInterval = 2; // hours
  bool _goalAchievedToday = false;
  
  // Add these new properties for minutes support
  int _reminderStartMinute = 0;
  int _reminderEndMinute = 0;
  
  final NotificationService _notificationService = NotificationService();

  // Getters
  List<IntakeEntry> get entries => _entries;
  double get dailyTarget => _dailyTarget;
  bool get notificationsEnabled => _notificationsEnabled;
  int get reminderStartHour => _reminderStartHour;
  int get reminderEndHour => _reminderEndHour;
  int get reminderInterval => _reminderInterval;
  int get reminderStartMinute => _reminderStartMinute;
  int get reminderEndMinute => _reminderEndMinute;

  // Update notification settings
  Future<void> updateNotificationSettings({
    bool? enabled,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    int? interval,
  }) async {
    if (enabled != null) _notificationsEnabled = enabled;
    if (startHour != null) _reminderStartHour = startHour;
    if (startMinute != null) _reminderStartMinute = startMinute;
    if (endHour != null) _reminderEndHour = endHour;
    if (endMinute != null) _reminderEndMinute = endMinute;
    if (interval != null) _reminderInterval = interval;
    
    await _saveData();
    await _setupReminders();
    notifyListeners();
  }

  // Method to calculate current streak correctly
  int calculateCurrentStreak() {
    if (_entries.isEmpty) return 0;
    
    final now = DateTime.now();
    int streak = 0;
    
    // Check consecutive days starting from today
    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final intake = getDailyIntake(date);
      
      if (intake >= _dailyTarget) {
        streak++;
      } else {
        // If it's today and no intake yet, don't break the streak
        if (i == 0 && intake == 0) {
          continue;
        }
        break;
      }
    }
    
    return streak;
  }

  // Get statistics with corrected streak calculation
  Map<String, dynamic> getStatistics() {
    if (_entries.isEmpty) {
      return {
        'totalDays': 0,
        'totalIntake': 0.0,
        'averageDaily': 0.0,
        'bestDay': 0.0,
        'streak': 0,
        'goalsAchieved': 0,
        'totalEntries': 0,
      };
    }

    final sortedEntries = List<IntakeEntry>.from(_entries)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final firstEntry = sortedEntries.first;
    final lastEntry = sortedEntries.last;
    final totalDays = lastEntry.timestamp.difference(firstEntry.timestamp).inDays + 1;
    final totalIntake = _entries.fold(0.0, (sum, entry) => sum + entry.amount);

    // Calculate best day
    final dailyIntakes = <String, double>{};
    for (final entry in _entries) {
      final dateKey = '${entry.timestamp.year}-${entry.timestamp.month}-${entry.timestamp.day}';
      dailyIntakes[dateKey] = (dailyIntakes[dateKey] ?? 0.0) + entry.amount;
    }
    final bestDay = dailyIntakes.values.isNotEmpty 
        ? dailyIntakes.values.reduce((a, b) => a > b ? a : b) 
        : 0.0;

    // Use the corrected streak calculation
    int streak = calculateCurrentStreak();

    // Calculate goals achieved
    int goalsAchieved = 0;
    for (final dateKey in dailyIntakes.keys) {
      if (dailyIntakes[dateKey]! >= _dailyTarget) {
        goalsAchieved++;
      }
    }

    return {
      'totalDays': totalDays,
      'totalIntake': totalIntake,
      'averageDaily': totalIntake / totalDays,
      'bestDay': bestDay,
      'streak': streak,
      'goalsAchieved': goalsAchieved,
      'totalEntries': _entries.length,
    };
  }

  // Set up reminders based on current settings
  Future<void> _setupReminders() async {
    if (!_notificationsEnabled) {
      await _notificationService.cancelAllReminders();
      return;
    }

    // Create reminder times based on interval
    List<Map<String, int>> reminderTimes = [];
    for (int hour = _reminderStartHour; hour <= _reminderEndHour; hour += _reminderInterval) {
      reminderTimes.add({
        'hour': hour, 
        'minute': hour == _reminderStartHour ? _reminderStartMinute : 0
      });
    }

    await _notificationService.scheduleMultipleReminders(reminderTimes);
  }

  // Get today's entries
  List<IntakeEntry> get todayEntries {
    final today = DateTime.now();
    return _entries.where((entry) {
      return entry.timestamp.year == today.year &&
          entry.timestamp.month == today.month &&
          entry.timestamp.day == today.day;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Get today's total intake
  double get todayIntake {
    return todayEntries.fold(0.0, (sum, entry) => sum + entry.amount);
  }

  // Get today's progress as percentage
  double get todayProgress {
    return (todayIntake / _dailyTarget).clamp(0.0, 1.0);
  }

  // Check if goal is achieved
  bool get isGoalAchieved => todayIntake >= _dailyTarget;

  // Initialize provider
  Future<void> initialize() async {
    try {
      await _loadData();
      await _notificationService.initialize();
      await _setupReminders();
      print('IntakeProvider initialized successfully');
    } catch (e) {
      print('Error initializing IntakeProvider: $e');
    }
  }

  // Add new entry
  void addEntry(double amount, String note, DateTime timestamp) {
    final previousIntake = todayIntake;
    final wasGoalAchieved = isGoalAchieved;
    
    final entry = IntakeEntry(
      amount: amount,
      timestamp: timestamp,
      note: note,
    );
    _entries.add(entry);
    
    // Check if goal was just achieved
    if (!wasGoalAchieved && isGoalAchieved && !_goalAchievedToday) {
      _goalAchievedToday = true;
      _notificationService.showGoalAchievedNotification(todayIntake, _dailyTarget);
    }
    
    _saveData();
    notifyListeners();
  }

  // Add quick entry (current time)
  void addQuickEntry(double amount) {
    addEntry(amount, '', DateTime.now());
  }

  // Update existing entry
  void updateEntry(String id, double amount, String note, DateTime timestamp) {
    final index = _entries.indexWhere((entry) => entry.id == id);
    if (index != -1) {
      _entries[index] = IntakeEntry(
        id: id,
        amount: amount,
        timestamp: timestamp,
        note: note,
      );
      _saveData();
      notifyListeners();
    }
  }

  // Delete entry
  void deleteEntry(IntakeEntry entry) {
    _entries.removeWhere((e) => e.id == entry.id);
    _saveData();
    notifyListeners();
  }

  // Get entries for specific date
  List<IntakeEntry> getEntriesForDate(DateTime date) {
    return _entries.where((entry) {
      return entry.timestamp.year == date.year &&
          entry.timestamp.month == date.month &&
          entry.timestamp.day == date.day;
    }).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  // Get daily intake for specific date
  double getDailyIntake(DateTime date) {
    return getEntriesForDate(date)
        .fold(0.0, (sum, entry) => sum + entry.amount);
  }

  // Get weekly data for chart
  List<Map<String, dynamic>> getWeeklyData() {
    final List<Map<String, dynamic>> weeklyData = [];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final intake = getDailyIntake(date);
      
      weeklyData.add({
        'day': _getDayName(date.weekday),
        'intake': intake,
        'date': date,
        'progress': (intake / _dailyTarget).clamp(0.0, 1.0),
      });
    }
    
    return weeklyData;
  }

  // Get monthly data
  List<Map<String, dynamic>> getMonthlyData() {
    final List<Map<String, dynamic>> monthlyData = [];
    final now = DateTime.now();
    
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final intake = getDailyIntake(date);
      
      monthlyData.add({
        'day': date.day,
        'intake': intake,
        'date': date,
        'progress': (intake / _dailyTarget).clamp(0.0, 1.0),
      });
    }
    
    return monthlyData;
  }

  // Update daily target
  void updateDailyTarget(double target) {
    _dailyTarget = target;
    _saveData();
    notifyListeners();
  }

  // Test notification
  Future<void> testNotification() async {
    await _notificationService.testNotification();
  }

  // Show progress notification
  Future<void> showProgressNotification() async {
    await _notificationService.showProgressNotification(todayIntake, _dailyTarget);
  }

  // Clear all data
  void clearAllData() {
    _entries.clear();
    _goalAchievedToday = false;
    _saveData();
    notifyListeners();
  }

  // Reset daily goal achieved flag (call this at start of new day)
  void resetDailyFlags() {
    _goalAchievedToday = false;
  }

  // Private helper methods
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save entries
      final entriesJson = _entries.map((entry) => entry.toMap()).toList();
      await prefs.setString('intake_entries', json.encode(entriesJson));
      
      // Save daily target
      await prefs.setDouble('daily_target', _dailyTarget);
      
      // Save notification settings
      await prefs.setBool('notifications_enabled', _notificationsEnabled);
      await prefs.setInt('reminder_start_hour', _reminderStartHour);
      await prefs.setInt('reminder_start_minute', _reminderStartMinute);
      await prefs.setInt('reminder_end_hour', _reminderEndHour);
      await prefs.setInt('reminder_end_minute', _reminderEndMinute);
      await prefs.setInt('reminder_interval', _reminderInterval);
      
      // Save daily flags
      await prefs.setBool('goal_achieved_today', _goalAchievedToday);
      await prefs.setString('last_save_date', DateTime.now().toIso8601String());
      
      print('Data saved successfully');
    } catch (e) {
      print('Error saving data: $e');
    }
  }

  // Load data from SharedPreferences
  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load entries
      final entriesString = prefs.getString('intake_entries');
      if (entriesString != null) {
        final entriesJson = json.decode(entriesString) as List;
        _entries = entriesJson
            .map((json) => IntakeEntry.fromMap(json))
            .toList();
      }
      
      // Load daily target
      _dailyTarget = prefs.getDouble('daily_target') ?? 2000.0;
      
      // Load notification settings
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _reminderStartHour = prefs.getInt('reminder_start_hour') ?? 8;
      _reminderStartMinute = prefs.getInt('reminder_start_minute') ?? 0;
      _reminderEndHour = prefs.getInt('reminder_end_hour') ?? 22;
      _reminderEndMinute = prefs.getInt('reminder_end_minute') ?? 0;
      _reminderInterval = prefs.getInt('reminder_interval') ?? 2;
      
      // Load daily flags and check if it's a new day
      final lastSaveDate = prefs.getString('last_save_date');
      if (lastSaveDate != null) {
        final lastSave = DateTime.parse(lastSaveDate);
        final today = DateTime.now();
        
        // If it's a new day, reset daily flags
        if (lastSave.day != today.day || 
            lastSave.month != today.month || 
            lastSave.year != today.year) {
          _goalAchievedToday = false;
        } else {
          _goalAchievedToday = prefs.getBool('goal_achieved_today') ?? false;
        }
      }
      
      print('Data loaded successfully: ${_entries.length} entries');
    } catch (e) {
      print('Error loading data: $e');
    }
  }
}
