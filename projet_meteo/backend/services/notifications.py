from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, validator
from typing import Optional
import services.notifications_service as svc

router = APIRouter(prefix="/notifications", tags=["🔔 Notifications"])


# ──────────────────────────────────────────────────────────────────────────────
#  SCHEMAS PYDANTIC
# ──────────────────────────────────────────────────────────────────────────────

class AutorisationUpdate(BaseModel):
    autorisees: bool

class ModeAlerteUpdate(BaseModel):
    mode: str  # "son" ou "discret"

    @validator("mode")
    def valider_mode(cls, v):
        if v not in ("son", "discret"):
            raise ValueError("mode doit être 'son' ou 'discret'")
        return v

class TypesNotifUpdate(BaseModel):
    ecran_verrouillage: Optional[bool] = None
    badge: Optional[bool] = None
    popup: Optional[bool] = None

class ContenuVerrouillageUpdate(BaseModel):
    contenu: str  # "afficher" ou "masquer"

    @validator("contenu")
    def valider_contenu(cls, v):
        if v not in ("afficher", "masquer"):
            raise ValueError("contenu doit être 'afficher' ou 'masquer'")
        return v

class CategoriesUpdate(BaseModel):
    mises_a_jour_apps: Optional[bool] = None
    meteo_extreme: Optional[bool] = None
    bulletin_quotidien: Optional[bool] = None
    notification_en_cours: Optional[bool] = None
    actualisation_meteo: Optional[bool] = None


# ──────────────────────────────────────────────────────────────────────────────
#  ROUTES
# ──────────────────────────────────────────────────────────────────────────────

@router.get("/")
def get_notifications():
    """Retourne tous les paramètres de notification."""
    return svc.get_all()


@router.patch("/autorisation")
def update_autorisation(body: AutorisationUpdate):
    """Active ou désactive les notifications."""
    return svc.set_autorisation(body.autorisees)


@router.patch("/mode-alerte")
def update_mode_alerte(body: ModeAlerteUpdate):
    """
    Change le mode d'alerte.
    - 'son'     → son + vibration + popup activé
    - 'discret' → silencieux + popup désactivé
    """
    return svc.set_mode_alerte(body.mode)


@router.patch("/types")
def update_types(body: TypesNotifUpdate):
    """
    Met à jour les types de notification (écran verr., badge, pop-up).
    Note : popup ne peut être activé qu'en mode 'son'.
    """
    updates = body.dict(exclude_none=True)
    if not updates:
        raise HTTPException(status_code=400, detail="Aucune valeur fournie")
    return svc.set_types(updates)


@router.patch("/ecran-verrouillage")
def update_ecran_verrouillage(body: ContenuVerrouillageUpdate):
    """Afficher ou masquer le contenu sur l'écran verrouillé."""
    return svc.set_contenu_verrouillage(body.contenu)


@router.get("/categories")
def get_categories():
    """Retourne les catégories de notification."""
    return svc.get_categories()


@router.patch("/categories")
def update_categories(body: CategoriesUpdate):
    """Met à jour une ou plusieurs catégories de notification."""
    updates = body.dict(exclude_none=True)
    if not updates:
        raise HTTPException(status_code=400, detail="Aucune valeur fournie")
    return svc.set_categories(updates)


@router.post("/reset")
def reset_notifications():
    """Remet les notifications aux valeurs par défaut."""
    return svc.reset()
