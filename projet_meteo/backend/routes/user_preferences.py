from fastapi import APIRouter
from pydantic import BaseModel
from services.preferences_service import save_preferences, get_preferences

router = APIRouter(prefix="/user", tags=["User Preferences"])

class Preferences(BaseModel):
    notifications: bool
    rain_alert: bool
    wind_alert: bool
    heat_alert: bool

@router.post("/preferences")
def update_preferences(prefs: Preferences):
    updated = save_preferences(prefs.dict())
    return {
        "message": "Préférences mises à jour",
        "preferences": updated
    }

@router.get("/preferences")
def read_preferences():
    return get_preferences()