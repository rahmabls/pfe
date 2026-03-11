"""
display_weather.py — route pour afficher un résumé météo complet
destiné à l'écran d'accueil de l'app Flutter.
"""
from fastapi import APIRouter
import services.ml_service as ml
import services.weather_data_service as data_svc
from datetime import date
import math

router = APIRouter(prefix="/meteo", tags=["🌦️ Météo Accueil"])

# Béni Mellal coords (pour astronomie)
LAT, LON, TZ = 32.3373, -6.3498, 1


def _icon_from_conditions(temp: float, pluie: bool, vent_fort: bool, cloud: float) -> str:
    if pluie:
        return "rainy"
    if vent_fort:
        return "windy"
    if cloud > 70:
        return "cloudy"
    if cloud > 30:
        return "partly_cloudy"
    if temp > 35:
        return "hot"
    return "sunny"


@router.get("/accueil")
def meteo_accueil():
    """Résumé complet pour l'écran d'accueil Flutter."""
    temp_f   = data_svc.get_features_for_temp()
    rain_f   = data_svc.get_features_for_rain()
    wind_f   = data_svc.get_features_for_wind()
    canic_f  = data_svc.get_features_for_canicule()

    temp_1h  = ml.predict_temperature_1h(temp_f)
    temp_24h = ml.predict_temperature_24h(temp_f)
    pluie    = ml.predict_rain(rain_f)
    vent     = ml.predict_wind_strong(wind_f)
    canicule = ml.predict_canicule(canic_f)

    row = data_svc.get_latest_row()
    cloud = float(row["cloud_cover"]) if not __import__("pandas").isna(row["cloud_cover"]) else 0.0

    icone = _icon_from_conditions(
        temp=temp_f["temperature_2m"],
        pluie=pluie["pluie_probable"],
        vent_fort=vent["vent_fort"],
        cloud=cloud,
    )

    return {
        "ville": "Béni Mellal",
        "icone": icone,
        "temperature_actuelle_C": round(temp_f["temperature_2m"], 1),
        "ressenti_C":             round(temp_f["apparent_temperature"], 1),
        "humidite_pct":           round(temp_f["relative_humidity_2m"], 1),
        "pression_hpa":           round(temp_f["pressure_msl"], 1),
        "vent_kmh":               round(wind_f["wind_speed_10m"], 1),
        "rafales_kmh":            round(wind_f["wind_gusts_10m"], 1),
        "uv_index":               round(temp_f["uv_index"], 1),
        "couverture_nuageuse_pct": round(cloud, 1),
        "predictions": {
            "temperature_1h_C":  round(temp_1h, 1),
            "temperature_24h_C": round(temp_24h, 1),
            "pluie":    pluie,
            "vent":     vent,
            "canicule": canicule,
        },
    }
