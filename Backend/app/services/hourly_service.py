from Backend.app.schemas.hourly_schema import (
    HourlyForecast,
    HourlyForecastResponse,
)
from Backend.app.services.open_meteo import get_hourly_forecast


async def hourly_forecast(
    latitude: float,
    longitude: float,
    timezone: str = "auto",
) -> HourlyForecastResponse:

    data = await get_hourly_forecast(
        latitude=latitude,
        longitude=longitude,
        timezone=timezone,
    )

    hourly = data["hourly"]

    hourly_data = []

    for i in range(len(hourly["time"])):
        hourly_data.append(
            HourlyForecast(
                time=hourly["time"][i],
                temperature=hourly["temperature_2m"][i],
                apparent_temperature=hourly["apparent_temperature"][i],
                humidity=hourly["relative_humidity_2m"][i],
                precipitation=hourly["precipitation"][i],
                precipitation_probability=hourly[
                    "precipitation_probability"
                ][i],
                wind_speed=hourly["wind_speed_10m"][i],
                wind_direction=hourly["wind_direction_10m"][i],
                weather_code=hourly["weather_code"][i],
            )
        )

    return HourlyForecastResponse(
        latitude=data["latitude"],
        longitude=data["longitude"],
        timezone=data["timezone"],
        hourly=hourly_data,
    )