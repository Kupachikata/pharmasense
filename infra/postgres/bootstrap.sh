#!/usr/bin/env bash
# Creates the two PharmaSense roles and the database. Run once as a PostgreSQL superuser.
# Used by the postgres container (docker-entrypoint-initdb.d), CI and local development.
#
#   pharmasense_owner  owns the schema and runs Alembic migrations
#   pharmasense_app    used by the API; table privileges are granted (and, for audit
#                      tables, revoked) by the migrations, never here
set -euo pipefail

: "${PHARMASENSE_DB:=pharmasense}"
: "${PHARMASENSE_OWNER_PASSWORD:?PHARMASENSE_OWNER_PASSWORD must be set}"
: "${PHARMASENSE_APP_PASSWORD:?PHARMASENSE_APP_PASSWORD must be set}"

psql -v ON_ERROR_STOP=1 \
  -v db="$PHARMASENSE_DB" \
  -v owner_pw="$PHARMASENSE_OWNER_PASSWORD" \
  -v app_pw="$PHARMASENSE_APP_PASSWORD" \
  --dbname "${POSTGRES_DB:-postgres}" <<'SQL'
SELECT format('CREATE ROLE pharmasense_owner LOGIN PASSWORD %L', :'owner_pw')
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pharmasense_owner') \gexec
SELECT format('CREATE ROLE pharmasense_app LOGIN PASSWORD %L', :'app_pw')
WHERE NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'pharmasense_app') \gexec
SELECT format('CREATE DATABASE %I OWNER pharmasense_owner', :'db')
WHERE NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = :'db') \gexec
SELECT format('REVOKE ALL ON DATABASE %I FROM PUBLIC', :'db') \gexec
SELECT format('GRANT CONNECT ON DATABASE %I TO pharmasense_app', :'db') \gexec
\connect :db
REVOKE CREATE ON SCHEMA public FROM PUBLIC;
ALTER SCHEMA public OWNER TO pharmasense_owner;
GRANT USAGE ON SCHEMA public TO pharmasense_app;
SQL
