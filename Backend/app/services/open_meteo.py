import httpx


WEATHER_BASE_URL = "https://api.open-meteo.com/v1/forecast"

AIR_QUALITY_BASE_URL = (
    "https://air-quality-api.open-meteo.com/v1/air-quality"
)

# weather current method 
async def get_current_weather(
    latitude: float,
    longitude: float,
    timezone: str = "auto",
):
    params = {
        "latitude": latitude,
        "longitude": longitude,
        "current": ",".join(
            [
                "temperature_2m",
                "apparent_temperature",
                "relative_humidity_2m",
                "precipitation",
                "wind_speed_10m",
                "weather_code",
            ]
        ),
        "timezone": timezone,
    }

    async with httpx.AsyncClient() as client:
        response = await client.get(
            WEATHER_BASE_URL,
            params=params,
            timeout=10.0,
        )

        response.raise_for_status()

        return response.json()



# forcast method 
async def get_forecast(
    latitude: float,
    longitude: float,
    timezone: str = "auto",
):
    params = {
        "latitude": latitude,
        "longitude": longitude,
        "daily": ",".join(
            [
                "weather_code",
                "temperature_2m_max",
                "temperature_2m_min",
                "precipitation_sum",
                "precipitation_probability_max",
                "wind_speed_10m_max",
                "sunrise",
                "sunset",
            ]
        ),
        "timezone": timezone,
        "forecast_days": 7,
    }

    async with httpx.AsyncClient() as client:
        response = await client.get(
            WEATHER_BASE_URL,
            params=params,
            timeout=10.0,
        )

        response.raise_for_status()

        return response.json()


# hourly forecast
async def get_hourly_forecast(
    latitude: float,
    longitude: float,
    timezone: str = "auto",
):
    params = {
        "latitude": latitude,
        "longitude": longitude,
        "hourly": ",".join(
            [
                "temperature_2m",
                "apparent_temperature",
                "relative_humidity_2m",
                "precipitation",
                "precipitation_probability",
                "wind_speed_10m",
                "wind_direction_10m",
                "weather_code",
            ]
        ),
        "timezone": timezone,
        "forecast_hours": 48,
    }

    async with httpx.AsyncClient() as client:
        response = await client.get(
            WEATHER_BASE_URL,
            params=params,
            timeout=10.0,
        )

        response.raise_for_status()

        return response.json()
    
 
# Air quality
async def get_air_quality(
    latitude: float,
    longitude: float,
    timezone: str = "auto",
):
    params = {
        "latitude": latitude,
        "longitude": longitude,
        "hourly": ",".join(
            [
                "pm10",
                "pm2_5",
                "carbon_monoxide",
                "nitrogen_dioxide",
                "sulphur_dioxide",
                "ozone",
            ]
        ),
        "timezone": timezone,
        "forecast_days": 1,
    }

    async with httpx.AsyncClient() as client:
        response = await client.get(
            AIR_QUALITY_BASE_URL,
            params=params,
            timeout=10.0,
        )

        response.raise_for_status()

        return response.json()