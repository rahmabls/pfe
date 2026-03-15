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
  List<dynamic>? previsions10j;
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
      final results = await Future.wait([
        ApiService.get("/meteo/accueil"),
        ApiService.getList("/meteo/previsions"),
      ]);
      setState(() {
        meteo = results[0] as Map<String, dynamic>;
        previsions10j = results[1] as List<dynamic>;
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

  Color _couleurIcone(String? icone) {
    switch (icone) {
      case "rainy":
        return Colors.lightBlueAccent;
      case "windy":
        return Colors.white70;
      case "cloudy":
        return Colors.white70;
      case "partly_cloudy":
        return Colors.yellow;
      case "hot":
        return Colors.yellow;
      default:
        return Colors.yellow;
    }
  }

  String _descriptionMeteo(String? icone) {
    switch (icone) {
      case "rainy":
        return "Pluvieux";
      case "windy":
        return "Venteux";
      case "cloudy":
        return "Nuageux";
      case "partly_cloudy":
        return "Partiellement nuageux";
      case "hot":
        return "Ensoleillé";
      default:
        return "Ensoleillé";
    }
  }

  String _uvDescription(dynamic uv) {
    final v = (uv ?? 0).toDouble();
    if (v <= 2) return "Faible";
    if (v <= 5) return "Modéré";
    if (v <= 7) return "Élevé";
    return "Très élevé";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Fond dégradé ──────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF5A6E7E),
                  Color(0xFF4A5A66),
                  Color(0xFF3A4A55),
                  Color(0xFF2C3A42),
                ],
              ),
            ),
          ),

          // ── Nuages 3D FIXES ───────────────────────────────────────
          Positioned.fill(child: CustomPaint(painter: _CloudPainter())),

          // ── Contenu scrollable ────────────────────────────────────
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
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Text(
              meteo!["ville"] ?? "Béni Mellal",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 34,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
            Text(
              "${meteo!["temperature_actuelle_C"]}°",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 96,
                fontWeight: FontWeight.w100,
                height: 1.0,
              ),
            ),
            Text(
              _descriptionMeteo(meteo!["icone"]),
              style: const TextStyle(color: Colors.white70, fontSize: 20),
            ),
            Text(
              "↑ ${pred["temperature_24h_C"]}°  ↓ ${meteo!["ressenti_C"]}°",
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // ── Prévisions horaires ──────────────────────────
                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.access_time,
                              color: Colors.white54,
                              size: 14,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "PRÉVISIONS HORAIRES",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white24, height: 16),
                        SizedBox(
                          height: 100,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _HeureCardApple(
                                "Maint.",
                                _iconeMeteo(meteo!["icone"]),
                                "${meteo!["temperature_actuelle_C"]}°",
                                _couleurIcone(meteo!["icone"]),
                              ),
                              _HeureCardApple(
                                "+1h",
                                _iconeMeteo(meteo!["icone"]),
                                "${pred["temperature_1h_C"]}°",
                                _couleurIcone(meteo!["icone"]),
                              ),
                              _HeureCardApple(
                                "+24h",
                                _iconeMeteo(meteo!["icone"]),
                                "${pred["temperature_24h_C"]}°",
                                _couleurIcone(meteo!["icone"]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Prévisions 10 jours ──────────────────────────
                  if (previsions10j != null && previsions10j!.isNotEmpty)
                    _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(
                                Icons.calendar_month,
                                color: Colors.white54,
                                size: 14,
                              ),
                              SizedBox(width: 6),
                              Text(
                                "PRÉVISIONS SUR 10 JOURS",
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: Colors.white24, height: 16),
                          ...previsions10j!.asMap().entries.map((entry) {
                            final i = entry.key;
                            final j = entry.value as Map<String, dynamic>;
                            final double tempMin = (j["temp_min"] ?? 0)
                                .toDouble();
                            final double tempMax = (j["temp_max"] ?? 0)
                                .toDouble();
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 50,
                                        child: Text(
                                          j["jour"] ?? "",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        _iconeMeteo(j["icone"]),
                                        color: _couleurIcone(j["icone"]),
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 35,
                                        child: Text(
                                          "${j["temp_min"]}°",
                                          style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _TemperatureBar(
                                          tempMin: tempMin,
                                          tempMax: tempMax,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 35,
                                        child: Text(
                                          "${j["temp_max"]}°",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (i < previsions10j!.length - 1)
                                  const Divider(
                                    color: Colors.white12,
                                    height: 1,
                                  ),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // ── Ressenti + Humidité ──────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.thermostat,
                                    color: Colors.white54,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "RESSENTI",
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${meteo!["ressenti_C"]}°",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                "Similaire à la température réelle.",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.water_drop,
                                    color: Colors.white54,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "HUMIDITÉ",
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${meteo!["humidite_pct"]}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Point de rosée : ${meteo!["ressenti_C"]}°",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Vent ─────────────────────────────────────────
                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.air, color: Colors.white54, size: 14),
                            SizedBox(width: 4),
                            Text(
                              "VENT",
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 11,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _WindRow("Vent", "${meteo!["vent_kmh"]} km/h"),
                        _WindRow("Rafales", "${meteo!["rafales_kmh"]} km/h"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Pression + UV ────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.speed,
                                    color: Colors.white54,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "PRESSION",
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${meteo!["pression_hpa"]}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                              const Text(
                                "hPa",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(
                                    Icons.wb_sunny,
                                    color: Colors.white54,
                                    size: 14,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    "INDICE UV",
                                    style: TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${meteo!["uv_index"]}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                              Text(
                                _uvDescription(meteo!["uv_index"]),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ── Alertes ──────────────────────────────────────
                  if (pluie["pluie_probable"] == true ||
                      vent["vent_fort"] == true ||
                      canicule["canicule"] == true)
                    _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "⚠️ ALERTES",
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                              letterSpacing: 1,
                            ),
                          ),
                          const Divider(color: Colors.white24, height: 16),
                          if (pluie["pluie_probable"] == true)
                            _AlerteRow(
                              "🌧️ Pluie probable",
                              "${pluie["probabilite"]}%",
                              Colors.lightBlueAccent,
                            ),
                          if (vent["vent_fort"] == true)
                            _AlerteRow(
                              "💨 Vent fort",
                              "${vent["probabilite"]}%",
                              Colors.orangeAccent,
                            ),
                          if (canicule["canicule"] == true)
                            _AlerteRow(
                              "🔥 Risque canicule",
                              "${canicule["probabilite"]}%",
                              Colors.redAccent,
                            ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _WindRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _AlerteRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return Container(
      color: const Color(0xFF2C3A42),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white70, size: 26),
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChatScreen()),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.psychology,
                color: Colors.white,
                size: 26,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.calendar_month,
              color: Colors.white70,
              size: 26,
            ),
            onPressed: () => Navigator.pushNamed(context, '/forecast'),
          ),
        ],
      ),
    );
  }
}

// ── Carte verre ───────────────────────────────────────────────────────────────
class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: child,
    );
  }
}

// ── Carte heure ───────────────────────────────────────────────────────────────
class _HeureCardApple extends StatelessWidget {
  final String hour, temp;
  final IconData icon;
  final Color iconColor;
  const _HeureCardApple(this.hour, this.icon, this.temp, this.iconColor);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hour,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            temp,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Barre température ─────────────────────────────────────────────────────────
class _TemperatureBar extends StatelessWidget {
  final double tempMin, tempMax;
  const _TemperatureBar({required this.tempMin, required this.tempMax});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: const LinearGradient(
          colors: [Color(0xFF4FC3F7), Color(0xFF81C784), Color(0xFFFFD54F)],
        ),
      ),
    );
  }
}

