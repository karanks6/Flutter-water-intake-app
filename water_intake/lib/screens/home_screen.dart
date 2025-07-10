import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:water_intake_logger/providers/intake_provider.dart';
import 'package:water_intake_logger/screens/history_screen.dart';
import 'package:water_intake_logger/screens/log_entry_screen.dart';
import 'package:water_intake_logger/screens/settings_screen.dart';
import 'package:water_intake_logger/widgets/intake_card.dart';
import 'package:water_intake_logger/widgets/progress_chart.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final intakeProvider = Provider.of<IntakeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Water Intake'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HistoryScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            IntakeCard(
              currentIntake: intakeProvider.dailyIntake,
              targetIntake: intakeProvider.targetIntake,
            ),
            const SizedBox(height: 20),
            // Placeholder for a more detailed daily/weekly progress chart
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ProgressChart(
                data: intakeProvider.weeklyIntake, // Example: pass weekly data
                target: intakeProvider.targetIntake,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const LogEntryScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Log Water'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}