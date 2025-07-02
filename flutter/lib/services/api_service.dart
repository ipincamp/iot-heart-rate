import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://localhost:3000/api/heartrate';

  Future<List<dynamic>> fetchHeartRate() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch heart rate data');
    }
  }

  Future<List<dynamic>> fetchDailyTrend() async {
    final res = await http.get(Uri.parse('$baseUrl/trend/daily'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to fetch daily trend');
  }

  Future<List<dynamic>> fetchHourlyTrend() async {
    final res = await http.get(Uri.parse('$baseUrl/trend/hourly'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to fetch hourly trend');
  }
}
