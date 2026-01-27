from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # Database Settings
    DATABASE_URL: str = "sqlite+aiosqlite:///./yet.db"

    # Security Settings
    SECRET_KEY: str = "your-secret-key-here-change-this-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )

settings = Settings()