// ── Nuages 3D réalistes ───────────────────────────────────────────────────────
class _CloudPainter extends CustomPainter {
  void _drawCloud(Canvas canvas, Offset center, double scale, double opacity) {
    // ── Ombre au sol ──────────────────────────────────────────────
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(10 * scale, 25 * scale),
        width: 220 * scale,
        height: 35 * scale,
      ),
      shadowPaint,
    );

    final List<_CloudBubble> bubbles = [
      _CloudBubble(center.translate(-70 * scale, 15 * scale), 45 * scale),
      _CloudBubble(center.translate(-35 * scale, 0 * scale), 60 * scale),
      _CloudBubble(center.translate(5 * scale, -18 * scale), 72 * scale),
      _CloudBubble(center.translate(48 * scale, -8 * scale), 62 * scale),
      _CloudBubble(center.translate(85 * scale, 10 * scale), 48 * scale),
      _CloudBubble(center.translate(-85 * scale, 20 * scale), 35 * scale),
      _CloudBubble(center.translate(110 * scale, 18 * scale), 35 * scale),
    ];

    // ── Couche 1 : base sombre ────────────────────────────────────
    for (final b in bubbles) {
      final p = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          center: const Alignment(0.2, 0.3),
          colors: [
            Colors.blueGrey.shade300.withOpacity(0.55 * opacity),
            Colors.blueGrey.shade500.withOpacity(0.35 * opacity),
          ],
        ).createShader(Rect.fromCircle(center: b.center, radius: b.radius));
      canvas.drawCircle(b.center.translate(3, 8), b.radius * 1.05, p);
    }

    // ── Couche 2 : corps blanc ────────────────────────────────────
    for (final b in bubbles) {
      final p = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [
            Colors.white.withOpacity(0.90 * opacity),
            Colors.blueGrey.shade200.withOpacity(0.65 * opacity),
          ],
        ).createShader(Rect.fromCircle(center: b.center, radius: b.radius));
      canvas.drawCircle(b.center, b.radius, p);
    }

    // ── Couche 3 : lumière haut-gauche ────────────────────────────
    for (final b in bubbles) {
      final p = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          center: const Alignment(-0.5, -0.5),
          radius: 0.8,
          colors: [
            Colors.white.withOpacity(0.70 * opacity),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: b.center, radius: b.radius));
      canvas.drawCircle(
        b.center.translate(-b.radius * 0.25, -b.radius * 0.25),
        b.radius * 0.65,
        p,
      );
    }

    // ── Couche 4 : reflet spéculaire ──────────────────────────────
    for (final b in bubbles.take(4)) {
      final p = Paint()
        ..style = PaintingStyle.fill
        ..shader =
            RadialGradient(
              colors: [
                Colors.white.withOpacity(0.55 * opacity),
                Colors.white.withOpacity(0.0),
              ],
            ).createShader(
              Rect.fromCircle(
                center: b.center.translate(-b.radius * 0.3, -b.radius * 0.35),
                radius: b.radius * 0.4,
              ),
            );
      canvas.drawCircle(
        b.center.translate(-b.radius * 0.3, -b.radius * 0.35),
        b.radius * 0.4,
        p,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Nuage principal
    _drawCloud(canvas, Offset(size.width * 0.48, 95), 1.6, 1.0);
    // Nuage droite
    _drawCloud(canvas, Offset(size.width * 0.92, 55), 0.9, 0.8);
    // Nuage gauche
    _drawCloud(canvas, Offset(size.width * 0.08, 140), 0.7, 0.55);
    // Nuage lointain
    _drawCloud(
      canvas,
      Offset(size.width * 0.65, size.height * 0.28),
      1.1,
      0.25,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _CloudBubble {
  final Offset center;
  final double radius;
  const _CloudBubble(this.center, this.radius);
}
