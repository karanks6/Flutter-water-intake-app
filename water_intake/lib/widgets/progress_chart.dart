import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/intake_provider.dart';

class ProgressChart extends StatelessWidget {
  const ProgressChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IntakeProvider>(
      builder: (context, intakeProvider, child) {
        final weeklyData = intakeProvider.getWeeklyData();

        return Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Last 7 Days',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Target: ${intakeProvider.dailyTarget.toStringAsFixed(0)} ml',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Bar Chart Section
              LayoutBuilder(
                builder: (context, constraints) {
                  final maxBarHeight = constraints.maxHeight > 200 ? 160.0 : 120.0;

                  return SizedBox(
                    height: maxBarHeight + 50, // extra space for labels
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: weeklyData.map((data) {
                        final percentage = (data['intake'] / intakeProvider.dailyTarget).clamp(0.0, 1.0);
                        final barHeight = percentage * maxBarHeight;

                        Color startColor;
                        Color endColor;
                        if (percentage >= 1.0) {
                          startColor = Colors.green[700]!;
                          endColor = Colors.green[400]!;
                        } else if (percentage >= 0.7) {
                          startColor = Colors.orange[700]!;
                          endColor = Colors.orange[400]!;
                        } else {
                          startColor = Colors.blue[700]!;
                          endColor = Colors.blue[400]!;
                        }

                        return Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                '${data['intake'].toStringAsFixed(0)}',
                                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: barHeight,
                                width: 14,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [startColor, endColor],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                data['day'],
                                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(Colors.green, 'Goal Met'),
                  const SizedBox(width: 12),
                  _buildLegendItem(Colors.orange, 'Close'),
                  const SizedBox(width: 12),
                  _buildLegendItem(Colors.blue, 'Below'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
