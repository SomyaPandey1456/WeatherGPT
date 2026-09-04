from fastapi import APIRouter, Query

from Backend.app.schemas.weather_schema import CurrentWeatherResponse
from Backend.app.services.weather_service import weather


router = APIRouter(
    prefix="/weather",
    tags=["Weather"],
)


@router.get(
    "/current",
    response_model=CurrentWeatherResponse,
)
async def get_current_weather(
    latitude: float = Query(..., ge=-90, le=90),
    longitude: float = Query(..., ge=-180, le=180),
    timezone: str = Query("auto"),
):
    return await weather(
        latitude=latitude,
        longitude=longitude,
        timezone=timezone,
    )