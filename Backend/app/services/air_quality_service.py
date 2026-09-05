from Backend.app.schemas.air_qualiy_schema import (
    AirQuality,
    AirQualityResponse,
)

from Backend.app.services.open_meteo import get_air_quality
from Backend.app.services.Indian_aqi import calculate_indian_aqi
from Backend.app.services.air_quality_average import calculate_rolling_average


async def air_quality(
    latitude: float,
    longitude: float,
    timezone: str = "auto",
) -> AirQualityResponse:

    data = await get_air_quality(
        latitude=latitude,
        longitude=longitude,
        timezone=timezone,
    )

    hourly = data["hourly"]


    # Raw pollutant data

    pm10_values = hourly["pm10"]
    pm2_5_values = hourly["pm2_5"]
    carbon_monoxide_values = hourly["carbon_monoxide"]
    nitrogen_dioxide_values = hourly["nitrogen_dioxide"]
    sulphur_dioxide_values = hourly["sulphur_dioxide"]
    ozone_values = hourly["ozone"]

    # ---------------------------------------------------------
    # Calculate rolling averages
    #
    # 24-hour:
    #   PM10
    #   PM2.5
    #   NO2
    #   SO2
    #
    # 8-hour:
    #   CO
    #   O3
    # ---------------------------------------------------------

    pm10_avg = calculate_rolling_average(
        pm10_values,
        window=24,
    )

    pm2_5_avg = calculate_rolling_average(
        pm2_5_values,
        window=24,
    )

    nitrogen_dioxide_avg = calculate_rolling_average(
        nitrogen_dioxide_values,
        window=24,
    )

    sulphur_dioxide_avg = calculate_rolling_average(
        sulphur_dioxide_values,
        window=24,
    )

    ozone_avg = calculate_rolling_average(
        ozone_values,
        window=8,
    )

    # Open-Meteo provides CO in µg/m³.
    # Convert to mg/m³ for the AQI calculation.
    carbon_monoxide_mg = [
        value / 1000 if value is not None else None
        for value in carbon_monoxide_values
    ]

    carbon_monoxide_avg = calculate_rolling_average(
        carbon_monoxide_mg,
        window=8,
    )


    # Build response
    

    air_quality_data = []

    for i in range(len(hourly["time"])):

        
        # Only use pollutant averages that are actually
        # available.
        

        pm10 = pm10_avg[i]
        pm2_5 = pm2_5_avg[i]
        nitrogen_dioxide = nitrogen_dioxide_avg[i]
        sulphur_dioxide = sulphur_dioxide_avg[i]
        ozone = ozone_avg[i]
        carbon_monoxide = carbon_monoxide_avg[i]

        
        # Check whether at least one pollutant can be used.
        

        has_valid_pollutant = any(
            value is not None
            for value in [
                pm10,
                pm2_5,
                nitrogen_dioxide,
                sulphur_dioxide,
                ozone,
                carbon_monoxide,
            ]
        )

        if has_valid_pollutant:

            aqi, aqi_category, health_message = calculate_indian_aqi(
                pm10=pm10,
                pm2_5=pm2_5,
                carbon_monoxide=carbon_monoxide,
                nitrogen_dioxide=nitrogen_dioxide,
                sulphur_dioxide=sulphur_dioxide,
                ozone=ozone,
            )

        else:

            aqi = None
            aqi_category = None
            health_message = None

        
        # Add hourly pollutant data to response.
        

        air_quality_data.append(
            AirQuality(
                time=hourly["time"][i],

                pm10=pm10_values[i],
                pm2_5=pm2_5_values[i],
                carbon_monoxide=carbon_monoxide_values[i],
                nitrogen_dioxide=nitrogen_dioxide_values[i],
                sulphur_dioxide=sulphur_dioxide_values[i],
                ozone=ozone_values[i],

                aqi=aqi,
                aqi_category=aqi_category,
                health_message=health_message,
            )
        )

    return AirQualityResponse(
        latitude=data["latitude"],
        longitude=data["longitude"],
        timezone=data["timezone"],
        air_quality=air_quality_data,
    )