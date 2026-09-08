import aiohttp
from langchain_core.tools import StructuredTool
from pydantic import BaseModel, Field


# creating tool definition using StructuredModel : 


class GetWeatherInput(BaseModel):
    lat : float = Field(description='Value of latitude at the location')
    long : float = Field(description='Value of longitude at the location')

async def get_weather_now(lat : float, long : float) -> dict:

    """Asynchronously call a mock weather server API."""
    
    params = {"lat": lat, "long": long}
    url = f"https://api.open-meteo.com/v1/forecast?latitude={params['lat']}&longitude={params['long']}&current=precipitation,rain,temperature_2m,relative_humidity_2m&temperature_unit=celsius"
    
    # Using aiohttp for non-blocking network requests
    async with aiohttp.ClientSession() as session:
        try:
            async with session.get(
                url,
                timeout=aiohttp.ClientTimeout(total=10),
            ) as response:
                if response.status == 200:
                    return await response.json()
                return {"error": f"Server responded with status {response.status}"}
        except Exception as e:
            return {"error": f"Failed to connect to server: {str(e)}"}


get_weather_now_tool = StructuredTool.from_function(
    coroutine = get_weather_now,
    name = 'get_weather',
    description='fetch real time weather information for given latitude and longitude values',
    args_schema=GetWeatherInput
)



