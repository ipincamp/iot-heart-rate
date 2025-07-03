// lib/widgets/line_chart_trend.dart

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/heart_data.dart';

class LineChartTrend extends StatelessWidget {
  final List<HeartData> data;

  const LineChartTrend({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Tidak ada data tren.'));
    }

    final spots = data
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.bpm))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 180,
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

            // Sumbu X (waktu)
            bottomTitles: AxisTitles(
              axisNameWidget: const Text('Waktu'),
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final idx = value.toInt();
                  if (idx < 0 || idx >= data.length) {
                    return const SizedBox.shrink();
                  }

                  // Format waktu menggunakan DateFormat
                  final datetimeString = data[idx].date; // This is a String?
                  final datetime = datetimeString != null
                      ? DateTime.parse(datetimeString)
                      : DateTime.now();
                  final label = DateFormat('HH:mm').format(datetime);

                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(label, style: const TextStyle(fontSize: 10)),
                  );
                },
              ),
            ),

            // Sumbu Y (BPM)
            leftTitles: AxisTitles(
              axisNameWidget: const Text('BPM'),
              sideTitles: SideTitles(
                showTitles: true,
                interval: 30,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(value.toInt().toString()),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 2,
              color: Colors.red,
              dotData: FlDotData(show: false),
              belowBarData: BarAreaData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
