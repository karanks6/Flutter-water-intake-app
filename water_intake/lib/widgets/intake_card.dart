import 'package:flutter/material.dart';

class IntakeCard extends StatelessWidget {
  final int total;
  final int goal;

  const IntakeCard({super.key, required this.total, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text("Today's Intake", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text("$total ml / $goal ml", style: const TextStyle(fontSize: 24)),
          ],
        ),
      ),
    );
  }
}