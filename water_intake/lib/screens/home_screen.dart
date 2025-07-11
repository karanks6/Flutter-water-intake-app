import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/intake_provider.dart';
import '../widgets/intake_card.dart';
import '../widgets/progress_chart.dart';
import 'log_entry_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Water Intake Logger'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<IntakeProvider>(
        builder: (context, intakeProvider, child) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Today's Progress Card
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Progress',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${intakeProvider.todayIntake.toStringAsFixed(0)} ml',
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                    color: Colors.blue[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'of ${intakeProvider.dailyTarget.toStringAsFixed(0)} ml',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            CircularProgressIndicator(
                              value: intakeProvider.todayProgress,
                              strokeWidth: 8,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                intakeProvider.todayProgress >= 1.0
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: intakeProvider.todayProgress,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            intakeProvider.todayProgress >= 1.0
                                ? Colors.green
                                : Colors.blue,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${(intakeProvider.todayProgress * 100).toStringAsFixed(0)}% Complete',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Quick Add Buttons
                Text(
                  'Quick Add',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildQuickAddButton(context, 250, 'Glass', Icons.local_drink),
                    _buildQuickAddButton(context, 500, 'Bottle', Icons.sports_bar),
                    _buildQuickAddButton(context, 1000, 'Large', Icons.water_drop),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Weekly Chart
                Text(
                  'Weekly Progress',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                Container(
                  height: 360,
                  child: ProgressChart(),
                ),
                
                SizedBox(height: 26),
                
                // Recent Entries
                Text(
                  'Recent Entries',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 28),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: intakeProvider.todayEntries.length > 3 
                      ? 3 
                      : intakeProvider.todayEntries.length,
                  itemBuilder: (context, index) {
                    final entry = intakeProvider.todayEntries[index];
                    return IntakeCard(
                      entry: entry,
                      onEdit: () => _editEntry(context, entry),
                      onDelete: () => _deleteEntry(context, entry),
                    );
                  },
                ),
                
                if (intakeProvider.todayEntries.length > 3)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => HistoryScreen()),
                      );
                    },
                    child: Text('View All Entries'),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LogEntryScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[600],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Already on home screen
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsScreen()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget _buildQuickAddButton(BuildContext context, double amount, String label, IconData icon) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: () {
            Provider.of<IntakeProvider>(context, listen: false)
                .addQuickEntry(amount);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added ${amount.toStringAsFixed(0)} ml'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 24),
              SizedBox(height: 4),
              Text('${amount.toStringAsFixed(0)} ml'),
              Text(label, style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ),
    );
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