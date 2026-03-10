"""
notifications_service.py
Gère la persistance des paramètres de notification dans un fichier JSON.
"""
import json
import os

NOTIF_FILE = os.path.join(os.path.dirname(__file__), "..", "data", "notifications.json")

# ── Valeurs par défaut (correspond exactement à l'écran Flutter) ──────────────
DEFAULT = {
    "autorisation": {
        "autorisees": True,
    },
    "alertes": {
        "mode": "son",          # "son" → son+vibration  |  "discret" → silencieux
    },
    "types": {
        "ecran_verrouillage": True,
        "badge":              True,
        "popup":              True,   # visible seulement si mode == "son"
    },
    "ecran_verrouillage": {
        "contenu": "afficher",  # "afficher" ou "masquer"
    },
    "categories": {
        "mises_a_jour_apps":    True,
        "meteo_extreme":        True,
        "bulletin_quotidien":   True,
        "notification_en_cours": False,
        "actualisation_meteo":  True,
    },
}


# ──────────────────────────────────────────────────────────────────────────────
#  PERSISTENCE
# ──────────────────────────────────────────────────────────────────────────────

def _load() -> dict:
    if os.path.exists(NOTIF_FILE):
        with open(NOTIF_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
        return _deep_merge(DEFAULT.copy(), data)
    return _deep_copy(DEFAULT)


def _save(data: dict) -> None:
    os.makedirs(os.path.dirname(NOTIF_FILE), exist_ok=True)
    with open(NOTIF_FILE, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def _deep_merge(base: dict, override: dict) -> dict:
    result = base.copy()
    for k, v in override.items():
        if k in result and isinstance(result[k], dict) and isinstance(v, dict):
            result[k] = _deep_merge(result[k], v)
        else:
            result[k] = v
    return result


def _deep_copy(d: dict) -> dict:
    import copy
    return copy.deepcopy(d)


# ──────────────────────────────────────────────────────────────────────────────
#  API PUBLIQUE
# ──────────────────────────────────────────────────────────────────────────────

def get_all() -> dict:
    """Retourne tous les paramètres de notification."""
    data = _load()
    # Ajoute un champ calculé : popup visible dans l'UI seulement si mode = son
    data["types"]["popup_visible"] = (data["alertes"]["mode"] == "son")
    return data


def set_autorisation(autorisees: bool) -> dict:
    """Active ou désactive toutes les notifications."""
    data = _load()
    data["autorisation"]["autorisees"] = autorisees
    _save(data)
    return get_all()


def set_mode_alerte(mode: str) -> dict:
    """
    Change le mode :
    - 'discret' → désactive automatiquement le popup (logique métier de l'app)
    - 'son'     → réactive le popup
    """
    data = _load()
    data["alertes"]["mode"] = mode
    if mode == "discret":
        data["types"]["popup"] = False
    else:
        data["types"]["popup"] = True
    _save(data)
    return get_all()


def set_types(updates: dict) -> dict:
    """
    Met à jour les types (écran_verrouillage, badge, popup).
    Règle : popup ne peut être True que si mode == 'son'.
    """
    data = _load()

    if "popup" in updates and updates["popup"]:
        if data["alertes"]["mode"] == "discret":
            updates["popup"] = False   # interdiction silencieuse

    data["types"].update(updates)
    _save(data)
    return get_all()


def set_contenu_verrouillage(contenu: str) -> dict:
    """Afficher ou masquer le contenu sur l'écran verrouillé."""
    data = _load()
    data["ecran_verrouillage"]["contenu"] = contenu
    _save(data)
    return get_all()


def get_categories() -> dict:
    """Retourne uniquement les catégories."""
    return _load()["categories"]


def set_categories(updates: dict) -> dict:
    """Met à jour une ou plusieurs catégories."""
    data = _load()
    data["categories"].update(updates)
    _save(data)
    return get_all()


def reset() -> dict:
    """Remet tout aux valeurs par défaut."""
    data = _deep_copy(DEFAULT)
    _save(data)
    return get_all()
