import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/intake_entry.dart';
import '../providers/intake_provider.dart';

class LogEntryScreen extends StatefulWidget {
  const LogEntryScreen({super.key});

  @override
  State<LogEntryScreen> createState() => _LogEntryScreenState();
}

class _LogEntryScreenState extends State<LogEntryScreen> {
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Water Intake")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: "Amount (ml)"),
            keyboardType: TextInputType.number,
          ),
          ElevatedButton(
              onPressed: () {
                final amount = int.tryParse(_controller.text);
                if (amount != null) {
                  Provider.of<IntakeProvider>(context, listen: false)
                      .addEntry(IntakeEntry(date: DateTime.now(), amount: amount));
                  Navigator.pop(context);
                }
              },
              child: const Text("Save"))
        ]),
      ),
    );
  }
}