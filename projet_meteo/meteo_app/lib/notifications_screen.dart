import 'package:flutter/material.dart';
import 'api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  Map<String, dynamic>? data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final res = await ApiService.get("/notifications/");
      setState(() { data = res; isLoading = false; });
    } catch (_) {
      setState(() { isLoading = false; });
    }
  }

  Future<void> _patch(String endpoint, Map<String, dynamic> body) async {
    try {
      final res = await ApiService.patch(endpoint, body);
      setState(() { data = res; });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _patchCategorie(Map<String, dynamic> body) async {
    try {
      final res = await ApiService.patch("/notifications/categories", body);
      setState(() { data!["categories"] = res["categories"] ?? res; });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications de l'application"),
        backgroundColor: const Color(0xFF3A1A6E),
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
            : data == null
                ? const Center(child: Text("Erreur de chargement", style: TextStyle(color: Colors.white)))
                : _buildContenu(),
      ),
    );
  }

  Widget _buildContenu() {
    final autorisation = data!["autorisation"] as Map<String, dynamic>;
    final alertes      = data!["alertes"]      as Map<String, dynamic>;
    final types        = data!["types"]        as Map<String, dynamic>;
    final verr         = data!["ecran_verrouillage"] as Map<String, dynamic>;
    final popupVisible = types["popup_visible"] == true;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Switch principal ──────────────────────────────────────────────
        SwitchListTile(
          title: const Text("Autorisation des notifications", style: TextStyle(color: Colors.white)),
          value: autorisation["autorisees"] == true,
          activeThumbColor: Colors.blue,
          onChanged: (v) => _patch("/notifications/autorisation", {"autorisees": v}),
        ),

        const SizedBox(height: 10),
        const Text("Alertes", style: TextStyle(color: Colors.white70, fontSize: 16)),

        // ── Mode son / discret ────────────────────────────────────────────
        RadioListTile<String>(
          title: const Text("Autoriser le son et la vibration", style: TextStyle(color: Colors.white)),
          value: "son",
          groupValue: alertes["mode"],
          onChanged: (v) => _patch("/notifications/mode-alerte", {"mode": v}),
        ),
        RadioListTile<String>(
          title: const Text("Discret", style: TextStyle(color: Colors.white)),
          value: "discret",
          groupValue: alertes["mode"],
          onChanged: (v) => _patch("/notifications/mode-alerte", {"mode": v}),
        ),

        const SizedBox(height: 20),
        const Text("Types de notification", style: TextStyle(color: Colors.white70, fontSize: 16)),
        const SizedBox(height: 10),

        // ── Cartes types ──────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NotifCard(
              title: "Écran verr.",
              isAllowed: types["ecran_verrouillage"] == true,
              onTap: () => _patch("/notifications/types", {
                "ecran_verrouillage": !(types["ecran_verrouillage"] == true),
              }),
            ),
            _NotifCard(
              title: "Badge",
              isAllowed: types["badge"] == true,
              onTap: () => _patch("/notifications/types", {
                "badge": !(types["badge"] == true),
              }),
            ),
            if (popupVisible)
              _NotifCard(
                title: "Pop-up",
                isAllowed: types["popup"] == true,
                onTap: () => _patch("/notifications/types", {
                  "popup": !(types["popup"] == true),
                }),
              ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Contenu écran verrouillage ────────────────────────────────────
        ListTile(
          title: const Text("Notif. sur écran verrouillage", style: TextStyle(color: Colors.white)),
          subtitle: Text(
            verr["contenu"] == "afficher" ? "Afficher le contenu" : "Masquer le contenu",
            style: const TextStyle(color: Colors.blueAccent),
          ),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          onTap: () => _showVerrDialog(verr["contenu"]),
        ),

        const SizedBox(height: 10),

        // ── Catégories ────────────────────────────────────────────────────
        ListTile(
          title: const Text("Catégories de notification", style: TextStyle(color: Colors.white)),
          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => _CategoriesScreen(
                categories: Map<String, dynamic>.from(data!["categories"]),
                onUpdate: _patchCategorie,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showVerrDialog(String current) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Contenu sur écran verrouillé"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text("Afficher le contenu"),
              value: "afficher",
              groupValue: current,
              onChanged: (v) {
                Navigator.pop(ctx);
                _patch("/notifications/ecran-verrouillage", {"contenu": v});
              },
            ),
            RadioListTile<String>(
              title: const Text("Masquer le contenu"),
              value: "masquer",
              groupValue: current,
              onChanged: (v) {
                Navigator.pop(ctx);
                _patch("/notifications/ecran-verrouillage", {"contenu": v});
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Carte notification ────────────────────────────────────────────────────────
class _NotifCard extends StatelessWidget {
  final String title;
  final bool isAllowed;
  final VoidCallback onTap;
  const _NotifCard({required this.title, required this.isAllowed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 95,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: isAllowed ? Colors.blue : Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.notifications, color: isAllowed ? Colors.blue : Colors.grey),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Colors.white)),
            Text(
              isAllowed ? "Autorisé" : "Non autorisé",
              style: TextStyle(color: isAllowed ? Colors.blueAccent : Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Page catégories ───────────────────────────────────────────────────────────
class _CategoriesScreen extends StatefulWidget {
  final Map<String, dynamic> categories;
  final Future<void> Function(Map<String, dynamic>) onUpdate;
  const _CategoriesScreen({required this.categories, required this.onUpdate});

  @override
  State<_CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<_CategoriesScreen> {
  late Map<String, dynamic> cats;

  @override
  void initState() {
    super.initState();
    cats = Map<String, dynamic>.from(widget.categories);
  }

  Future<void> _toggle(String key) async {
    final newVal = !(cats[key] == true);
    setState(() => cats[key] = newVal);
    await widget.onUpdate({key: newVal});
  }

  static const Map<String, String> _labels = {
    "mises_a_jour_apps":    "Mises à jour des applications",
    "meteo_extreme":        "Météo extrême",
    "bulletin_quotidien":   "Bulletin météo quotidien",
    "notification_en_cours": "Notification en cours",
    "actualisation_meteo":  "Actualisation de la météo",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Catégories de notification"),
        backgroundColor: const Color(0xFF3A1A6E),
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
          children: _labels.entries.map((e) {
            return SwitchListTile(
              title: Text(e.value, style: const TextStyle(color: Colors.white)),
              value: cats[e.key] == true,
              activeThumbColor: Colors.blue,
              onChanged: (_) => _toggle(e.key),
            );
          }).toList(),
        ),
      ),
    );
  }
}
