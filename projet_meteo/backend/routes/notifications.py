from fastapi import APIRouter
from services.preferences_service import (
    get_all_preferences,
    update_preferences,
    get_notifications,
    set_notifications_autorisees,
    set_mode_alerte,
    set_categories,
)

router = APIRouter(prefix="/notifications", tags=["🔔 Notifications"])


# ── GET toutes les notifications ──────────────────────────────────────────────
@router.get("/")
def get_notifications_route():
    prefs = get_all_preferences()
    notifs = prefs["notifications"]
    return {
        "autorisation": {
            "autorisees": notifs["autorisees"],
        },
        "alertes": {
            "mode": notifs["mode_alerte"],
        },
        "types": {
            "ecran_verrouillage": notifs["ecran_verrouillage"],
            "badge":              notifs["badge"],
            "popup":              notifs["popup"],
            "popup_visible":      True,
        },
        "ecran_verrouillage": {
            "contenu": notifs["contenu_ecran_verrouillage"],
        },
        "categories": notifs["categories"],
    }


# ── Autorisation ──────────────────────────────────────────────────────────────
@router.patch("/autorisation")
def patch_autorisation(body: dict):
    updated = update_preferences({"notifications": {"autorisees": body.get("autorisees")}})
    return get_notifications_route()


# ── Mode alerte ───────────────────────────────────────────────────────────────
@router.patch("/mode-alerte")
def patch_mode_alerte(body: dict):
    updated = update_preferences({"notifications": {"mode_alerte": body.get("mode")}})
    return get_notifications_route()


# ── Types ─────────────────────────────────────────────────────────────────────
@router.patch("/types")
def patch_types(body: dict):
    updated = update_preferences({"notifications": body})
    return get_notifications_route()


# ── Écran verrouillage ────────────────────────────────────────────────────────
@router.patch("/ecran-verrouillage")
def patch_ecran_verrouillage(body: dict):
    updated = update_preferences({"notifications": {"contenu_ecran_verrouillage": body.get("contenu")}})
    return get_notifications_route()


# ── Catégories ────────────────────────────────────────────────────────────────
@router.patch("/categories")
def patch_categories(body: dict):
    updated = update_preferences({"notifications": {"categories": body}})
    return {"categories": updated["notifications"]["categories"]}
