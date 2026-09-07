from functools import lru_cache
from pydantic import computed_field
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    # Application
    app_name: str = "WeatherGPT"
    app_version: str = "1.0.0"
    environment: str = "development"
    debug: bool = True
    
    # API
    api_v1_prefix: str = "/api/v1"

    # Weather provider
    weather_api_key: str = ""

    # CORS (cross origin resource sharing)
    cors_origins: str = "*"
    @computed_field
    def allowed_origins(self) -> list[str]:
        return [origin.strip() for origin in self.cors_origins.split(",")]  # automatically convert them to list {easy to use}


    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()