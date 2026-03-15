import 'package:flutter/material.dart';
import 'api_service.dart';
import 'local_meteo_screen.dart';
import 'notifications_screen.dart';
import 'personalisation_screen.dart';
import 'autorisations_screen.dart';
import 'contact_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? prefs;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final res = await ApiService.get("/preferences/");
      setState(() {
        prefs = res;
        isLoading = false;
      });
    } catch (_) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _patchAlerte(String key, bool value) async {
    try {
      final res = await ApiService.patch("/preferences/alertes", {key: value});
      setState(() {
        prefs = res;
      });
    } catch (e) {
      _erreur(e);
    }
  }

  Future<void> _patchMeteoLocale(String key, bool value) async {
    try {
      final res = await ApiService.patch("/preferences/meteo-locale", {
        key: value,
      });
      setState(() {
        prefs = res;
      });
    } catch (e) {
      _erreur(e);
    }
  }

  void _erreur(Object e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Paramètres météo",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400),
        ),
        backgroundColor: const Color(0xFF4A5A66),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Fond dégradé plus clair ───────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF6A7D8E),
                  Color(0xFF556675),
                  Color(0xFF445566),
                  Color(0xFF334455),
                ],
              ),
            ),
          ),

          // ── Nuages petits et transparents ─────────────────────────
          Positioned.fill(child: CustomPaint(painter: _CloudPainterSettings())),

          // ── Contenu ───────────────────────────────────────────────
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : prefs == null
              ? const Center(
                  child: Text(
                    "Erreur de chargement",
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : _buildContenu(),
        ],
      ),
    );
  }

  Widget _buildContenu() {
    final alertes = prefs!["alertes"] as Map<String, dynamic>;
    final meteoLocale = prefs!["meteo_locale"] as Map<String, dynamic>;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Préférences utilisateur ───────────────────────────────
        _GlassBlock(
          children: [
            const _SectionTitle("PRÉFÉRENCES UTILISATEUR"),
            _SwitchTile(
              title: "Alertes pluie",
              value: alertes["pluie"] == true,
              onChanged: (v) => _patchAlerte("pluie", v),
            ),
            _Divider(),
            _SwitchTile(
              title: "Alertes vent fort",
              value: alertes["vent_fort"] == true,
              onChanged: (v) => _patchAlerte("vent_fort", v),
            ),
            _Divider(),
            _SwitchTile(
              title: "Alertes canicule",
              value: alertes["canicule"] == true,
              onChanged: (v) => _patchAlerte("canicule", v),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Météo locale ──────────────────────────────────────────
        _GlassBlock(
          children: [
            _RowTile(
              title: "Météo locale",
              subtitle: meteoLocale["accepter"] == true ? "Accepter" : "Refusé",
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LocalMeteoScreen()),
                );
                _charger();
              },
            ),
            _Divider(),
            _SwitchTile(
              title: "Actualisation automatique",
              value: meteoLocale["actualisation_automatique"] == true,
              onChanged: (v) =>
                  _patchMeteoLocale("actualisation_automatique", v),
            ),
            _Divider(),
            _SwitchTile(
              title: "Affichage météo sur écran Applis",
              value: meteoLocale["affichage_ecran_applis"] == true,
              onChanged: (v) => _patchMeteoLocale("affichage_ecran_applis", v),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Notifications ─────────────────────────────────────────
        _GlassBlock(
          children: [
            _RowTile(
              title: "Notifications",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Personnalisation ──────────────────────────────────────
        _GlassBlock(
          children: [
            _RowTile(
              title: "Service de personnalisation",
              subtitle: "Pas en cours d'utilisation",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PersonalisationScreen(),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── Autorisations ─────────────────────────────────────────
        _GlassBlock(
          children: [
            _RowTile(
              title: "Autorisations",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AutorisationsScreen()),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // ── À propos & Contact ────────────────────────────────────
        _GlassBlock(
          children: [
            const _RowTile(title: "À propos de l'application Météo"),
            _Divider(),
            _RowTile(
              title: "Nous contacter",
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ContactScreen()),
              ),
            ),
          ],
        ),

        const SizedBox(height: 30),
      ],
    );
  }
}

// ── Widgets helpers ───────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white54,
          fontWeight: FontWeight.w600,
          fontSize: 12,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _GlassBlock extends StatelessWidget {
  final List<Widget> children;
  const _GlassBlock({required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      value: value,
      activeColor: Colors.white,
      activeTrackColor: const Color(0xFF5A8A7A),
      inactiveThumbColor: Colors.white54,
      inactiveTrackColor: Colors.white24,
      onChanged: onChanged,
    );
  }
}

class _RowTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  const _RowTile({required this.title, this.subtitle, this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 15),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(
                color: Colors.lightBlueAccent,
                fontSize: 13,
              ),
            )
          : null,
      trailing: onTap != null
          ? const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 14)
          : null,
      onTap: onTap,
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: Colors.white12,
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}

// ── Nuages petits et transparents ─────────────────────────────────────────────
class _CloudPainterSettings extends CustomPainter {
  void _drawCloud(Canvas canvas, Offset center, double scale, double opacity) {
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.10 * opacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(10 * scale, 25 * scale),
        width: 220 * scale,
        height: 35 * scale,
      ),
      shadowPaint,
    );

    final List<_CB> bubbles = [
      _CB(center.translate(-70 * scale, 15 * scale), 45 * scale),
      _CB(center.translate(-35 * scale, 0 * scale), 60 * scale),
      _CB(center.translate(5 * scale, -18 * scale), 72 * scale),
      _CB(center.translate(48 * scale, -8 * scale), 62 * scale),
      _CB(center.translate(85 * scale, 10 * scale), 48 * scale),
      _CB(center.translate(-85 * scale, 20 * scale), 35 * scale),
      _CB(center.translate(110 * scale, 18 * scale), 35 * scale),
    ];

    for (final b in bubbles) {
      final p = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          center: const Alignment(0.2, 0.3),
          colors: [
            Colors.blueGrey.shade300.withOpacity(0.40 * opacity),
            Colors.blueGrey.shade500.withOpacity(0.25 * opacity),
          ],
        ).createShader(Rect.fromCircle(center: b.center, radius: b.radius));
      canvas.drawCircle(b.center.translate(3, 8), b.radius * 1.05, p);
    }

    for (final b in bubbles) {
      final p = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          center: const Alignment(-0.3, -0.4),
          colors: [
            Colors.white.withOpacity(0.70 * opacity),
            Colors.blueGrey.shade200.withOpacity(0.45 * opacity),
          ],
        ).createShader(Rect.fromCircle(center: b.center, radius: b.radius));
      canvas.drawCircle(b.center, b.radius, p);
    }

    for (final b in bubbles) {
      final p = Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          center: const Alignment(-0.5, -0.5),
          radius: 0.8,
          colors: [
            Colors.white.withOpacity(0.50 * opacity),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(center: b.center, radius: b.radius));
      canvas.drawCircle(
        b.center.translate(-b.radius * 0.25, -b.radius * 0.25),
        b.radius * 0.65,
        p,
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Nuages petits et transparents
    _drawCloud(canvas, Offset(size.width * 0.75, 80), 0.8, 0.4);
    _drawCloud(canvas, Offset(size.width * 0.15, 60), 0.6, 0.3);
    _drawCloud(canvas, Offset(size.width * 0.55, size.height * 0.25), 0.7, 0.2);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _CB {
  final Offset center;
  final double radius;
  const _CB(this.center, this.radius);
}

// ── Widgets publics ───────────────────────────────────────────────────────────
class SettingsBlock extends StatelessWidget {
  final List<Widget> children;
  const SettingsBlock({super.key, required this.children});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class SettingsRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  const SettingsRow({
    super.key,
    required this.title,
    this.subtitle,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(color: Colors.lightBlueAccent),
            )
          : null,
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white70,
        size: 16,
      ),
      onTap: onTap,
    );
  }
}
