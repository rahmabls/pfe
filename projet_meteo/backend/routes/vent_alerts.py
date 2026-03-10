from fastapi import APIRouter
import services.weather_data_service as data_svc
import services.ml_service as ml

router = APIRouter(prefix="/alertes/vent", tags=["🚨 Alertes Vent"])

SEUIL_VENT_FORT   = 50.0   # km/h
SEUIL_VENT_DANGER = 80.0   # km/h


@router.get("/")
def alertes_vent():
    """Retourne les alertes de vent fort."""
    features = data_svc.get_features_for_wind()
    vitesse   = features["wind_speed_10m"]
    rafales   = features["wind_gusts_10m"]
    alertes = []

    prediction = ml.predict_wind_strong(features)

    if vitesse >= SEUIL_VENT_DANGER or rafales >= SEUIL_VENT_DANGER:
        alertes.append({
            "type": "VENT_DANGEREUX",
            "niveau": "DANGER",
            "message": f"🌪️ Vent dangereux : {round(vitesse, 1)} km/h (rafales {round(rafales, 1)} km/h)",
        })
    elif vitesse >= SEUIL_VENT_FORT or prediction["vent_fort"]:
        alertes.append({
            "type": "VENT_FORT",
            "niveau": "ATTENTION",
            "message": f"💨 Vent fort : {round(vitesse, 1)} km/h (rafales {round(rafales, 1)} km/h)",
        })

    return {
        "vitesse_kmh":  round(vitesse, 1),
        "rafales_kmh":  round(rafales, 1),
        "direction_deg": round(features["wind_direction_10m"], 0),
        "prediction_ml": prediction,
        "alertes": alertes,
        "nombre_alertes": len(alertes),
    }
