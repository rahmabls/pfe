from fastapi import APIRouter
import pandas as pd
import joblib
import os

router = APIRouter(prefix="/predict", tags=["Rain"])

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

model = joblib.load(os.path.join(BASE_DIR, "models", "model_rain_logistic.pkl"))
scaler = joblib.load(os.path.join(BASE_DIR, "models", "scaler_rain.pkl"))
features = joblib.load(os.path.join(BASE_DIR, "models", "features_rain.pkl"))



@router.post("/rain")
def predict_rain(data: dict):

    X = pd.DataFrame([data])[features]
    X = scaler.transform(X)

    proba = model.predict_proba(X)[0][1]

    if proba > 0.5:
        status = "pluie probable"
    else:
        status = "pas de pluie"

    return {
        "pluie": status,
        "probabilite": round(float(proba*100),2)
    }