from fastapi import APIRouter
from datetime import datetime, timedelta
import joblib
import pandas as pd

from routes.prediction_temp import forecast_next_hours

router = APIRouter(prefix="/alert", tags=["Wind Alerts"])

# charger modèle
model = joblib.load("model_wind_binary.pkl")
scaler = joblib.load("scaler_wind_binary.pkl")
features = joblib.load("features_wind_binary.pkl")


# -------------------------------------------------
# detecter vent fort
# -------------------------------------------------
def detect_wind_alert(hours, weather_rows):

    strong_hours = []

    for i,row in enumerate(weather_rows):

        X = pd.DataFrame([row])[features]
        X = scaler.transform(X)

        pred = model.predict(X)[0]

        if pred == 1:
            strong_hours.append(hours[i])

    # chercher périodes continues
    alerts = []
    count = 0
    start = None

    for i,h in enumerate(strong_hours):

        if count == 0:
            start = h
            count = 1
        else:
            count += 1

        if count >= 2:
            alerts.append((start,h))

    return alerts


# -------------------------------------------------
# endpoint
# -------------------------------------------------
@router.post("/wind/24h")
def wind_alert_24h(current_weather: dict):

    temps = forecast_next_hours(current_weather,24)

    now = datetime.now()
    hours = [(now + timedelta(hours=i+1)).strftime("%H:%M") for i in range(24)]

    # ici on simule météo future = copie actuelle
    weather_rows = [current_weather.copy() for _ in range(24)]

    alerts = detect_wind_alert(hours,weather_rows)

    return {
        "alerts_wind": alerts
    }