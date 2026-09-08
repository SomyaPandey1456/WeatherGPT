from typing import Optional
from fastapi import APIRouter, Query

from Backend.app.schemas.weather_schema.hourly_schema import HourlyForecastResponse
from Backend.app.services.weather_feature.hourly_service import hourly_forecast
import Backend.app.services.location_feature.location_store as location_store


router = APIRouter(
    prefix="/weather",
    tags=["Hourly Forecast"],
)


@router.get(
    "/hourly",
    response_model=HourlyForecastResponse,
)
async def get_hourly_weather(
    latitude: Optional[float] = Query(None, ge=-90, le=90),
    longitude: Optional[float] = Query(None, ge=-180, le=180),
    timezone: str = Query("auto"),
):
    if latitude is None or longitude is None:
        stored = location_store.get_user_location()
        latitude = stored.get("latitude")
        longitude = stored.get("longitude")

    if latitude is None or longitude is None:
        latitude = 28.4744
        longitude = 77.5040

    return await hourly_forecast(
        latitude=latitude,
        longitude=longitude,
        timezone=timezone,
    )