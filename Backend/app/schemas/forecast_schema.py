from pydantic import BaseModel
from typing import List


class DailyForecast(BaseModel):
    date: str
    weather_code: int
    temperature_max: float
    temperature_min: float
    precipitation_sum: float
    precipitation_probability_max: int
    wind_speed_max: float
    sunrise: str
    sunset: str


class ForecastResponse(BaseModel):
    latitude: float
    longitude: float
    timezone: str
    forecast: List[DailyForecast]