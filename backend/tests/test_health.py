from collections.abc import Iterator
from typing import Any

import pytest
from fastapi.testclient import TestClient
from sqlalchemy.exc import OperationalError

from app import __version__
from app.core.errors import PROBLEM_JSON
from app.data_access.db import get_session


class _UnreachableSession:
    def execute(self, *_: Any) -> None:
        raise OperationalError("SELECT 1", {}, Exception("connection refused"))


@pytest.mark.db
def test_health_reports_ok_with_database(client: TestClient) -> None:
    response = client.get("/api/v1/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok", "database": "ok", "version": __version__}


def test_health_returns_problem_details_when_database_is_down(client: TestClient) -> None:
    def unreachable() -> Iterator[_UnreachableSession]:
        yield _UnreachableSession()

    client.app.dependency_overrides[get_session] = unreachable  # type: ignore[attr-defined]

    response = client.get("/api/v1/health")

    assert response.status_code == 503
    assert response.headers["content-type"] == PROBLEM_JSON
    body = response.json()
    assert body["status"] == 503
    assert body["title"] == "Service Unavailable"
    assert body["instance"] == "/api/v1/health"
