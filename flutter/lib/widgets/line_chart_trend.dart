import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/heart_data.dart';

class LineChartTrend extends StatelessWidget {
  final List<HeartData> data;

  const LineChartTrend({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text('Tidak ada data tren.'));
    }

    // Pakai index sebagai X dan BPM sebagai Y
    final spots = List.generate(data.length, (i) {
      return FlSpot(i.toDouble(), data[i].bpm);
    });

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: 180,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Text(data[index].waktu);
                }
                return const Text('');
              },
              interval: 1,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, interval: 30),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            spots: spots,
            color: Colors.red,
            barWidth: 2,
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
