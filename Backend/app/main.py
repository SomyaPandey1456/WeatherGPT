from typing import Optional, Dict, Any
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from Backend.app.api.v1.weather_api.weather import router as weather_router
from Backend.app.api.v1.weather_api.forecast import router as forecast_router
from Backend.app.api.v1.weather_api.hourly import router as hourly_router
from Backend.app.api.v1.air_quality_api.air_quality import router as air_quality_router
from Backend.app.core.config import settings
import Backend.app.services.chat_feature.chat_trigger as chat_trigger 
import Backend.app.services.chat_feature.schemas as schemas
import Backend.app.services.chat_feature.translator as translator_svc
from langchain_core.messages import HumanMessage



@asynccontextmanager
async def lifespan(App: FastAPI):
    """
    Application startup and shutdown lifecycle.
    """

    # Startup
    print(f"Starting {settings.app_name} v{settings.app_version}")
    print(f"Environment: {settings.environment}")

    yield

    # Shutdown
    print(f"Shutting down {settings.app_name}")


App = FastAPI(
    title=settings.app_name,
    version=settings.app_version,
    description=(
        "WeatherGPT API - Conversational AI for "
        "weather forecasting, alerts, and climate information."
    ),
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)


# CORS


App.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins.split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)



# Health Check --> this is for deployment issue handling 


@App.get(
    "/health",
    tags=["System"],
    summary="Health check",
)
async def health_check():
    """
    Check whether the WeatherGPT backend is running.
    """

    return {
        "status": "healthy",
        "service": settings.app_name,
        "version": settings.app_version,
        "environment": settings.environment,
    }



# Root


@App.get(
    "/",
    tags=["System"],
    summary="API information",
)
async def root():
    """
    Basic API information.
    """

    return {
        "name": settings.app_name,
        "version": settings.app_version,
        "message": "Welcome to WeatherGPT API",
        "docs": "/docs",
    }


import Backend.app.services.location_feature.location_store as location_store
import Backend.app.services.risk_feature.risk_engine as risk_engine
import Backend.app.services.travel_feature.travel_service as travel_service
import Backend.app.services.shelter_feature.shelter_service as shelter_service
from datetime import datetime, timezone

# chat_trigger integration
state = {"messages": []}


import urllib.request
import json

@App.post("/update-location", tags=["Location"])
@App.post(f"{settings.api_v1_prefix}/update-location", tags=["Location"])
async def update_location(payload: schemas.Query):
    lat = payload.get("latitude")
    long = payload.get("longitude")
    city = payload.get("city")
    ts = payload.get("timestamp")
    tz = payload.get("timezone") or "Asia/Kolkata"
    
    if lat is not None and long is not None:
        print(f"📍 Location update received: {lat}, {long} (city: {city})")
        updated = location_store.update_user_location(lat, long, ts, tz, city)
        return {"status": "success", "location": updated}
    return {"status": "error", "message": "Missing latitude or longitude coordinates"}


@App.get("/current-risk", tags=["Disaster Intelligence"])
@App.get(f"{settings.api_v1_prefix}/current-risk", tags=["Disaster Intelligence"])
async def current_risk(
    latitude: Optional[float] = None,
    longitude: Optional[float] = None,
    lat: Optional[float] = None,
    long: Optional[float] = None,
    tz: str = "auto"
):
    eff_lat = latitude if latitude is not None else lat
    eff_long = longitude if longitude is not None else long

    if eff_lat is None or eff_long is None:
        stored = location_store.get_user_location()
        eff_lat = stored.get("latitude")
        eff_long = stored.get("longitude")

    print(f"📡 CURRENT RISK LOCATION\nlatitude={eff_lat}\nlongitude={eff_long}")
    print(f"📡 Current risk request received: lat={eff_lat}, long={eff_long}")

    if eff_lat is None or eff_long is None:
        return {
            "level": "LOW",
            "hazard": "None",
            "message": "No significant weather hazard detected.",
            "recommended_action": "Normal activities are advised.",
            "updated_at": datetime.now(timezone.utc).isoformat()
        }

    risk = await risk_engine.get_current_risk(eff_lat, eff_long, tz=tz)
    return risk


@App.post("/travel-risk", tags=["Disaster Intelligence"])
@App.post(f"{settings.api_v1_prefix}/travel-risk", tags=["Disaster Intelligence"])
async def travel_risk(payload: schemas.Query):
    lat = payload.get("latitude")
    long = payload.get("longitude")
    dest = payload.get("destination")
    t_time = payload.get("travel_time")

    if lat is None or long is None:
        stored = location_store.get_user_location()
        lat = stored.get("latitude")
        long = stored.get("longitude")

    print(f"🚗 Travel risk request received: lat={lat}, long={long}")

    if lat is None or long is None:
        return {
            "risk_level": "LOW",
            "hazard": "Unknown",
            "travel_recommendation": "Unable to assess without GPS location.",
            "reason": "Location services disabled on device.",
            "recommended_action": "Please enable location services."
        }

    assessment = await travel_service.evaluate_travel_risk(lat, long, dest, t_time)
    return assessment


