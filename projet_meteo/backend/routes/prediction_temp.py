from fastapi import APIRouter
import services.ml_service as ml
import services.weather_data_service as data_svc

router = APIRouter(prefix="/prediction/temperature", tags=["🌡️ Température"])


@router.get("/1h")
def temperature_1h():
    """Prédit la température dans 1 heure."""
    features = data_svc.get_features_for_temp()
    predicted = ml.predict_temperature_1h(features)
    return {
        "horizon": "1h",
        "temperature_actuelle_C": round(features["temperature_2m"], 1),
        "temperature_predite_C": round(predicted, 1),
    }


@router.get("/24h")
def temperature_24h():
    """Prédit la température dans 24 heures."""
    features = data_svc.get_features_for_temp()
    predicted = ml.predict_temperature_24h(features)
    return {
        "horizon": "24h",
        "temperature_actuelle_C": round(features["temperature_2m"], 1),
        "temperature_predite_C": round(predicted, 1),
    }


@router.get("/all")
def temperature_all():
    """Retourne les prédictions 1h et 24h ensemble."""
    features = data_svc.get_features_for_temp()
    return {
        "temperature_actuelle_C": round(features["temperature_2m"], 1),
        "dans_1h_C":  round(ml.predict_temperature_1h(features), 1),
        "dans_24h_C": round(ml.predict_temperature_24h(features), 1),
    }
