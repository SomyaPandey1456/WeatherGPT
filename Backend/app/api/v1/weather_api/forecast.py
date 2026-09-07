from fastapi import APIRouter, Query
from Backend.app.schemas.weather_schema.forecast_schema import ForecastResponse
from Backend.app.services.weather_feature.forecast_service import forecast


router = APIRouter(
    prefix="/weather",
    tags=["Weather Forecast"],
)


@router.get(
    "/forecast",
    response_model=ForecastResponse,
)
async def get_weather_forecast(
    latitude: float = Query(..., ge=-90, le=90),
    longitude: float = Query(..., ge=-180, le=180),
    timezone: str = Query("auto"),
):
    return await forecast(
        latitude=latitude,
        longitude=longitude,
        timezone=timezone,
    )