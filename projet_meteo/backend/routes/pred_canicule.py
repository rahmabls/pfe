
from fastapi import APIRouter
import pandas as pd
import joblib
import os

router = APIRouter(prefix="/predict", tags=["Rain"])

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

model = joblib.load(os.path.join(BASE_DIR, "models", "model_extreme_logreg.pkl"))
scaler = joblib.load(os.path.join(BASE_DIR, "models", "scaler_extreme.pkl"))
features = joblib.load(os.path.join(BASE_DIR, "models", "features_extreme.pkl"))

labels = {
    0: ("froid","bleu"),
    1: ("normal","vert"),
    2: ("canicule","rouge")
}

@router.post("/extreme")
def predict_extreme(data: dict):

    X = pd.DataFrame([data])[features]
    X = scaler.transform(X)

    proba = model.predict_proba(X)[0]
    pred = proba.argmax()

    event,level = labels[pred]

    return {
        "event": event,
        "niveau": level,
        "probabilite": float(proba[pred])
    }