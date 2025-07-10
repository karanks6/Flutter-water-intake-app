import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/intake_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _targetController = TextEditingController();

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<IntakeProvider>(context);
    _targetController.text = provider.dailyTarget.toInt().toString();

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Daily Target Section
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Target',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _targetController,
                    decoration: InputDecoration(
                      labelText: 'Target Amount (ml)',
                      border: OutlineInputBorder(),
                      suffixText: 'ml',
                      helperText: 'Enter your daily water intake goal',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final amount = double.tryParse(value);
                      if (amount != null && amount > 0) {
                        provider.updateDailyTarget(amount);
                      }
                    },
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade600,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Recommended: 2000-3000 ml per day for adults',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  // Quick target buttons
                  Text(
                    'Quick Set:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildQuickTargetChip(1500, '1.5L'),
                      _buildQuickTargetChip(2000, '2L'),
                      _buildQuickTargetChip(2500, '2.5L'),
                      _buildQuickTargetChip(3000, '3L'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Reminders Section
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reminders',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  SwitchListTile(
                    title: Text('Enable Reminders'),
                    subtitle: Text('Get notified to drink water regularly'),
                    value: provider.remindersEnabled,
                    onChanged: (value) {
                      provider.updateReminderSettings(value, provider.reminderInterval);
                    },
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (provider.remindersEnabled) ...[
                    SizedBox(height: 16),
                    Text(
                      'Reminder Interval',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: provider.reminderInterval,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Frequency',
                        helperText: 'How often to remind you',
                      ),
                      items: [
                        DropdownMenuItem(value: 30, child: Text('Every 30 minutes')),
                        DropdownMenuItem(value: 60, child: Text('Every hour')),
                        DropdownMenuItem(value: 120, child: Text('Every 2 hours')),
                        DropdownMenuItem(value: 180, child: Text('Every 3 hours')),
                        DropdownMenuItem(value: 240, child: Text('Every 4 hours')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          provider.updateReminderSettings(provider.remindersEnabled, value);
                        }
                      },
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications_active,
                            color: Colors.green.shade600,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Reminders will help you stay consistently hydrated throughout the day',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Statistics Section
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Statistics',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildStatRow('Today\'s Intake', '${provider.todayIntake.toInt()} ml'),
                  _buildStatRow('Daily Target', '${provider.dailyTarget.toInt()} ml'),
                  _buildStatRow('Progress', '${(provider.todayProgress * 100).toInt()}%'),
                  _buildStatRow('Total Entries', '${provider.entries.length}'),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // About Section
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.water_drop, color: Colors.blue),
                    title: Text('Water Intake Logger'),
                    subtitle: Text('Version 1.0.0'),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Track your daily water intake and stay hydrated for better health!',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 16),
                  ExpansionTile(
                    title: Text(
                      'Hydration Tips',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.only(left: 16, bottom: 8),
                    children: [
                      _buildTipItem('💧', 'Drink water first thing in the morning'),
                      _buildTipItem('🥤', 'Keep a water bottle with you always'),
                      _buildTipItem('⏰', 'Set regular reminders throughout the day'),
                      _buildTipItem('🍉', 'Eat water-rich foods like fruits and vegetables'),
                      _buildTipItem('🌡️', 'Drink more water in hot weather or during exercise'),
                      _buildTipItem('👀', 'Monitor your urine color as a hydration indicator'),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.health_and_safety,
                          color: Colors.orange.shade600,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Proper hydration supports energy levels, brain function, and overall health',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Data Management Section
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data Management',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  ListTile(
                    leading: Icon(Icons.refresh, color: Colors.blue),
                    title: Text('Reset Daily Progress'),
                    subtitle: Text('Clear today\'s water intake entries'),
                    contentPadding: EdgeInsets.zero,
                    onTap: () => _showResetDialog(context, 'daily'),
                  ),
                  ListTile(
                    leading: Icon(Icons.delete_outline, color: Colors.red),
                    title: Text('Clear All Data'),
                    subtitle: Text('Delete all water intake records'),
                    contentPadding: EdgeInsets.zero,
                    onTap: () => _showResetDialog(context, 'all'),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildQuickTargetChip(double amount, String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        final provider = Provider.of<IntakeProvider>(context, listen: false);
        provider.updateDailyTarget(amount);
        _targetController.text = amount.toInt().toString();
      },
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String emoji, String tip) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: TextStyle(fontSize: 16)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, String type) {
    final provider = Provider.of<IntakeProvider>(context, listen: false);
    final isDaily = type == 'daily';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isDaily ? 'Reset Daily Progress' : 'Clear All Data'),
        content: Text(
          isDaily
              ? 'Are you sure you want to clear today\'s water intake entries? This action cannot be undone.'
              : 'Are you sure you want to delete all water intake records? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (isDaily) {
                _resetDailyProgress(provider);
              } else {
                _clearAllData(provider);
              }
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isDaily ? 'Daily progress reset' : 'All data cleared',
                  ),
                ),
              );
            },
            child: Text(
              isDaily ? 'Reset' : 'Delete All',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _resetDailyProgress(IntakeProvider provider) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(Duration(days: 1));
    
    final todayEntries = provider.entries
        .where((e) => e.timestamp.isAfter(startOfDay) && e.timestamp.isBefore(endOfDay))
        .toList();
    
    for (final entry in todayEntries) {
      provider.deleteEntry(entry.id);
    }
  }

  void _clearAllData(IntakeProvider provider) {
    final allEntries = [...provider.entries];
    for (final entry in allEntries) {
      provider.deleteEntry(entry.id);
    }
  }
}