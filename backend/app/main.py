from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.translate import router as translate_router
from app.api.watermark import router as watermark_router
from app.core.config import settings
from app.core.fonts import require_fonts


def create_app() -> FastAPI:
    require_fonts()
    app = FastAPI(title=settings.app_name, version="1.0.0")
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    app.include_router(translate_router)
    app.include_router(watermark_router)
    return app


app = create_app()
