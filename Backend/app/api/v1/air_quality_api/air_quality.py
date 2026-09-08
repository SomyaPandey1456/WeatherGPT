from typing import Optional
from fastapi import APIRouter, Query
from Backend.app.schemas.air_quality_schema.air_qualiy_schema import AirQualityResponse
from Backend.app.services.air_quality_feature.air_quality_service import air_quality
import Backend.app.services.location_feature.location_store as location_store


router = APIRouter(
    prefix="/weather",
    tags=["Air Quality"],
)


@router.get(
    "/air-quality",
    response_model=AirQualityResponse,
)
async def get_air_quality(
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

    return await air_quality(
        latitude=latitude,
        longitude=longitude,
        timezone=timezone,
    )