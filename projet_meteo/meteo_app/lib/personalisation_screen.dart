import 'package:flutter/material.dart';

class PersonalisationScreen extends StatefulWidget {
  const PersonalisationScreen({super.key});

  @override
  State<PersonalisationScreen> createState() => _PersonalisationScreenState();
}

class _PersonalisationScreenState extends State<PersonalisationScreen> {
  bool showInputField = false;
  TextEditingController emailOrPhoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Service de personnalisation"),
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
          children: [
            /* ===== OPTION 1 : GOOGLE ===== */
            Card(
              color: Colors.white.withOpacity(0.1),
              child: ListTile(
                leading: const Icon(Icons.account_circle, color: Colors.white),
                title: const Text(
                  "Se connecter avec Google",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  _showGoogleAccountsDialog();
                },
              ),
            ),

            const SizedBox(height: 10),

            /* ===== OPTION 2 : EMAIL / TÉLÉPHONE ===== */
            Card(
              color: Colors.white.withOpacity(0.1),
              child: ListTile(
                leading: const Icon(Icons.email, color: Colors.white),
                title: const Text(
                  "Se connecter par Gmail ou numéro",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  setState(() {
                    showInputField = true;
                  });
                },
              ),
            ),

            if (showInputField)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: TextField(
                  controller: emailOrPhoneController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Entrez votre email ou numéro",
                    hintStyle: const TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showGoogleAccountsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choisir un compte Google"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text("nasima@gmail.com"),
              ),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text("nasima.erraki@gmail.com"),
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ===== PAGE QR CODE (comme ton screenshot) ===== */
class QrCodeScreen extends StatelessWidget {
  const QrCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Numérisation QR"),
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Numérisation de ce code QR",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.qr_code, size: 150, color: Colors.black),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                "Utilisez un autre appareil Galaxy pour scanner",
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                onPressed: () {},
                child: const Text("Créer un code QR"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
