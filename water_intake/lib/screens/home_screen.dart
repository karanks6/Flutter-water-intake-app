import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/intake_provider.dart';
import '../widgets/intake_card.dart';
import '../widgets/progress_chart.dart';
import 'log_entry_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<IntakeProvider>(context);
    
    final screens = [
      _buildHomeTab(provider),
      HistoryScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
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
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () => _showQuickAddDialog(context),
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildHomeTab(IntakeProvider provider) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Water Intake Logger',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            IntakeCard(),
            SizedBox(height: 20),
            Text(
              'Weekly Progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 10),
            Expanded(
              child: ProgressChart(),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LogEntryScreen()),
                    ),
                    icon: Icon(Icons.add),
                    label: Text('Log Water'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HistoryScreen()),
                    ),
                    icon: Icon(Icons.history),
                    label: Text('View History'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickAddDialog(BuildContext context) {
    final provider = Provider.of<IntakeProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quick Add'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQuickAddButton(context, provider, 250, 'Glass'),
            _buildQuickAddButton(context, provider, 500, 'Bottle'),
            _buildQuickAddButton(context, provider, 1000, 'Large Bottle'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddButton(BuildContext context, IntakeProvider provider, double amount, String label) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: () {
          provider.addEntry(IntakeEntry(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            timestamp: DateTime.now(),
            amount: amount,
            note: label,
          ));
          Navigator.pop(context);
        },
        child: Text('$label (${amount.toInt()}ml)'),
      ),
    );
  }
}