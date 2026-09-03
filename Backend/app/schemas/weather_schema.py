from pydantic import BaseModel, Field

class Location(BaseModel):
    latitude: float
    longitude: float
    timezone: str


class CurrentWeather(BaseModel):
    temperature: float
    apparent_temperature: float
    humidity: int
    precipitation: float
    wind_speed: float
    weather_code: int


class CurrentWeatherResponse(BaseModel):
    location: Location
    current: CurrentWeather
    