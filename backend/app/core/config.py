from functools import lru_cache
from typing import Literal

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Runtime settings, read from environment variables (see .env.example)."""

    model_config = SettingsConfigDict(extra="ignore")

    app_env: Literal["dev", "test", "prod"] = "dev"
    # Connection used by the API: the least-privilege application role.
    database_url: str
    # Connection used by Alembic: the schema owner role.
    migration_database_url: str
    cors_origins: list[str] = ["http://localhost:5173"]


@lru_cache
def get_settings() -> Settings:
    return Settings()
