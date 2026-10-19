# PharmaSense developer commands. Run `make help` for the list.
# Variables in .env (copy from .env.example) are exported to every command.
ifneq (,$(wildcard .env))
include .env
export
endif

BACKEND := cd backend &&
FRONTEND := cd frontend &&

.PHONY: help up down logs db-up db-bootstrap migrate api-dev web-dev install \
        test test-backend test-frontend lint typecheck fmt check spec-md

help: ## List commands
	@grep -hE '^[a-z-]+:.*## ' Makefile | awk -F':.*## ' '{printf "  %-15s %s\n", $$1, $$2}'

up: ## Start postgres, api and web with docker compose (http://localhost:8080)
	docker compose up --build -d
	@echo "Web: http://localhost:$${WEB_PORT:-8080}  API docs: http://localhost:$${API_PORT:-8000}/api/v1/docs"

down: ## Stop the docker compose stack (data volume is kept)
	docker compose down

logs: ## Follow logs of the docker compose stack
	docker compose logs -f

db-up: ## Start only PostgreSQL in docker (for running api/tests on the host)
	docker compose up -d --wait db

db-bootstrap: ## Create roles and database on a non-docker PostgreSQL 16 (needs superuser via PG* vars)
	./infra/postgres/bootstrap.sh

install: ## Install backend and frontend dependencies on the host
	$(BACKEND) uv sync
	$(FRONTEND) npm ci

migrate: ## Apply Alembic migrations
	$(BACKEND) uv run alembic upgrade head

api-dev: migrate ## Run the API on the host with auto-reload (port 8000)
	$(BACKEND) uv run uvicorn app.main:app --reload --port 8000

web-dev: ## Run the Vite dev server on the host (port 5173, proxies /api to :8000)
	$(FRONTEND) npm run dev

test: test-backend test-frontend ## Run all tests

test-backend: migrate ## Backend tests against the database in DATABASE_URL, with coverage
	$(BACKEND) uv run pytest --cov --cov-report=term-missing:skip-covered

test-frontend: ## Frontend unit tests
	$(FRONTEND) npm test

lint: ## Ruff (lint + format check) and ESLint
	$(BACKEND) uv run ruff check . && uv run ruff format --check .
	$(FRONTEND) npm run lint

typecheck: ## mypy --strict and tsc
	$(BACKEND) uv run mypy
	$(FRONTEND) npm run typecheck

fmt: ## Auto-format backend code
	$(BACKEND) uv run ruff format . && uv run ruff check --fix .

check: lint typecheck test ## Everything CI runs

spec-md: ## Regenerate docs/spec/spec.md and figures from the .docx (needs pandoc)
	cd docs/spec && rm -rf figures && pandoc PharmaSense_Documentation_Draft_v3.docx -t gfm \
		--wrap=none --extract-media=. -o spec.md && mv media figures && \
		sed -i 's#src="media/#src="figures/#g' spec.md
