from fastapi import APIRouter
from pydantic import BaseModel
from typing import Optional
from services.preferences_service import (
    get_all_preferences,
    update_preferences,
    get_alertes,
    get_meteo_locale,
    get_personnalisation,
    set_compte_connecte,
    deconnecter_compte,
)

router = APIRouter(prefix="/preferences", tags=["⚙️ Préférences"])


# ── GET toutes les préférences ─────────────────────────────────────────────────
@router.get("/")
def get_preferences():
    return get_all_preferences()


# ── Alertes ───────────────────────────────────────────────────────────────────
@router.get("/alertes")
def get_alertes_route():
    return get_alertes()

@router.patch("/alertes")
def patch_alertes(body: dict):
    updated = update_preferences({"alertes": body})
    return updated


# ── Météo locale ──────────────────────────────────────────────────────────────
@router.get("/meteo-locale")
def get_meteo_locale_route():
    return get_meteo_locale()

@router.patch("/meteo-locale")
def patch_meteo_locale(body: dict):
    updated = update_preferences({"meteo_locale": body})
    return updated


# ── Personnalisation ──────────────────────────────────────────────────────────
@router.get("/personnalisation")
def get_personnalisation_route():
    return get_personnalisation()


class ConnexionBody(BaseModel):
    email: str
    methode: str

@router.post("/personnalisation/connecter")
def connecter(body: ConnexionBody):
    updated = set_compte_connecte(body.email, body.methode)
    return updated

@router.post("/personnalisation/deconnecter")
def deconnecter():
    updated = deconnecter_compte()
    return updated
