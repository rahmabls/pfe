import json
import os

FILE_PATH = "display_weather.json"


def set_display_weather(enabled: bool):
    data = {"display_weather": enabled}
    with open(FILE_PATH, "w") as f:
        json.dump(data, f)


def get_display_weather():
    if not os.path.exists(FILE_PATH):
        return {"display_weather": False}

    with open(FILE_PATH, "r") as f:
        return json.load(f)