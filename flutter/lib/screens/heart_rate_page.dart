import 'package:flutter/material.dart';
import 'dart:async';
import 'package:praktikum/widgets/bar_chart_daily.dart';
import 'package:praktikum/widgets/line_chart_trend.dart';
import 'package:praktikum/models/heart_data.dart';
import 'package:praktikum/screens/history.dart';
import 'package:praktikum/services/api_service.dart';
import 'package:praktikum/widgets/heart_status_card.dart';

class HeartRatePage extends StatefulWidget {
  const HeartRatePage({super.key});

  @override
  State<HeartRatePage> createState() => _HeartRatePageState();
}

class _HeartRatePageState extends State<HeartRatePage>
    with SingleTickerProviderStateMixin {
  List<HeartData> realtimeData = []; // ← dari fetchHeartRate()
  List<HeartData> hourlyTrendData = [];
  List<HeartData> dailyTrendData = [];
  Timer? refreshTimer;
  Timer? _staleCheckTimer;
  late AnimationController _animationController;

  DateTime? _lastDataTime;
  bool _isDataStale = false;

  List<HeartData> get visibleData => hourlyTrendData;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _fetchData();

    refreshTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchData(),
    );

    _staleCheckTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _checkDataStale(),
    );
  }

  Future<void> _fetchData() async {
    try {
      final realtimeResponse = await ApiService().fetchHeartRate();
      final rawData = realtimeResponse
          .map((item) => HeartData.fromRawJson(item))
          .toList();

      final hourlyResponse = await ApiService().fetchHourlyTrend();
      final dailyResponse = await ApiService().fetchDailyTrend();

      final hourlyData = hourlyResponse
          .map((item) => HeartData.fromHourlyJson(item))
          .toList();
      final dailyData = dailyResponse
          .map((item) => HeartData.fromDailyJson(item))
          .toList();

      setState(() {
        realtimeData = rawData;
        hourlyTrendData = hourlyData;
        dailyTrendData = dailyData;
        _lastDataTime = DateTime.now();
        _isDataStale = false;
        _animationController.repeat(reverse: true);
      });
    } catch (e) {
      print("Gagal mengambil data: $e");
    }
  }

  void _checkDataStale() {
    if (_lastDataTime == null) return;

    final isStale = DateTime.now().difference(_lastDataTime!).inSeconds > 5;
    if (isStale != _isDataStale) {
      setState(() {
        _isDataStale = isStale;
        if (_isDataStale) {
          _animationController.stop();
        } else {
          _animationController.repeat(reverse: true);
        }
      });
    }
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    _staleCheckTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  double getAverageBPM() {
    if (visibleData.isEmpty) return 0.0;
    return visibleData.map((e) => e.bpm).reduce((a, b) => a + b) /
        visibleData.length;
  }

  void _showHistoryPage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const HeartHistoryPage()));
  }

  @override
  Widget build(BuildContext context) {
    if (_isDataStale && _animationController.isAnimating) {
      _animationController.stop();
    } else if (!_isDataStale && !_animationController.isAnimating) {
      _animationController.repeat(reverse: true);
    }

    final last = realtimeData.isNotEmpty ? realtimeData.last : null;
    final avgBpm = getAverageBPM();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Deteksi Tekanan Jantung'),
        actions: [
          IconButton(
            icon: const Icon(Icons.access_time),
            onPressed: _showHistoryPage,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: visibleData.isEmpty
            ? const Center(child: Text('Menunggu data BPM...'))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeartStatusCard(
                      avgBpm: avgBpm,
                      last: last,
                      isAnimating: !_isDataStale && visibleData.isNotEmpty,
                      animationController: _animationController,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Grafik Tren BPM (1 Jam Terakhir)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: LineChartTrend(data: hourlyTrendData),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Grafik Rata-rata BPM Harian',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: BarChartDaily(data: dailyTrendData),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
