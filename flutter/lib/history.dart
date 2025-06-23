import 'package:flutter/material.dart';
import 'main.dart'; // untuk akses HeartData

class HeartHistoryPage extends StatelessWidget {
  final List<HeartData> data;

  const HeartHistoryPage({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Riwayat Pembacaan')),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          final d = data[index];
          return ListTile(
            leading: Icon(Icons.favorite, color: Colors.red),
            title: Text('BPM: ${d.bpm}'),
            subtitle: Text('SPO²: ${d.spo2}%, Waktu: ${d.waktu}'),
          );
        },
      ),
    );
  }
}