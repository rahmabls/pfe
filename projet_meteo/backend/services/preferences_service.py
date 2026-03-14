import json
import os

# Fichier JSON local pour stocker les préférences (simple, sans base de données)
PREFS_FILE = "user_preferences.json"

# Valeurs par défaut
DEFAULT_PREFERENCES = {
    "alertes": {
        "pluie": True,
        "vent_fort": False,
        "canicule": True,
    },
    "meteo_locale": {
        "accepter": True,
        "actualisation_automatique": True,
        "affichage_ecran_applis": False,
    },
    "notifications": {
        "autorisees": True,
        "mode_alerte": "son",          # "son" ou "discret"
        "ecran_verrouillage": True,
        "badge": True,
        "popup": True,
        "contenu_ecran_verrouillage": "afficher",  # "afficher" ou "masquer"
        "categories": {
            "mises_a_jour_apps": True,
            "meteo_extreme": True,
            "bulletin_quotidien": True,
            "notification_en_cours": False,
            "actualisation_meteo": True,
        },
    },
    "personnalisation": {
        "compte_connecte": None,       # email ou None
        "methode_connexion": None,     # "google", "email", "qr" ou None
    },
}


def _load() -> dict:
    """Charge les préférences depuis le fichier JSON."""
    if os.path.exists(PREFS_FILE):
        with open(PREFS_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
            # Fusionne avec les défauts pour gérer les nouvelles clés
            return _deep_merge(DEFAULT_PREFERENCES.copy(), data)
    return DEFAULT_PREFERENCES.copy()


def _save(prefs: dict) -> None:
    """Sauvegarde les préférences dans le fichier JSON."""
    with open(PREFS_FILE, "w", encoding="utf-8") as f:
        json.dump(prefs, f, ensure_ascii=False, indent=2)


def _deep_merge(base: dict, override: dict) -> dict:
    """Fusionne deux dicts récursivement (override écrase base)."""
    result = base.copy()
    for key, value in override.items():
        if key in result and isinstance(result[key], dict) and isinstance(value, dict):
            result[key] = _deep_merge(result[key], value)
        else:
            result[key] = value
    return result


# ─────────────────────────────────────────────
#  FONCTIONS PUBLIQUES
# ─────────────────────────────────────────────

def get_all_preferences() -> dict:
    return _load()


def update_preferences(updates: dict) -> dict:
    """Met à jour les préférences avec un dict partiel (deep merge)."""
    prefs = _load()
    prefs = _deep_merge(prefs, updates)
    _save(prefs)
    return prefs


def reset_preferences() -> dict:
    """Remet toutes les préférences aux valeurs par défaut."""
    _save(DEFAULT_PREFERENCES.copy())
    return DEFAULT_PREFERENCES.copy()


# ─── Raccourcis pour les alertes ───

def get_alertes() -> dict:
    return _load()["alertes"]

def set_alerte_pluie(value: bool) -> dict:
    return update_preferences({"alertes": {"pluie": value}})

def set_alerte_vent(value: bool) -> dict:
    return update_preferences({"alertes": {"vent_fort": value}})

def set_alerte_canicule(value: bool) -> dict:
    return update_preferences({"alertes": {"canicule": value}})


# ─── Raccourcis pour météo locale ───

def get_meteo_locale() -> dict:
    return _load()["meteo_locale"]

def set_meteo_locale_accepter(value: bool) -> dict:
    return update_preferences({"meteo_locale": {"accepter": value}})

def set_actualisation_auto(value: bool) -> dict:
    return update_preferences({"meteo_locale": {"actualisation_automatique": value}})

def set_affichage_ecran(value: bool) -> dict:
    return update_preferences({"meteo_locale": {"affichage_ecran_applis": value}})


# ─── Raccourcis pour notifications ───

def get_notifications() -> dict:
    return _load()["notifications"]

def set_notifications_autorisees(value: bool) -> dict:
    return update_preferences({"notifications": {"autorisees": value}})

def set_mode_alerte(mode: str) -> dict:
    """mode = 'son' ou 'discret'"""
    return update_preferences({"notifications": {"mode_alerte": mode}})

def set_categories(categories: dict) -> dict:
    return update_preferences({"notifications": {"categories": categories}})


# ─── Raccourcis pour personnalisation ───

def get_personnalisation() -> dict:
    return _load()["personnalisation"]

def set_compte_connecte(email: str, methode: str) -> dict:
    return update_preferences({
        "personnalisation": {
            "compte_connecte": email,
            "methode_connexion": methode,
        }
    })

def deconnecter_compte() -> dict:
    return update_preferences({
        "personnalisation": {
            "compte_connecte": None,
            "methode_connexion": None,
        }
    })