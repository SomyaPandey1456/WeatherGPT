from typing import Optional
from fastapi import APIRouter, Query
from Backend.app.schemas.weather_schema.forecast_schema import ForecastResponse
from Backend.app.services.weather_feature.forecast_service import forecast
import Backend.app.services.location_feature.location_store as location_store


router = APIRouter(
    prefix="/weather",
    tags=["Weather Forecast"],
)


@router.get(
    "/forecast",
    response_model=ForecastResponse,
)
async def get_weather_forecast(
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

    return await forecast(
        latitude=latitude,
        longitude=longitude,
        timezone=timezone,
    )