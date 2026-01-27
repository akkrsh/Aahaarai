import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ApiService {
  // Android Emulator → http://10.0.2.2:8000
  // Windows → http://127.0.0.1:8000
  // Web → http://localhost:8000
  static const String baseUrl = "http://127.0.0.1:8000";

  static Future<List> uploadFoodImage(File image) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/food/upload'),
    );

    request.files.add(
      await http.MultipartFile.fromPath('image', image.path),
    );

    var response = await request.send();
    var responseBody = await response.stream.bytesToString();

    final decoded = jsonDecode(responseBody);
    return jsonDecode(decoded['ai'])['items'];
  }

  static Future<Map<String, dynamic>> getDailySummary() async {
    final response = await http.get(
      Uri.parse('$baseUrl/daily/summary?user_id=demo&burned=400'),
    );
    return jsonDecode(response.body);
  }
}