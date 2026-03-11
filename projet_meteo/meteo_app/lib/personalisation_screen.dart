import 'package:flutter/material.dart';
import 'api_service.dart';

class PersonalisationScreen extends StatefulWidget {
  const PersonalisationScreen({super.key});
  @override
  State<PersonalisationScreen> createState() => _PersonalisationScreenState();
}

class _PersonalisationScreenState extends State<PersonalisationScreen> {
  Map<String, dynamic>? perso;
  bool isLoading = true;
  bool showInput = false;
  final TextEditingController _emailCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _charger();
  }

  Future<void> _charger() async {
    try {
      final res = await ApiService.get("/preferences/personnalisation");
      setState(() { perso = res; isLoading = false; });
    } catch (_) {
      setState(() { isLoading = false; });
    }
  }

  Future<void> _connecter(String email, String methode) async {
    if (email.trim().isEmpty) return;
    try {
      final res = await ApiService.post("/preferences/personnalisation/connecter", {
        "email": email.trim(),
        "methode": methode,
      });
      setState(() {
        perso = res["personnalisation"] ?? res;
        showInput = false;
      });
      _emailCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Connecté avec succès"), backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _deconnecter() async {
    try {
      await ApiService.post("/preferences/personnalisation/deconnecter");
      setState(() => perso = {"compte_connecte": null, "methode_connexion": null});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Déconnecté"), backgroundColor: Colors.orange),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e"), backgroundColor: Colors.red),
      );
    }
  }

  void _showGoogleDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Choisir un compte Google"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text("nasima@gmail.com"),
              onTap: () {
                Navigator.pop(ctx);
                _connecter("nasima@gmail.com", "google");
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text("nasima.erraki@gmail.com"),
              onTap: () {
                Navigator.pop(ctx);
                _connecter("nasima.erraki@gmail.com", "google");
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estConnecte = perso != null && perso!["compte_connecte"] != null;

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
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── Compte connecté ────────────────────────────────────
                  if (estConnecte)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  perso!["compte_connecte"],
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "via ${perso!["methode_connexion"]}",
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: _deconnecter,
                            child: const Text("Déconnecter", style: TextStyle(color: Colors.redAccent)),
                          ),
                        ],
                      ),
                    ),

                  // ── Option Google ──────────────────────────────────────
                  Card(
                    color: Colors.white.withOpacity(0.1),
                    child: ListTile(
                      leading: const Icon(Icons.account_circle, color: Colors.white),
                      title: const Text("Se connecter avec Google", style: TextStyle(color: Colors.white)),
                      onTap: _showGoogleDialog,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // ── Option Email / Téléphone ───────────────────────────
                  Card(
                    color: Colors.white.withOpacity(0.1),
                    child: ListTile(
                      leading: const Icon(Icons.email, color: Colors.white),
                      title: const Text("Se connecter par Gmail ou numéro", style: TextStyle(color: Colors.white)),
                      onTap: () => setState(() => showInput = !showInput),
                    ),
                  ),

                  if (showInput) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _emailCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Entrez votre email ou numéro",
                        hintStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.1),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A4CFF)),
                      onPressed: () => _connecter(_emailCtrl.text, "email"),
                      child: const Text("Valider", style: TextStyle(color: Colors.white)),
                    ),
                  ],

                  const SizedBox(height: 10),

                  // ── Option QR Code ─────────────────────────────────────
                  Card(
                    color: Colors.white.withOpacity(0.1),
                    child: ListTile(
                      leading: const Icon(Icons.qr_code, color: Colors.white),
                      title: const Text("Se connecter avec QR Code", style: TextStyle(color: Colors.white)),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QrCodeScreen()),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ── QR Code Screen ────────────────────────────────────────────────────────────
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
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Container(
                width: 220, height: 220,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: const Center(child: Icon(Icons.qr_code, size: 150, color: Colors.black)),
              ),
              const SizedBox(height: 20),
              const Text(
                "Utilisez un autre appareil pour scanner",
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
