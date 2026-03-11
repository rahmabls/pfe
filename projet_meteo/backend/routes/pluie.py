from fastapi import APIRouter
import services.ml_service as ml
import services.weather_data_service as data_svc

router = APIRouter(prefix="/prediction/pluie", tags=["🌧️ Pluie"])


@router.get("/")
def predict_pluie():
    """Prédit la probabilité de pluie à partir des données actuelles."""
    features = data_svc.get_features_for_rain()
    result = ml.predict_rain(features)

    # Message lisible pour Flutter
    if result["probabilite"] >= 70:
        message = "🌧️ Forte probabilité de pluie"
    elif result["probabilite"] >= 40:
        message = "🌦️ Pluie possible"
    else:
        message = "☀️ Peu de risque de pluie"

    return {
        **result,
        "message": message,
        "humidite_actuelle": round(features["relative_humidity_2m"], 1),
        "pression_actuelle": round(features["pressure_msl"], 1),
    }
