import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool allowNotifications = true;
  String alertMode = "son"; // "son" ou "discret"

  bool lockScreenAllowed = true;
  bool badgeAllowed = true;
  bool popupAllowed = true;

  String lockScreenContent = "afficher"; // "afficher" ou "masquer"

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
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /* ===== SWITCH PRINCIPAL ===== */
            SwitchListTile(
              title: const Text(
                "Autorisation des notifications",
                style: TextStyle(color: Colors.white),
              ),
              value: allowNotifications,
              activeThumbColor: Colors.blue,
              onChanged: (value) {
                setState(() {
                  allowNotifications = value;
                });
              },
            ),

            const SizedBox(height: 10),

            const Text(
              "Alertes",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),

            /* ===== CHOIX SON / DISCRET ===== */
            RadioListTile<String>(
              title: const Text(
                "Autoriser le son et la vibration",
                style: TextStyle(color: Colors.white),
              ),
              value: "son",
              groupValue: alertMode,
              onChanged: (value) {
                setState(() {
                  alertMode = value!;
                  popupAllowed = true; // en mode son, pop-up possible
                });
              },
            ),

            RadioListTile<String>(
              title: const Text(
                "Discret",
                style: TextStyle(color: Colors.white),
              ),
              value: "discret",
              groupValue: alertMode,
              onChanged: (value) {
                setState(() {
                  alertMode = value!;
                  popupAllowed = false; // EN DISCRET → PAS DE POP-UP
                });
              },
            ),

            const SizedBox(height: 20),

            const Text(
              "Types de notification",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),

            const SizedBox(height: 10),

            /* ===== CARTES (comportement EXACT demandé) ===== */
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                NotificationCard(
                  title: "Écran verr.",
                  isAllowed: lockScreenAllowed,
                  onTap: () {
                    setState(() {
                      lockScreenAllowed = !lockScreenAllowed;
                    });
                  },
                ),

                NotificationCard(
                  title: "Badge",
                  isAllowed: badgeAllowed,
                  onTap: () {
                    setState(() {
                      badgeAllowed = !badgeAllowed;
                    });
                  },
                ),

                // 👉 POP-UP : visible UNIQUEMENT en mode SON
                if (alertMode == "son")
                  NotificationCard(
                    title: "Pop-up",
                    isAllowed: popupAllowed,
                    onTap: () {
                      setState(() {
                        popupAllowed = !popupAllowed;
                      });
                    },
                  ),
              ],
            ),

            const SizedBox(height: 20),

            /* ===== NOTIF SUR ÉCRAN VERROUILLAGE ===== */
            ListTile(
              title: const Text(
                "Notif. sur écran verrouillage",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                lockScreenContent == "afficher"
                    ? "Afficher le contenu"
                    : "Masquer le contenu",
                style: const TextStyle(color: Colors.blueAccent),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 16,
              ),
              onTap: () {
                _showLockScreenDialog();
              },
            ),

            const SizedBox(height: 10),

            /* ===== CATÉGORIES DE NOTIFICATION ===== */
            ListTile(
              title: const Text(
                "Catégories de notification",
                style: TextStyle(color: Colors.white),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white70,
                size: 16,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationCategoriesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /* ===== FENÊTRE "AFFICHER / MASQUER" (comme ton 1er écran) ===== */
  void _showLockScreenDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Contenu sur écran verrouillé"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text("Afficher le contenu"),
                value: "afficher",
                groupValue: lockScreenContent,
                onChanged: (value) {
                  setState(() {
                    lockScreenContent = value!;
                  });
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text("Masquer le contenu"),
                value: "masquer",
                groupValue: lockScreenContent,
                onChanged: (value) {
                  setState(() {
                    lockScreenContent = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/* ===== CARTE NOTIFICATION ===== */
class NotificationCard extends StatelessWidget {
  final String title;
  final bool isAllowed;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.title,
    required this.isAllowed,
    required this.onTap,
  });

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
            Icon(
              Icons.notifications,
              color: isAllowed ? Colors.blue : Colors.grey,
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Colors.white)),
            Text(
              isAllowed ? "Autorisé" : "Non autorisé",
              style: TextStyle(
                color: isAllowed ? Colors.blueAccent : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* ===== PAGE CATÉGORIES (comme ton 2e écran) ===== */
class NotificationCategoriesScreen extends StatefulWidget {
  const NotificationCategoriesScreen({super.key});

  @override
  State<NotificationCategoriesScreen> createState() =>
      _NotificationCategoriesScreenState();
}

class _NotificationCategoriesScreenState
    extends State<NotificationCategoriesScreen> {
  bool majApps = true;
  bool meteoExtreme = true;
  bool bulletin = true;
  bool notifEnCours = false;
  bool actualisation = true;

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
          children: [
            SwitchListTile(
              title: const Text(
                "Mises à jour des applications",
                style: TextStyle(color: Colors.white),
              ),
              value: majApps,
              activeThumbColor: Colors.blue,
              onChanged: (v) => setState(() => majApps = v),
            ),

            SwitchListTile(
              title: const Text(
                "Météo extrême",
                style: TextStyle(color: Colors.white),
              ),
              value: meteoExtreme,
              activeThumbColor: Colors.blue,
              onChanged: (v) => setState(() => meteoExtreme = v),
            ),

            SwitchListTile(
              title: const Text(
                "Bulletin météo quotidien",
                style: TextStyle(color: Colors.white),
              ),
              value: bulletin,
              activeThumbColor: Colors.blue,
              onChanged: (v) => setState(() => bulletin = v),
            ),

            SwitchListTile(
              title: const Text(
                "Notification en cours",
                style: TextStyle(color: Colors.white),
              ),
              value: notifEnCours,
              activeThumbColor: Colors.blue,
              onChanged: (v) => setState(() => notifEnCours = v),
            ),

            SwitchListTile(
              title: const Text(
                "Actualisation de la météo",
                style: TextStyle(color: Colors.white),
              ),
              value: actualisation,
              activeThumbColor: Colors.blue,
              onChanged: (v) => setState(() => actualisation = v),
            ),
          ],
        ),
      ),
    );
  }
}