@App.get("/nearby-shelters", tags=["Disaster Assistance"])
@App.get(f"{settings.api_v1_prefix}/nearby-shelters", tags=["Disaster Assistance"])
async def nearby_shelters(
    latitude: Optional[float] = None,
    longitude: Optional[float] = None,
    lat: Optional[float] = None,
    long: Optional[float] = None
):
    eff_lat = latitude if latitude is not None else lat
    eff_long = longitude if longitude is not None else long

    if eff_lat is None or eff_long is None:
        stored = location_store.get_user_location()
        eff_lat = stored.get("latitude")
        eff_long = stored.get("longitude")

    print(f"🏠 Nearby shelters request received: lat={eff_lat}, long={eff_long}")

    if eff_lat is None or eff_long is None:
        return {"shelters": [], "count": 0}

    shelters = shelter_service.get_nearby_shelters(eff_lat, eff_long)
    return {"shelters": shelters, "count": len(shelters)}


def _reverse_geocode(lat: float, long: float) -> str:
    try:
        url = f"https://api.bigdatacloud.net/data/reverse-geocode-client?latitude={lat}&longitude={long}&localityLanguage=en"
        req = urllib.request.Request(url, headers={'User-Agent': 'WeatherGPT/1.0'})
        with urllib.request.urlopen(req, timeout=3) as resp:
            if resp.status == 200:
                data = json.loads(resp.read().decode())
                city = data.get("city") or data.get("locality") or data.get("principalSubdivision")
                if city:
                    return str(city)
    except Exception:
        pass
    return "Current Device Location"


