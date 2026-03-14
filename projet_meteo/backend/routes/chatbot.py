from fastapi import APIRouter
from pydantic import BaseModel
from google import genai
import services.weather_data_service as data_svc
import services.ml_service as ml

router = APIRouter(prefix="/chatbot", tags=["🤖 Chatbot Météo"])

# ── Config Gemini ──────────────────────────────────────────────────────────
GEMINI_API_KEY = "AIzaSyCytX5FrLVXBBug_MND6jpM5366Ae2GAg0"


class ChatRequest(BaseModel):
    message: str


def _build_context() -> str:
    temp_f  = data_svc.get_features_for_model_features()
    rain_f  = data_svc.get_features_for_rain()
    wind_f  = data_svc.get_features_for_wind()
    canic_f = data_svc.get_features_for_canicule()

    pluie    = ml.predict_rain(rain_f)
    vent     = ml.predict_wind_strong(wind_f)
    canicule = ml.predict_canicule(canic_f)
    temp_1h  = ml.predict_temperature_1h(temp_f)
    temp_24h = ml.predict_temperature_24h(temp_f)

    return f"""
Tu es un assistant météo intelligent pour la ville de Béni Mellal, Maroc.
Réponds toujours en français, de façon claire et concise.
Utilise uniquement les données ci-dessous pour répondre aux questions météo.

=== DONNÉES MÉTÉO ACTUELLES ===
- Température actuelle     : {round(temp_f['temperature_2m'], 1)} °C
- Ressenti                 : {round(temp_f['apparent_temperature'], 1)} °C
- Humidité                 : {round(temp_f['relative_humidity_2m'], 1)} %
- Pression                 : {round(temp_f['pressure_msl'], 1)} hPa
- Vent                     : {round(wind_f['wind_speed_10m'], 1)} km/h
- Rafales                  : {round(wind_f['wind_gusts_10m'], 1)} km/h
- UV Index                 : {round(temp_f['uv_index'], 1)}

=== PRÉDICTIONS ML ===
- Température dans 1h      : {round(temp_1h, 1)} °C
- Température dans 24h     : {round(temp_24h, 1)} °C
- Pluie probable           : {'Oui' if pluie['pluie_probable'] else 'Non'} ({pluie['probabilite']} %)
- Vent fort                : {'Oui' if vent['vent_fort'] else 'Non'} ({vent['probabilite']} %)
- Risque canicule          : {'Oui' if canicule['canicule'] else 'Non'} ({canicule['probabilite']} %)
"""


@router.post("/")
def chat(req: ChatRequest):
    try:
        client  = genai.Client(api_key=GEMINI_API_KEY)  # ← créé ici à chaque requête
        context = _build_context()
        prompt  = f"{context}\n\nQuestion de l'utilisateur : {req.message}"
        response = client.models.generate_content(
            model="gemini-2.0-flash",
            contents=prompt,
        )
        return {
            "question": req.message,
            "reponse":  response.text,
        }
    except Exception as e:
        return {
            "question": req.message,
            "reponse":  "Le chatbot est temporairement indisponible. Réessayez dans quelques minutes.",
            "erreur":   str(e)
        }