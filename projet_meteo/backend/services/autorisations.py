from fastapi import APIRouter
from pydantic import BaseModel
import services.autorisations_service as svc

router = APIRouter(prefix="/autorisations", tags=["🔐 Autorisations"])


# ──────────────────────────────────────────────────────────────────────────────
#  SCHEMAS
# ──────────────────────────────────────────────────────────────────────────────

class AutorisationUpdate(BaseModel):
    accordee: bool


# ──────────────────────────────────────────────────────────────────────────────
#  ROUTES
# ──────────────────────────────────────────────────────────────────────────────

@router.get("/")
def get_autorisations():
    """Retourne l'état de toutes les autorisations facultatives."""
    return svc.get_all()


@router.patch("/position")
def update_position(body: AutorisationUpdate):
    """Accorder ou refuser l'accès à la position de l'appareil."""
    return svc.set_position(body.accordee)


@router.patch("/notifications")
def update_notifications(body: AutorisationUpdate):
    """Accorder ou refuser l'affichage des notifications."""
    return svc.set_notifications(body.accordee)


@router.post("/reset")
def reset_autorisations():
    """Remet toutes les autorisations aux valeurs par défaut."""
    return svc.reset()
