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


# chat_trigger integration (need to remove global state as user a and user b are mixed in single session)
state = {"messages": []}


@App.post("/chat_with_bot")
async def make_query(query: schemas.Query):

    global state

    state["messages"].append(
        HumanMessage(content=query["user"])
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