from fastapi import APIRouter, Query

from Backend.app.schemas.weather_schema.hourly_schema import HourlyForecastResponse
from Backend.app.services.weather_feature.hourly_service import hourly_forecast


router = APIRouter(
    prefix="/weather",
    tags=["Hourly Forecast"],
)


@router.get(
    "/hourly",
    response_model=HourlyForecastResponse,
)
async def get_hourly_weather(
    latitude: float = Query(..., ge=-90, le=90),
    longitude: float = Query(..., ge=-180, le=180),
    timezone: str = Query("auto"),
):
    return await hourly_forecast(
        latitude=latitude,
        longitude=longitude,
        timezone=timezone,
    )