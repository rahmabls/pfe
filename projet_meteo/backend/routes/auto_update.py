"""
auto_update.py — route pour déclencher/consulter la mise à jour automatique
des données météo depuis Open-Meteo (gratuit, pas de clé API).
"""
from fastapi import APIRouter, BackgroundTasks
import httpx
import pandas as pd
import os
from datetime import datetime, timezone

router = APIRouter(prefix="/auto-update", tags=["🔄 Mise à jour auto"])

CSV_PATH = os.path.join(os.path.dirname(__file__), "..", "data", "output_clean.csv")

# URL Open-Meteo pour Béni Mellal (toutes les variables du CSV)
OPEN_METEO_URL = (
    "https://api.open-meteo.com/v1/forecast"
    "?latitude=32.3373&longitude=-6.3498"
    "&hourly=temperature_2m,relative_humidity_2m,dew_point_2m,apparent_temperature,"
    "precipitation,rain,showers,snowfall,snow_depth,weather_code,pressure_msl,"
    "surface_pressure,cloud_cover,cloud_cover_low,cloud_cover_mid,cloud_cover_high,"
    "visibility,evapotranspiration,et0_fao_evapotranspiration,vapour_pressure_deficit,"
    "wind_speed_10m,wind_speed_80m,wind_speed_120m,wind_direction_10m,wind_direction_80m,"
    "wind_direction_120m,wind_gusts_10m,temperature_80m,temperature_120m,is_day,"
    "uv_index,uv_index_clear_sky,sunshine_duration,wet_bulb_temperature_2m,cape,"
    "lifted_index,convective_inhibition,freezing_level_height"
    "&wind_speed_unit=kmh&timezone=Africa%2FCasablanca&forecast_days=2"
)

_last_update: str = "Jamais"


async def _do_update():
    global _last_update
    async with httpx.AsyncClient(timeout=30) as client:
        resp = await client.get(OPEN_METEO_URL)
        resp.raise_for_status()
        data = resp.json()

    hourly = data["hourly"]
    times  = hourly.pop("time")
    df_new = pd.DataFrame(hourly)
    df_new.insert(0, "date", times)

    # Charge l'ancien CSV et fusionne (évite les doublons sur la date)
    if os.path.exists(CSV_PATH):
        df_old = pd.read_csv(CSV_PATH)
        df_combined = pd.concat([df_old, df_new], ignore_index=True)
        df_combined = df_combined.drop_duplicates(subset=["date"], keep="last")
        df_combined = df_combined.sort_values("date").reset_index(drop=True)
    else:
        df_combined = df_new

    df_combined.to_csv(CSV_PATH, index=False)
    _last_update = datetime.now(timezone.utc).isoformat()

    # Recharge le cache en mémoire
    import services.weather_data_service as wds
    wds._df = None  # force rechargement à la prochaine requête


@router.post("/maintenant")
async def update_now(background_tasks: BackgroundTasks):
    """Déclenche une mise à jour immédiate des données (tâche en arrière-plan)."""
    background_tasks.add_task(_do_update)
    return {"message": "✅ Mise à jour lancée en arrière-plan"}


@router.get("/statut")
def statut():
    """Indique la date/heure de la dernière mise à jour."""
    return {
        "derniere_mise_a_jour": _last_update,
        "csv_existe": os.path.exists(CSV_PATH),
    }
