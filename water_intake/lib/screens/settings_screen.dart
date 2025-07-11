import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/intake_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _targetController = TextEditingController();
  bool _notificationsEnabled = true;
  TimeOfDay _reminderTime = TimeOfDay(hour: 9, minute: 0);

  @override
  void initState() {
    super.initState();
    final intakeProvider = Provider.of<IntakeProvider>(context, listen: false);
    _targetController.text = intakeProvider.dailyTarget.toString();
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Consumer<IntakeProvider>(
        builder: (context, intakeProvider, child) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Daily Target Setting
                Text(
                  'Daily Target',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                TextFormField(
                  controller: _targetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Daily Target (ml)',
                    border: OutlineInputBorder(),
                    suffixText: 'ml',
                  ),
                  onChanged: (value) {
                    final target = double.tryParse(value);
                    if (target != null && target > 0) {
                      intakeProvider.updateDailyTarget(target);
                    }
                  },
                ),
                
                SizedBox(height: 16),
                
                // Quick Target Buttons
                Text(
                  'Common Targets',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildTargetChip(2000),
                    _buildTargetChip(2500),
                    _buildTargetChip(3000),
                    _buildTargetChip(3500),
                  ],
                ),
                
                SizedBox(height: 24),
                
                // Notification Settings
                Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                
                SwitchListTile(
                  title: Text('Enable Reminders'),
                  subtitle: Text('Get notified to drink water'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      _notificationsEnabled = value;
                    });
                  },
                ),
                
                ListTile(
                  title: Text('Reminder Time'),
                  subtitle: Text(_reminderTime.format(context)),
                  leading: Icon(Icons.access_time),
                  onTap: _notificationsEnabled ? _selectReminderTime : null,
                  enabled: _notificationsEnabled,
                ),
                
                SizedBox(height: 5),
                
                // App Info
                Text(
                  'App Information',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                
                ListTile(
                  title: Text('Version'),
                  subtitle: Text('1.0.0'),
                  leading: Icon(Icons.info),
                ),
                
                ListTile(
                  title: Text('Reset All Data'),
                  subtitle: Text('Clear all water intake records'),
                  leading: Icon(Icons.warning, color: Colors.red),
                  onTap: _showResetDialog,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTargetChip(double target) {
    return ActionChip(
      label: Text('${target.toStringAsFixed(0)} ml'),
      onPressed: () {
        _targetController.text = target.toString();
        Provider.of<IntakeProvider>(context, listen: false)
            .updateDailyTarget(target);
      },
    );
  }

  void _selectReminderTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset All Data'),
          content: Text(
            'Are you sure you want to delete all water intake records? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Provider.of<IntakeProvider>(context, listen: false)
                    .clearAllData();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('All data has been cleared')),
                );
              },
              child: Text('Reset', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}