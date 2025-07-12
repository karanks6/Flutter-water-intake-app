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
            mainAxisSize: MainAxisSize.min, // Prevent column from expanding unnecessarily
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

              // Bar Chart with fixed height - everything contained within
              Container(
                height: 280, // Further increased height to accommodate all elements
                padding: EdgeInsets.all(8), // Add padding to ensure content stays within bounds
                child: Column(
                  children: [
                    // Bar chart section
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // Calculate space allocation
                          final topLabelHeight = 16.0;
                          final bottomLabelHeight = 16.0;
                          final legendHeight = 20.0;
                          final spacing = 8.0;
                          final maxBarHeight = constraints.maxHeight - 
                              topLabelHeight - bottomLabelHeight - legendHeight - (spacing * 3);

                          // Find maximum intake for proper scaling
                          final maxIntake = weeklyData.fold<double>(0, (max, data) {
                            final intake = data['intake'] as double;
                            return intake > max ? intake : max;
                          });
                          
                          // Use the larger value for scaling to prevent overflow
                          final scaleReference = maxIntake > intakeProvider.dailyTarget 
                              ? maxIntake 
                              : intakeProvider.dailyTarget;

                          return Column(
                            children: [
                              // Bar chart area
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: weeklyData.map((data) {
                                    final intake = data['intake'] as double;
                                    final percentage = intake / intakeProvider.dailyTarget;
                                    
                                    // Scale bar height based on the reference value
                                    final barHeight = intake == 0 ? 0.0 : 
                                        (intake / scaleReference * maxBarHeight)
                                            .clamp(5.0, maxBarHeight); // Minimum height of 4 for visibility

                                    return Expanded(
                                      child: Container(
                                        margin: EdgeInsets.symmetric(horizontal: 2),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            // Amount text with fixed height
                                            Container(
                                              height: topLabelHeight,
                                              alignment: Alignment.center,
                                              child: Text(
                                                intake.toStringAsFixed(0),
                                                style: TextStyle(
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ),

                                            SizedBox(height: 2),

                                            // Bar container with fixed height
                                            Container(
                                              height: maxBarHeight,
                                              alignment: Alignment.bottomCenter,
                                              child: Container(
                                                width: double.infinity,
                                                height: barHeight,
                                                decoration: BoxDecoration(
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
                                            ),

                                            SizedBox(height: 4),

                                            // Day label with fixed height
                                            Container(
                                              height: bottomLabelHeight,
                                              alignment: Alignment.center,
                                              child: Text(
                                                data['day'],
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey[700],
                                                ),
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

                              // Legend - contained within the chart container
                              SizedBox(
                                height: legendHeight,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _buildLegendItem(Colors.green, 'Goal Met'),
                                    SizedBox(width: 12),
                                    _buildLegendItem(Colors.orange, 'Close'),
                                    SizedBox(width: 12),
                                    _buildLegendItem(Colors.blue, 'Below'),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
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