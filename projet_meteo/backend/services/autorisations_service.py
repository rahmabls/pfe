"""
autorisations_service.py
Gère la persistance des autorisations facultatives de l'application.
"""
import json
import os
import copy

DATA_FILE = os.path.join(os.path.dirname(__file__), "..", "data", "autorisations.json")

# ── Valeurs par défaut ────────────────────────────────────────────────────────
DEFAULT = {
    "position": {
        "accordee":    False,
        "label":       "Position",
        "description": "accéder à la position de l'appareil",
        "icone":       "location_on",
    },
    "notifications": {
        "accordee":    False,
        "label":       "Notifications",
        "description": "afficher des notifications",
        "icone":       "notifications",
    },
    "message_info": (
        "Vous pouvez toujours utiliser les fonctions de base "
        "de l'application sans accorder les autorisations facultatives."
    ),
}


# ──────────────────────────────────────────────────────────────────────────────
#  PERSISTENCE
# ──────────────────────────────────────────────────────────────────────────────

def _load() -> dict:
    if os.path.exists(DATA_FILE):
        with open(DATA_FILE, "r", encoding="utf-8") as f:
            saved = json.load(f)
        data = copy.deepcopy(DEFAULT)
        # Restaure uniquement les valeurs booléennes sauvegardées
        for key in ("position", "notifications"):
            if key in saved and "accordee" in saved[key]:
                data[key]["accordee"] = saved[key]["accordee"]
        return data
    return copy.deepcopy(DEFAULT)


def _save(data: dict) -> None:
    os.makedirs(os.path.dirname(DATA_FILE), exist_ok=True)
    # Sauvegarde uniquement les valeurs booléennes (labels/icones sont statiques)
    payload = {
        "position":      {"accordee": data["position"]["accordee"]},
        "notifications": {"accordee": data["notifications"]["accordee"]},
    }
    with open(DATA_FILE, "w", encoding="utf-8") as f:
        json.dump(payload, f, ensure_ascii=False, indent=2)


# ──────────────────────────────────────────────────────────────────────────────
#  API PUBLIQUE
# ──────────────────────────────────────────────────────────────────────────────

def get_all() -> dict:
    """Retourne l'état complet des autorisations."""
    return _load()


def set_position(accordee: bool) -> dict:
    """Accorder ou refuser l'accès à la position."""
    data = _load()
    data["position"]["accordee"] = accordee
    _save(data)
    return get_all()


def set_notifications(accordee: bool) -> dict:
    """Accorder ou refuser les notifications."""
    data = _load()
    data["notifications"]["accordee"] = accordee
    _save(data)
    return get_all()


def reset() -> dict:
    """Remet tout à False (non accordé)."""
    data = copy.deepcopy(DEFAULT)
    _save(data)
    return get_all()
