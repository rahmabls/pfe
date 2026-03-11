from fastapi import APIRouter
from datetime import date, datetime
import math

router = APIRouter(prefix="/astronomie", tags=["🌙 Astronomie"])

# Coordonnées de Béni Mellal
LAT  =  32.3373
LON  =  -6.3498
TZ   =   1       # UTC+1 (Maroc)


def _sun_times(d: date) -> dict:
    """Calcule lever et coucher du soleil pour une date donnée (Béni Mellal)."""
    day_of_year = d.timetuple().tm_yday
    lat_rad = math.radians(LAT)

    # Déclinaison solaire
    declination = math.radians(23.45 * math.sin(math.radians(360 / 365 * (day_of_year - 81))))

    # Heure solaire (angle horaire au coucher)
    cos_h = (-math.tan(lat_rad) * math.tan(declination))
    cos_h = max(-1, min(1, cos_h))
    h = math.degrees(math.acos(cos_h))

    # Équation du temps (simplifiée)
    B = math.radians(360 / 365 * (day_of_year - 81))
    eot = 9.87 * math.sin(2 * B) - 7.53 * math.cos(B) - 1.5 * math.sin(B)

    solar_noon = 12 - (LON / 15) - (eot / 60) + TZ

    sunrise_h = solar_noon - h / 15
    sunset_h  = solar_noon + h / 15

    def to_hhmm(h_float: float) -> str:
        h_int = int(h_float)
        m_int = int(round((h_float - h_int) * 60))
        if m_int == 60:
            h_int += 1
            m_int = 0
        return f"{h_int:02d}:{m_int:02d}"

    return {
        "lever_soleil":  to_hhmm(sunrise_h),
        "coucher_soleil": to_hhmm(sunset_h),
        "duree_jour_h":  round(2 * h / 15, 2),
    }


def _moon_phase(d: date) -> dict:
    """Calcule la phase lunaire approximative."""
    known_new_moon = date(2024, 1, 11)
    delta = (d - known_new_moon).days % 29
    cycle = delta / 29.0

    if cycle < 0.03 or cycle > 0.97:
        phase, emoji = "Nouvelle lune", "🌑"
    elif cycle < 0.22:
        phase, emoji = "Croissant croissant", "🌒"
    elif cycle < 0.28:
        phase, emoji = "Premier quartier", "🌓"
    elif cycle < 0.47:
        phase, emoji = "Lune gibbeuse croissante", "🌔"
    elif cycle < 0.53:
        phase, emoji = "Pleine lune", "🌕"
    elif cycle < 0.72:
        phase, emoji = "Lune gibbeuse décroissante", "🌖"
    elif cycle < 0.78:
        phase, emoji = "Dernier quartier", "🌗"
    else:
        phase, emoji = "Croissant décroissant", "🌘"

    illumination = round(50 * (1 - math.cos(2 * math.pi * cycle)), 1)
    jours_pleine = round((0.5 - cycle) % 1 * 29.5)

    return {
        "phase": phase,
        "emoji": emoji,
        "illumination_pct": illumination,
        "jours_avant_pleine_lune": jours_pleine,
    }


@router.get("/aujourd-hui")
def astronomie_aujourd_hui():
    """Données astronomiques pour aujourd'hui."""
    today = date.today()
    sun = _sun_times(today)
    moon = _moon_phase(today)
    return {
        "date": today.isoformat(),
        "ville": "Béni Mellal",
        "soleil": sun,
        "lune": moon,
    }


@router.get("/date/{annee}/{mois}/{jour}")
def astronomie_date(annee: int, mois: int, jour: int):
    """Données astronomiques pour une date spécifique."""
    d = date(annee, mois, jour)
    return {
        "date": d.isoformat(),
        "ville": "Béni Mellal",
        "soleil": _sun_times(d),
        "lune": _moon_phase(d),
    }
