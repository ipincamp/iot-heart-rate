import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tekanan_darah.dart';

class ApiService {
  Future<List<TekananDarahData>> fetchTekananDarah() async {
    final response = await http.get(
      Uri.parse('http://your-api-url/tekanan-darah'),
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse
          .map((data) => TekananDarahData.fromJson(data))
          .toList();
    } else {
      throw Exception('Gagal memuat data tekanan darah');
    }
  }
}
