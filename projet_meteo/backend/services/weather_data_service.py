"""
Service central : 
- Récupère les données météo en temps réel depuis Open-Meteo
- Calcule les features engineerées (lags, sin/cos temporels, trends)
- Utilisé pour l'affichage ET les prédictions ML
"""
import os
import math
import requests
import pandas as pd
import numpy as np
from datetime import datetime

CSV_PATH  = os.path.join(os.path.dirname(__file__), "..", "data", "output_clean.csv")
LATITUDE  = 32.37258
LONGITUDE = -6.334961

_df: pd.DataFrame | None = None
_realtime_cache: dict    = {}
_cache_time: datetime | None = None
CACHE_MINUTES = 10  # recharge toutes les 10 minutes


# ──────────────────────────────────────────────────────────────────────────────
#  OPTION 1 — DONNÉES TEMPS RÉEL (Open-Meteo)
# ──────────────────────────────────────────────────────────────────────────────

def get_realtime_data() -> dict:
    """
    Récupère les données météo actuelles depuis Open-Meteo.
    Utilise un cache de 10 minutes pour éviter les appels excessifs.
    """
    global _realtime_cache, _cache_time

    # Cache valide ?
    if _cache_time and (datetime.now() - _cache_time).seconds < CACHE_MINUTES * 60:
        return _realtime_cache

    url = "https://api.open-meteo.com/v1/forecast"
    params = {
        "latitude":  LATITUDE,
        "longitude": LONGITUDE,
        "current": [
            "temperature_2m", "relative_humidity_2m", "dew_point_2m",
            "apparent_temperature", "precipitation", "rain", "showers",
            "snowfall", "weather_code", "pressure_msl", "surface_pressure",
            "cloud_cover", "cloud_cover_low", "cloud_cover_mid", "cloud_cover_high",
            "visibility", "wind_speed_10m", "wind_direction_10m", "wind_gusts_10m",
            "is_day", "uv_index",
        ],
        "timezone": "GMT"
    }

    try:
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        data = response.json()["current"]
        _realtime_cache = data
        _cache_time = datetime.now()
        return data
    except Exception as e:
        print(f"⚠️ Open-Meteo erreur: {e} — utilisation du CSV")
        row = get_latest_row()
        return row.to_dict()


# ──────────────────────────────────────────────────────────────────────────────
#  CHARGEMENT CSV (pour les lags historiques)
# ──────────────────────────────────────────────────────────────────────────────

def _load_csv() -> pd.DataFrame:
    global _df
    if _df is None:
        df = pd.read_csv(CSV_PATH, parse_dates=["date"])
        df = df.sort_values("date").reset_index(drop=True)
        _df = df
    return _df


def get_dataframe() -> pd.DataFrame:
    return _load_csv()


def get_latest_row() -> pd.Series:
    return _load_csv().iloc[-1]


# ──────────────────────────────────────────────────────────────────────────────
#  HELPERS
# ──────────────────────────────────────────────────────────────────────────────

def _v(data, col: str, default: float = 0.0) -> float:
    if isinstance(data, dict):
        val = data.get(col, default)
    else:
        val = data.get(col, default) if hasattr(data, 'get') else default
    return float(default if (val is None or (isinstance(val, float) and math.isnan(val))) else val)


def _lag(df: pd.DataFrame, col: str, n: int) -> float:
    idx = len(df) - 1 - n
    if idx < 0:
        return _v(df.iloc[0], col)
    return _v(df.iloc[idx], col)


# ──────────────────────────────────────────────────────────────────────────────
#  FEATURES COMMUNES
# ──────────────────────────────────────────────────────────────────────────────

