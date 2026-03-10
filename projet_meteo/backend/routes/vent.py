from fastapi import APIRouter
import services.ml_service as ml
import services.weather_data_service as data_svc

router = APIRouter(prefix="/prediction/vent", tags=["💨 Vent"])


@router.get("/")
def predict_vent():
    """Prédit si un vent fort est probable."""
    features = data_svc.get_features_for_wind()
    result = ml.predict_wind_strong(features)

    if result["probabilite"] >= 70:
        message = "💨 Vent fort prévu — soyez prudent"
    elif result["probabilite"] >= 40:
        message = "🌬️ Vent modéré possible"
    else:
        message = "🍃 Vent faible prévu"

    return {
        **result,
        "message": message,
        "vitesse_actuelle_kmh": round(features["wind_speed_10m"], 1),
        "rafales_actuelles_kmh": round(features["wind_gusts_10m"], 1),
        "direction_deg": round(features["wind_direction_10m"], 0),
    }
