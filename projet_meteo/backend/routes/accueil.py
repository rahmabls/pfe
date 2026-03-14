from fastapi import APIRouter
import services.weather_data_service as data_svc
import services.ml_service as ml

router = APIRouter(prefix="/meteo", tags=["🏠 Accueil"])


@router.get("/accueil")
def accueil():
    """Endpoint principal pour le HomeScreen Flutter."""

    # Features
    temp_f  = data_svc.get_features_for_model_features()
    rain_f  = data_svc.get_features_for_rain()
    wind_f  = data_svc.get_features_for_wind()
    canic_f = data_svc.get_features_for_canicule()

    # Prédictions ML
    pluie    = ml.predict_rain(rain_f)
    vent     = ml.predict_wind_strong(wind_f)
    canicule = ml.predict_canicule(canic_f)
    temp_1h  = ml.predict_temperature_1h(temp_f)
    temp_24h = ml.predict_temperature_24h(temp_f)

    # Icône météo
    def get_icone():
        if canicule["canicule"]:
            return "hot"
        if pluie["pluie_probable"]:
            return "rainy"
        if vent["vent_fort"]:
            return "windy"
        if temp_f["cloud_cover"] > 70:
            return "cloudy"
        if temp_f["cloud_cover"] > 30:
            return "partly_cloudy"
        return "sunny"

    return {
        "ville":                    "Béni Mellal",
        "temperature_actuelle_C":   round(temp_f["temperature_2m"], 1),
        "ressenti_C":               round(temp_f["apparent_temperature"], 1),
        "humidite_pct":             round(temp_f["relative_humidity_2m"], 1),
        "vent_kmh":                 round(temp_f["wind_speed_10m"], 1),
        "rafales_kmh":              round(temp_f["wind_gusts_10m"], 1),
        "uv_index":                 round(temp_f["uv_index"], 1),
        "couverture_nuageuse_pct":  round(temp_f["cloud_cover"], 1),
        "pression_hpa":             round(temp_f["pressure_msl"], 1),
        "icone":                    get_icone(),
        "predictions": {
            "temperature_1h_C":  round(temp_1h, 1),
            "temperature_24h_C": round(temp_24h, 1),
            "pluie":             pluie,
            "vent":              vent,
            "canicule":          canicule,
        },
    }