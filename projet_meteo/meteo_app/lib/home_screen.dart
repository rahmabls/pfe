import 'package:flutter/material.dart';
import 'api_service.dart';
import 'chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? meteo;
  bool isLoading = true;
  String? erreur;

  @override
  void initState() {
    super.initState();
    _chargerMeteo();
  }

  Future<void> _chargerMeteo() async {
    setState(() {
      isLoading = true;
      erreur = null;
    });
    try {
      final data = await ApiService.get("/meteo/accueil");
      setState(() {
        meteo = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        erreur = "Impossible de charger la météo";
      });
    }
  }

  IconData _iconeMeteo(String? icone) {
    switch (icone) {
      case "rainy":
        return Icons.grain;
      case "windy":
        return Icons.air;
      case "cloudy":
        return Icons.cloud;
      case "partly_cloudy":
        return Icons.cloud_queue;
      case "hot":
        return Icons.wb_sunny;
      default:
        return Icons.wb_sunny;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      body: Stack(
        children: [
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
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : erreur != null
                ? _buildErreur()
                : _buildContenu(),
          ),
        ],
      ),
      floatingActionButton: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        ),
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF8E2DE2), Color(0xFF6A4CFF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8E2DE2).withOpacity(0.6),
                blurRadius: 20,
              ),
            ],
          ),
          child: const Icon(Icons.psychology, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildErreur() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: Colors.white54, size: 60),
          const SizedBox(height: 12),
          Text(erreur!, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _chargerMeteo,
            child: const Text("Réessayer"),
          ),
        ],
      ),
    );
  }

  Widget _buildContenu() {
    final pred = meteo!["predictions"] as Map<String, dynamic>;
    final pluie = pred["pluie"] as Map<String, dynamic>;
    final vent = pred["vent"] as Map<String, dynamic>;
    final canicule = pred["canicule"] as Map<String, dynamic>;

    return RefreshIndicator(
      onRefresh: _chargerMeteo,
      child: CustomScrollView(
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: Colors.transparent,
            expandedHeight: 220,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    meteo!["ville"] ?? "Béni Mellal",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${meteo!["temperature_actuelle_C"]}°C • ${meteo!["ressenti_C"]}° ressenti",
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Icon(
                    _iconeMeteo(meteo!["icone"]),
                    size: 120,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Prévisions horaires ML ─────────────────────────────
                  SizedBox(
                    height: 120,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _HeureCard(
                          "Maint.",
                          "${meteo!["temperature_actuelle_C"]}°",
                        ),
                        _HeureCard("+1h", "${pred["temperature_1h_C"]}°"),
                        _HeureCard("+24h", "${pred["temperature_24h_C"]}°"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Grille infos live ──────────────────────────────────
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    children: [
                      _InfoMiniCard(
                        "RESSENTI",
                        "${meteo!["ressenti_C"]}°",
                        Icons.thermostat,
                      ),
                      _InfoMiniCard(
                        "HUMIDITÉ",
                        "${meteo!["humidite_pct"]}%",
                        Icons.water_drop,
                      ),
                      _InfoMiniCard(
                        "VENT",
                        "${meteo!["vent_kmh"]} km/h",
                        Icons.air,
                      ),
                      _InfoMiniCard(
                        "RAFALES",
                        "${meteo!["rafales_kmh"]} km/h",
                        Icons.storm,
                      ),
                      _InfoMiniCard(
                        "UV",
                        "${meteo!["uv_index"]}",
                        Icons.wb_sunny,
                      ),
                      _InfoMiniCard(
                        "NUAGES",
                        "${meteo!["couverture_nuageuse_pct"]}%",
                        Icons.cloud,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── Pression ───────────────────────────────────────────
                  _CarteInfo(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "PRESSION",
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${meteo!["pression_hpa"]} hPa",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Alertes ML ─────────────────────────────────────────
                  if (pluie["pluie_probable"] == true ||
                      vent["vent_fort"] == true ||
                      canicule["canicule"] == true)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "⚠️ ALERTES",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (pluie["pluie_probable"] == true)
                          _AlerteBadge(
                            "🌧️ Pluie probable — ${pluie["probabilite"]}%",
                            Colors.blueAccent,
                          ),
                        if (vent["vent_fort"] == true)
                          _AlerteBadge(
                            "💨 Vent fort — ${vent["probabilite"]}%",
                            Colors.orangeAccent,
                          ),
                        if (canicule["canicule"] == true)
                          _AlerteBadge(
                            "🔥 Risque canicule — ${canicule["probabilite"]}%",
                            Colors.redAccent,
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFF2B1055).withOpacity(0.95),
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 26),
              onPressed: () => Navigator.pushNamed(context, '/settings'),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: Color(0xFF6A4CFF),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.home, color: Colors.white, size: 30),
                onPressed: () => Navigator.pushNamed(context, '/'),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.calendar_month,
                color: Colors.white,
                size: 26,
              ),
              onPressed: () => Navigator.pushNamed(context, '/forecast'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Widgets réutilisables ─────────────────────────────────────────────────────

class _HeureCard extends StatelessWidget {
  final String hour, temp;
  const _HeureCard(this.hour, this.temp);
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
          const Icon(Icons.cloud, color: Colors.white),
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

class _InfoMiniCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  const _InfoMiniCard(this.title, this.value, this.icon);
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
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          Text(
            value,
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

class _CarteInfo extends StatelessWidget {
  final Widget child;
  const _CarteInfo({required this.child});
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
      child: child,
    );
  }
}

class _AlerteBadge extends StatelessWidget {
  final String message;
  final Color color;
  const _AlerteBadge(this.message, this.color);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        message,
        style: TextStyle(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
