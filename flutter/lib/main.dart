// import 'package:flutter/material.dart';
// import 'api.dart';
// import 'data_jarak.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Data Ultrasonic',
//       debugShowCheckedModeBanner: false,
//       home: DataJarakPage(),
//     );
//   }
// }

// class DataJarakPage extends StatefulWidget {
//   @override
//   _DataJarakPageState createState() => _DataJarakPageState();
// }

// class _DataJarakPageState extends State<DataJarakPage> {
//   late Future<List<JarakData>> futureData;

//   @override
//   void initState() {
//     super.initState();
//     futureData = ApiService().fetchData();
//   }

//   Future<void> _refreshData() async {
//     setState(() {
//       futureData = ApiService().fetchData();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Data Tekanan Darah'),
//         actions: [
//           IconButton(
//             icon: Icon(Icons.refresh),
//             onPressed: _refreshData,
//           )
//         ],
//       ),
//       body: FutureBuilder<List<JarakData>>(
//         future: futureData,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('Belum ada data'));
//           } else {
//             List<JarakData> data = snapshot.data!;
//             return ListView.builder(
//               itemCount: data.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text('Jarak: ${data[index].jarak} cm'),
//                   subtitle: Text('Waktu: ${data[index].waktu}'),
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:async';
import 'history.dart';

void main() => runApp(MyApp());

class HeartData {
  final double bpm;
  final int spo2;
  final String waktu;

  HeartData({required this.bpm, required this.spo2, required this.waktu});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deteksi Tekanan Jantung',
      debugShowCheckedModeBanner: false,
      home: HeartRatePage(),
    );
  }
}

class HeartRatePage extends StatefulWidget {
  @override
  _HeartRatePageState createState() => _HeartRatePageState();
}

class _HeartRatePageState extends State<HeartRatePage>
    with SingleTickerProviderStateMixin {
  List<HeartData> fullData = [];
  List<HeartData> visibleData = [];
  Timer? dataTimer;
  int currentIndex = 0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    fullData = [
      HeartData(bpm: 19.5, spo2: 38, waktu: '08:00'),
      HeartData(bpm: 12.0, spo2: 31, waktu: '08:05'),
      HeartData(bpm: 12.5, spo2: 32, waktu: '08:10'),
      HeartData(bpm: 13.2, spo2: 33, waktu: '08:15'),
      HeartData(bpm: 11.7, spo2: 30, waktu: '08:20'),
      HeartData(bpm: 18.0, spo2: 34, waktu: '08:25'),
      HeartData(bpm: 15.8, spo2: 35, waktu: '10:30'),
    ];

    dataTimer = Timer.periodic(Duration(milliseconds: 250), (timer) {
      if (currentIndex < fullData.length) {
        setState(() {
          visibleData.add(fullData[currentIndex]);
          currentIndex++;
        });
      } else {
        timer.cancel();
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    dataTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  double getAverageBPM() {
    if (visibleData.isEmpty) return 0.0;
    return visibleData.map((e) => e.bpm).reduce((a, b) => a + b) /
        visibleData.length;
  }

  void _showHistoryDialog() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => HeartHistoryPage(data: visibleData),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final last = visibleData.isNotEmpty ? visibleData.last : null;
    final avgBpm = getAverageBPM();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('Deteksi Tekanan Jantung'),
            Spacer(),
            IconButton(
              icon: Icon(Icons.access_time),
              onPressed: _showHistoryDialog,
            )
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: visibleData.isEmpty
            ? Center(child: Text('Menunggu data BPM pertama...'))
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade200,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('AVG BPM:', style: TextStyle(fontSize: 14)),
                                      Text(avgBpm.toStringAsFixed(1),
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                      SizedBox(height: 12),
                                      Text('SPO²:', style: TextStyle(fontSize: 14)),
                                      Text('${last?.spo2 ?? "-"}%',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                ScaleTransition(
                                  scale: Tween(begin: 1.0, end: 1.2).animate(
                                      CurvedAnimation(
                                          parent: _animationController,
                                          curve: Curves.easeInOut)),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Icon(Icons.favorite,
                                          color: Colors.red, size: 85),
                                      Text(
                                        last?.bpm.toStringAsFixed(1) ?? "-",
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Text('Grafik Beats per Minute (BPM)',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 200,
                      child: LineChart(
                        LineChartData(
                          minX: 0,
                          maxX: (visibleData.length - 1).toDouble(),
                          minY: 0,
                          maxY: 30,
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, _) {
                                  int index = value.toInt();
                                  if (index < visibleData.length) {
                                    return Text(visibleData[index].waktu,
                                        style: TextStyle(fontSize: 10));
                                  }
                                  return Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: true),
                            ),
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              spots: visibleData
                                  .asMap()
                                  .entries
                                  .map((e) => FlSpot(
                                      e.key.toDouble(), e.value.bpm))
                                  .toList(),
                              isCurved: true,
                              color: Colors.red,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(show: false),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}