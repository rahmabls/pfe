import 'package:flutter/material.dart';
import 'api_service.dart';

class AutorisationsScreen extends StatefulWidget {
  const AutorisationsScreen({super.key});
  @override
  State<AutorisationsScreen> createState() => _AutorisationsScreenState();
}

class _AutorisationsScreenState extends State<AutorisationsScreen> {
  Map<String, dynamic>? data;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final res = await ApiService.get("/autorisations/");
      setState(() { data = res; isLoading = false; });
    } catch (_) {
      setState(() { isLoading = false; });
    }
  }

  Future<void> _toggle(String type, bool value) async {
    try {
      final res = await ApiService.patch("/autorisations/$type", {"accordee": value});
      setState(() { data = res; });
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
        title: const Text("Autorisations"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : data == null
              ? const Center(child: Text("Erreur de chargement"))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Autorisations facultatives",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // Position
                      SwitchListTile(
                        secondary: const Icon(Icons.location_on_outlined),
                        title: const Text("Position"),
                        subtitle: const Text("accéder à la position de l'appareil"),
                        value: data!["position"]["accordee"] == true,
                        onChanged: (v) => _toggle("position", v),
                      ),

                      // Notifications
                      SwitchListTile(
                        secondary: const Icon(Icons.notifications_outlined),
                        title: const Text("Notifications"),
                        subtitle: const Text("afficher des notifications"),
                        value: data!["notifications"]["accordee"] == true,
                        onChanged: (v) => _toggle("notifications", v),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        data!["message_info"] ?? "",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
    );
  }
}
