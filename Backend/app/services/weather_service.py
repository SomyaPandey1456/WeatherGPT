from Backend.app.services.open_meteo import get_current_weather


async def weather(
    latitude: float,
    longitude: float,
    timezone: str = "auto",
):
    data = await get_current_weather(
        latitude=latitude,
        longitude=longitude,
        timezone=timezone,
    )

    current = data["current"]

    return {
        "location": {
            "latitude": data["latitude"],
            "longitude": data["longitude"],
            "timezone": data["timezone"],
        },
        "current": {
            "temperature": current["temperature_2m"],
            "apparent_temperature": current["apparent_temperature"],
            "humidity": current["relative_humidity_2m"],
            "precipitation": current["precipitation"],
            "wind_speed": current["wind_speed_10m"],
            "weather_code": current["weather_code"],
        },
    }