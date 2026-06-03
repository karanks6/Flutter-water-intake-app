import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/intake_provider.dart';
import '../widgets/intake_card.dart';
import '../widgets/progress_chart.dart';
import '../widgets/water_wave_widget.dart';
import '../widgets/streak_flame_widget.dart';
import '../widgets/quick_add_button.dart';
import '../widgets/theme_toggle_button.dart';
import '../theme/app_text_styles.dart';
import 'log_entry_screen.dart';
import 'history_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('AQUA LOG', style: Theme.of(context).textTheme.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: const [ThemeToggleButton()],
      ),
      body: Consumer<IntakeProvider>(
        builder: (context, intakeProvider, child) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final surfaceColor = isDark ? const Color(0xFF141B2D) : Colors.white;
          final borderColor = isDark ? const Color(0xFF1E2A3E) : Colors.blue[50]!;
          final gradTopColor = isDark ? const Color(0xFF1A2540) : Colors.blue[50]!;
          final gradBotColor = isDark ? const Color(0xFF111827) : Colors.cyan[50]!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Today's Progress / Hero Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: borderColor, width: 1.5),
                  ),
                  color: surfaceColor,
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        colors: [
                          gradTopColor.withOpacity(isDark ? 0.6 : 0.4),
                          gradBotColor.withOpacity(isDark ? 0.4 : 0.2),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Today's Hydration",
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getMotivationalQuote(intakeProvider.todayProgress),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            StreakFlameWidget(
                              streakCount: intakeProvider.calculateCurrentStreak(),
                              size: 40,
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: WaterWaveWidget(
                            progress: intakeProvider.todayProgress,
                            currentIntake: intakeProvider.todayIntake,
                            dailyTarget: intakeProvider.dailyTarget,
                            size: 190,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                Text('Quick Add', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    QuickAddButton(
                      amount: 250,
                      label: 'Glass',
                      icon: Icons.local_drink_rounded,
                      gradientColors: [Color(0xFF00E5FF), Color(0xFF00B0FF)],
                    ),
                    QuickAddButton(
                      amount: 500,
                      label: 'Bottle',
                      icon: Icons.sports_bar_rounded,
                      gradientColors: [Color(0xFF00B0FF), Color(0xFF2979FF)],
                    ),
                    QuickAddButton(
                      amount: 1000,
                      label: 'Large',
                      icon: Icons.water_drop_rounded,
                      gradientColors: [Color(0xFF2979FF), Color(0xFF651FFF)],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 360, child: ProgressChart()),
                const SizedBox(height: 26),

                // Recent Entries
                Text('Recent Entries', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
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
                    child: Text('View All Entries',
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                const SizedBox(height: 100), // space above FAB
              ],
            ),
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 80), // Floating above bottom shell
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LogEntryScreen()),
            );
          },
          backgroundColor: Colors.blue[600],
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }




  String _getMotivationalQuote(double progress) {
    if (progress <= 0) {
      return "Start your day with a glass of water! 💧";
    } else if (progress < 0.3) {
      return "Great start! Keep sipping. 💧";
    } else if (progress < 0.6) {
      return "You're doing fantastic, keep going! 🚀";
    } else if (progress < 1.0) {
      return "Almost at your daily goal! 🌟";
    } else {
      return "Goal Achieved! You are fully hydrated! 🎉";
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Delete Entry', style: AppTextStyles.tileTitle),
          content: Text('Are you sure you want to delete this entry?', style: AppTextStyles.tileSubtitle),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: AppTextStyles.tileTitle),
            ),
            TextButton(
              onPressed: () {
                Provider.of<IntakeProvider>(context, listen: false)
                    .deleteEntry(entry);
                Navigator.of(context).pop();
              },
              child: Text('Delete', style: AppTextStyles.dangerTitle),
            ),
          ],
        );
      },
    );
  }
}