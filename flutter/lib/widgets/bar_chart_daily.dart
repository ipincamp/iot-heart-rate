import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/heart_data.dart';

class BarChartDaily extends StatelessWidget {
  final List<HeartData> data;
  const BarChartDaily({super.key, required this.data});

  @override
  @override
  Widget build(BuildContext context) {
    final sorted = data.where((e) => e.date != null).toList()
      ..sort((a, b) => a.date!.compareTo(b.date!));

    final List<BarChartGroupData> bars = [];
    final List<String> labels = [];

    for (int i = 0; i < sorted.length; i++) {
      final d = sorted[i];
      bars.add(
        BarChartGroupData(
          x: i,
          barRods: [BarChartRodData(toY: d.bpm, color: Colors.blue)],
        ),
      );
      labels.add(d.date!.substring(5));
    }

    return BarChart(
      BarChartData(
        barGroups: bars,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                return index < labels.length
                    ? Text(labels[index], style: TextStyle(fontSize: 10))
                    : Text('');
              },
            ),
          ),
        ),
      ),
    );
  }
}
