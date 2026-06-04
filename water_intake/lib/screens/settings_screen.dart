import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import '../providers/intake_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_text_styles.dart';
import '../widgets/theme_toggle_button.dart';
import 'main_shell.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _targetController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _notificationsEnabled = true;
  int _reminderStartHour = 8;
  int _reminderStartMinute = 0;
  int _reminderEndHour = 22;
  int _reminderEndMinute = 0;
  int _reminderInterval = 120;
  bool _isScrolled = false;
  bool _exactAlarmGranted = true; // optimistic default

  @override
  void initState() {
    super.initState();
    _initializeSettings();
    _checkExactAlarmPermission();
    _scrollController.addListener(() {
      final scrolled = _scrollController.offset > 10;
      if (scrolled != _isScrolled) {
        setState(() => _isScrolled = scrolled);
      }
    });
  }

  Future<void> _checkExactAlarmPermission() async {
    final granted = await NotificationService().canScheduleExactAlarms();
    if (mounted) {
      setState(() => _exactAlarmGranted = granted);
    }
  }

  void _initializeSettings() {
    final intakeProvider = Provider.of<IntakeProvider>(context, listen: false);
    _targetController.text = intakeProvider.dailyTarget.toStringAsFixed(0);
    _notificationsEnabled = intakeProvider.notificationsEnabled;
    _reminderStartHour = intakeProvider.reminderStartHour;
    _reminderStartMinute = intakeProvider.reminderStartMinute;
    _reminderEndHour = intakeProvider.reminderEndHour;
    _reminderEndMinute = intakeProvider.reminderEndMinute;
    _reminderInterval = intakeProvider.reminderInterval;
  }

  @override
  void dispose() {
    _targetController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF141B2D) : Colors.white;
    final borderColor = isDark ? const Color(0xFF1E2A3E) : Colors.blue.shade50;
    final bgColor = isDark ? const Color(0xFF0A0F1E) : const Color(0xFFF3F9FD);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
        backgroundColor: _isScrolled
            ? (isDark ? const Color(0xFF0D1425) : const Color(0xFFF3F9FD))
            : (isDark ? const Color(0xFF0D1425) : const Color(0xFFF3F9FD)),
        elevation: _isScrolled ? 2 : 0,
        shadowColor: Colors.black26,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        actions: const [ThemeToggleButton()],
      ),
      body: Consumer<IntakeProvider>(
        builder: (context, intakeProvider, child) {
          if (_reminderStartHour != intakeProvider.reminderStartHour ||
              _reminderStartMinute != intakeProvider.reminderStartMinute ||
              _reminderEndHour != intakeProvider.reminderEndHour ||
              _reminderEndMinute != intakeProvider.reminderEndMinute ||
              _reminderInterval != intakeProvider.reminderInterval ||
              _notificationsEnabled != intakeProvider.notificationsEnabled) {
            _notificationsEnabled = intakeProvider.notificationsEnabled;
            _reminderStartHour = intakeProvider.reminderStartHour;
            _reminderStartMinute = intakeProvider.reminderStartMinute;
            _reminderEndHour = intakeProvider.reminderEndHour;
            _reminderEndMinute = intakeProvider.reminderEndMinute;
            _reminderInterval = intakeProvider.reminderInterval;
          }

          return ListView(
            controller: _scrollController,
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 100.0),
            children: [
              _buildSectionHeader('Daily Target', Icons.flag_rounded),
              _buildAnimatedCard(
                child: _buildCardWrapper(
                  child: _buildDailyTargetCard(intakeProvider),
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  isDark: isDark,
                ),
                delayMs: 50,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Notifications & Reminders', Icons.notifications_active_rounded),
              _buildAnimatedCard(
                child: _buildCardWrapper(
                  child: _buildNotificationSettingsCard(intakeProvider),
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  isDark: isDark,
                ),
                delayMs: 150,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('Statistics & Badges', Icons.analytics_rounded),
              _buildAnimatedCard(
                child: _buildCardWrapper(
                  child: _buildStatisticsCard(intakeProvider),
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  isDark: isDark,
                ),
                delayMs: 250,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('App Management', Icons.settings_rounded),
              _buildAnimatedCard(
                child: _buildCardWrapper(
                  child: _buildAppManagementCard(intakeProvider),
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  isDark: isDark,
                ),
                delayMs: 350,
              ),
              const SizedBox(height: 24),
              _buildSectionHeader('About', Icons.info_outline_rounded),
              _buildAnimatedCard(
                child: _buildCardWrapper(
                  child: _buildAboutCard(),
                  surfaceColor: surfaceColor,
                  borderColor: borderColor,
                  isDark: isDark,
                ),
                delayMs: 450,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 12.0, top: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[700], size: 20),
          const SizedBox(width: 8),
          Text(title, style: AppTextStyles.settingsSectionHeader),
        ],
      ),
    );
  }

  Widget _buildCardWrapper({required Widget child, required Color surfaceColor, required Color borderColor, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.blue.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildAnimatedCard({required Widget child, required int delayMs}) {
    return StaggeredAnimatedCard(
      delay: Duration(milliseconds: delayMs),
      child: child,
    );
  }

  Widget _buildDailyTargetCard(IntakeProvider intakeProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _targetController,
            keyboardType: TextInputType.number,
            style: AppTextStyles.inputValue,
            decoration: InputDecoration(
              labelText: 'Daily Target',
              labelStyle: AppTextStyles.inputLabel,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: isDark
                      ? Colors.blue.withOpacity(0.3)
                      : Colors.blue[100]!.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.blue[500]!, width: 2),
              ),
              suffixText: 'ml',
              suffixStyle: AppTextStyles.badgeValue,
              prefixIcon: Icon(
                Icons.local_drink_rounded,
                color: isDark ? Colors.blue[300] : Colors.blue[600],
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.blue.withOpacity(0.08)
                  : Colors.blue[50]!.withOpacity(0.15),
            ),
            onChanged: (value) {
              final target = double.tryParse(value);
              if (target != null && target > 0) {
                intakeProvider.updateDailyTarget(target);
              }
            },
          ),
          const SizedBox(height: 18),
          Text('Quick Targets', style: AppTextStyles.settingsSectionHeader),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTargetChip(intakeProvider, 1500, 'Light'),
              _buildTargetChip(intakeProvider, 2000, 'Normal'),
              _buildTargetChip(intakeProvider, 2500, 'Active'),
              _buildTargetChip(intakeProvider, 3000, 'Athlete'),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: intakeProvider.todayProgress,
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.blue[50]!.withOpacity(0.5),
              valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '${intakeProvider.todayIntake.toStringAsFixed(0)} ml / ${intakeProvider.dailyTarget.toStringAsFixed(0)} ml logged today',
            style: AppTextStyles.progressHelper,
          ),
        ],
      ),
    );
  }

  Widget _buildTargetChip(
      IntakeProvider intakeProvider, double target, String label) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = intakeProvider.dailyTarget == target;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _targetController.text = target.toStringAsFixed(0);
        intakeProvider.updateDailyTarget(target);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF00B0FF), Color(0xFF2979FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected
              ? null
              : (isDark
                  ? Colors.white.withOpacity(0.07)
                  : Colors.blue[50]!.withOpacity(0.4)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : (isDark
                    ? Colors.white.withOpacity(0.12)
                    : Colors.blue[100]!.withOpacity(0.5)),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.blue[300]!.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTextStyles.chipLabel.copyWith(
                color: isSelected
                    ? Colors.white
                    : (isDark ? Colors.white70 : Colors.blueGrey[700]),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${target.toStringAsFixed(0)} ml',
              style: AppTextStyles.chipSubLabel.copyWith(
                color: isSelected
                    ? Colors.white.withOpacity(0.85)
                    : (isDark
                        ? Colors.white38
                        : Colors.blueGrey[400]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettingsCard(IntakeProvider intakeProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pillBgColor = _notificationsEnabled
        ? (isDark ? Colors.blue.withOpacity(0.15) : Colors.blue[50]!.withOpacity(0.7))
        : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]);
    final pillBorderColor = _notificationsEnabled
        ? (isDark ? Colors.blue.withOpacity(0.3) : Colors.blue[100]!.withOpacity(0.5))
        : (isDark ? Colors.white10 : Colors.grey[200]!);
    final pillTextColor = _notificationsEnabled
        ? (isDark ? const Color(0xFF90CAF9) : Colors.blue[800])
        : (isDark ? Colors.white24 : Colors.blueGrey[300]);
    final pillIconColor = _notificationsEnabled
        ? (isDark ? const Color(0xFF90CAF9) : Colors.blue[600])
        : (isDark ? Colors.white24 : Colors.blueGrey[300]);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          _buildSwitchTile(
            title: 'Enable Reminders',
            subtitle: 'Receive notifications to drink water regularly',
            icon: _notificationsEnabled ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              intakeProvider.updateNotificationSettings(enabled: value);
            },
          ),
          const Divider(height: 1, indent: 68, endIndent: 16),
          _buildCustomSettingTile(
            title: 'Reminder Start Time',
            subtitle: 'Time when reminders begin',
            icon: Icons.alarm_rounded,
            enabled: _notificationsEnabled,
            onTap: () => _selectStartTime(intakeProvider),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: pillBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: pillBorderColor,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TimeOfDay(hour: _reminderStartHour, minute: _reminderStartMinute).format(context),
                    style: AppTextStyles.badgeValue.copyWith(
                      color: pillTextColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit_rounded,
                    size: 12,
                    color: pillIconColor,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, indent: 68, endIndent: 16),
          _buildCustomSettingTile(
            title: 'Reminder End Time',
            subtitle: 'Time when reminders stop',
            icon: Icons.alarm_off_rounded,
            enabled: _notificationsEnabled,
            onTap: () => _selectEndTime(intakeProvider),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: pillBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: pillBorderColor,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TimeOfDay(hour: _reminderEndHour, minute: _reminderEndMinute).format(context),
                    style: AppTextStyles.badgeValue.copyWith(
                      color: pillTextColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.edit_rounded,
                    size: 12,
                    color: pillIconColor,
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, indent: 68, endIndent: 16),
          _buildCustomSettingTile(
            title: 'Reminder Interval',
            subtitle: 'Frequency of notifications',
            icon: Icons.timer_rounded,
            enabled: _notificationsEnabled,
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: pillBgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: pillBorderColor,
                ),
              ),
              child: DropdownButton<int>(
                value: _reminderInterval,
                underline: const SizedBox.shrink(),
                style: AppTextStyles.badgeValue.copyWith(
                  fontWeight: FontWeight.w700,
                  color: pillTextColor,
                ),
                icon: Icon(
                  Icons.arrow_drop_down_rounded,
                  color: pillIconColor,
                ),
                dropdownColor: isDark ? const Color(0xFF1E2A3E) : Colors.white,
                items: [30, 60, 120, 180, 240, 360].map((minutes) {
                  String label;
                  if (minutes < 60) {
                    label = '$minutes mins';
                  } else {
                    int hours = minutes ~/ 60;
                    label = '$hours hr${hours > 1 ? "s" : ""}';
                  }
                  return DropdownMenuItem(
                    value: minutes,
                    child: Text(label),
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
          ),
          if (_notificationsEnabled) ...[
            const Divider(height: 1, indent: 68, endIndent: 16),
            _buildDeviceCompatibilityPanel(),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Divider(height: 1),
          ),
          // Test notification button
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
            child: _NotificationTestButton(),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 12.0),
            child: _ShowWeeklyProgressButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard(IntakeProvider intakeProvider) {
    final stats = intakeProvider.getStatistics();
    final currentStreak = stats['streak'] as int;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total Days', stats['totalDays'].toString(), Icons.calendar_today_rounded),
              _buildStatItem('Total Entries', stats['totalEntries'].toString(), Icons.history_rounded),
              _buildStatItem('Goals Met', stats['goalsAchieved'].toString(), Icons.emoji_events_rounded),
            ],
          ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Streak', '$currentStreak day${currentStreak != 1 ? 's' : ''}', Icons.local_fire_department_rounded),
              _buildStatItem('Best Day', '${stats['bestDay'].toStringAsFixed(0)} ml', Icons.star_rounded),
              _buildStatItem('Avg Daily', '${stats['averageDaily'].toStringAsFixed(0)} ml', Icons.trending_up_rounded),
            ],
          ),
          const Divider(height: 32),
          Text(
            'Hydration Milestones',
            style: AppTextStyles.settingsSectionHeader,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAchievementBadge(
                label: 'Bronze Badge',
                requirement: '3-Day Streak',
                isUnlocked: currentStreak >= 3,
                unlockedColor: Colors.brown[400]!,
                icon: Icons.filter_3_rounded,
              ),
              _buildAchievementBadge(
                label: 'Silver Badge',
                requirement: '7-Day Streak',
                isUnlocked: currentStreak >= 7,
                unlockedColor: Colors.blueGrey[400]!,
                icon: Icons.filter_7_rounded,
              ),
              _buildAchievementBadge(
                label: 'Gold Badge',
                requirement: '30-Day Streak',
                isUnlocked: currentStreak >= 30,
                unlockedColor: const Color(0xFFFFD700),
                icon: Icons.workspace_premium_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge({
    required String label,
    required String requirement,
    required bool isUnlocked,
    required Color unlockedColor,
    required IconData icon,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnlocked ? unlockedColor.withOpacity(0.12) : Colors.blueGrey[50]!.withOpacity(0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: isUnlocked ? unlockedColor.withOpacity(0.7) : Colors.blueGrey[100]!.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: unlockedColor.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: isUnlocked ? unlockedColor : Colors.blueGrey[200],
            size: 26,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isUnlocked
                ? (Theme.of(context).brightness == Brightness.dark ? Colors.white70 : const Color(0xFF0D47A1))
                : Colors.blueGrey[400],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          requirement,
          style: AppTextStyles.labelSmall,
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[600], size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: AppTextStyles.statValue,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.labelMedium,
        ),
      ],
    );
  }

  Widget _buildAppManagementCard(IntakeProvider intakeProvider) {
    return Column(
      children: [
        _buildDangerTile(
          title: 'Reset All Data',
          subtitle: 'Permanently clear all water intake records',
          icon: Icons.warning_amber_rounded,
          onTap: () => _showResetDialog(intakeProvider),
        ),
      ],
    );
  }

  Widget _buildAboutCard() {
    return Column(
      children: [
        _buildCustomSettingTile(
          title: 'Version',
          subtitle: '1.0.0',
          icon: Icons.info_outline_rounded,
          trailing: const Text(
            'v1.0.0',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.blueGrey,
            ),
          ),
        ),
        const Divider(height: 1, indent: 68, endIndent: 16),
        _buildCustomSettingTile(
          title: 'Feedback & Support',
          subtitle: 'Help us improve the app',
          icon: Icons.rate_review_rounded,
          trailing: Icon(Icons.chevron_right_rounded, color: Colors.blueGrey[300]),
          onTap: () {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Thank you for supporting AQUA LOG! 💧'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Colors.blue[800],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCustomSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget trailing,
    bool enabled = true,
    VoidCallback? onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerColor = enabled
        ? (isDark ? Colors.blue.withOpacity(0.15) : Colors.blue[50]!.withOpacity(0.7))
        : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]!.withOpacity(0.5));
    final iconColor = enabled
        ? (isDark ? const Color(0xFF90CAF9) : Colors.blue[600])
        : (isDark ? Colors.white24 : Colors.blueGrey[200]);

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.tileTitle.copyWith(
                      color: enabled
                          ? (isDark ? Colors.white : const Color(0xFF0D47A1))
                          : Colors.blueGrey[400],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: enabled ? AppTextStyles.tileSubtitle : AppTextStyles.tileSubtitleDisabled,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Opacity(
              opacity: enabled ? 1.0 : 0.4,
              child: trailing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerColor = value
        ? (isDark ? Colors.blue.withOpacity(0.15) : Colors.blue[50]!.withOpacity(0.7))
        : (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100]!.withOpacity(0.5));
    final iconColor = value
        ? (isDark ? const Color(0xFF90CAF9) : Colors.blue[600])
        : (isDark ? Colors.white24 : Colors.blueGrey[200]);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: containerColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.tileTitle,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.tileSubtitle,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue[600],
            activeTrackColor: Colors.blue[100],
          ),
        ],
      ),
    );
  }

  Widget _buildDangerTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerColor = isDark
        ? Colors.redAccent.withOpacity(0.15)
        : Colors.red[50]!.withOpacity(0.7);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: Colors.redAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.dangerTitle,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.dangerSubtitle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.redAccent,
              size: 20,
            ),
          ],
        ),
      ),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
  /// Builds the cross-device notification compatibility panel.
  Widget _buildDeviceCompatibilityPanel() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final cardBg = isDark
        ? const Color(0xFF1A2540)
        : const Color(0xFFF0F7FF);
    final borderCol = _exactAlarmGranted
        ? (isDark ? Colors.green.withOpacity(0.4) : Colors.green.shade200)
        : (isDark ? Colors.orange.withOpacity(0.4) : Colors.orange.shade200);
    final statusColor = _exactAlarmGranted ? Colors.green : Colors.orange;
    final statusIcon = _exactAlarmGranted ? Icons.verified_rounded : Icons.warning_amber_rounded;
    final statusText = _exactAlarmGranted
        ? 'Exact alarms are enabled — reminders will fire precisely on time.'
        : 'Exact alarms are NOT enabled. Notifications may be delayed or skipped on your device.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderCol, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Icon(Icons.phonelink_setup_rounded,
                    color: isDark ? const Color(0xFF90CAF9) : Colors.blue[700], size: 18),
                const SizedBox(width: 8),
                Text(
                  'Cross-Device Compatibility',
                  style: AppTextStyles.tileTitle.copyWith(
                    color: isDark ? Colors.white : const Color(0xFF0D47A1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Exact alarm status row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(statusIcon, color: statusColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    statusText,
                    style: AppTextStyles.tileSubtitle.copyWith(
                      color: isDark
                          ? (_exactAlarmGranted
                              ? Colors.green[300]
                              : Colors.orange[300])
                          : (_exactAlarmGranted
                              ? Colors.green[700]
                              : Colors.orange[700]),
                    ),
                  ),
                ),
              ],
            ),

            // Grant permission button (only shown when not granted)
            if (!_exactAlarmGranted) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () async {
                  await openAppSettings();
                  await Future.delayed(const Duration(seconds: 1));
                  _checkExactAlarmPermission();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.settings_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 6),
                      Text(
                        'Grant Exact Alarm Permission',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // OEM-specific tips
            Text(
              '📱 Device-Specific Tips',
              style: AppTextStyles.tileTitle.copyWith(
                fontSize: 13,
                color: isDark ? Colors.white70 : Colors.blueGrey[700],
              ),
            ),
            const SizedBox(height: 10),
            _buildOemTip(
              icon: '🔴',
              brand: 'Xiaomi / Redmi / POCO (MIUI / HyperOS)',
              steps: 'Settings → Apps → Manage Apps → AQUA LOG → Enable "Auto-start" + set Battery Saver to "No restrictions"',
              isDark: isDark,
            ),
            _buildOemTip(
              icon: '🔵',
              brand: 'Samsung (One UI)',
              steps: 'Settings → Battery → Background usage limits → Never sleeping apps → Add AQUA LOG',
              isDark: isDark,
            ),
            _buildOemTip(
              icon: '🟠',
              brand: 'Huawei / Honor (EMUI / MagicOS)',
              steps: 'Settings → Battery → App launch → AQUA LOG → Set to "Manage manually" and enable all',
              isDark: isDark,
            ),
            _buildOemTip(
              icon: '🟢',
              brand: 'Oppo / Realme (ColorOS)',
              steps: 'Settings → Battery → Power Saving → App Quick Freeze → Unfreeze AQUA LOG',
              isDark: isDark,
            ),
            _buildOemTip(
              icon: '🟡',
              brand: 'Vivo (OriginOS / FuntouchOS)',
              steps: 'Settings → Battery → Background app management → AQUA LOG → Allow background activities',
              isDark: isDark,
            ),
            _buildOemTip(
              icon: '🔷',
              brand: 'OnePlus / Nothing (OxygenOS)',
              steps: 'Settings → Battery → Battery Optimization → Find AQUA LOG → Set to "Don\'t optimize"',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOemTip({
    required String icon,
    required String brand,
    required String steps,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand,
                  style: AppTextStyles.tileTitle.copyWith(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.blueGrey[800],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  steps,
                  style: AppTextStyles.tileSubtitle.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A button that fires a test notification immediately to verify device compatibility.
class _NotificationTestButton extends StatefulWidget {
  const _NotificationTestButton();

  @override
  State<_NotificationTestButton> createState() =>
      _NotificationTestButtonState();
}

class _NotificationTestButtonState extends State<_NotificationTestButton> {
  bool _isTesting = false;

  Future<void> _runTest() async {
    setState(() => _isTesting = true);
    await NotificationService().testNotification();
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isTesting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.notifications_active_rounded,
                  color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text('Test notification sent! Check your notification bar.'),
            ],
          ),
          backgroundColor: Colors.green[700],
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isTesting ? null : _runTest,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: _isTesting
              ? const LinearGradient(
                  colors: [Color(0xFF78909C), Color(0xFF546E7A)])
              : const LinearGradient(
                  colors: [Color(0xFF00BCD4), Color(0xFF0097A7)]),
          borderRadius: BorderRadius.circular(14),
          boxShadow: _isTesting
              ? []
              : [
                  BoxShadow(
                    color: Colors.cyan.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isTesting)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            else
              const Icon(Icons.notifications_active_rounded,
                  color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              _isTesting ? 'Sending...' : 'Send Test Notification',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShowWeeklyProgressButton extends StatefulWidget {
  const _ShowWeeklyProgressButton();

  @override
  State<_ShowWeeklyProgressButton> createState() => _ShowWeeklyProgressButtonState();
}

class _ShowWeeklyProgressButtonState extends State<_ShowWeeklyProgressButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.94,
      upperBound: 1.0,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    );
    _scaleController.value = 1.0;
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.reverse(),
      onTapUp: (_) => _scaleController.forward(),
      onTapCancel: () => _scaleController.forward(),
      onTap: () {
        HapticFeedback.mediumImpact(); // Satisfying haptic feedback
        
        // Use activeState singleton reference if available, otherwise context lookup
        final shellState = MainShellScreenState.activeState ??
            context.findAncestorStateOfType<MainShellScreenState>();
        if (shellState != null) {
          shellState.setIndex(0); // Switch index to Home Tab (where progress graph is)
        } else {
          // Fallback if not inside MainShellScreen
          Navigator.pop(context);
        }
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00B0FF), Color(0xFF2979FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue[400]!.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.show_chart_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Show Weekly Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StaggeredAnimatedCard extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;

  const StaggeredAnimatedCard({
    super.key,
    required this.child,
    required this.delay,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  State<StaggeredAnimatedCard> createState() => _StaggeredAnimatedCardState();
}

class _StaggeredAnimatedCardState extends State<StaggeredAnimatedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  bool _started = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _slideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _timer = Timer(widget.delay, () {
      if (mounted) {
        setState(() {
          _started = true;
        });
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double opacity = _started ? _fadeAnimation.value : 0.0;
        final double slide = _started ? _slideAnimation.value : 30.0;
        return Transform.translate(
          offset: Offset(0.0, slide),
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}