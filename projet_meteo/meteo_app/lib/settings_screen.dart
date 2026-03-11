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
      setState(() { prefs = res; isLoading = false; });
    } catch (_) {
      setState(() { isLoading = false; });
    }
  }

  Future<void> _patchAlerte(String key, bool value) async {
    try {
      final res = await ApiService.patch("/preferences/alertes", {key: value});
      setState(() { prefs = res; });
    } catch (e) {
      _erreur(e);
    }
  }

  Future<void> _patchMeteoLocale(String key, bool value) async {
    try {
      final res = await ApiService.patch("/preferences/meteo-locale", {key: value});
      setState(() { prefs = res; });
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
        title: const Text("Paramètres météo"),
        backgroundColor: const Color(0xFF3A1A6E),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3A1A6E), Color(0xFF1B1F3B)],
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : prefs == null
                ? const Center(child: Text("Erreur de chargement", style: TextStyle(color: Colors.white)))
                : _buildContenu(),
      ),
    );
  }

  Widget _buildContenu() {
    final alertes      = prefs!["alertes"]      as Map<String, dynamic>;
    final meteoLocale  = prefs!["meteo_locale"] as Map<String, dynamic>;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Préférences utilisateur ───────────────────────────────────────
        SettingsBlock(children: [
          const _SectionTitle("PRÉFÉRENCES UTILISATEUR"),

          SwitchListTile(
            title: const Text("Alertes pluie", style: TextStyle(color: Colors.white)),
            value: alertes["pluie"] == true,
            activeThumbColor: Colors.blue,
            onChanged: (v) => _patchAlerte("pluie", v),
          ),
          SwitchListTile(
            title: const Text("Alertes vent fort", style: TextStyle(color: Colors.white)),
            value: alertes["vent_fort"] == true,
            activeThumbColor: Colors.blue,
            onChanged: (v) => _patchAlerte("vent_fort", v),
          ),
          SwitchListTile(
            title: const Text("Alertes canicule", style: TextStyle(color: Colors.white)),
            value: alertes["canicule"] == true,
            activeThumbColor: Colors.blue,
            onChanged: (v) => _patchAlerte("canicule", v),
          ),
        ]),

        const SizedBox(height: 12),

        // ── Météo locale ──────────────────────────────────────────────────
        SettingsBlock(children: [
          SettingsRow(
            title: "Météo locale",
            subtitle: meteoLocale["accepter"] == true ? "Accepter" : "Refusé",
            onTap: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const LocalMeteoScreen()));
              _charger(); // recharge après retour
            },
          ),
          SwitchListTile(
            title: const Text("Actualisation automatique", style: TextStyle(color: Colors.white)),
            value: meteoLocale["actualisation_automatique"] == true,
            activeThumbColor: Colors.blue,
            onChanged: (v) => _patchMeteoLocale("actualisation_automatique", v),
          ),
          SwitchListTile(
            title: const Text("Affichage météo sur écran Applis", style: TextStyle(color: Colors.white)),
            value: meteoLocale["affichage_ecran_applis"] == true,
            activeThumbColor: Colors.blue,
            onChanged: (v) => _patchMeteoLocale("affichage_ecran_applis", v),
          ),
        ]),

        const SizedBox(height: 12),

        // ── Notifications ─────────────────────────────────────────────────
        SettingsBlock(children: [
          SettingsRow(
            title: "Notifications",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
        ]),

        const SizedBox(height: 12),

        // ── Personnalisation ──────────────────────────────────────────────
        SettingsBlock(children: [
          SettingsRow(
            title: "Service de personnalisation",
            subtitle: "Pas en cours d'utilisation",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PersonalisationScreen())),
          ),
        ]),

        const SizedBox(height: 12),

        // ── Autorisations ─────────────────────────────────────────────────
        SettingsBlock(children: [
          SettingsRow(
            title: "Autorisations",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AutorisationsScreen())),
          ),
        ]),

        const SizedBox(height: 12),

        // ── À propos & Contact ────────────────────────────────────────────
        SettingsBlock(children: [
          const SettingsRow(title: "À propos de l'application Météo"),
          SettingsRow(
            title: "Nous contacter",
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactScreen())),
          ),
        ]),
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
      padding: const EdgeInsets.all(8.0),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }
}

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
  const SettingsRow({super.key, required this.title, this.subtitle, this.onTap});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(color: Colors.blueAccent)) : null,
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
      onTap: onTap,
    );
  }
}
