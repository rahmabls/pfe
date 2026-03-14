from fastapi import APIRouter
from pydantic import BaseModel
from services.preferences_service import update_preferences, get_all_preferences

router = APIRouter(prefix="/user", tags=["User Preferences"])

class Preferences(BaseModel):
    notifications: bool
    rain_alert: bool
    wind_alert: bool
    heat_alert: bool

@router.post("/preferences")
def save_preferences(prefs: Preferences):
    updated = update_preferences({
        "notifications": {"autorisees": prefs.notifications},
        "alertes": {
            "pluie": prefs.rain_alert,
            "vent_fort": prefs.wind_alert,
            "canicule": prefs.heat_alert,
        }
    })
    return {
        "message": "Préférences mises à jour",
        "preferences": updated
    }

@router.get("/preferences")
def read_preferences():
    return get_all_preferences()