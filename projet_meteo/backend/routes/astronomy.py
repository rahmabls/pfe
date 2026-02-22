from fastapi import APIRouter
from suntime import Sun
from datetime import datetime
import pytz

router = APIRouter(prefix="/astro", tags=["Astronomy"])

LAT = 32.3373
LON = -6.3498

@router.get("/sun")
def sun_times():
    sun = Sun(LAT, LON)
    tz = pytz.timezone("Africa/Casablanca")

    today = datetime.utcnow()

    sunrise = sun.get_sunrise_time(today)
    sunset = sun.get_sunset_time(today)

    sunrise_local = sunrise.astimezone(tz).strftime("%H:%M")
    sunset_local = sunset.astimezone(tz).strftime("%H:%M")

    return {
        "ville": "Beni Mellal",
        "lever_soleil": sunrise_local,
        "coucher_soleil": sunset_local
    }