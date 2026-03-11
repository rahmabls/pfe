from fastapi import APIRouter
import services.ml_service as ml
import services.weather_data_service as data_svc

router = APIRouter(prefix="/prediction/canicule", tags=["🔥 Canicule"])


@router.get("/")
def predict_canicule():
    """Prédit le risque de canicule."""
    features = data_svc.get_features_for_canicule()
    result = ml.predict_canicule(features)

    if result["probabilite"] >= 70:
        message = "🔥 Risque élevé de canicule — restez hydraté"
        niveau = "ÉLEVÉ"
    elif result["probabilite"] >= 40:
        message = "⚠️ Chaleur intense possible"
        niveau = "MODÉRÉ"
    else:
        message = "✅ Pas de risque de canicule"
        niveau = "FAIBLE"

    return {
        **result,
        "message": message,
        "niveau_risque": niveau,
        "temperature_actuelle_C": round(features["temperature_2m"], 1),
        "ressenti_C": round(features["apparent_temperature"], 1),
        "humidite_pct": round(features["relative_humidity_2m"], 1),
        "uv_index": round(features["uv_index"], 1),
    }
