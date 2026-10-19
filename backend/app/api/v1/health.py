from typing import Literal

from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app import __version__
from app.core.errors import ProblemError
from app.data_access.db import get_session
from app.services.health import database_is_reachable

router = APIRouter(tags=["health"])


class Health(BaseModel):
    status: Literal["ok"]
    database: Literal["ok"]
    version: str


@router.get(
    "/health",
    responses={503: {"description": "Database unreachable (problem details)"}},
)
def health(session: Session = Depends(get_session)) -> Health:
    if not database_is_reachable(session):
        raise ProblemError(503, "Database is unreachable")
    return Health(status="ok", database="ok", version=__version__)
