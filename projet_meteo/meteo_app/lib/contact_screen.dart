import 'package:flutter/material.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  void _showConnexionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF3A1A6E), Color(0xFF1B1F3B)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const Text(
                "Connexion au service",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              _connexionTile(
                icon: Icons.g_mobiledata,
                text: "Se connecter avec Google",
                onTap: () {
                  Navigator.pop(context);
                  _showGoogleChoice(context);
                },
              ),

              _connexionTile(
                icon: Icons.email,
                text: "Se connecter par Gmail / Téléphone",
                onTap: () {
                  Navigator.pop(context);
                  _showEmailPhoneDialog(context);
                },
              ),

              _connexionTile(
                icon: Icons.qr_code,
                text: "Se connecter avec QR Code",
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  static Widget _connexionTile({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(text, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.white70,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  void _showGoogleChoice(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Choisir un compte Google"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              ListTile(
                leading: Icon(Icons.person),
                title: Text("nasima@gmail.com"),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text("nasima.erraki@gmail.com"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEmailPhoneDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Connexion"),
          content: const TextField(
            decoration: InputDecoration(
              labelText: "Email ou numéro de téléphone",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Valider"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nous contacter"),
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
            const Text(
              "Obtenez de l’aide et une assistance pour votre application météo.",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 16),

            _helpTile(
              icon: Icons.chat,
              title: "Chat texte",
              onTap: () => _showConnexionSheet(context),
            ),

            _helpTile(
              icon: Icons.headset,
              title: "Gestion à distance",
              onTap: () => _showConnexionSheet(context),
            ),

            _helpTile(
              icon: Icons.send,
              title: "Envoyer une question",
              onTap: () => _showConnexionSheet(context),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _helpTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white.withOpacity(0.12),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white70,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }
}
