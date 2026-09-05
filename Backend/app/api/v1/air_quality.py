from fastapi import APIRouter, Query
from Backend.app.schemas.air_qualiy_schema import AirQualityResponse
from Backend.app.services.air_quality_service import air_quality


router = APIRouter(
    prefix="/weather",
    tags=["Air Quality"],
)


@router.get(
    "/air-quality",
    response_model=AirQualityResponse,
)
async def get_air_quality(
    latitude: float = Query(..., ge=-90, le=90),
    longitude: float = Query(..., ge=-180, le=180),
    timezone: str = Query("auto"),
):
    return await air_quality(
        latitude=latitude,
        longitude=longitude,
        timezone=timezone,
    )