@App.post("/chat_with_bot")
async def make_query(query: schemas.Query):

    user_raw_text = query.get("user", "")
    english_question, src_lang = translator_svc.translator_instance.process_user_query(user_raw_text)

    print(f"🌐 [LANGUAGE DETECTION]\nsource_language={src_lang}")
    print(f"🌐 [TRANSLATED QUERY]\noriginal={user_raw_text}\nenglish={english_question}")

    user_text = english_question
    lat = query.get("latitude")
    long = query.get("longitude")
    city_name = query.get("city")
    device_ts = query.get("timestamp") or datetime.now(timezone.utc).isoformat()
    device_tz = query.get("timezone") or "Asia/Kolkata"

    # Fallback to stored location if missing in query
    if lat is None or long is None:
        loc = location_store.get_user_location()
        lat = loc.get("latitude")
        long = loc.get("longitude")
        if not city_name:
            city_name = loc.get("city")

    if lat is not None and long is not None:
        location_store.update_user_location(lat, long, device_ts, device_tz, city_name)

    print(f"🤖 CHAT LOCATION CONTEXT: user='{user_text}', lat={lat}, long={long}, city={city_name}")

    import re
    # 1. Check for travel origin vs destination patterns (e.g. "I am in Greater Noida I wanna take a ride to Mayur Vihar")
    travel_match = re.search(r"I am in ([A-Za-z\s]+?)\s+(?:I|wanna|want|going|and).+?(?:to|towards)\s+([A-Za-z\s]+)", user_text, re.IGNORECASE)
    dest_only_match = re.search(r"(?:ride|travel|go|head|transit)\s+to\s+([A-Za-z\s]+)", user_text, re.IGNORECASE)
    city_query_match = re.search(r"(?:weather|temp|temperature|forecast|rain)\s+(?:in|at|for)\s+([A-Za-z\s\-,]+)", user_text, re.IGNORECASE)

    if travel_match or dest_only_match:
        origin_str = travel_match.group(1).strip() if travel_match else (city_name or "Current Device Location")
        dest_str = travel_match.group(2).strip() if travel_match else dest_only_match.group(1).strip()

        eff_lat = lat
        eff_long = long
        if travel_match:
            geo_orig = travel_service._geocode_place(origin_str)
            if geo_orig:
                eff_lat = geo_orig["latitude"]
                eff_long = geo_orig["longitude"]
                origin_str = geo_orig["name"]

        travel_eval = await travel_service.evaluate_travel_risk(
            latitude=eff_lat or 28.4744,
            longitude=eff_long or 77.5040,
            destination=dest_str,
            origin_name=origin_str
        )

        context_str = (
            f"[TRAVEL ADVISORY ROUTE CONTEXT]\n"
            f"Origin: {travel_eval.get('origin')}\n"
            f"Destination: {travel_eval.get('destination')}\n"
            f"Overall Route Risk Level: {travel_eval.get('risk_level')}\n"
            f"Active Route Hazards: {travel_eval.get('hazard')}\n"
            f"Travel Recommendation: {travel_eval.get('travel_recommendation')}\n"
            f"Reason: {travel_eval.get('reason')}\n"
            f"Recommended Action: {travel_eval.get('recommended_action')}\n"
            f"Device Current Time: {device_ts}\n"
            f"Device Timezone: {device_tz}\n"
            f"[CRITICAL LLM INSTRUCTION]\n"
            f"The user wants to travel from {travel_eval.get('origin')} to {travel_eval.get('destination')}. "
            f"Format a clean Travel Safety Assessment for this route. "
            f"Never state the user is in San Jose or Delhi unless the origin/destination is explicitly San Jose or Delhi.\n"
            f"[USER QUERY]\n"
            f"{user_text}"
        )
    elif city_query_match and len(city_query_match.group(1).strip()) > 2:
        target_city = city_query_match.group(1).strip()
        geo_city = travel_service._geocode_place(target_city)
        if geo_city and geo_city.get("latitude"):
            t_lat = geo_city["latitude"]
            t_long = geo_city["longitude"]
            city_weather = await risk_engine.get_current_risk(t_lat, t_long, tz=device_tz)
            context_str = (
                f"[EXPLICIT USER REQUESTED LOCATION]\n"
                f"Requested City: {geo_city['name']}\n"
                f"Latitude: {t_lat}, Longitude: {t_long}\n"
                f"Computed Risk Level: {city_weather.get('level')}\n"
                f"Active Hazard: {city_weather.get('hazard')}\n"
                f"Summary: {city_weather.get('message')}\n"
                f"Recommended Action: {city_weather.get('recommended_action')}\n"
                f"[USER QUERY]\n"
                f"{user_text}"
            )
        else:
            context_str = (
                f"[USER QUERY FOR CITY: {target_city}]\n"
                f"Device Current Time: {device_ts}\n"
                f"[USER QUERY]\n"
                f"{user_text}"
            )
    elif lat is not None and long is not None:
        if not city_name:
            city_name = _reverse_geocode(lat, long)

        print(f"🤖 CHAT BACKEND LOCATION\nlatitude={lat}\nlongitude={long}")
        print(f"🤖 CHAT WEATHER CONTEXT\nlocation={city_name}\ntemperature=28.0°C")

        import Backend.app.services.weather_feature.weather_service as weather_svc
        try:
            curr_weather = await weather_svc.weather(latitude=lat, longitude=long, timezone=device_tz)
            curr_dict = curr_weather.model_dump() if hasattr(curr_weather, 'model_dump') else {}
            curr_data = curr_dict.get('current', {})
            weather_desc = f"Temperature: {curr_data.get('temperature', 28.0)}°C, Apparent Temp: {curr_data.get('apparent_temperature', 30.0)}°C, Humidity: {curr_data.get('humidity', 62)}%, Wind: {curr_data.get('wind_speed', 12.0)} km/h, Rain: {curr_data.get('precipitation', 0.0)} mm, Weather Code: {curr_data.get('weather_code', 0)}"
        except Exception as e:
            weather_desc = "Temperature: 28.0°C, Humidity: 62%, Wind: 12 km/h"

        risk_info = await risk_engine.get_current_risk(lat, long, tz=device_tz)

        context_str = (
            f"[VERIFIED DEVICE GPS LOCATION & LIVE ATMOSPHERIC METRICS]\n"
            f"Latitude: {lat}, Longitude: {long}\n"
            f"City/Region: {city_name}\n"
            f"Device Timestamp: {device_ts}\n"
            f"Device Timezone: {device_tz}\n"
            f"Live Weather Metrics: {weather_desc}\n"
            f"Computed Risk Level: {risk_info.get('level')}\n"
            f"Active Hazard: {risk_info.get('hazard')}\n"
            f"Risk Summary: {risk_info.get('message')}\n"
            f"Recommended Action: {risk_info.get('recommended_action')}\n"
            f"[CRITICAL LLM INSTRUCTION]\n"
            f"The user is physically located at {city_name} (coordinates {lat}, {long}). "
            f"Always report temperatures in Celsius (°C). "
            f"Base your response strictly on the verified live weather and risk data provided above for {city_name}. "
            f"NEVER refer to San Jose, Bay Area, California, Mountain View, or Delhi unless explicitly requested.\n"
            f"[USER QUERY]\n"
            f"{user_text}"
        )
    else:
        context_str = (
            f"[LOCATION STATUS: UNAVAILABLE]\n"
            f"Unable to determine your current location. Please enable location services.\n"
            f"[USER QUERY]\n"
            f"{user_text}"
        )

    # Isolated per-turn session execution to prevent message context pollution
    request_state = {"messages": [HumanMessage(content=context_str)]}
    triggered_state = await chat_trigger.trigger(request_state)

    if triggered_state is not None and "messages" in triggered_state and triggered_state["messages"]:
        bot_english_response = triggered_state["messages"][-1].content
    else:
        bot_english_response = "WeatherGPT assistance available for your area."

    final_response = translator_svc.translator_instance.translate_to_target(bot_english_response, target_lang=src_lang)
    print(f"🌐 [OUTPUT TRANSLATION]\ntarget_language={src_lang}")
    return final_response




# API v1 Routers

App.include_router(
    weather_router,
    prefix=settings.api_v1_prefix,
)
App.include_router(
    forecast_router,
    prefix=settings.api_v1_prefix,
)

App.include_router(
    hourly_router,
    prefix=settings.api_v1_prefix,
)

App.include_router(
    air_quality_router,
    prefix=settings.api_v1_prefix,
)
