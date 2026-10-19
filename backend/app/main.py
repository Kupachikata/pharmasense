from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app import __version__
from app.api.v1 import router as v1_router
from app.core.config import get_settings
from app.core.errors import register_problem_handlers


def create_app() -> FastAPI:
    settings = get_settings()
    app = FastAPI(
        title="PharmaSense API",
        version=__version__,
        openapi_url="/api/v1/openapi.json",
        docs_url="/api/v1/docs",
        redoc_url=None,
    )
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    register_problem_handlers(app)
    app.include_router(v1_router)
    return app


app = create_app()
