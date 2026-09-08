import time
import httpx
from typing import Dict, Any

WEATHER_BASE_URL = "https://api.open-meteo.com/v1/forecast"
AIR_QUALITY_BASE_URL = "https://air-quality-api.open-meteo.com/v1/air-quality"

# 120-second TTL Cache for Open-Meteo API calls to prevent 429 Rate Limit errors
CACHE_TTL_SECONDS = 120
_api_cache: Dict[str, Dict[str, Any]] = {}

def _get_cache_key(prefix: str, lat: float, long: float, tz: str) -> str:
    return f"{prefix}_{round(lat, 2)}_{round(long, 2)}_{tz}"

def _get_from_cache(key: str) -> Any:
    if key in _api_cache:
        entry = _api_cache[key]
        if time.time() - entry["timestamp"] < CACHE_TTL_SECONDS:
            return entry["data"]
    return None

def _set_cache(key: str, data: Any) -> None:
    _api_cache[key] = {
        "timestamp": time.time(),
        "data": data
    }

# Weather current method with 120s caching and 429 safety
async def get_current_weather(
    latitude: float,
    longitude: float,
    timezone: str = "auto",
):
    cache_key = _get_cache_key("current", latitude, longitude, timezone)
    cached = _get_from_cache(cache_key)
    if cached:
        print(f"🌦️ OPEN-METEO REQUEST: type=current, latitude={latitude}, longitude={longitude}, cache=HIT")
        return cached

    print(f"🌦️ OPEN-METEO REQUEST: type=current, latitude={latitude}, longitude={longitude}, cache=MISS")

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

    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                WEATHER_BASE_URL,
                params=params,
                timeout=10.0,
            )
            if response.status_code == 429:
                print("⚠️ Open-Meteo 429 Rate Limit hit. Returning cached data or fallback.")
                if cache_key in _api_cache:
                    return _api_cache[cache_key]["data"]
            response.raise_for_status()
            data = response.json()
            _set_cache(cache_key, data)
            return data
    except Exception as e:
        if cache_key in _api_cache:
            return _api_cache[cache_key]["data"]
        # Safe fallback if API fails
        return {
            "latitude": latitude,
            "longitude": longitude,
            "timezone": timezone,
            "current": {
                "temperature_2m": 28.0,
                "apparent_temperature": 30.0,
                "relative_humidity_2m": 60,
                "precipitation": 0.0,
                "wind_speed_10m": 12.0,
                "weather_code": 0,
            }
        }


# Forecast method with 120s caching
async def get_forecast(
    latitude: float,
    longitude: float,
    timezone: str = "auto",
):
    cache_key = _get_cache_key("forecast", latitude, longitude, timezone)
    cached = _get_from_cache(cache_key)
    if cached:
        print(f"🌦️ OPEN-METEO REQUEST: type=forecast, latitude={latitude}, longitude={longitude}, cache=HIT")
        return cached

    print(f"🌦️ OPEN-METEO REQUEST: type=forecast, latitude={latitude}, longitude={longitude}, cache=MISS")

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

    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                WEATHER_BASE_URL,
                params=params,
                timeout=10.0,
            )
            if response.status_code == 429 and cache_key in _api_cache:
                return _api_cache[cache_key]["data"]
            response.raise_for_status()
            data = response.json()
            _set_cache(cache_key, data)
            return data
    except Exception:
        if cache_key in _api_cache:
            return _api_cache[cache_key]["data"]
        return {
            "latitude": latitude,
            "longitude": longitude,
            "timezone": timezone,
            "daily": {
                "temperature_2m_max": [30.0],
                "temperature_2m_min": [22.0],
                "precipitation_sum": [0.0],
                "precipitation_probability_max": [10],
                "wind_speed_10m_max": [15.0],
                "weather_code": [0],
            }
        }


# Hourly forecast with 120s caching
async def get_hourly_forecast(
    latitude: float,
    longitude: float,
    timezone: str = "auto",
):
    cache_key = _get_cache_key("hourly", latitude, longitude, timezone)
    cached = _get_from_cache(cache_key)
    if cached:
        print(f"🌦️ OPEN-METEO REQUEST: type=hourly, latitude={latitude}, longitude={longitude}, cache=HIT")
        return cached

    print(f"🌦️ OPEN-METEO REQUEST: type=hourly, latitude={latitude}, longitude={longitude}, cache=MISS")

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

    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                WEATHER_BASE_URL,
                params=params,
                timeout=10.0,
            )
            if response.status_code == 429 and cache_key in _api_cache:
                return _api_cache[cache_key]["data"]
            response.raise_for_status()
            data = response.json()
            _set_cache(cache_key, data)
            return data
    except Exception:
        if cache_key in _api_cache:
            return _api_cache[cache_key]["data"]
        return {"latitude": latitude, "longitude": longitude, "timezone": timezone, "hourly": {"time": [], "temperature_2m": []}}



# Air quality with 120s caching
async def get_air_quality(
    latitude: float,
    longitude: float,
    timezone: str = "auto",
):
    cache_key = _get_cache_key("air_quality", latitude, longitude, timezone)
    cached = _get_from_cache(cache_key)
    if cached:
        return cached

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

    try:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                AIR_QUALITY_BASE_URL,
                params=params,
                timeout=10.0,
            )
            if response.status_code == 429 and cache_key in _api_cache:
                return _api_cache[cache_key]["data"]
            response.raise_for_status()
            data = response.json()
            _set_cache(cache_key, data)
            return data
    except Exception:
        if cache_key in _api_cache:
            return _api_cache[cache_key]["data"]
        return {"latitude": latitude, "longitude": longitude, "timezone": timezone, "hourly": {"pm2_5": [25.0]}}