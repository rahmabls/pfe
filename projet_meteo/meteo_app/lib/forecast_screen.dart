import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

/* SERVICE API */
class WeatherService {
  static const String apiKey = "ab361aaca5f0aa0a6bc91b19f47ea51b";
  static const String url =
      "https://api.openweathermap.org/data/2.5/weather?q=Beni%20Mellal&units=metric&lang=fr&appid=$apiKey";

  static Future<Map<String, dynamic>> fetchWeather() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception("Erreur API météo");
    }
  }
}

/* =========================
   ECRAN FORECAST
   ========================= */
class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});

  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  Map<String, dynamic>? weatherData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadWeather();
  }

  Future<void> loadWeather() async {
    try {
      final data = await WeatherService.fetchWeather();
      setState(() {
        weatherData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3A1A6E), Color(0xFF1B1F3B)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /* ===== TITRE ===== */
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Prévisions détaillées",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.home, color: Colors.white),
                      onPressed: () {
                        Navigator.pushNamed(context, '/');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  weatherData!["name"],
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),

                const SizedBox(height: 20),

                /* ===== LEVER / COUCHER DU SOLEIL (API) ===== */
                DetailCard(
                  title: "Cycle solaire",
                  icon: Icons.wb_sunny,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "☀️ Lever : ${DateTime.fromMillisecondsSinceEpoch(weatherData!["sys"]["sunrise"] * 1000).toLocal().hour}:${DateTime.fromMillisecondsSinceEpoch(weatherData!["sys"]["sunrise"] * 1000).toLocal().minute.toString().padLeft(2, '0')}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "🌇 Coucher : ${DateTime.fromMillisecondsSinceEpoch(weatherData!["sys"]["sunset"] * 1000).toLocal().hour}:${DateTime.fromMillisecondsSinceEpoch(weatherData!["sys"]["sunset"] * 1000).toLocal().minute.toString().padLeft(2, '0')}",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                /* ===== PHASE DE LA LUNE (statique comme avant) ===== */
                const DetailCard(
                  title: "Phase lunaire",
                  icon: Icons.nightlight_round,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🌙 Dernier quartier",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Illumination : 50%",
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Prochaine pleine lune : dans 22 jours",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                /* ===== POINT DE ROSÉE (API APPROXIMATION) ===== */
                DetailCard(
                  title: "Point de rosée",
                  icon: Icons.thermostat,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🌡️ ${weatherData!["main"]["temp"].toStringAsFixed(0)}°C",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Air plutôt humide.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                /* ===== COUVERTURE NUAGEUSE ===== */
                DetailCard(
                  title: "Couverture nuageuse",
                  icon: Icons.cloud,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "☁️ ${weatherData!["clouds"]["all"]}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Ciel majoritairement couvert.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                /* ===== VENT & RAFALES ===== */
                DetailCard(
                  title: "Vent & rafales",
                  icon: Icons.air,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "🌬 Vent : ${weatherData!["wind"]["speed"]} km/h",
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "🧭 Direction : ${weatherData!["wind"]["deg"]}°",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                /* ===== RISQUE MÉTÉO ===== */
                DetailCard(
                  title: "Risque météo",
                  icon: Icons.warning_amber,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "⚠️ ${weatherData!["weather"][0]["description"]}",
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Données issues d’OpenWeatherMap",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/* ===== WIDGET CARTE (IDENTIQUE À TON DESIGN) ===== */
class DetailCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const DetailCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFC6B6FF)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
