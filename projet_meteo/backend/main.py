from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import httpx
import os


from routes import (
    astronomy,
    pluie,
    vent,
    pred_canicule,
    prediction_temp,
    temp_alerts,
    vent_alerts,
    user_preferences,
    display_weather,
    auto_update,
    chatbot
)

app = FastAPI(
    title="🌦️ Météo Béni Mellal API",
    description="Backend ML pour l'application météo — PFE",
    version="1.0.0",
)

# ── CORS (Flutter peut appeler l'API) ──────────────────────────────────────
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── ROUTES ─────────────────────────────────────────────────────────────────
app.include_router(astronomy.router)
app.include_router(pluie.router)
app.include_router(vent.router)
app.include_router(pred_canicule.router)
app.include_router(prediction_temp.router)
app.include_router(temp_alerts.router)
app.include_router(vent_alerts.router)
app.include_router(user_preferences.router)
app.include_router(display_weather.router)
app.include_router(auto_update.router)
app.include_router(chatbot.router)


@app.get("/", tags=["Health"])
def root():
    return {"status": "✅ API Météo opérationnelle", "ville": "Béni Mellal"}
