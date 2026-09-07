from typing import Optional, Tuple


# Indian National Air Quality Index (CPCB)

# AQI categories:
# 0 - 50      : Good
# 51 - 100    : Satisfactory
# 101 - 200   : Moderately Polluted
# 201 - 300   : Poor
# 301 - 400   : Very Poor
# 401 - 500   : Severe

# Pollutant concentration breakpoints
# Format:
# (
#     concentration_low,
#     concentration_high,
#     aqi_low,
#     aqi_high
# )
# PM10, PM2.5, NO2, SO2 and O3 are in µg/m³.
# CO is in mg/m³.
#
# IMPORTANT:
# These calculations should be applied to the appropriate
# averaging periods before calculating the AQI.


BREAKPOINTS = {

    "pm10": [
        (0, 50, 0, 50),
        (51, 100, 51, 100),
        (101, 250, 101, 200),
        (251, 350, 201, 300),
        (351, 430, 301, 400),
        (431, float("inf"), 401, 500),
    ],

    "pm2_5": [
        (0, 30, 0, 50),
        (31, 60, 51, 100),
        (61, 90, 101, 200),
        (91, 120, 201, 300),
        (121, 250, 301, 400),
        (251, float("inf"), 401, 500),
    ],

    "nitrogen_dioxide": [
        (0, 40, 0, 50),
        (41, 80, 51, 100),
        (81, 180, 101, 200),
        (181, 280, 201, 300),
        (281, 400, 301, 400),
        (401, float("inf"), 401, 500),
    ],

    "sulphur_dioxide": [
        (0, 40, 0, 50),
        (41, 80, 51, 100),
        (81, 380, 101, 200),
        (381, 800, 201, 300),
        (801, 1600, 301, 400),
        (1601, float("inf"), 401, 500),
    ],

    "carbon_monoxide": [
        (0.0, 1.0, 0, 50),
        (1.1, 2.0, 51, 100),
        (2.1, 10.0, 101, 200),
        (10.1, 17.0, 201, 300),
        (17.1, 34.0, 301, 400),
        (34.1, float("inf"), 401, 500),
    ],

    "ozone": [
        (0, 50, 0, 50),
        (51, 100, 51, 100),
        (101, 168, 101, 200),
        (169, 208, 201, 300),
        (209, 748, 301, 400),
        (749, float("inf"), 401, 500),
    ],
}



# AQI categories


AQI_CATEGORIES = {
    "Good": (0, 50),
    "Satisfactory": (51, 100),
    "Moderately Polluted": (101, 200),
    "Poor": (201, 300),
    "Very Poor": (301, 400),
    "Severe": (401, 500),
}



# Health messages


HEALTH_MESSAGES = {

    "Good": (
        "Air quality is good. "
        "Air pollution poses little or no risk."
    ),

    "Satisfactory": (
        "Air quality is satisfactory. "
        "Sensitive individuals may experience minor discomfort."
    ),

    "Moderately Polluted": (
        "Sensitive people may experience breathing discomfort. "
        "People with respiratory or heart conditions should reduce "
        "prolonged outdoor exertion."
    ),

    "Poor": (
        "People may experience breathing discomfort, especially "
        "those with respiratory or heart conditions. "
        "Sensitive groups should limit prolonged outdoor exertion."
    ),

    "Very Poor": (
        "Risk of respiratory illness increases. "
        "People with respiratory or heart conditions, children, "
        "and older adults should avoid prolonged outdoor exertion."
    ),

    "Severe": (
        "Health risk is increased for everyone. "
        "People should avoid prolonged or strenuous outdoor activity."
    ),
}



# Calculate pollutant sub-index


def _calculate_sub_index(
    concentration: Optional[float],
    breakpoints: list[tuple[float, float, int, int]],
) -> Optional[int]:

    if concentration is None:
        return None

    if concentration < 0:
        return None

    for (
        concentration_low,
        concentration_high,
        aqi_low,
        aqi_high,
    ) in breakpoints:

        if concentration_low <= concentration <= concentration_high:

            if concentration_high == concentration_low:
                return aqi_high

            sub_index = (
                (
                    (aqi_high - aqi_low)
                    / (concentration_high - concentration_low)
                )
                * (concentration - concentration_low)
                + aqi_low
            )

            return round(sub_index)

    return None



# Get AQI category


def _get_category(aqi: int) -> str:

    if aqi <= 50:
        return "Good"

    if aqi <= 100:
        return "Satisfactory"

    if aqi <= 200:
        return "Moderately Polluted"

    if aqi <= 300:
        return "Poor"

    if aqi <= 400:
        return "Very Poor"

    return "Severe"



# Get health message


def _get_health_message(category: str) -> str:

    return HEALTH_MESSAGES.get(
        category,
        "Air quality information is currently unavailable.",
    )


# Main Indian AQI calculation

def calculate_indian_aqi(
    pm10: Optional[float],
    pm2_5: Optional[float],
    carbon_monoxide: Optional[float],
    nitrogen_dioxide: Optional[float],
    sulphur_dioxide: Optional[float],
    ozone: Optional[float],
) -> Tuple[int, str, str]:

    pollutants = {
        "pm10": pm10,
        "pm2_5": pm2_5,
        "carbon_monoxide": carbon_monoxide,
        "nitrogen_dioxide": nitrogen_dioxide,
        "sulphur_dioxide": sulphur_dioxide,
        "ozone": ozone,
    }

    sub_indices = []

    for pollutant, concentration in pollutants.items():

        sub_index = _calculate_sub_index(
            concentration=concentration,
            breakpoints=BREAKPOINTS[pollutant],
        )

        if sub_index is not None:
            sub_indices.append(sub_index)

    # No valid pollutant data available.
    if not sub_indices:

        return (
            0,
            "Good",
            "Air quality information is currently unavailable.",
        )

    # Overall AQI is determined by the highest
    # pollutant sub-index.
    aqi = max(sub_indices)

    # Keep AQI within the 0-500 scale.
    aqi = max(0, min(aqi, 500))

    category = _get_category(aqi)

    health_message = _get_health_message(category)

    return (
        aqi,
        category,
        health_message,
    )