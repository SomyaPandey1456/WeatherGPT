from Backend.app.services.open_meteo import get_forecast
from Backend.app.schemas.forecast_schema import (
    DailyForecast,
    ForecastResponse,
)


async def forecast(
    latitude: float,
    longitude: float,
    timezone: str = "auto",
) -> ForecastResponse:

    data = await get_forecast(
        latitude=latitude,
        longitude=longitude,
        timezone=timezone,
    )

    daily = data["daily"]

    forecast_data = []

    for i in range(len(daily["time"])):
        forecast_data.append(
            DailyForecast(
                date=daily["time"][i],
                weather_code=daily["weather_code"][i],
                temperature_max=daily["temperature_2m_max"][i],
                temperature_min=daily["temperature_2m_min"][i],
                precipitation_sum=daily["precipitation_sum"][i],
                precipitation_probability_max=daily[
                    "precipitation_probability_max"
                ][i],
                wind_speed_max=daily["wind_speed_10m_max"][i],
                sunrise=daily["sunrise"][i],
                sunset=daily["sunset"][i],
            )
        )

    return ForecastResponse(
        latitude=data["latitude"],
        longitude=data["longitude"],
        timezone=data["timezone"],
        forecast=forecast_data,
    )