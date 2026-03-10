import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Émulateur Android → 10.0.2.2 = localhost du PC
  static const String baseUrl = "http://10.0.2.2:8000";

  static final Map<String, String> _headers = {
    "Content-Type": "application/json",
  };

  static Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http
        .get(Uri.parse("$baseUrl$endpoint"), headers: _headers)
        .timeout(const Duration(seconds: 10));
    return _handle(response);
  }

  static Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final response = await http
        .patch(
          Uri.parse("$baseUrl$endpoint"),
          headers: _headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 10));
    return _handle(response);
  }

  static Future<Map<String, dynamic>> post(
    String endpoint, [
    Map<String, dynamic>? body,
  ]) async {
    final response = await http
        .post(
          Uri.parse("$baseUrl$endpoint"),
          headers: _headers,
          body: body != null ? jsonEncode(body) : null,
        )
        .timeout(const Duration(seconds: 10));
    return _handle(response);
  }

  static Map<String, dynamic> _handle(http.Response response) {
    final data = jsonDecode(utf8.decode(response.bodyBytes));
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    throw Exception(
      "Erreur ${response.statusCode} : ${data['detail'] ?? response.body}",
    );
  }
}
