// import 'dart:convert'; 
// import 'package:http/http.dart' as http; 
// import 'data_jarak.dart'; 
 
// class ApiService { 
//   final String baseUrl = 
// "http://10.10.25.43:8000/get_data.php"; 
 
//   Future<List<JarakData>> fetchData() async { 
//     final response = await http.get(Uri.parse(baseUrl)); 
 
//     if (response.statusCode == 200) { 
//       final jsonData = json.decode(response.body); 
//       if (jsonData['status'] == true) { 
//         List dataList = jsonData['data']; 
//         return dataList.map((item) => 
// JarakData.fromJson(item)).toList(); 
//       } else { 
//         throw Exception("API error: ${jsonData['message']}"); 
//       } 
//     } else { 
//       throw Exception("Failed to load data from server"); 
//     } 
//   } 
// } 

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tekanan_darah.dart';

class ApiService {
  Future<List<TekananDarahData>> fetchTekananDarah() async {
    final response = await http.get(Uri.parse('http://your-api-url/tekanan-darah'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => TekananDarahData.fromJson(data)).toList();
    } else {
      throw Exception('Gagal memuat data tekanan darah');
    }
  }
}
