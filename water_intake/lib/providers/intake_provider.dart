import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/intake_entry.dart';
import '../services/notification_service.dart';

class IntakeProvider extends ChangeNotifier {
  List<IntakeEntry> _entries = [];
  double _dailyTarget = 2000.0; // ml
  bool _remindersEnabled = true;
  int _reminderInterval = 60; // minutes

  List<IntakeEntry> get entries => [..._entries];
  double get dailyTarget => _dailyTarget;
  bool get remindersEnabled => _remindersEnabled;
  int get reminderInterval => _reminderInterval;

  IntakeProvider() {
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load entries
    final entriesJson = prefs.getString('intake_entries') ?? '[]';
    final entriesList = json.decode(entriesJson) as List;
    _entries = entriesList.map((e) => IntakeEntry.fromJson(e)).toList();
    
    // Load settings
    _dailyTarget = prefs.getDouble('daily_target') ?? 2000.0;
    _remindersEnabled = prefs.getBool('reminders_enabled') ?? true;
    _reminderInterval = prefs.getInt('reminder_interval') ?? 60;
    
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save entries
    final entriesJson = json.encode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString('intake_entries', entriesJson);
    
    // Save settings
    await prefs.setDouble('daily_target', _dailyTarget);
    await prefs.setBool('reminders_enabled', _remindersEnabled);
    await prefs.setInt('reminder_interval', _reminderInterval);
  }

  Future<void> addEntry(IntakeEntry entry) async {
    _entries.add(entry);
    await _saveData();
    notifyListeners();
  }

  Future<void> updateEntry(IntakeEntry updatedEntry) async {
    final index = _entries.indexWhere((e) => e.id == updatedEntry.id);
    if (index != -1) {
      _entries[index] = updatedEntry;
      await _saveData();
      notifyListeners();
    }
  }

  Future<void> deleteEntry(String id) async {
    _entries.removeWhere((e) => e.id == id);
    await _saveData();
    notifyListeners();
  }

  double getDailyIntake(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    
    return _entries
        .where((e) => e.timestamp.isAfter(startOfDay) && e.timestamp.isBefore(endOfDay))
        .fold(0.0, (sum, entry) => sum + entry.amount);
  }

  List<IntakeEntry> getEntriesForDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    
    return _entries
        .where((e) => e.timestamp.isAfter(startOfDay) && e.timestamp.isBefore(endOfDay))
        .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Map<DateTime, double> getWeeklyData(DateTime startDate) {
    final weekData = <DateTime, double>{};
    
    for (int i = 0; i < 7; i++) {
      final date = startDate.add(Duration(days: i));
      weekData[date] = getDailyIntake(date);
    }
    
    return weekData;
  }

  Future<void> updateDailyTarget(double target) async {
    _dailyTarget = target;
    await _saveData();
    notifyListeners();
  }

  Future<void> updateReminderSettings(bool enabled, int interval) async {
    _remindersEnabled = enabled;
    _reminderInterval = interval;
    await _saveData();
    
    if (enabled) {
      await NotificationService.scheduleRepeatingNotification(interval);
    } else {
      await NotificationService.cancelAllNotifications();
    }
    
    notifyListeners();
  }

  double get todayProgress => getDailyIntake(DateTime.now()) / _dailyTarget;
  double get todayIntake => getDailyIntake(DateTime.now());
}