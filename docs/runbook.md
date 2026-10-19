# Runbook

Operational notes for running PharmaSense. Grows with each milestone.

## Services

| Service | Port (host) | Health |
|---------|-------------|--------|
| db (PostgreSQL 16) | 127.0.0.1:5432 | `pg_isready` |
| api (FastAPI) | 127.0.0.1:8000 | `GET /api/v1/health` returns 200 `{"status":"ok","database":"ok"}`; 503 problem details if the database is down |
| web (Nginx + React) | 127.0.0.1:8080 | `GET /` and `GET /api/v1/health` through the proxy |

Ports are bound to localhost only. Production TLS is added in M8 (decision D-035).

## Database roles

| Role | Used by | Privileges |
|------|---------|------------|
| `postgres` | bootstrap only | superuser |
| `pharmasense_owner` | Alembic migrations | owns the schema and all tables |
| `pharmasense_app` | API | granted by migrations; no UPDATE or DELETE on audit tables (NFR-08) |

Roles and the database are created by `infra/postgres/bootstrap.sh`. In docker it runs once,
when the `pgdata` volume is first created. It is safe to run again.

## Common tasks

- **Start / stop:** `make up`, `make down`.
- **Apply migrations:** they run automatically when the api container starts; on the host, `make migrate`.
- **Reset the docker database:** `docker compose down -v && make up` (deletes all data).
- **API starts but health returns 503:** the database is not reachable with `DATABASE_URL`; check
  `docker compose logs db` and that the passwords in `.env` match the ones used when the volume
  was created (changing `.env` later does not change existing role passwords; reset the volume or
  run `ALTER ROLE ... PASSWORD` as `postgres`).
