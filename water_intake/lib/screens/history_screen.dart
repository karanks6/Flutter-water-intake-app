import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/intake_provider.dart';
import '../models/intake_entry.dart';
import 'log_entry_screen.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<IntakeProvider>(context);
    final entries = provider.getEntriesForDate(_selectedDate);
    final dailyIntake = provider.getDailyIntake(_selectedDate);
    final progress = dailyIntake / provider.dailyTarget;

    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => setState(() {
                        _selectedDate = _selectedDate.subtract(Duration(days: 1));
                      }),
                      icon: Icon(Icons.chevron_left),
                    ),
                    InkWell(
                      onTap: _selectDate,
                      child: Text(
                        DateFormat('EEEE, MMM d, yyyy').format(_selectedDate),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      onPressed: _selectedDate.isBefore(DateTime.now())
                          ? () => setState(() {
                                _selectedDate = _selectedDate.add(Duration(days: 1));
                              })
                          : null,
                      icon: Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          '${dailyIntake.toInt()} ml',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: progress >= 1.0 ? Colors.green : Colors.blue,
                          ),
                        ),
                        Text(
                          'of ${provider.dailyTarget.toInt()} ml target',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            progress >= 1.0 ? Colors.green : Colors.blue,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${(progress * 100).toInt()}% complete',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: entries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_drop_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No water intake logged for this day',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return Card(
                        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(Icons.water_drop),
                          ),
                          title: Text('${entry.amount.toInt()} ml'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormat('h:mm a').format(entry.timestamp)),
                              if (entry.note != null) Text(entry.note!),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LogEntryScreen(entry: entry),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }
}