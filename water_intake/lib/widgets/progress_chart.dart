import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/intake_provider.dart';
import '../theme/app_text_styles.dart';

/// Animated weekly bar chart.
/// Bars grow from zero to their actual values on first appearance,
/// and re-animate whenever data changes.
class ProgressChart extends StatefulWidget {
  const ProgressChart({super.key});

  @override
  State<ProgressChart> createState() => _ProgressChartState();
}

class _ProgressChartState extends State<ProgressChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _barController;
  late Animation<double> _barAnimation;

  @override
  void initState() {
    super.initState();
    _barController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _barAnimation = CurvedAnimation(
      parent: _barController,
      curve: Curves.easeOutBack,
    );
    // Kick off entrance animation after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _barController.forward();
    });
  }

  @override
  void dispose() {
    _barController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IntakeProvider>(
      builder: (context, intakeProvider, child) {
        final weeklyData = intakeProvider.getWeeklyData();
        final dailyTarget = intakeProvider.dailyTarget;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final surfaceColor = isDark ? const Color(0xFF141B2D) : Colors.white;
        final borderColor =
            isDark ? const Color(0xFF1E2A3E) : Colors.blue.shade50;

        // Y-axis headroom: at least 30% above the highest bar so the Target
        // label always has room to render above it without overlapping.
        double maxIntake = weeklyData.fold<double>(0.0, (max, data) {
          final val = data['intake'] as double;
          return val > max ? val : max;
        });
        // Always ensure dailyTarget line sits in the lower 75% of the chart
        final maxYValue =
            (maxIntake > dailyTarget ? maxIntake : dailyTarget) * 1.35;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withOpacity(0.25)
                    : Colors.blue[900]!.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header row ─────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Progress',
                        style: AppTextStyles.sectionHeader,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last 7 Days overview',
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.blue.withOpacity(0.2)
                          : Colors.blue[50]!.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: isDark
                          ? Border.all(
                              color: Colors.blue.withOpacity(0.3), width: 1)
                          : null,
                    ),
                    child: Text(
                      'Target: ${dailyTarget.toStringAsFixed(0)} ml',
                      style: AppTextStyles.badgeValue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ── Animated bar chart ─────────────────────────────────────
              AnimatedBuilder(
                animation: _barAnimation,
                builder: (context, _) {
                  final t = _barAnimation.value.clamp(0.0, 1.0);

                  return SizedBox(
                    height: 220,
                    child: BarChart(
                      swapAnimationDuration: Duration.zero,
                      BarChartData(
                        alignment: BarChartAlignment.spaceEvenly,
                        maxY: maxYValue,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipColor: (group) => Colors.blue[900]!,
                            tooltipBorderRadius: BorderRadius.circular(12),
                            tooltipPadding: const EdgeInsets.all(8),
                            getTooltipItem:
                                (group, groupIndex, rod, rodIndex) {
                              final dayData = weeklyData[groupIndex];
                              final intake = dayData['intake'] as double;
                              return BarTooltipItem(
                                '${dayData['day']}\n${intake.toStringAsFixed(0)} ml',
                                AppTextStyles.chartTooltip,
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();
                                if (index < 0 ||
                                    index >= weeklyData.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    weeklyData[index]['day'],
                                    style: AppTextStyles.axisLabel,
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        // Target line — label placed BELOW the line so bars
                        // never overlap it even when they touch the top.
                        extraLinesData: ExtraLinesData(
                          horizontalLines: [
                            HorizontalLine(
                              y: dailyTarget,
                              color: Colors.cyan[300]!.withOpacity(0.8),
                              strokeWidth: 1.5,
                              dashArray: [6, 4],
                              label: HorizontalLineLabel(
                                show: true,
                                // Placed bottom-left so it never overlaps
                                // a tall bar growing from the right
                                alignment: Alignment.bottomLeft,
                                padding: const EdgeInsets.only(
                                    left: 4, bottom: 4),
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.cyan[300]
                                      : Colors.cyan[700],
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  backgroundColor: isDark
                                      ? const Color(0xFF141B2D)
                                          .withOpacity(0.6)
                                      : Colors.white.withOpacity(0.6),
                                ),
                                labelResolver: (line) => ' Target ',
                              ),
                            ),
                          ],
                        ),
                        barGroups:
                            List.generate(weeklyData.length, (index) {
                          final dayData = weeklyData[index];
                          final intake =
                              (dayData['intake'] as double) * t;
                          final progress = dayData['progress'] as double;

                          LinearGradient rodGradient;
                          if (progress >= 1.0) {
                            rodGradient = const LinearGradient(
                              colors: [
                                Color(0xFF00E676),
                                Color(0xFF00B0FF)
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            );
                          } else if (progress >= 0.7) {
                            rodGradient = const LinearGradient(
                              colors: [
                                Color(0xFFFFB74D),
                                Color(0xFFFF8A65)
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            );
                          } else {
                            rodGradient = const LinearGradient(
                              colors: [
                                Color(0xFF4FC3F7),
                                Color(0xFF0288D1)
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            );
                          }

                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: intake,
                                gradient: rodGradient,
                                width: 16,
                                borderRadius: BorderRadius.circular(6),
                                backDrawRodData:
                                    BackgroundBarChartRodData(
                                  show: true,
                                  toY: dailyTarget,
                                  color: isDark
                                      ? Colors.white.withOpacity(0.05)
                                      : Colors.blue[50]!
                                          .withOpacity(0.35),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              // ── Legend ─────────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(
                      const Color(0xFF00E676), 'Goal Met', isDark),
                  const SizedBox(width: 16),
                  _buildLegendItem(
                      const Color(0xFFFFB74D), '70%+ Done', isDark),
                  const SizedBox(width: 16),
                  _buildLegendItem(
                      const Color(0xFF0288D1), 'Below', isDark),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label, bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.labelMedium),
      ],
    );
  }
}