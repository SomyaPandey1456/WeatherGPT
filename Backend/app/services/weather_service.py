import httpx

from Backend.app.schemas.weather_schema import (
    CurrentWeatherResponse,
    Location,
    CurrentWeather,
)


class WeatherService:

    BASE_URL = "https://api.open-meteo.com/v1/forecast"

    async def get_current_weather(
        self,
        latitude: float,
        longitude: float,
    ) -> CurrentWeatherResponse:

        params = {
            "latitude": latitude,
            "longitude": longitude,
            "current": (
                "temperature_2m,"
                "apparent_temperature,"
                "relative_humidity_2m,"
                "precipitation,"
                "wind_speed_10m,"
                "weather_code"
            ),
            "timezone": "auto",
        }

        async with httpx.AsyncClient(timeout=10.0) as client:

            response = await client.get(
                self.BASE_URL,
                params=params,
            )

            response.raise_for_status()

            data = response.json()

        current = data["current"]

        return CurrentWeatherResponse(
            location=Location(
                latitude=data["latitude"],
                longitude=data["longitude"],
                timezone=data["timezone"],
            ),
            current=CurrentWeather(
                temperature=current["temperature_2m"],
                apparent_temperature=current["apparent_temperature"],
                humidity=current["relative_humidity_2m"],
                precipitation=current["precipitation"],
                wind_speed=current["wind_speed_10m"],
                weather_code=current["weather_code"],
            ),
        )


weather_service = WeatherService()