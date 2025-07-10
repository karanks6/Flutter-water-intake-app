import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/intake_entry.dart';
import '../services/notification_service.dart';

class IntakeProvider with ChangeNotifier {
  List<IntakeEntry> _entries = [];
  double _dailyTarget = 2000.0; // Default 2L
  final NotificationService _notificationService = NotificationService();

  // Getters
  List<IntakeEntry> get entries => _entries;
  double get dailyTarget => _dailyTarget;

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

  // Initialize provider
  Future<void> initialize() async {
    await _loadData();
    await _notificationService.initialize();
  }

  // Add new entry
  void addEntry(double amount, String note, DateTime timestamp) {
    final entry = IntakeEntry(
      amount: amount,
      timestamp: timestamp,
      note: note,
    );
    _entries.add(entry);
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

  // Clear all data
  void clearAllData() {
    _entries.clear();
    _saveData();
    notifyListeners();
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    if (_entries.isEmpty) {
      return {
        'totalDays': 0,
        'totalIntake': 0.0,
        'averageDaily': 0.0,
        'bestDay': 0.0,
        'streak': 0,
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

    // Calculate streak
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final date = now.subtract(Duration(days: i));
      final intake = getDailyIntake(date);
      if (intake >= _dailyTarget) {
        streak++;
      } else {
        break;
      }
    }

    return {
      'totalDays': totalDays,
      'totalIntake': totalIntake,
      'averageDaily': totalIntake / totalDays,
      'bestDay': bestDay,
      'streak': streak,
    };
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
    } catch (e) {
      print('Error loading data: $e');
    }
  }
}
