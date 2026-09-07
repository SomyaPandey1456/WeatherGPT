from typing import List
from pydantic import BaseModel


class HourlyForecast(BaseModel):
    time: str
    temperature: float
    apparent_temperature: float
    humidity: int
    precipitation: float
    precipitation_probability: int
    wind_speed: float
    wind_direction: float
    weather_code: int


class HourlyForecastResponse(BaseModel):
    latitude: float
    longitude: float
    timezone: str
    hourly: List[HourlyForecast]