import 'package:flutter/material.dart';

class LocalMeteoScreen extends StatefulWidget {
  const LocalMeteoScreen({super.key});

  @override
  State<LocalMeteoScreen> createState() => _LocalMeteoScreenState();
}

class _LocalMeteoScreenState extends State<LocalMeteoScreen> {
  bool accepterLocal = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Météo locale"),
        backgroundColor: const Color(0xFF3A1A6E),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF3A1A6E), Color(0xFF1B1F3B)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SwitchListTile(
                  title: const Text(
                    "Accepter",
                    style: TextStyle(color: Colors.white),
                  ),
                  value: accepterLocal,
                  activeThumbColor: Colors.blue,
                  onChanged: (value) {
                    setState(() {
                      accepterLocal = value;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Les données sur votre position actuelle seront collectées et utilisées "
                "pour fournir certaines des fonctions de l’application Météo, par exemple "
                "pour vous indiquer la météo locale.\n\n"
                "Afin de vous fournir des informations météorologiques en continu, "
                "cette application traitera régulièrement les données sur votre position "
                "même lorsque vous ne l’utilisez pas.\n\n"
                "Vous pouvez désactiver l’utilisation de votre position à tout moment "
                "dans les paramètres de l’application.",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
