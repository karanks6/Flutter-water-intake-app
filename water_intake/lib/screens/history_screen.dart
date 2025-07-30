import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/intake_provider.dart';
import '../widgets/intake_card.dart';
import 'log_entry_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Consumer<IntakeProvider>(
        builder: (context, intakeProvider, child) {
          return Column(
            children: [
              // Date Picker
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    ElevatedButton(
                      onPressed: _selectDate,
                      child: Text('Change Date'),
                    ),
                  ],
                ),
              ),
              

              // Daily Summary
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Intake',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${intakeProvider.getDailyIntake(_selectedDate).toStringAsFixed(0)} ml',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.blue[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Progress',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(
                          '${((intakeProvider.getDailyIntake(_selectedDate) / intakeProvider.dailyTarget) * 100).toStringAsFixed(0)}%',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.blue[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 16),
              
              // Entries List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: intakeProvider.getEntriesForDate(_selectedDate).length,
                  itemBuilder: (context, index) {
                    final entry = intakeProvider.getEntriesForDate(_selectedDate)[index];
                    return IntakeCard(
                      entry: entry,
                      onEdit: () => _editEntry(context, entry),
                      onDelete: () => _deleteEntry(context, entry),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }


  void _editEntry(BuildContext context, dynamic entry) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogEntryScreen(entry: entry),
      ),
    );
  }


  void _deleteEntry(BuildContext context, dynamic entry) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Entry'),
          content: Text('Are you sure you want to delete this entry?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<IntakeProvider>(context, listen: false)
                    .deleteEntry(entry);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
