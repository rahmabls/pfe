from fastapi import APIRouter
from services.preferences_service import get_all_preferences, update_preferences

router = APIRouter(prefix="/autorisations", tags=["🔐 Autorisations"])

# Stockage simple en mémoire
_autorisations = {
    "position":      {"accordee": False},
    "notifications": {"accordee": True},
}


@router.get("/")
def get_autorisations():
    return {
        **_autorisations,
        "message_info": (
            "Les autorisations permettent à l'application d'accéder "
            "à certaines fonctionnalités de votre appareil."
        ),
    }


@router.patch("/{type_autorisation}")
def patch_autorisation(type_autorisation: str, body: dict):
    if type_autorisation not in _autorisations:
        _autorisations[type_autorisation] = {}
    _autorisations[type_autorisation]["accordee"] = body.get("accordee", False)
    return {
        **_autorisations,
        "message_info": (
            "Les autorisations permettent à l'application d'accéder "
            "à certaines fonctionnalités de votre appareil."
        ),
    }
