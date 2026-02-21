import 'dart:convert';
import 'package:http/http.dart' as http;
import 'weather_model.dart';

class WeatherService {
  final String apiKey = "ab361aaca5f0aa0a6bc91b19f47ea51b";

  Future<Weather> fetchWeather() async {
    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=Beni%20Mellal&units=metric&appid=$apiKey";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Weather.fromJson(data);
    } else {
      throw Exception("Erreur API");
    }
  }
}