def _base_features(data) -> dict:
    """Fonctionne avec une Series pandas ou un dict Open-Meteo."""
    return {
        "temperature_2m":              _v(data, "temperature_2m"),
        "relative_humidity_2m":        _v(data, "relative_humidity_2m"),
        "dew_point_2m":                _v(data, "dew_point_2m"),
        "apparent_temperature":        _v(data, "apparent_temperature"),
        "precipitation":               _v(data, "precipitation"),
        "rain":                        _v(data, "rain"),
        "showers":                     _v(data, "showers"),
        "snowfall":                    _v(data, "snowfall"),
        "snow_depth":                  _v(data, "snow_depth"),
        "weather_code":                _v(data, "weather_code"),
        "pressure_msl":                _v(data, "pressure_msl"),
        "surface_pressure":            _v(data, "surface_pressure"),
        "cloud_cover":                 _v(data, "cloud_cover"),
        "cloud_cover_low":             _v(data, "cloud_cover_low"),
        "cloud_cover_mid":             _v(data, "cloud_cover_mid"),
        "cloud_cover_high":            _v(data, "cloud_cover_high"),
        "visibility":                  _v(data, "visibility"),
        "evapotranspiration":          _v(data, "evapotranspiration"),
        "et0_fao_evapotranspiration":  _v(data, "et0_fao_evapotranspiration"),
        "vapour_pressure_deficit":     _v(data, "vapour_pressure_deficit"),
        "wind_speed_10m":              _v(data, "wind_speed_10m"),
        "wind_speed_80m":              _v(data, "wind_speed_80m"),
        "wind_speed_120m":             _v(data, "wind_speed_120m"),
        "wind_direction_10m":          _v(data, "wind_direction_10m"),
        "wind_direction_80m":          _v(data, "wind_direction_80m"),
        "wind_direction_120m":         _v(data, "wind_direction_120m"),
        "wind_gusts_10m":              _v(data, "wind_gusts_10m"),
        "temperature_80m":             _v(data, "temperature_80m"),
        "temperature_120m":            _v(data, "temperature_120m"),
        "is_day":                      _v(data, "is_day"),
        "uv_index":                    _v(data, "uv_index"),
        "uv_index_clear_sky":          _v(data, "uv_index_clear_sky"),
        "sunshine_duration":           _v(data, "sunshine_duration"),
        "wet_bulb_temperature_2m":     _v(data, "wet_bulb_temperature_2m"),
        "cape":                        _v(data, "cape"),
        "lifted_index":                _v(data, "lifted_index"),
        "convective_inhibition":       _v(data, "convective_inhibition"),
        "freezing_level_height":       _v(data, "freezing_level_height"),
        "relative_humidity_950hPa":    _v(data, "relative_humidity_950hPa"),
        "temperature_950hPa":          _v(data, "temperature_950hPa"),
        "cloud_cover_950hPa":          _v(data, "cloud_cover_950hPa"),
        "wind_speed_950hPa":           _v(data, "wind_speed_950hPa"),
        "wind_direction_950hPa":       _v(data, "wind_direction_950hPa"),
    }


def _time_features(dt: datetime = None) -> dict:
    if dt is None:
        dt = datetime.now()
    h = dt.hour
    m = dt.month
    return {
        "month":      m,
        "hour":       h,
        "day":        dt.day,
        "dayofweek":  dt.weekday(),
        "dayofyear":  dt.timetuple().tm_yday,
        "hour_sin":   math.sin(2 * math.pi * h / 24),
        "hour_cos":   math.cos(2 * math.pi * h / 24),
        "month_sin":  math.sin(2 * math.pi * m / 12),
        "month_cos":  math.cos(2 * math.pi * m / 12),
    }


# ──────────────────────────────────────────────────────────────────────────────
#  OPTION 2 — FEATURES POUR PRÉDICTIONS ML (temps réel + lags CSV)
# ──────────────────────────────────────────────────────────────────────────────

def get_features_for_temp() -> dict:
    """Données temps réel sans lags (compatibilité)."""
    realtime = get_realtime_data()
    return {**_base_features(realtime), **_time_features()}


def get_features_for_rain() -> dict:
    """Données temps réel + lags depuis CSV."""
    df       = _load_csv()
    realtime = get_realtime_data()
    f        = {**_base_features(realtime), **_time_features()}

    for n in [1, 3, 6]:
        f[f"humidity_lag_{n}"]  = _lag(df, "relative_humidity_2m", n)
        f[f"cloud_lag_{n}"]     = _lag(df, "cloud_cover",           n)
        f[f"pressure_lag_{n}"]  = _lag(df, "pressure_msl",          n)

    f["pressure_drop_3h"] = f["pressure_msl"] - f["pressure_lag_3"]
    return f


def get_features_for_wind() -> dict:
    """Données temps réel + lags depuis CSV."""
    df       = _load_csv()
    realtime = get_realtime_data()
    f        = {**_base_features(realtime), **_time_features()}

    for n in [1, 3, 6, 12, 24]:
        f[f"wind_lag_{n}"] = _lag(df, "wind_speed_10m", n)

    f["wind_trend_3h"] = f["wind_speed_10m"] - f["wind_lag_3"]
    return f


def get_features_for_canicule() -> dict:
    """Données temps réel + lags depuis CSV."""
    df       = _load_csv()
    realtime = get_realtime_data()
    f        = {**_base_features(realtime), **_time_features()}

    for n in [1, 3, 6, 12, 24]:
        f[f"temp_lag_{n}"] = _lag(df, "temperature_2m", n)

    return f


def get_features_for_model_features() -> dict:
    """Données temps réel + tous les lags depuis CSV (pour température)."""
    df       = _load_csv()
    realtime = get_realtime_data()
    f        = {**_base_features(realtime), **_time_features()}

    for n in [1, 2, 3, 6, 12, 24]:
        f[f"temp_lag_{n}"]     = _lag(df, "temperature_2m",       n)
        f[f"humidity_lag_{n}"] = _lag(df, "relative_humidity_2m", n)
        f[f"pressure_lag_{n}"] = _lag(df, "pressure_msl",         n)

    f["temp_trend_3h"] = f["temperature_2m"] - f["temp_lag_3"]
    f["temp_trend_6h"] = f["temperature_2m"] - f["temp_lag_6"]
    return f