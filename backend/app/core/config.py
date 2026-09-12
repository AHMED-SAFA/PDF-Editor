from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="PDF_EDITOR_", extra="ignore")

    app_name: str = "PDF Editor APIs"
    max_upload_bytes: int = 20 * 1024 * 1024
    cors_origins: list[str] = ["*"]

    @property
    def fonts_dir(self) -> Path:
        return Path(__file__).resolve().parents[1] / "assets" / "fonts"


settings = Settings()
