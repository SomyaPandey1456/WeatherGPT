from datetime import datetime, timezone
from typing import Dict, Any, Optional
from Backend.app.services.provider.open_meteo import get_current_weather, get_forecast

async def get_current_risk(
    latitude: float,
    longitude: float,
    tz: str = "auto"
) -> Dict[str, Any]:
    """
    Lightweight, deterministic backend risk engine.
    Evaluates weather hazards using configurable thresholds.
    """
    now_iso = datetime.now(timezone.utc).isoformat()
    
    try:
        current_data = await get_current_weather(latitude, longitude, timezone=tz)
        forecast_data = await get_forecast(latitude, longitude, timezone=tz)
    except Exception as e:
        # Fallback response if weather API fails
        return {
            "level": "LOW",
            "hazard": "General Weather Monitoring",
            "message": f"Unable to fetch live weather details at this moment. ({str(e)})",
            "recommended_action": "Stay aware of local weather conditions.",
            "updated_at": now_iso,
            "raw_weather": {}
        }

    current = current_data.get("current", {})
    daily = forecast_data.get("daily", {})

    temp_c = current.get("temperature_2m", 25.0)
    apparent_temp_c = current.get("apparent_temperature", temp_c)
    precipitation = current.get("precipitation", 0.0)
    wind_speed = current.get("wind_speed_10m", 0.0)
    weather_code = current.get("weather_code", 0)

    max_temp_today = daily.get("temperature_2m_max", [temp_c])[0] if daily.get("temperature_2m_max") else temp_c
    precip_prob_today = daily.get("precipitation_probability_max", [0])[0] if daily.get("precipitation_probability_max") else 0
    precip_sum_today = daily.get("precipitation_sum", [0.0])[0] if daily.get("precipitation_sum") else 0.0

    # Risk evaluation rules
    # 1. Heavy rainfall & potential waterlogging
    if precip_sum_today >= 30.0 or precipitation >= 10.0 or (precip_prob_today >= 80 and precip_sum_today >= 15.0):
        return {
            "level": "HIGH",
            "hazard": "Heavy Rainfall & Potential Waterlogging",
            "message": f"Heavy rainfall is active or expected in your area (precipitation {precip_sum_today}mm, probability {precip_prob_today}%).",
            "recommended_action": "Avoid low-lying roads, underpasses, and delay non-essential travel.",
            "updated_at": now_iso,
            "raw_weather": {"temp_c": temp_c, "wind_speed": wind_speed, "precip_sum": precip_sum_today}
        }
    elif precip_sum_today >= 10.0 or precipitation >= 2.5 or precip_prob_today >= 60:
        return {
            "level": "MODERATE",
            "hazard": "Potential Waterlogging & Wet Conditions",
            "message": f"Moderate rainfall expected today (rain chance {precip_prob_today}%). Localized waterlogging may occur.",
            "recommended_action": "Carry an umbrella, allow extra commute time, and drive cautiously.",
            "updated_at": now_iso,
            "raw_weather": {"temp_c": temp_c, "wind_speed": wind_speed, "precip_sum": precip_sum_today}
        }

    # 2. Thunderstorm / Lightning risk
    if weather_code in [95, 96, 99]:
        return {
            "level": "HIGH",
            "hazard": "Thunderstorm & Lightning Warning",
            "message": "Thunderstorm activity detected in your location.",
            "recommended_action": "Seek safe indoor shelter immediately. Avoid open ground, tall trees, and metallic structures.",
            "updated_at": now_iso,
            "raw_weather": {"temp_c": temp_c, "wind_speed": wind_speed}
        }

    # 3. Severe Heat risk
    if max_temp_today >= 42.0 or apparent_temp_c >= 44.0:
        return {
            "level": "CRITICAL",
            "hazard": "Severe Heatwave Warning",
            "message": f"Extreme high temperature anticipated ({max_temp_today}°C, feels like {apparent_temp_c}°C).",
            "recommended_action": "Avoid direct outdoor sun exposure between 12 PM - 4 PM. Stay hydrated.",
            "updated_at": now_iso,
            "raw_weather": {"temp_c": temp_c, "apparent_temp": apparent_temp_c}
        }
    elif max_temp_today >= 38.0 or apparent_temp_c >= 40.0:
        return {
            "level": "MODERATE",
            "hazard": "Elevated Heat Exposure Risk",
            "message": f"High temperatures expected today ({max_temp_today}°C).",
            "recommended_action": "Drink plenty of water and wear light cotton clothing.",
            "updated_at": now_iso,
            "raw_weather": {"temp_c": temp_c, "apparent_temp": apparent_temp_c}
        }

    # 4. High Wind risk
    if wind_speed >= 45.0:
        return {
            "level": "HIGH",
            "hazard": "Strong Gusty Winds Warning",
            "message": f"High wind speeds recorded ({wind_speed} km/h).",
            "recommended_action": "Secure loose outdoor objects and stay clear of weak trees or billboards.",
            "updated_at": now_iso,
            "raw_weather": {"temp_c": temp_c, "wind_speed": wind_speed}
        }

    # 5. Snow / Freezing risk
    if weather_code in [71, 73, 75, 77, 85, 86] or temp_c <= 0.0:
        return {
            "level": "MODERATE",
            "hazard": "Freezing Temperature & Snow Risk",
            "message": f"Freezing conditions or snowfall recorded ({temp_c}°C).",
            "recommended_action": "Keep warm, check heating equipment, and beware of icy roads.",
            "updated_at": now_iso,
            "raw_weather": {"temp_c": temp_c}
        }

    # Default Low Risk
    return {
        "level": "LOW",
        "hazard": "Normal Weather Conditions",
        "message": "No significant weather hazards detected near your current location.",
        "recommended_action": "Enjoy your day! Keep an eye on hourly updates.",
        "updated_at": now_iso,
        "raw_weather": {"temp_c": temp_c, "wind_speed": wind_speed}
    }
