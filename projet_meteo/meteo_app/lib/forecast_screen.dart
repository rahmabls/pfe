import 'package:flutter/material.dart';
import 'api_service.dart';

class ForecastScreen extends StatefulWidget {
  const ForecastScreen({super.key});
  @override
  State<ForecastScreen> createState() => _ForecastScreenState();
}

class _ForecastScreenState extends State<ForecastScreen> {
  Map<String, dynamic>? astro;
  Map<String, dynamic>? pluie;
  Map<String, dynamic>? vent;
  Map<String, dynamic>? canicule;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    setState(() { isLoading = true; });
    try {
      final results = await Future.wait([
        ApiService.get("/astronomie/aujourd-hui"),
        ApiService.get("/prediction/pluie"),
        ApiService.get("/prediction/vent"),
        ApiService.get("/prediction/canicule"),
      ]);
      setState(() {
        astro    = results[0];
        pluie    = results[1];
        vent     = results[2];
        canicule = results[3];
        isLoading = false;
      });
    } catch (_) {
      setState(() { isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.white))
              : RefreshIndicator(
                  onRefresh: _charger,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Titre
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Prévisions détaillées",
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.home, color: Colors.white),
                              onPressed: () => Navigator.pushNamed(context, '/'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // ── Cycle solaire ─────────────────────────────────
                        if (astro != null) ...[
                          DetailCard(
                            title: "Cycle solaire",
                            icon: Icons.wb_sunny,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("☀️ Lever : ${astro!["soleil"]["lever_soleil"]}", style: const TextStyle(color: Colors.white)),
                                const SizedBox(height: 6),
                                Text("🌇 Coucher : ${astro!["soleil"]["coucher_soleil"]}", style: const TextStyle(color: Colors.white)),
                                const SizedBox(height: 6),
                                Text("⏱ Durée du jour : ${astro!["soleil"]["duree_jour_h"]}h", style: const TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),

                          // ── Phase lunaire ─────────────────────────────
                          DetailCard(
                            title: "Phase lunaire",
                            icon: Icons.nightlight_round,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${astro!["lune"]["emoji"]} ${astro!["lune"]["phase"]}", style: const TextStyle(color: Colors.white)),
                                const SizedBox(height: 6),
                                Text("Illumination : ${astro!["lune"]["illumination_pct"]}%", style: const TextStyle(color: Colors.white)),
                                const SizedBox(height: 6),
                                Text(
                                  "Pleine lune dans ${astro!["lune"]["jours_avant_pleine_lune"]} jours",
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // ── Pluie ML ──────────────────────────────────────
                        if (pluie != null) ...[
                          DetailCard(
                            title: "Prévision pluie",
                            icon: Icons.grain,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(pluie!["message"], style: const TextStyle(color: Colors.white, fontSize: 16)),
                                const SizedBox(height: 6),
                                Text("Probabilité : ${pluie!["probabilite"]}%", style: const TextStyle(color: Colors.white70)),
                                Text("Humidité actuelle : ${pluie!["humidite_actuelle"]}%", style: const TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // ── Vent ML ───────────────────────────────────────
                        if (vent != null) ...[
                          DetailCard(
                            title: "Vent & rafales",
                            icon: Icons.air,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(vent!["message"], style: const TextStyle(color: Colors.white, fontSize: 16)),
                                const SizedBox(height: 6),
                                Text("🌬 Vitesse : ${vent!["vitesse_actuelle_kmh"]} km/h", style: const TextStyle(color: Colors.white)),
                                Text("💨 Rafales : ${vent!["rafales_actuelles_kmh"]} km/h", style: const TextStyle(color: Colors.white70)),
                                Text("🧭 Direction : ${vent!["direction_deg"]}°", style: const TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // ── Canicule ML ───────────────────────────────────
                        if (canicule != null) ...[
                          DetailCard(
                            title: "Risque canicule",
                            icon: Icons.local_fire_department,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(canicule!["message"], style: const TextStyle(color: Colors.white, fontSize: 16)),
                                const SizedBox(height: 6),
                                Text("Niveau : ${canicule!["niveau_risque"]}", style: const TextStyle(color: Colors.white70)),
                                Text("Température : ${canicule!["temperature_actuelle_C"]}°C (ressenti ${canicule!["ressenti_C"]}°C)", style: const TextStyle(color: Colors.white70)),
                                Text("UV : ${canicule!["uv_index"]}", style: const TextStyle(color: Colors.white70)),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

// ── Carte détail ──────────────────────────────────────────────────────────────
class DetailCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const DetailCard({super.key, required this.title, required this.icon, required this.child});

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
          Row(children: [
            Icon(icon, color: const Color(0xFFC6B6FF)),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
