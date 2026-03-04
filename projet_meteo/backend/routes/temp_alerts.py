from fastapi import APIRouter
from routes.prediction_temp import forecast_next_hours
from datetime import datetime, timedelta

router = APIRouter(prefix="/alert", tags=["Alerts"])



# ---------------------------------------------------
# Détection d'événements
# ---------------------------------------------------
def detect_heatwave(temps, hours):

    alerts = []

    count = 0
    start = None

    for i,t in enumerate(temps):

        if t >= 38:
            if count == 0:
                start = hours[i]
            count += 1
        else:
            if count >= 3:
                alerts.append((start,hours[i-1],"canicule"))
            count = 0

    if count >= 3:
        alerts.append((start,hours[-1],"canicule"))

    return alerts


def detect_coldwave(temps, hours):

    alerts = []
    count = 0
    start = None

    for i,t in enumerate(temps):

        if t <= 0:
            if count == 0:
                start = hours[i]
            count += 1
        else:
            if count >= 2:
                alerts.append((start,hours[i-1],"froid"))
            count = 0

    if count >= 2:
        alerts.append((start,hours[-1],"froid"))

    return alerts


# ---------------------------------------------------
# API endpoint
# ---------------------------------------------------
@router.post("/24h")
def alert_24h(current_weather: dict):

    temps = forecast_next_hours(current_weather,24)

    now = datetime.now()
    hours = [(now + timedelta(hours=i+1)).strftime("%H:%M") for i in range(24)]

    heat = detect_heatwave(temps,hours)
    cold = detect_coldwave(temps,hours)

    return {
        "temperature": temps,
        "alerts_heatwave": heat,
        "alerts_coldwave": cold
    }