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
    lat = payload.get("latitude") if payload.get("latitude") is not None else payload.get("lat")
    long = payload.get("longitude") if payload.get("longitude") is not None else payload.get("long")
    city = payload.get("city") or payload.get("location_name")
    ts = payload.get("timestamp")
    tz = payload.get("timezone") or "Asia/Kolkata"
    
    if lat is not None and long is not None:
        print(f"📍 Location update received: {lat}, {long} (city: {city})")
        updated = location_store.update_user_location(lat, long, ts, tz, city)
        return {"status": "success", "location": updated}
    return {"status": "error", "message": "Missing latitude or longitude coordinates"}


@App.get("/current-risk", tags=["Disaster Intelligence"])
@App.get(f"{settings.api_v1_prefix}/current-risk", tags=["Disaster Intelligence"])
async def current_risk(lat: Optional[float] = None, long: Optional[float] = None, tz: str = "auto"):
    if lat is None or long is None:
        stored = location_store.get_user_location()
        lat = stored.get("latitude")
        long = stored.get("longitude")

    print(f"📡 Current risk request received: lat={lat}, long={long}")

    if lat is None or long is None:
        return {
            "level": "LOW",
            "hazard": "None",
            "message": "No significant weather hazard detected.",
            "recommended_action": "Normal activities are advised.",
            "updated_at": datetime.now(timezone.utc).isoformat()
        }

    risk = await risk_engine.get_current_risk(lat, long, tz=tz)
    return risk


@App.post("/travel-risk", tags=["Disaster Intelligence"])
@App.post(f"{settings.api_v1_prefix}/travel-risk", tags=["Disaster Intelligence"])
async def travel_risk(payload: schemas.Query):
    lat = payload.get("latitude") if payload.get("latitude") is not None else payload.get("lat")
    long = payload.get("longitude") if payload.get("longitude") is not None else payload.get("long")
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
async def nearby_shelters(lat: Optional[float] = None, long: Optional[float] = None):
    if lat is None or long is None:
        stored = location_store.get_user_location()
        lat = stored.get("latitude")
        long = stored.get("longitude")

    print(f"🏠 Nearby shelters request received: lat={lat}, long={long}")

    if lat is None or long is None:
        return {"shelters": [], "count": 0}

    shelters = shelter_service.get_nearby_shelters(lat, long)
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

    global state

    user_text = query.get("user", "")
    lat = query.get("latitude") if query.get("latitude") is not None else query.get("lat")
    long = query.get("longitude") if query.get("longitude") is not None else query.get("long")
    city_name = query.get("city") or query.get("location_name")
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

    print(f"🤖 Chat with bot received: user='{user_text}', lat={lat}, long={long}, city={city_name}")

    if lat is not None and long is not None:
        if not city_name:
            city_name = _reverse_geocode(lat, long)

        risk_info = await risk_engine.get_current_risk(lat, long, tz=device_tz)

        context_str = (
            f"[VERIFIED DEVICE GPS LOCATION]\n"
            f"Latitude: {lat}, Longitude: {long}\n"
            f"City/Region: {city_name}\n"
            f"Device Timestamp: {device_ts}\n"
            f"Device Timezone: {device_tz}\n"
            f"Computed Risk Level: {risk_info.get('level')}\n"
            f"Active Hazard: {risk_info.get('hazard')}\n"
            f"Risk Summary: {risk_info.get('message')}\n"
            f"Recommended Action: {risk_info.get('recommended_action')}\n"
            f"[CRITICAL LLM INSTRUCTION]\n"
            f"The user is physically located at {city_name} (coordinates {lat}, {long}). "
            f"Base your answer strictly on weather and hazards at {city_name}. "
            f"NEVER refer to Delhi or any other city unless the user explicitly asks about that city or their coordinates are in Delhi.\n"
            f"[USER QUERY]\n"
            f"{user_text}"
        )
    else:
        context_str = (
            f"[LOCATION STATUS: UNKNOWN]\n"
            f"Device GPS location is currently disabled or unavailable.\n"
            f"[USER QUERY]\n"
            f"{user_text}"
        )

    state["messages"].append(
        HumanMessage(content=context_str)
    )

    triggered_state = await chat_trigger.trigger(state)

    if triggered_state is not None:
        state = triggered_state

    return state["messages"][-1].content



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
