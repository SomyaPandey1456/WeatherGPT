from typing import List, Optional

from pydantic import BaseModel


class AirQuality(BaseModel):

    time: str

    pm10: Optional[float] = None
    pm2_5: Optional[float] = None
    carbon_monoxide: Optional[float] = None
    nitrogen_dioxide: Optional[float] = None
    sulphur_dioxide: Optional[float] = None
    ozone: Optional[float] = None

    aqi: Optional[int] = None
    aqi_category: Optional[str] = None
    health_message: Optional[str] = None


class AirQualityResponse(BaseModel):

    latitude: float
    longitude: float
    timezone: str

    air_quality: List[AirQuality]