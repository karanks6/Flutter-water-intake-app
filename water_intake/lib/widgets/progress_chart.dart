import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/intake_provider.dart';

class ProgressChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<IntakeProvider>(
      builder: (context, intakeProvider, child) {
        final weeklyData = intakeProvider.getWeeklyData();

        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            children: [
              // Chart Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Last 7 Days',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Target: ${intakeProvider.dailyTarget.toStringAsFixed(0)} ml',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Bar Chart
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: weeklyData.map((data) {
                    final percentage =
                        data['intake'] / intakeProvider.dailyTarget;
                    final barHeight = (percentage * 120).clamp(0.0, 120.0);

                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 2),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Amount text
                            Text(
                              '${data['intake'].toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),

                            SizedBox(height: 4),

                            // Bar
                            Container(
                              width: double.infinity,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: percentage >= 1.0
                                    ? Colors.green
                                    : percentage >= 0.7
                                    ? Colors.orange
                                    : Colors.blue,
                                borderRadius: BorderRadius.circular(4),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    percentage >= 1.0
                                        ? Colors.green[700]!
                                        : percentage >= 0.7
                                        ? Colors.orange[700]!
                                        : Colors.blue[700]!,
                                    percentage >= 1.0
                                        ? Colors.green[400]!
                                        : percentage >= 0.7
                                        ? Colors.orange[400]!
                                        : Colors.blue[400]!,
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 8),

                            // Day label
                            Text(
                              data['day'],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              SizedBox(height: 8),

              // Legend
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(Colors.green, 'Goal Met'),
                  SizedBox(width: 16),
                  _buildLegendItem(Colors.orange, 'Close'),
                  SizedBox(width: 16),
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
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }
}
