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
  int _reminderStartHour = 8;
  int _reminderStartMinute = 0;
  int _reminderEndHour = 22;
  int _reminderEndMinute = 0;
  int _reminderInterval = 2;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeSettings();
  }

  void _initializeSettings() {
    final intakeProvider = Provider.of<IntakeProvider>(context, listen: false);
    _targetController.text = intakeProvider.dailyTarget.toString();
    _notificationsEnabled = intakeProvider.notificationsEnabled;
    _reminderStartHour = intakeProvider.reminderStartHour;
    _reminderStartMinute = intakeProvider.reminderStartMinute ?? 0;
    _reminderEndHour = intakeProvider.reminderEndHour;
    _reminderEndMinute = intakeProvider.reminderEndMinute ?? 0;
    _reminderInterval = intakeProvider.reminderInterval;
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
        title: const Text('Settings'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Consumer<IntakeProvider>(
        builder: (context, intakeProvider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Daily Target Section
              _buildSectionHeader('Daily Target', Icons.flag),
              _buildDailyTargetCard(intakeProvider),
              const SizedBox(height: 24),

              // Notification Settings Section
              _buildSectionHeader('Notifications', Icons.notifications),
              _buildNotificationSettingsCard(intakeProvider),
              const SizedBox(height: 24),

              // Statistics Section (need to be changed)
              _buildSectionHeader('Statistics', Icons.analytics),
              _buildStatisticsCard(intakeProvider),
              const SizedBox(height: 24),

              // App Management Section
              _buildSectionHeader('App Management', Icons.settings),
              _buildAppManagementCard(intakeProvider),
              const SizedBox(height: 24),

              // About Section
              _buildSectionHeader('About', Icons.info),
              _buildAboutCard(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[600]),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTargetCard(IntakeProvider intakeProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _targetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Daily Target (ml)',
                border: const OutlineInputBorder(),
                suffixText: 'ml',
                helperText: 'Recommended: 2000-3000 ml per day',
                prefixIcon: const Icon(Icons.local_drink),
              ),
              onChanged: (value) {
                final target = double.tryParse(value);
                if (target != null && target > 0) {
                  intakeProvider.updateDailyTarget(target);
                }
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Quick Targets',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                _buildTargetChip(intakeProvider, 1500, 'Light'),
                _buildTargetChip(intakeProvider, 2000, 'Normal'),
                _buildTargetChip(intakeProvider, 2500, 'Active'),
                _buildTargetChip(intakeProvider, 3000, 'Athlete'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: intakeProvider.todayProgress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
            ),
            const SizedBox(height: 4),
            Text(
              '${intakeProvider.todayIntake.toStringAsFixed(0)} ml / ${intakeProvider.dailyTarget.toStringAsFixed(0)} ml today',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettingsCard(IntakeProvider intakeProvider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Enable Reminders'),
              subtitle: const Text('Get notified to drink water regularly'),
              value: _notificationsEnabled,
              secondary: const Icon(Icons.notifications_active),
              onChanged: (value) {
                setState(() {
                  _notificationsEnabled = value;
                });
                intakeProvider.updateNotificationSettings(enabled: value);
              },
            ),
            const Divider(),
            ListTile(
              title: const Text('Reminder Start Time'),
              subtitle: Text('${TimeOfDay(hour: _reminderStartHour, minute: _reminderStartMinute).format(context)}'),
              leading: const Icon(Icons.alarm),
              trailing: const Icon(Icons.edit),
              enabled: _notificationsEnabled,
              onTap: _notificationsEnabled ? () => _selectStartTime(intakeProvider) : null,
            ),
            ListTile(
              title: const Text('Reminder End Time'),
              subtitle: Text('${TimeOfDay(hour: _reminderEndHour, minute: _reminderEndMinute).format(context)}'),
              leading: const Icon(Icons.alarm_off),
              trailing: const Icon(Icons.edit),
              enabled: _notificationsEnabled,
              onTap: _notificationsEnabled ? () => _selectEndTime(intakeProvider) : null,
            ),
            ListTile(
              title: const Text('Reminder Interval'),
              subtitle: Text('Every $_reminderInterval hour(s)'),
              leading: const Icon(Icons.timer),
              trailing: DropdownButton<int>(
                value: _reminderInterval,
                items: [1, 2, 3, 4, 6].map((hour) {
                  return DropdownMenuItem(
                    value: hour,
                    child: Text('$hour hour${hour > 1 ? 's' : ''}'),
                  );
                }).toList(),
                onChanged: _notificationsEnabled ? (value) {
                  if (value != null) {
                    setState(() {
                      _reminderInterval = value;
                    });
                    intakeProvider.updateNotificationSettings(interval: value);
                  }
                } : null,
              ),
            ),
            const Divider(),
            Center(
              child: ElevatedButton.icon(
                onPressed: _notificationsEnabled ? () {
                  // Navigate to weekly progress chart
                  Navigator.pop(context); // Go back to main screen
                  // You can add additional navigation logic here if needed
                } : null,
                icon: const Icon(Icons.show_chart),
                label: const Text('Show Weekly Progress'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(IntakeProvider intakeProvider) {
    final stats = intakeProvider.getStatistics();
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Total Days', stats['totalDays'].toString(), Icons.calendar_today),
                _buildStatItem('Total Entries', stats['totalEntries'].toString(), Icons.edit),
                _buildStatItem('Goals Achieved', stats['goalsAchieved'].toString(), Icons.flag),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Current Streak', '${stats['streak']} days', Icons.local_fire_department),
                _buildStatItem('Best Day', '${stats['bestDay'].toStringAsFixed(0)} ml', Icons.star),
                _buildStatItem('Daily Average', '${stats['averageDaily'].toStringAsFixed(0)} ml', Icons.trending_up),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[600], size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.blue[600],
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAppManagementCard(IntakeProvider intakeProvider) {
    return Card(
      elevation: 4,
      child: Column(
        children: [
          ListTile(
            title: const Text('Reset All Data'),
            subtitle: const Text('Clear all water intake records'),
            leading: const Icon(Icons.warning, color: Colors.red),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showResetDialog(intakeProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Card(
      elevation: 4,
      child: Column(
        children: [
          ListTile(
            title: const Text('Version'),
            subtitle: const Text('1.0.0'),
            leading: const Icon(Icons.info),
          ),
          const Divider(height: 1),
          ListTile(
            title: const Text('Rate App'),
            subtitle: const Text('Help us improve'),
            leading: const Icon(Icons.star_rate),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thank you for your feedback!')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTargetChip(IntakeProvider intakeProvider, double target, String label) {
    final isSelected = intakeProvider.dailyTarget == target;
    return FilterChip(
      label: Text('$label\n${target.toStringAsFixed(0)} ml'),
      selected: isSelected,
      onSelected: (selected) {
        _targetController.text = target.toString();
        intakeProvider.updateDailyTarget(target);
      },
      selectedColor: Colors.blue[100],
    );
  }

  Future<void> _selectStartTime(IntakeProvider intakeProvider) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminderStartHour, minute: _reminderStartMinute),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _reminderStartHour = picked.hour;
        _reminderStartMinute = picked.minute;
      });
      intakeProvider.updateNotificationSettings(
        startHour: picked.hour,
        startMinute: picked.minute,
      );
    }
  }

  Future<void> _selectEndTime(IntakeProvider intakeProvider) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _reminderEndHour, minute: _reminderEndMinute),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _reminderEndHour = picked.hour;
        _reminderEndMinute = picked.minute;
      });
      intakeProvider.updateNotificationSettings(
        endHour: picked.hour,
        endMinute: picked.minute,
      );
    }
  }

  void _showResetDialog(IntakeProvider intakeProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset All Data'),
          content: const Text(
            'Are you sure you want to delete all water intake records? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                intakeProvider.clearAllData();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All data has been cleared'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text('Reset', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}