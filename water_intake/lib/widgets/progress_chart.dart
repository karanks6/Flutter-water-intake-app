import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/intake_provider.dart';
import 'package:intl/intl.dart';

class ProgressChart extends StatelessWidget {
  const ProgressChart({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<IntakeProvider>(context);
    final now = DateTime.now();
    final weekData = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      final total = provider.getEntriesForDay(day).fold(0, (sum, e) => sum + e.amount);
      return FlSpot(i.toDouble(), total.toDouble());
    });

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: weekData,
              isCurved: true,
              barWidth: 4,
              gradient: LinearGradient(
                  colors: [Colors.blue, Colors.lightBlueAccent],
              ),
              dotData: FlDotData(show: false),
            )
          ],
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final day = now.subtract(Duration(days: 6 - value.toInt()));
                  return Text(DateFormat.E().format(day));
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}