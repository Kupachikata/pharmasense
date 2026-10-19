# PharmaSense

Decision-intelligence platform for multi-branch pharmacies (HIT400 final-year project).
Three modules share one data foundation of batches, stock and sales:

1. **Interaction checker** (Objective 2): rule-based, severity-graded (S1 to S4) alerts with logged overrides.
2. **Demand forecasting** (Objective 1): scikit-learn quantile models on a PostgreSQL feature pipeline.
3. **Decision support** (Objective 3): scoring, transfer and order recommendations, live dashboards, smart reports.

The specification is in `docs/spec/`. Design decisions are in `docs/decisions.md`, and the
requirement-to-test map is in `docs/traceability.md`.

> All data in this repository is synthetic. Seeded interaction rules are demo data, not
> clinically validated.

## Run it (Docker)

Needs Docker with the Compose plugin and `make` (or run the commands in the Makefile by hand).

```bash
git clone <repo-url> pharmasense && cd pharmasense
cp .env.example .env          # then change the three passwords
make up                       # = docker compose up --build -d
```

Open <http://localhost:8080>. The badge at the top right says **Online** when the web app,
API and database are connected. API docs are at <http://localhost:8000/api/v1/docs>.

`make logs` follows the logs, `make down` stops the stack (data is kept in the `pgdata` volume;
`docker compose down -v` deletes it).

If port 5432, 8000 or 8080 is already in use, change `DB_PORT`, `API_PORT` or `WEB_PORT` in `.env`.

## Develop on the host

Needs Python 3.12 with [uv](https://docs.astral.sh/uv/), Node 22 and PostgreSQL 16.

```bash
cp .env.example .env
make db-up            # PostgreSQL in docker, or `make db-bootstrap` on a native PostgreSQL 16
make install          # uv sync + npm ci
make api-dev          # migrations, then API on :8000 with reload
make web-dev          # in a second terminal: Vite on :5173, proxies /api to :8000
```

`make db-bootstrap` runs `infra/postgres/bootstrap.sh`, which needs superuser access through the
usual `PGHOST`, `PGUSER` and `PGPASSWORD` variables. It creates the `pharmasense` database and
two roles: `pharmasense_owner` (runs migrations) and `pharmasense_app` (used by the API).

## Test and check

| Command | What it runs |
|---------|--------------|
| `make test` | Backend pytest (against the database in `DATABASE_URL`, with coverage) and frontend Vitest |
| `make lint` | ruff check, ruff format --check, ESLint |
| `make typecheck` | mypy --strict, tsc |
| `make check` | All of the above; this is what CI runs |

Backend tests need a running database with migrations applied (`make test-backend` applies them).

CI (`.github/workflows/ci.yml`) runs the backend checks against PostgreSQL 16, the frontend
checks, and a Docker Compose smoke test that starts the full stack from a clean checkout and
calls the health endpoint through the web proxy.

## Repository layout

```
backend/        FastAPI app (api -> services -> domain / data_access / infrastructure), Alembic, tests
frontend/       React + TypeScript + Vite app
infra/          PostgreSQL bootstrap script, Nginx config
docs/           spec, decisions, traceability, runbook
scripts/        data generator, simulators (from M1)
evaluation/     scripts and outputs for Chapter 5 (from M3)
```

## Status

| Milestone | Scope | State |
|-----------|-------|-------|
| M0 | Scaffold, CI, health endpoint | done |
| M1 | Schema, constraints, synthetic data generator | next |
| M2a/M2b | Core operations, FEFO sales, POS | |
| M3 | Interaction checker | |
| M4 | Forecasting | |
| M5 | Decision support, dashboards, smart reports | |
| M6 | Offline POS | |
| M7 | Scan-assisted capture | |
| M8 | Hardening and Chapter 5 evidence | |
