from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
import services.preferences_service as svc

router = APIRouter(prefix="/preferences", tags=["Préférences"])


# ─────────────────────────────────────────────
#  SCHEMAS PYDANTIC
# ─────────────────────────────────────────────

class AlertesUpdate(BaseModel):
    pluie: Optional[bool] = None
    vent_fort: Optional[bool] = None
    canicule: Optional[bool] = None

class MeteoLocaleUpdate(BaseModel):
    accepter: Optional[bool] = None
    actualisation_automatique: Optional[bool] = None
    affichage_ecran_applis: Optional[bool] = None

class NotifCategories(BaseModel):
    mises_a_jour_apps: Optional[bool] = None
    meteo_extreme: Optional[bool] = None
    bulletin_quotidien: Optional[bool] = None
    notification_en_cours: Optional[bool] = None
    actualisation_meteo: Optional[bool] = None

class NotificationsUpdate(BaseModel):
    autorisees: Optional[bool] = None
    mode_alerte: Optional[str] = None   # "son" ou "discret"
    ecran_verrouillage: Optional[bool] = None
    badge: Optional[bool] = None
    popup: Optional[bool] = None
    contenu_ecran_verrouillage: Optional[str] = None  # "afficher" ou "masquer"
    categories: Optional[NotifCategories] = None

class ConnexionUpdate(BaseModel):
    email: str
    methode: str   # "google", "email", "qr"


# ─────────────────────────────────────────────
#  ROUTES GÉNÉRALES
# ─────────────────────────────────────────────

@router.get("/")
def get_all():
    """Retourne toutes les préférences de l'utilisateur."""
    return svc.get_all_preferences()


@router.post("/reset")
def reset():
    """Remet toutes les préférences aux valeurs par défaut."""
    return svc.reset_preferences()


# ─────────────────────────────────────────────
#  ALERTES
# ─────────────────────────────────────────────

@router.get("/alertes")
def get_alertes():
    return svc.get_alertes()

@router.patch("/alertes")
def update_alertes(body: AlertesUpdate):
    updates = {k: v for k, v in body.dict().items() if v is not None}
    if not updates:
        raise HTTPException(status_code=400, detail="Aucune valeur fournie")
    return svc.update_preferences({"alertes": updates})


# ─────────────────────────────────────────────
#  MÉTÉO LOCALE
# ─────────────────────────────────────────────

@router.get("/meteo-locale")
def get_meteo_locale():
    return svc.get_meteo_locale()

@router.patch("/meteo-locale")
def update_meteo_locale(body: MeteoLocaleUpdate):
    updates = {k: v for k, v in body.dict().items() if v is not None}
    if not updates:
        raise HTTPException(status_code=400, detail="Aucune valeur fournie")
    return svc.update_preferences({"meteo_locale": updates})


# ─────────────────────────────────────────────
#  NOTIFICATIONS
# ─────────────────────────────────────────────

@router.get("/notifications")
def get_notifications():
    return svc.get_notifications()

@router.patch("/notifications")
def update_notifications(body: NotificationsUpdate):
    updates = body.dict(exclude_none=True)

    # Valide mode_alerte
    if "mode_alerte" in updates and updates["mode_alerte"] not in ("son", "discret"):
        raise HTTPException(status_code=400, detail="mode_alerte doit être 'son' ou 'discret'")

    # Valide contenu_ecran_verrouillage
    if "contenu_ecran_verrouillage" in updates:
        if updates["contenu_ecran_verrouillage"] not in ("afficher", "masquer"):
            raise HTTPException(status_code=400, detail="Valeur invalide pour contenu_ecran_verrouillage")

    return svc.update_preferences({"notifications": updates})


# ─────────────────────────────────────────────
#  PERSONNALISATION
# ─────────────────────────────────────────────

@router.get("/personnalisation")
def get_personnalisation():
    return svc.get_personnalisation()

@router.post("/personnalisation/connecter")
def connecter(body: ConnexionUpdate):
    methodes_valides = ("google", "email", "qr")
    if body.methode not in methodes_valides:
        raise HTTPException(status_code=400, detail=f"methode doit être parmi {methodes_valides}")
    return svc.set_compte_connecte(body.email, body.methode)

@router.post("/personnalisation/deconnecter")
def deconnecter():
    return svc.deconnecter_compte()
