import 'package:flutter/material.dart';
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
  bool notifMeteo = true;
  bool alertePluie = true;
  bool alerteVent = false;
  bool alerteCanicule = true;

  bool autoUpdate = true;
  bool showOnHome = false;

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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /* ===== PRÉFÉRENCES UTILISATEUR ===== */
            SettingsBlock(
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "PRÉFÉRENCES UTILISATEUR",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                SwitchListTile(
                  title: const Text(
                    "Notifications météo",
                    style: TextStyle(color: Colors.white),
                  ),
                  value: notifMeteo,
                  activeThumbColor: Colors.blue,
                  onChanged: (v) => setState(() => notifMeteo = v),
                ),

                SwitchListTile(
                  title: const Text(
                    "Alertes pluie",
                    style: TextStyle(color: Colors.white),
                  ),
                  value: alertePluie,
                  activeThumbColor: Colors.blue,
                  onChanged: (v) => setState(() => alertePluie = v),
                ),

                SwitchListTile(
                  title: const Text(
                    "Alertes vent fort",
                    style: TextStyle(color: Colors.white),
                  ),
                  value: alerteVent,
                  activeThumbColor: Colors.blue,
                  onChanged: (v) => setState(() => alerteVent = v),
                ),

                SwitchListTile(
                  title: const Text(
                    "Alertes canicule",
                    style: TextStyle(color: Colors.white),
                  ),
                  value: alerteCanicule,
                  activeThumbColor: Colors.blue,
                  onChanged: (v) => setState(() => alerteCanicule = v),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /* ===== MÉTÉO LOCALE ===== */
            SettingsBlock(
              children: [
                SettingsRow(
                  title: "Météo locale",
                  subtitle: "Accepter",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LocalMeteoScreen(),
                      ),
                    );
                  },
                ),

                SwitchListTile(
                  title: const Text(
                    "Actualisation automatique",
                    style: TextStyle(color: Colors.white),
                  ),
                  value: autoUpdate,
                  activeThumbColor: Colors.blue,
                  onChanged: (v) => setState(() => autoUpdate = v),
                ),

                SwitchListTile(
                  title: const Text(
                    "Affichage météo sur écran Applis",
                    style: TextStyle(color: Colors.white),
                  ),
                  value: showOnHome,
                  activeThumbColor: Colors.blue,
                  onChanged: (v) => setState(() => showOnHome = v),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /* ===== NOTIFICATIONS ===== */
            SettingsBlock(
              children: [
                SettingsRow(
                  title: "Notifications",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const NotificationsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            /* ===== SERVICE DE PERSONNALISATION ===== */
            SettingsBlock(
              children: [
                SettingsRow(
                  title: "Service de personnalisation",
                  subtitle: "Pas en cours d'utilisation",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PersonalisationScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            /* ===== AUTORISATIONS ===== */
            SettingsBlock(
              children: [
                SettingsRow(
                  title: "Autorisations",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AutorisationsScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            /* ===== À PROPOS & CONTACT ===== */
            SettingsBlock(
              children: [
                const SettingsRow(title: "À propos de l'application Météo"),

                SettingsRow(
                  title: "Nous contacter",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ContactScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* ===== BLOC STYLE ===== */
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

/* ===== LIGNE PARAMÈTRE ===== */
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
          ? Text(subtitle!, style: const TextStyle(color: Colors.blueAccent))
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
