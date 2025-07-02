import 'package:flutter/material.dart';
import '../models/heart_data.dart';
import '../services/api_service.dart';

class HeartHistoryPage extends StatefulWidget {
  const HeartHistoryPage({super.key});

  @override
  State<HeartHistoryPage> createState() => _HeartHistoryPageState();
}

class _HeartHistoryPageState extends State<HeartHistoryPage> {
  List<HeartData> displayedData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData(); // langsung ambil data dari API saat halaman dibuka
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService().fetchHeartRate();
      final data = response.map((item) => HeartData.fromRawJson(item)).toList();

      setState(() {
        displayedData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memuat data riwayat')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pembacaan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchData,
            tooltip: 'Perbarui data',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : displayedData.isEmpty
          ? const Center(child: Text('Belum ada data riwayat.'))
          : ListView.builder(
              itemCount: displayedData.length,
              itemBuilder: (context, index) {
                final d = displayedData[index];
                return ListTile(
                  leading: const Icon(Icons.favorite, color: Colors.red),
                  title: Text('BPM: ${d.bpm.toStringAsFixed(1)}'),
                  subtitle: Text(
                    'SPO²: ${d.spo2.toStringAsFixed(1)}%, Waktu: ${d.waktu}',
                  ),
                );
              },
            ),
    );
  }
}
