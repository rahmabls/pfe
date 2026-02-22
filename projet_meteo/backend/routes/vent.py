from fastapi import APIRouter
import joblib
import pandas as pd
import os

router = APIRouter(prefix="/predict", tags=["Wind"])

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

model = joblib.load(os.path.join(BASE_DIR, "models", "model_wind_binary.pkl"))
scaler = joblib.load(os.path.join(BASE_DIR, "models", "scaler_wind_binary.pkl"))
features = joblib.load(os.path.join(BASE_DIR, "models", "features_wind_binary.pkl"))


@router.post("/wind")
def predict_wind(data: dict):

    X = pd.DataFrame([data])[features]
    X = scaler.transform(X)

    pred = model.predict(X)[0]
    proba = model.predict_proba(X)[0][1]

    if pred == 1:
        return {"vent":"fort","niveau":"jaune","probabilite":float(proba)}
    else:
        return {"vent":"normal","niveau":"vert","probabilite":float(1-proba)}