from fastapi import APIRouter
import pandas as pd
import numpy as np
import joblib
from datetime import datetime, timedelta
import os


router = APIRouter(prefix="/predict", tags=["Forecast"])
BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

model = joblib.load(os.path.join(BASE_DIR, "models", "model_temperature_1h.pkl"))
features = joblib.load(os.path.join(BASE_DIR, "models", "model_features.pkl"))



def update_time_features(row, dt):

    row["date"] = dt
    row["hour"] = dt.hour
    row["day"] = dt.day
    row["month"] = dt.month
    row["dayofweek"] = dt.weekday()
    row["dayofyear"] = dt.timetuple().tm_yday

    row["hour_sin"] = np.sin(2*np.pi*dt.hour/24)
    row["hour_cos"] = np.cos(2*np.pi*dt.hour/24)
    row["month_sin"] = np.sin(2*np.pi*dt.month/12)
    row["month_cos"] = np.cos(2*np.pi*dt.month/12)

    return row


# ---------------------------------------------------
# Prévision récursive (le coeur)
# ---------------------------------------------------
def forecast_next_hours(initial_row, hours=24):

    history = initial_row.copy()
    predictions = []

    current_time = pd.to_datetime(history["date"])

    for _ in range(hours):

        X = pd.DataFrame([history])[features]
        next_temp = float(model.predict(X)[0])

        predictions.append(round(next_temp,2))

        # décaler les lags
        for lag in [24,12,6,3,2]:
            history[f"temp_lag_{lag}"] = history.get(f"temp_lag_{lag-1}", next_temp)

        history["temp_lag_1"] = next_temp

        # tendances
        history["temp_trend_3h"] = history["temp_lag_1"] - history.get("temp_lag_3", next_temp)
        history["temp_trend_6h"] = history["temp_lag_1"] - history.get("temp_lag_6", next_temp)

        # avancer l'heure
        current_time += timedelta(hours=1)
        history = update_time_features(history,current_time)

    return predictions


# ---------------------------------------------------
# ENDPOINT API
# ---------------------------------------------------
@router.post("/24h")
def predict_24h(current_weather: dict):

    temps = forecast_next_hours(current_weather,24)

    now = datetime.now()
    hours = [(now + timedelta(hours=i+1)).strftime("%H:%M") for i in range(24)]

    return {
        "hours": hours,
        "temperature": temps
    }