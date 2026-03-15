from fastapi import APIRouter
import services.weather_data_service as data_svc
import services.ml_service as ml
from datetime import date, timedelta

router = APIRouter(prefix="/meteo", tags=["🏠 Accueil"])


@router.get("/accueil")
def accueil():
    """Endpoint principal pour le HomeScreen Flutter."""
    temp_f  = data_svc.get_features_for_model_features()
    rain_f  = data_svc.get_features_for_rain()
    wind_f  = data_svc.get_features_for_wind()
    canic_f = data_svc.get_features_for_canicule()

    pluie    = ml.predict_rain(rain_f)
    vent     = ml.predict_wind_strong(wind_f)
    canicule = ml.predict_canicule(canic_f)
    temp_1h  = ml.predict_temperature_1h(temp_f)
    temp_24h = ml.predict_temperature_24h(temp_f)

    def get_icone():
        if canicule["canicule"]:   return "hot"
        if pluie["pluie_probable"]: return "rainy"
        if vent["vent_fort"]:       return "windy"
        if temp_f["cloud_cover"] > 70: return "cloudy"
        if temp_f["cloud_cover"] > 30: return "partly_cloudy"
        return "sunny"

    return {
        "ville":                   "Béni Mellal",
        "temperature_actuelle_C":  round(temp_f["temperature_2m"], 1),
        "ressenti_C":              round(temp_f["apparent_temperature"], 1),
        "humidite_pct":            round(temp_f["relative_humidity_2m"], 1),
        "vent_kmh":                round(temp_f["wind_speed_10m"], 1),
        "rafales_kmh":             round(temp_f["wind_gusts_10m"], 1),
        "uv_index":                round(temp_f["uv_index"], 1),
        "couverture_nuageuse_pct": round(temp_f["cloud_cover"], 1),
        "pression_hpa":            round(temp_f["pressure_msl"], 1),
        "icone":                   get_icone(),
        "predictions": {
            "temperature_1h_C":  round(temp_1h, 1),
            "temperature_24h_C": round(temp_24h, 1),
            "pluie":             pluie,
            "vent":              vent,
            "canicule":          canicule,
        },
    }


# ── NOUVEAU : Prévisions 10 jours ──────────────────────────────────────────
@router.get("/previsions")
def previsions():
    """Prévisions sur 10 jours pour le ForecastScreen Flutter."""
    temp_f  = data_svc.get_features_for_model_features()
    rain_f  = data_svc.get_features_for_rain()
    wind_f  = data_svc.get_features_for_wind()
    canic_f = data_svc.get_features_for_canicule()

    temp_actuelle = round(temp_f["temperature_2m"], 1)
    temp_1h       = round(ml.predict_temperature_1h(temp_f), 1)
    temp_24h      = round(ml.predict_temperature_24h(temp_f), 1)
    pluie         = ml.predict_rain(rain_f)
    vent          = ml.predict_wind_strong(wind_f)
    canicule      = ml.predict_canicule(canic_f)

    def get_icone(temp, pluie_prob, vent_fort, canicule_risque, cloud):
        if canicule_risque: return "hot"
        if pluie_prob:      return "rainy"
        if vent_fort:       return "windy"
        if cloud > 70:      return "cloudy"
        if cloud > 30:      return "partly_cloudy"
        return "sunny"

    jours_noms = ["Lun.", "Mar.", "Mer.", "Jeu.", "Ven.", "Sam.", "Dim."]
    today = date.today()
    previsions_liste = []

    for i in range(10):
        jour_date = today + timedelta(days=i)
        nom_jour = "Auj." if i == 0 else jours_noms[jour_date.weekday()]

        # Variation simulée basée sur les prédictions ML
        if i == 0:
            t_min = temp_actuelle - 3
            t_max = temp_actuelle + 3
        elif i == 1:
            t_min = temp_1h - 3
            t_max = temp_1h + 3
        else:
            t_min = round(temp_24h - (i * 0.3), 1)
            t_max = round(temp_24h + (i * 0.2), 1)

        previsions_liste.append({
            "jour":     nom_jour,
            "date":     jour_date.isoformat(),
            "icone":    get_icone(
                            t_max,
                            pluie["pluie_probable"],
                            vent["vent_fort"],
                            canicule["canicule"],
                            temp_f["cloud_cover"]
                        ),
            "temp_min": round(t_min, 1),
            "temp_max": round(t_max, 1),
        })

    return previsions_liste