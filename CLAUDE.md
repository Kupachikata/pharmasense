# PharmaSense

PharmaSense is a decision-intelligence platform for a pharmacy chain in Zimbabwe. It is NOT only
an inventory system. It supports three decisions on one shared data foundation:

1. Counter decision (Objective 2): is this sale safe? Rule-based drug interaction checker with
   severity-graded alerts (S1 to S4) and logged overrides.
2. Buying-desk decision (Objective 1): what will sell, and what should we order or move?
   Demand forecasting with prediction intervals (scikit-learn, PostgreSQL feature pipeline).
3. Head-office decision (Objective 3): what is happening across the chain, and what should we do?
   Scoring algorithm, real-time dashboards and smart reports (FastAPI, PostgreSQL, React).

Inventory, batches, POS and suppliers are the data foundation that all three read from.
Scanning (barcode, GS1 DataMatrix, prescription images) is an ASSISTIVE input channel, not a
fourth objective. Prescription-audit (IPFS) and automated RFQ agents are future work: do not build.

## Source of truth

- `docs/spec/PharmaSense_Documentation_Draft_v3.docx` is the specification. `docs/spec/spec.md`
  (with `docs/spec/figures/`) is a pandoc text version for searching; if they differ, the .docx wins.
  Regenerate with `make spec-md`.
  - Chapter 3: requirements (FR-01..FR-35, NFR-01..NFR-15), use cases UC01..UC25, problems P1..P9.
  - Chapter 4: architecture, ERDs and data dictionary (Section 4.4), feature table (Table 4.8),
    Algorithms 1 to 5 (Section 4.5.4), scan pipeline (4.5.5), screens (4.6).
- If the spec is silent or ambiguous, choose the simplest option, and record it in
  `docs/decisions.md` (date, decision, reason). If the spec and these rules conflict, stop and ask.
- Do not invent clinical content. See "Clinical safety rules" below.

## Commands

See README.md. Short form: `make up` (docker compose), `make test`, `make lint`, `make typecheck`.
Host development: `make db-up` (or `make db-bootstrap` on a native PostgreSQL 16), then `make test`.
Decisions taken where the spec is silent or conflicting are in `docs/decisions.md`; read it
before changing schema, algorithms or clinical behaviour.

## Fixed stack (do not swap without asking)

- Backend: Python 3.12, FastAPI, Pydantic v2, SQLAlchemy 2.x, Alembic, PostgreSQL 16.
- Forecasting: scikit-learn (HistGradientBoostingRegressor, quantile loss q50 and q90),
  pandas/numpy. Baselines: seasonal-naive and Croston-SBA. Features come from SQL views.
- Frontend: React + TypeScript + Vite, installable PWA with an offline queue (IndexedDB),
  server-sent events (SSE) for live dashboards.
- Tests: pytest, httpx, Playwright for a few end-to-end flows. Lint/format: ruff. Types: mypy.
- Dev environment: docker compose (postgres, api, web). One command to start everything.
- Suggested defaults, confirm before adding anything else: Tanstack Query, Recharts, zod,
  vite-plugin-pwa, zxing (barcode/DataMatrix). Any new runtime dependency needs a one-line
  justification in `docs/decisions.md`.

## Architecture rules

- Layers: presentation (React) -> api (FastAPI routers, auth, SSE) -> services (inventory, sales,
  interaction, forecasting, decision_support) -> domain (models, rules) + data_access
  (repositories, SQL views) + infrastructure (scheduler, audit log, exports).
  Routers contain no business logic. Services never import from routers.
- Batch is the central entity: stock, sales, transfers, receipts and stocktakes all reference a
  batch. Sales allocate stock FEFO (first-expiry-first-out) inside one DB transaction.
- Integrity lives in the database: foreign keys, CHECK constraints, a trigger that stops stock
  going negative, and no UPDATE or DELETE privilege on audit tables for the app role.
- Interaction checking is deterministic and rule-based. Alerts are never generated or decided by
  an LLM. Smart-report text is built from deterministic templates so each sentence traces to a number.
- Every forecast and recommendation stores the inputs or component values that produced it
  (shown to the user as the reason).
- Roles: dispenser/cashier, pharmacist, branch manager, procurement officer, head-office
  executive, system administrator. Enforce RBAC on the server, not only in the UI.

## Clinical safety rules (important)

- Seed rules are DEMO data only. Mark every seeded rule `validated = false` and show a
  "demo rule, not clinically validated" label in the UI. The engine enforces only
  `validated = true` rules, so provide an admin screen where a pharmacist validates a rule
  (records who and when). Do not claim clinical accuracy anywhere.
- If you load an open dataset (for example DDInter), check its licence first, record the source and
  version on every rule (`source_ref`), and import as `validated = false`.
- Only S1 and S2 alerts interrupt the sale and need an override (reason code and authenticated
  pharmacist). S3 and S4 are passive notices. Overrides are append-only and audited.
- Use synthetic data only. Never put real patient data, real prescriptions or real national
  IDs in the repo, tests, fixtures or logs. National ID is stored only as a salted hash.

## Engineering standards

- Small, reviewable commits on short-lived branches. Conventional commit messages.
- Every functional requirement you implement gets at least one test. Keep a traceability file
  `docs/traceability.md` mapping FR/NFR/UC ids -> code path -> test. Update it as you go.
- Migrations only through Alembic. Never edit a migration that has been committed.
- No secrets in git. Provide `.env.example`. Passwords hashed with argon2 or bcrypt.
- API: OpenAPI is the contract. Version routes under `/api/v1`. Return problem-details style errors.
- Performance and security targets come from the NFR table in Chapter 3. Read them before you
  design, and write a test or a benchmark script for each one that is measurable.
- Done means: tests pass, ruff and mypy clean, docs updated, and a short demo script works.

## Working agreement

- Work milestone by milestone (see the build plan in the kickoff prompt). Do not start the next
  milestone until the current one meets its acceptance criteria.
- Before a milestone, post a short plan. After it, post: what was built, how to run it, what is
  tested, what is NOT done, and open questions.
- Ask me before: changing the schema in a way that departs from the spec, adding a runtime
  dependency, deleting or rewriting existing work, or making any claim about accuracy.
- Report results honestly. If a metric is poor, say so and do not tune the test set to flatter it.
