import sys
import os

sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="Weather AI API",
    description="API de prévision météo intelligente - PFE",
    version="1.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ── Import des routes ──────────────────────────────────────────────────────────
from routes.astronomy       import router as astronomy_router
from routes.pluie           import router as rain_router
from routes.pred_canicule   import router as canicule_router
from routes.prediction_temp import router as temperature_router
from routes.temp_alerts     import router as temp_alerts_router
from routes.vent_alerts     import router as wind_alerts_router
from routes.vent            import router as wind_router
from routes.user_preferences import router as user_preferences_router
from routes.chatbot         import router as chatbot_router
from routes.accueil         import router as accueil_router
from routes.preferences     import router as preferences_router      # ← NOUVEAU
from routes.notifications   import router as notifications_router    # ← NOUVEAU
from routes.autorisations   import router as autorisations_router    # ← NOUVEAU
from routes.chat            import router as chat_router             # ← NOUVEAU

# ── Inclusion des routes ───────────────────────────────────────────────────────
app.include_router(astronomy_router)
app.include_router(rain_router)
app.include_router(canicule_router)
app.include_router(temperature_router)
app.include_router(temp_alerts_router)
app.include_router(wind_alerts_router)
app.include_router(wind_router)
app.include_router(user_preferences_router)
app.include_router(chatbot_router)
app.include_router(accueil_router)
app.include_router(preferences_router)      # ← NOUVEAU
app.include_router(notifications_router)    # ← NOUVEAU
app.include_router(autorisations_router)    # ← NOUVEAU
app.include_router(chat_router)             # ← NOUVEAU


@app.get("/")
def home():
    return {
        "status": "Weather AI backend running",
        "modules": [
            "temperature prediction",
            "rain probability",
            "heatwave detection",
            "wind alerts",
            "astronomy data",
            "user preferences",
            "notifications",
            "autorisations",
            "chatbot",
            "accueil",
        ]
    }