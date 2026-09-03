# this file contains api endpoints related to weather
from fastapi import APIRouter, Query
from Backend.app.services.weather_service import weather_service
from Backend.app.schemas.weather_schema import CurrentWeatherResponse


router = APIRouter(
    prefix="/weather",
    tags=["Weather"],
)


@router.get(
    "/current",
    response_model=CurrentWeatherResponse,
)
async def get_current_weather(
    lat: float = Query(..., description="Latitude"),
    lon: float = Query(..., description="Longitude"),
):

    return await weather_service.get_current_weather(
        latitude=lat,
        longitude=lon,
    )



