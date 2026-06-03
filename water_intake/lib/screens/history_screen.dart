import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/intake_provider.dart';
import '../widgets/intake_card.dart';
import '../widgets/theme_toggle_button.dart';
import '../theme/app_text_styles.dart';
import 'log_entry_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('HISTORY', style: Theme.of(context).textTheme.headlineMedium),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: const [ThemeToggleButton()],
      ),
      body: Consumer<IntakeProvider>(
        builder: (context, intakeProvider, child) {
          final entries = intakeProvider.getEntriesForDate(_selectedDate);
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final surfaceColor = isDark ? const Color(0xFF141B2D) : Colors.white;
          final borderColor = isDark ? const Color(0xFF1E2A3E) : Colors.blue.shade50;

          return Column(
            children: [
              // Premium Horizontal Calendar Strip
              _buildCalendarStrip(intakeProvider),
              
              const SizedBox(height: 12),

              // Modernized Daily Summary
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black45 : Colors.blue.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.blue.withOpacity(0.15)
                                : Colors.blue[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.water_drop, color: Colors.blue[600], size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Intake',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            Text(
                              '${intakeProvider.getDailyIntake(_selectedDate).toStringAsFixed(0)} ml',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.green.withOpacity(0.15)
                                : Colors.green[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.emoji_events, color: Colors.green[600], size: 24),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daily Goal',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            Text(
                              '${((intakeProvider.getDailyIntake(_selectedDate) / intakeProvider.dailyTarget) * 100).toStringAsFixed(0)}%',
                              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                                color: isDark ? Colors.green[400] : Colors.green[700],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),

              // Entries Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Logged Drinks',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${entries.length} items',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Entries List with empty state
              Expanded(
                child: entries.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), // Bottom padding for shell bar
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
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

  Widget _buildCalendarStrip(IntakeProvider provider) {
    final now = DateTime.now();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF141B2D) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E2A3E) : Colors.blue.shade50;

    return Container(
      height: 95,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 8, // 7 days + 1 calendar button at the end
        itemBuilder: (context, index) {
          if (index == 7) {
            // Calendar icon button for older dates
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 58,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: IconButton(
                icon: Icon(Icons.calendar_month, color: Colors.blue[600]),
                onPressed: _selectDate,
              ),
            );
          }

          // Subtract days to get last 7 days (index 0 is today, index 6 is 6 days ago)
          final date = now.subtract(Duration(days: index));
          final isSelected = DateUtils.isSameDay(date, _selectedDate);
          final dayName = _getDayAbbreviation(date.weekday);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: 58,
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        colors: [Colors.blue[600]!, Colors.cyan[400]!],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      )
                    : null,
                color: isSelected ? null : surfaceColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : borderColor,
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blue[400]!.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: AppTextStyles.calendarDayName(isSelected: isSelected),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    date.day.toString(),
                    style: AppTextStyles.calendarDayNumber(isSelected: isSelected),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.water_drop_outlined,
            size: 64,
            color: Colors.blueGrey[200],
          ),
          const SizedBox(height: 16),
          Text(
            'No water logged for this day',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Tap the "+" button to add entries!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  String _getDayAbbreviation(int weekday) {
    switch (weekday) {
      case 1: return 'M';
      case 2: return 'T';
      case 3: return 'W';
      case 4: return 'T';
      case 5: return 'F';
      case 6: return 'S';
      case 7: return 'S';
      default: return '';
    }
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF64B5F6),
                    onPrimary: Colors.black,
                    surface: Color(0xFF1A2336),
                    onSurface: Colors.white,
                  )
                : ColorScheme.light(
                    primary: Colors.blue[600]!,
                    onPrimary: Colors.white,
                    onSurface: Colors.blue[900]!,
                  ),
          ),
          child: child!,
        );
      },
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
