import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/intake_entry.dart';

class IntakeProvider extends ChangeNotifier {
  List<IntakeEntry> _entries = [];
  int _goal = 2000;

  List<IntakeEntry> get entries => _entries;
  int get goal => _goal;

  Future<void> loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('entries');
    final goal = prefs.getInt('goal');
    if (data != null) {
      _entries = (jsonDecode(data) as List)
          .map((e) => IntakeEntry.fromJson(e))
          .toList();
    }
    if (goal != null) _goal = goal;
    notifyListeners();
  }

  Future<void> saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(_entries.map((e) => e.toJson()).toList());
    await prefs.setString('entries', data);
    await prefs.setInt('goal', _goal);
  }

  void addEntry(IntakeEntry entry) {
    _entries.add(entry);
    saveEntries();
    notifyListeners();
  }

  void updateGoal(int newGoal) {
    _goal = newGoal;
    saveEntries();
    notifyListeners();
  }

  List<IntakeEntry> getEntriesForDay(DateTime day) => _entries
      .where((e) =>
          e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day)
      .toList();

  int getTodayTotal() => getEntriesForDay(DateTime.now())
      .fold(0, (sum, entry) => sum + entry.amount);

  List<IntakeEntry> getEntriesForWeek(DateTime startOfWeek) => _entries
      .where((e) => e.date.isAfter(startOfWeek.subtract(const Duration(days: 1))))
      .toList();
}