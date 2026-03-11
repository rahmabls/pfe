from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/local-weather", tags=["Local Weather"])

# modèle des paramètres envoyés par Flutter
class LocalWeatherSettings(BaseModel):
    location_permission: bool
    auto_update: bool
    show_on_apps_screen: bool

# stockage temporaire
settings_data = {}

# sauvegarder les paramètres
@router.post("/update")
def update_settings(settings: LocalWeatherSettings):

    settings_data["location_permission"] = settings.location_permission
    settings_data["auto_update"] = settings.auto_update
    settings_data["show_on_apps_screen"] = settings.show_on_apps_screen

    return {
        "message": "Settings updated",
        "data": settings_data
    }

# récupérer les paramètres
@router.get("/get")
def get_settings():
    return settings_data