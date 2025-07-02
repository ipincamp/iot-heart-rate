import 'package:intl/intl.dart';

class HeartData {
  final double bpm;
  final double spo2;
  final String waktu;
  final String? date;
  final int? group;

  HeartData({
    required this.bpm,
    required this.spo2,
    required this.waktu,
    this.date,
    this.group,
  });

  factory HeartData.fromHourlyJson(Map<String, dynamic> json) {
    return HeartData(
      bpm: (json['avg_bpm'] ?? 0).toDouble(), // ← ganti ke avg_bpm
      spo2: 0,
      group: json['group'],
      waktu: '${json['hour']}:00', // ← format waktu jadi jam
    );
  }

  factory HeartData.fromDailyJson(Map<String, dynamic> json) {
    return HeartData(
      bpm: (json['avg_bpm'] ?? 0).toDouble(),
      spo2: 0,
      waktu: '',
      date: json['date'],
    );
  }

  factory HeartData.fromRawJson(Map<String, dynamic> json) {
    return HeartData(
      bpm: (json['bpm'] ?? 0).toDouble(),
      spo2: (json['spo2'] ?? 0).toDouble(),
      waktu: json['timestamp'] != null
          ? DateFormat.Hms().format(DateTime.parse(json['timestamp']))
          : "-",
      date: json['timestamp'] != null
          ? DateFormat('yyyy-MM-dd').format(DateTime.parse(json['timestamp']))
          : null,
    );
  }
}
