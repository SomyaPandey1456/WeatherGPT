from typing import Optional
from fastapi import APIRouter, Query
from Backend.app.schemas.weather_schema.weather_schema import CurrentWeatherResponse
from Backend.app.services.weather_feature.weather_service import weather
import Backend.app.services.location_feature.location_store as location_store

router = APIRouter(
    prefix="/weather",
    tags=["Weather"],
)


@router.get(
    "/current",
    response_model=CurrentWeatherResponse,
)
async def get_current_weather(
    latitude: Optional[float] = Query(None, ge=-90, le=90),
    longitude: Optional[float] = Query(None, ge=-180, le=180),
    timezone: str = Query("auto"),
    id: Optional[str] = Query(None),
):
    if latitude is None or longitude is None:
        stored = location_store.get_user_location()
        latitude = stored.get("latitude")
        longitude = stored.get("longitude")

    if latitude is None or longitude is None:
        latitude = 28.4744
        longitude = 77.5040

    return await weather(
        latitude=latitude,
        longitude=longitude,
        timezone=timezone,
    )