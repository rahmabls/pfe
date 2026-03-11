
import os
import joblib          # ← joblib au lieu de pickle
import pickle          # ← seulement pour les listes de features
import numpy as np

MODELS_DIR = os.path.join(os.path.dirname(__file__), "..", "models")


def _load_joblib(filename: str):
    """Charge un modèle sauvegardé avec joblib.dump()"""
    path = os.path.join(MODELS_DIR, filename)
    return joblib.load(path)


def _load_pickle(filename: str):
    """Charge une liste de features sauvegardée avec pickle.dump()"""
    path = os.path.join(MODELS_DIR, filename)
    with open(path, "rb") as f:
        return pickle.load(f)


# ── Chargement unique au démarrage ────────────────────────────────────────────
model_temp_1h       = _load_joblib("model_temperature_1h.pkl")
model_temp_24h      = _load_joblib("model_temperature_24h.pkl")
model_rain          = _load_joblib("model_rain_logistic.pkl")
model_wind          = _load_joblib("model_wind_binary.pkl")
model_canicule      = _load_joblib("model_extreme_logreg.pkl")

scaler_rain         = _load_joblib("scaler_rain.pkl")
scaler_wind         = _load_joblib("scaler_wind_binary.pkl")
scaler_extreme      = _load_joblib("scaler_extreme.pkl")

# Listes de features (sauvegardées avec pickle natif → pas joblib)
features_rain       = _load_pickle("features_rain.pkl")
features_wind       = _load_pickle("features_wind_binary.pkl")
features_extreme    = _load_pickle("features_extreme.pkl")


def _to_array(features_dict: dict, feature_list: list) -> np.ndarray:
    """Convertit un dict de features en tableau numpy dans le bon ordre."""
    row = [features_dict.get(f, 0.0) for f in feature_list]
    return np.array([row], dtype=float)


# ── Température ───────────────────────────────────────────────────────────────

def predict_temperature_1h(features: dict) -> float:
    import pandas as pd
    X = pd.DataFrame([features])
    return float(model_temp_1h.predict(X)[0])


def predict_temperature_24h(features: dict) -> float:
    import pandas as pd
    X = pd.DataFrame([features])
    return float(model_temp_24h.predict(X)[0])


# ── Pluie ─────────────────────────────────────────────────────────────────────

def predict_rain(features: dict) -> dict:
    X        = _to_array(features, features_rain)
    X_scaled = scaler_rain.transform(X)
    pred     = int(model_rain.predict(X_scaled)[0])
    proba    = float(model_rain.predict_proba(X_scaled)[0][1])
    return {
        "pluie_probable": bool(pred),
        "probabilite":    round(proba * 100, 1),
    }


# ── Vent fort ─────────────────────────────────────────────────────────────────

def predict_wind_strong(features: dict) -> dict:
    X        = _to_array(features, features_wind)
    X_scaled = scaler_wind.transform(X)
    pred     = int(model_wind.predict(X_scaled)[0])
    proba    = float(model_wind.predict_proba(X_scaled)[0][1])
    return {
        "vent_fort":   bool(pred),
        "probabilite": round(proba * 100, 1),
    }


# ── Canicule ──────────────────────────────────────────────────────────────────

def predict_canicule(features: dict) -> dict:
    X        = _to_array(features, features_extreme)
    X_scaled = scaler_extreme.transform(X)
    pred     = int(model_canicule.predict(X_scaled)[0])
    proba    = float(model_canicule.predict_proba(X_scaled)[0][1])
    return {
        "canicule":    bool(pred),
        "probabilite": round(proba * 100, 1),
    }