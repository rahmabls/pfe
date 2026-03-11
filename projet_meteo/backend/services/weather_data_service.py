"""
Service central : charge le CSV, calcule les features engineerées
(lags, sin/cos temporels, trends) pour chaque modèle ML.
"""
import os
import math
import pandas as pd
import numpy as np
from datetime import datetime

CSV_PATH = os.path.join(os.path.dirname(__file__), "..", "data", "output_clean.csv")

_df: pd.DataFrame | None = None


# ──────────────────────────────────────────────────────────────────────────────
#  CHARGEMENT CSV
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

def _v(row: pd.Series, col: str, default: float = 0.0) -> float:
    val = row.get(col, default)
    return float(default if pd.isna(val) else val)


def _lag(df: pd.DataFrame, col: str, n: int) -> float:
    """Valeur de `col` il y a n lignes (lag horaire)."""
    idx = len(df) - 1 - n
    if idx < 0:
        return _v(df.iloc[0], col)
    return _v(df.iloc[idx], col)


# ──────────────────────────────────────────────────────────────────────────────
#  FEATURES COMMUNES (colonnes brutes CSV)
# ──────────────────────────────────────────────────────────────────────────────

def _base_features(row: pd.Series) -> dict:
    return {
        "temperature_2m":              _v(row, "temperature_2m"),
        "relative_humidity_2m":        _v(row, "relative_humidity_2m"),
        "dew_point_2m":                _v(row, "dew_point_2m"),
        "apparent_temperature":        _v(row, "apparent_temperature"),
        "precipitation":               _v(row, "precipitation"),
        "rain":                        _v(row, "rain"),
        "showers":                     _v(row, "showers"),
        "snowfall":                    _v(row, "snowfall"),
        "snow_depth":                  _v(row, "snow_depth"),
        "weather_code":                _v(row, "weather_code"),
        "pressure_msl":                _v(row, "pressure_msl"),
        "surface_pressure":            _v(row, "surface_pressure"),
        "cloud_cover":                 _v(row, "cloud_cover"),
        "cloud_cover_low":             _v(row, "cloud_cover_low"),
        "cloud_cover_mid":             _v(row, "cloud_cover_mid"),
        "cloud_cover_high":            _v(row, "cloud_cover_high"),
        "visibility":                  _v(row, "visibility"),
        "evapotranspiration":          _v(row, "evapotranspiration"),
        "et0_fao_evapotranspiration":  _v(row, "et0_fao_evapotranspiration"),
        "vapour_pressure_deficit":     _v(row, "vapour_pressure_deficit"),
        "wind_speed_10m":              _v(row, "wind_speed_10m"),
        "wind_speed_80m":              _v(row, "wind_speed_80m"),
        "wind_speed_120m":             _v(row, "wind_speed_120m"),
        "wind_direction_10m":          _v(row, "wind_direction_10m"),
        "wind_direction_80m":          _v(row, "wind_direction_80m"),
        "wind_direction_120m":         _v(row, "wind_direction_120m"),
        "wind_gusts_10m":              _v(row, "wind_gusts_10m"),
        "temperature_80m":             _v(row, "temperature_80m"),
        "temperature_120m":            _v(row, "temperature_120m"),
        "is_day":                      _v(row, "is_day"),
        "uv_index":                    _v(row, "uv_index"),
        "uv_index_clear_sky":          _v(row, "uv_index_clear_sky"),
        "sunshine_duration":           _v(row, "sunshine_duration"),
        "wet_bulb_temperature_2m":     _v(row, "wet_bulb_temperature_2m"),
        "cape":                        _v(row, "cape"),
        "lifted_index":                _v(row, "lifted_index"),
        "convective_inhibition":       _v(row, "convective_inhibition"),
        "freezing_level_height":       _v(row, "freezing_level_height"),
        "relative_humidity_950hPa":    _v(row, "relative_humidity_950hPa"),
        "temperature_950hPa":          _v(row, "temperature_950hPa"),
        "cloud_cover_950hPa":          _v(row, "cloud_cover_950hPa"),
        "wind_speed_950hPa":           _v(row, "wind_speed_950hPa"),
        "wind_direction_950hPa":       _v(row, "wind_direction_950hPa"),
    }


def _time_features(row: pd.Series) -> dict:
    try:
        dt = pd.to_datetime(row["date"])
    except Exception:
        dt = datetime.now()
    h  = dt.hour
    m  = dt.month
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
#  FEATURES PAR MODÈLE
# ──────────────────────────────────────────────────────────────────────────────

def get_features_for_temp() -> dict:
    """model_temperature_1h.pkl / model_temperature_24h.pkl (XGBoost)."""
    df  = _load_csv()
    row = df.iloc[-1]
    return {**_base_features(row), **_time_features(row)}


def get_features_for_rain() -> dict:
    """model_rain_logistic.pkl — features_rain.pkl."""
    df  = _load_csv()
    row = df.iloc[-1]
    f   = {**_base_features(row), **_time_features(row)}

    for n in [1, 3, 6]:
        f[f"humidity_lag_{n}"]  = _lag(df, "relative_humidity_2m", n)
        f[f"cloud_lag_{n}"]     = _lag(df, "cloud_cover",           n)
        f[f"pressure_lag_{n}"]  = _lag(df, "pressure_msl",          n)

    f["pressure_drop_3h"] = f["pressure_msl"] - f["pressure_lag_3"]
    return f


def get_features_for_wind() -> dict:
    """model_wind_binary.pkl — features_wind_binary.pkl."""
    df  = _load_csv()
    row = df.iloc[-1]
    f   = {**_base_features(row), **_time_features(row)}

    for n in [1, 3, 6, 12, 24]:
        f[f"wind_lag_{n}"] = _lag(df, "wind_speed_10m", n)

    f["wind_trend_3h"] = f["wind_speed_10m"] - f["wind_lag_3"]
    return f


def get_features_for_canicule() -> dict:
    """model_extreme_logreg.pkl — features_extreme.pkl."""
    df  = _load_csv()
    row = df.iloc[-1]
    f   = {**_base_features(row), **_time_features(row)}

    for n in [1, 3, 6, 12, 24]:
        f[f"temp_lag_{n}"] = _lag(df, "temperature_2m", n)

    return f


def get_features_for_model_features() -> dict:
    """model_features.pkl (liste complète avec lags temp/humidity/pressure)."""
    df  = _load_csv()
    row = df.iloc[-1]
    f   = {**_base_features(row), **_time_features(row)}

    for n in [1, 2, 3, 6, 12, 24]:
        f[f"temp_lag_{n}"]     = _lag(df, "temperature_2m",       n)
        f[f"humidity_lag_{n}"] = _lag(df, "relative_humidity_2m", n)
        f[f"pressure_lag_{n}"] = _lag(df, "pressure_msl",         n)

    f["temp_trend_3h"] = f["temperature_2m"] - f["temp_lag_3"]
    f["temp_trend_6h"] = f["temperature_2m"] - f["temp_lag_6"]
    return f
