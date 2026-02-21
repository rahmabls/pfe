import 'package:flutter/material.dart';

class AutorisationsScreen extends StatelessWidget {
  const AutorisationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Autorisations"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Autorisations facultatives",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 12),

            ListTile(
              leading: Icon(Icons.location_on_outlined),
              title: Text("Position"),
              subtitle: Text("accéder à la position de l'appareil"),
            ),

            ListTile(
              leading: Icon(Icons.notifications_outlined),
              title: Text("Notifications"),
              subtitle: Text("afficher des notifications"),
            ),

            SizedBox(height: 20),

            Text(
              "Vous pouvez toujours utiliser les fonctions de base "
              "de l'application sans accorder les autorisations facultatives.",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
