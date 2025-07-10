import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/intake_provider.dart';
import '../widgets/intake_card.dart';
import '../screens/log_entry_screen.dart';
import '../screens/history_screen.dart';
import '../screens/settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<IntakeProvider>(context);
    final todayTotal = provider.getTodayTotal();
    final goal = provider.goal;
    final percent = (todayTotal / goal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Water Intake Logger"),
        actions: [
          IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen())))
        ],
      ),
      body: Column(
        children: [
          IntakeCard(total: todayTotal, goal: goal),
          LinearProgressIndicator(value: percent),
          const SizedBox(height: 20),
          ElevatedButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LogEntryScreen())),
              child: const Text("Add Water Intake")),
          ElevatedButton(
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const HistoryScreen())),
              child: const Text("View History"))
        ],
      ),
    );
  }
}