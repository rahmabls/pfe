import 'package:flutter/material.dart';
import 'weather_model.dart';
import 'weather_service.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Weather? weather;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      WeatherService service = WeatherService();
      Weather w = await service.fetchWeather();

      setState(() {
        weather = w;
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
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
          // ===== FOND DÉGRADÉ (IDENTIQUE) =====
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF3A1A6E), Color(0xFF1B1F3B)],
              ),
            ),
          ),

          SafeArea(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    slivers: [
                      /* ===== TITRE + NUAGE (IDENTIQUE) ===== */
                      SliverAppBar(
                        pinned: true,
                        floating: false,
                        backgroundColor: Colors.transparent,
                        expandedHeight: 220,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Béni Mellal",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              //valeur API
                              Text(
                                "${weather!.temp.toStringAsFixed(0)}° • ${weather!.description}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Icon(
                                Icons.cloud,
                                size: 140,
                                color: Colors.white.withOpacity(0.4),
                              ),
                            ],
                          ),
                        ),
                      ),

                      /* ===== CONTENU SCROLLABLE (IDENTIQUE) ===== */
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              SizedBox(
                                height: 120,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: const [
                                    HeureCard("1", "20°"),
                                    HeureCard("Now", "20°"),
                                    HeureCard("3", "20°"),
                                    HeureCard("4", "20°"),
                                    HeureCard("5", "20°"),
                                    HeureCard("6", "20°"),
                                    HeureCard("7", "20°"),
                                    HeureCard("8", "20°"),
                                    HeureCard("9", "20°"),
                                    HeureCard("10", "20°"),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              Row(
                                children: const [
                                  Icon(
                                    Icons.calendar_today,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "PRÉVISIONS SUR 10 JOURS",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),

                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: Column(
                                  children: const [
                                    ForecastRow(
                                      day: "Auj.",
                                      min: 11,
                                      max: 16,
                                      icon: Icons.cloud,
                                    ),
                                    ForecastRow(
                                      day: "Mar.",
                                      min: 11,
                                      max: 20,
                                      icon: Icons.wb_sunny,
                                    ),
                                    ForecastRow(
                                      day: "Mer.",
                                      min: 11,
                                      max: 22,
                                      icon: Icons.wb_sunny,
                                    ),
                                    ForecastRow(
                                      day: "Jeu.",
                                      min: 12,
                                      max: 22,
                                      icon: Icons.wb_sunny,
                                    ),
                                    ForecastRow(
                                      day: "Ven.",
                                      min: 9,
                                      max: 16,
                                      icon: Icons.cloud,
                                    ),
                                    ForecastRow(
                                      day: "Sam.",
                                      min: 7,
                                      max: 16,
                                      icon: Icons.wb_sunny,
                                    ),
                                    ForecastRow(
                                      day: "Dim.",
                                      min: 7,
                                      max: 20,
                                      icon: Icons.wb_sunny,
                                    ),
                                    ForecastRow(
                                      day: "Lun.",
                                      min: 10,
                                      max: 22,
                                      icon: Icons.wb_sunny,
                                    ),
                                    ForecastRow(
                                      day: "Mar.",
                                      min: 12,
                                      max: 23,
                                      icon: Icons.wb_sunny,
                                    ),
                                    ForecastRow(
                                      day: "Mer.",
                                      min: 12,
                                      max: 23,
                                      icon: Icons.wb_sunny,
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              /* ===== GRILLE D’INFOS ===== */
                              GridView.count(
                                crossAxisCount: 2,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                children: const [
                                  InfoMiniCard(
                                    title: "RESSENTI",
                                    value: "15°",
                                    icon: Icons.thermostat,
                                  ),
                                  InfoMiniCard(
                                    title: "INDICE UV",
                                    value: "4",
                                    icon: Icons.wb_sunny,
                                  ),
                                  InfoMiniCard(
                                    title: "VENT",
                                    value: "8 km/h",
                                    icon: Icons.air,
                                  ),
                                  InfoMiniCard(
                                    title: "HUMIDITÉ",
                                    value: "81%",
                                    icon: Icons.water_drop,
                                  ),
                                  InfoMiniCard(
                                    title: "VISIBILITÉ",
                                    value: "14 km",
                                    icon: Icons.visibility,
                                  ),
                                  InfoMiniCard(
                                    title: "PRÉCIPITATIONS",
                                    value: "3 mm",
                                    icon: Icons.water_drop_outlined,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              /* ===== PRESSION ===== */
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                  ),
                                ),
                                child: const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "PRESSION",
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "1.024 hPa",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        },
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF8E2DE2), Color(0xFF6A4CFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8E2DE2).withOpacity(0.6),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(Icons.psychology, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      /* ===== BARRE ARRONDIE (TU NE VOULAIS PAS TOUCHER) ===== */
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Container(
          height: 70,
          decoration: BoxDecoration(
            color: const Color(0xFF2B1055).withOpacity(0.95),
            borderRadius: BorderRadius.circular(35), // 🔹 arrondi
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // ⚙️ Paramètres (gauche)
              IconButton(
                icon: const Icon(Icons.settings, color: Colors.white, size: 26),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),

              // 🏠 Accueil (mis en avant au centre)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF6A4CFF), // violet plus clair
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.home, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.pushNamed(context, '/');
                  },
                ),
              ),

              // 📅 Prévisions (droite)
              IconButton(
                icon: const Icon(
                  Icons.calendar_month,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/forecast');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ===== CARTES (IDENTIQUES) ===== */
class InfoMiniCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const InfoMiniCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFC6B6FF)),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: Colors.white70)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/* ===== PRÉVISIONS 10 JOURS ===== */
class ForecastRow extends StatelessWidget {
  final String day;
  final int min;
  final int max;
  final IconData icon;

  const ForecastRow({
    super.key,
    required this.day,
    required this.min,
    required this.max,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    double ratio = (max - min) / 15;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 60,
            child: Text(
              day,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Icon(icon, color: Colors.yellowAccent, size: 22),
          const SizedBox(width: 10),
          SizedBox(
            width: 30,
            child: Text("$min°", style: const TextStyle(color: Colors.white70)),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: ratio.clamp(0.2, 1.0),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8AFF8A), Color(0xFFFFE066)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            "$max°",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

/* ===== CARTES HORAIRES ===== */
class HeureCard extends StatelessWidget {
  final String hour;
  final String temp;

  const HeureCard(this.hour, this.temp, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF6A4CFF).withOpacity(0.25),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hour,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Icon(Icons.cloud, color: Colors.white),
          const SizedBox(height: 6),
          Text(
            temp,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
