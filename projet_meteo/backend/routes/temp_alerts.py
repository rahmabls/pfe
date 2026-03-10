from fastapi import APIRouter
import services.weather_data_service as data_svc
import services.ml_service as ml

router = APIRouter(prefix="/alertes/temperature", tags=["🚨 Alertes Température"])

# Seuils configurables
SEUIL_FROID = 5.0     # °C
SEUIL_CHAUD = 38.0    # °C


@router.get("/")
def alertes_temperature():
    """Retourne les alertes de température (froid extrême / canicule)."""
    features = data_svc.get_features_for_temp()
    temp = features["temperature_2m"]
    ressenti = features["apparent_temperature"]
    alertes = []

    if temp <= SEUIL_FROID:
        alertes.append({
            "type": "FROID",
            "niveau": "DANGER" if temp <= 0 else "ATTENTION",
            "message": f"❄️ Température très basse : {round(temp, 1)}°C",
        })

    if temp >= SEUIL_CHAUD:
        canicule = ml.predict_canicule(data_svc.get_features_for_canicule())
        alertes.append({
            "type": "CHALEUR",
            "niveau": "DANGER" if canicule["probabilite"] >= 70 else "ATTENTION",
            "message": f"🔥 Chaleur extrême : {round(temp, 1)}°C (ressenti {round(ressenti, 1)}°C)",
            "probabilite_canicule": canicule["probabilite"],
        })

    return {
        "temperature_C": round(temp, 1),
        "ressenti_C": round(ressenti, 1),
        "alertes": alertes,
        "nombre_alertes": len(alertes),
    }
