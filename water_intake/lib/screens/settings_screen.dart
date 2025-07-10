import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/intake_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _goalController;

  @override
  void initState() {
    super.initState();
    final goal = context.read<IntakeProvider>().goal;
    _goalController = TextEditingController(text: goal.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(
            controller: _goalController,
            decoration: const InputDecoration(labelText: "Daily Goal (ml)"),
            keyboardType: TextInputType.number,
          ),
          ElevatedButton(
              onPressed: () {
                final newGoal = int.tryParse(_goalController.text);
                if (newGoal != null) {
                  context.read<IntakeProvider>().updateGoal(newGoal);
                  Navigator.pop(context);
                }
              },
              child: const Text("Save Goal"))
        ]),
      ),
    );
  }
}