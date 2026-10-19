# Decisions

Decisions taken where the specification (`docs/spec/`) is silent, ambiguous or in conflict.
Format: id, date, decision, reason. Status "approved" means the project owner agreed it in the
Step 0 review on 2026-10-19. Later entries are added as they are made.

## Clinical and safety

| ID | Date | Decision | Reason |
|----|------|----------|--------|
| D-001 | 2026-10-19 | Seed rules are imported with `validated = false` and `is_demo = true`. The demo script validates a small subset through the real validation screen as a fictitious "Demo Pharmacist" account, which records who and when. The UI shows "demo rule, not clinically validated" whenever `is_demo = true`, whether or not the rule is validated. | The engine enforces only validated rules (Algorithm 1), so an honest demo needs a recorded validation step; the demo label must survive it. Approved. |
| D-002 | 2026-10-19 | Demo rules use only the pairs shown in the spec's own prototypes (Fig. 4.15, B.5): warfarin + ibuprofen/NSAIDs, simvastatin + clarithromycin, penicillin allergy vs beta-lactam class, NSAIDs + peptic ulcer disease, paracetamol + metoclopramide. Mechanism and advice text is copied exactly from the spec. Any further rule comes from a licensed source or the validating pharmacists. | Do not invent clinical content. Approved. |
| D-003 | 2026-10-19 | Open question for the validating pharmacists: should a direct match between a recorded allergen ingredient and a basket ingredient always alert, and at which severity? Until answered, the engine does only what Algorithm 1 specifies (allergy alerts come from allergy rules). The gap is listed in the evaluation report. | Clinical decision; not for the developer to set. |
| D-004 | 2026-10-19 | Override reason codes live in a table (`override_reason`) seeded with placeholder codes marked as needing pharmacist approval. | Spec requires an enum but gives no list. Approved. |
| D-005 | 2026-10-19 | Returned items go to a quarantine state by default, not back into sellable stock. | Resale of returned medicine is a regulatory question. Approved. |
| D-006 | 2026-10-19 | Offline override: pharmacist PIN hashes are cached per branch with a short expiry; patient profiles are cached only for consenting patients with recent visits at that branch; both encrypted in IndexedDB. | Section 4.3.4 requires offline override; NFR-07 requires minimisation. Approved. |

## Data model additions beyond Section 4.4 (approved)

| ID | Date | Decision | Reason |
|----|------|----------|--------|
| D-010 | 2026-10-19 | Add append-only `stock_movement` ledger written by every receipt, sale, transfer, adjustment and return. | Stock-out days and on-order at week t (Table 4.8) need history; `stock_level` holds only the current quantity. |
| D-011 | 2026-10-19 | Rule sides reference either an ingredient or a class. Add `ingredient_class` and `ingredient_class_member`. Allergy rules carry an allergen class; condition rules carry an ICD-10 code. Rules gain mechanism, advice, `validated_at`, version, retired, `is_demo`. Add `interaction_rule_version` for edit history. | Class rules ("NSAIDs", "beta-lactam") cannot be expressed with ingredient FKs; FR-16 needs version history. ATC alone is too coarse (beta-lactam spans two ATC groups). |
| D-012 | 2026-10-19 | Add `patient_medication`. | Algorithm 1 uses patient.current_medicines; no table in the ERD. |
| D-013 | 2026-10-19 | A sale starts as DRAFT. `sale` gains `status`, `total`, `idempotency_key`, client UUID; `sale_line` gains `unit_price`. Alerts attach to the draft sale. | Screening happens before completion; offline replay needs idempotency; Table 4.6 has unit_price. |
| D-014 | 2026-10-19 | Add one `recommendation` table (type transfer or purchase, components jsonb, status, decided_by, decided_at, reason). | Algorithm 4 stores recommendations with component values; no table in the ERD. |
| D-015 | 2026-10-19 | Add `calendar_week`, `branch.region`, `branch_route` (transport cost c_ij), `supplier_product` (price list), `purchase_order.expected_date`, `batch.received_date`, `stock_level.qty_reserved`, `user_account.pin_hash` with lock-out fields, `exchange_rate`. | Needed by Table 4.8, Algorithm 4, FR-09, UC19, Table 4.4 and NFR-14. |

## Spec conflicts and unspecified defaults

| ID | Date | Decision | Reason |
|----|------|----------|--------|
| D-020 | 2026-10-19 | Python 3.12. | Table 1.4 says 3.11; CLAUDE.md says 3.12. CLAUDE.md is newer. |
| D-021 | 2026-10-19 | Six login roles: dispenser, pharmacist, branch_manager, procurement_officer, executive, admin. Supplier is external and has no login. | FR-01 says seven; Table 3.4 has six internal actors plus Supplier. Ch. 3 wording to be corrected. |
| D-022 | 2026-10-19 | FEFO locks candidate `stock_level` rows (`SELECT ... FOR UPDATE`) inside the sale transaction before planning. | Algorithm 2 plans outside the transaction, which races under concurrent sales. |
| D-023 | 2026-10-19 | An offline sale that replay cannot satisfy is stored with a shortfall record for the branch manager; stock never goes negative. | Section 4.3.4 "accepted but flagged" vs the negative-stock trigger. |
| D-024 | 2026-10-19 | The 5% fallback margin (Algorithm 3) is the run gate; the 10% relative WAPE improvement (Table 1.1) is a success criterion. Both are reported. | They measure different things. |
| D-025 | 2026-10-19 | Baseline per series: Croston-SBA when average inter-demand interval >= 1.32, else seasonal-naive. | "MEAN(wape_baseline)" does not say which baseline. |
| D-026 | 2026-10-19 | Baseline q90 comes from empirical back-test residual quantiles. | Baselines give point forecasts; safety stock needs q90. |
| D-027 | 2026-10-19 | Fallback gate is per run (Algorithm 3); each forecast line also carries a flag shown on screen (Table 3.8). | Spec differs between the two places. |
| D-028 | 2026-10-19 | Stock-out weeks are a feature but are excluded from training targets and metrics. | Section 4.4.4: censored sales must not be learned as low demand. |
| D-029 | 2026-10-19 | All rolling features are shifted by at least one week; a test proves features at week t use only data up to t. | Leakage control. |
| D-030 | 2026-10-19 | Daily demand = weekly forecast / 7; beyond the 8-week horizon the last week is held flat. Summing weekly q90 over several weeks overstates the q90 of the total; this is conservative and documented. | Algorithm 4 works in days; forecasts are weekly. |
| D-031 | 2026-10-19 | Configurable defaults: review period T = 7 days; excess = cover > 12 weeks; near-expiry = 90 days; report materiality = 10%; supplier price score = max(0, 1 - (p - pmin) / pmin); fill and on-time rates derived from PO and GRN data. | Spec does not set them. |
| D-032 | 2026-10-19 | National ID stored as HMAC-SHA256 with a secret key from the environment. | A per-row random salt makes lookup impossible; still hash-only (NFR-07). |
| D-033 | 2026-10-19 | Rx sale requires a patient and a prescription record; OTC patient optional; a patient without consent has no stored profile and is served as anonymous OTC. | FR-06, FR-07, data dictionary. |
| D-034 | 2026-10-19 | Handwriting recognition is not built; images classed as handwritten go to manual entry. Image retention is configurable, default 30 days, marked "to be confirmed with the Medicines Control Authority". Barcode and DataMatrix decoding happens in the browser (ZXing); the server validates GS1 element strings. | Table 4.9 marks handwriting pilot-only; NFR-15 leaves retention open. |
| D-035 | 2026-10-19 | Partially met NFRs: NFR-04 availability is not measurable in the project; NFR-13 delivers an encrypted backup with a tested restore and a configurable off-site target; NFR-06 TLS via an Nginx container with a self-signed certificate locally. | Project environment limits. |
| D-036 | 2026-10-19 | Evaluation additions: H3 replay simulation (M5), H2 interruption rate vs alert-all (M3), blinded 50-recommendation rating sheet (M5), 250-scenario set format (M3), NFR-03 capacity test (M8). | Required by Table 1.1 and Table 1.2. |
| D-037 | 2026-10-19 | Live dashboard fan-out uses PostgreSQL LISTEN/NOTIFY; no Redis. | Works across several API workers without another service. |

## Dependencies

Each runtime dependency with a one-line reason. Approved as a list on 2026-10-19; each is added
only when the milestone that uses it starts.

| Dependency | Reason | Added in |
|------------|--------|----------|
| fastapi, uvicorn, pydantic, pydantic-settings | Fixed stack; settings from environment. | M0 |
| sqlalchemy, alembic, psycopg (v3) | Fixed stack; psycopg 3 is the maintained PostgreSQL driver. | M0 |
| argon2-cffi | Password and PIN hashing (NFR-06). | M2 |
| PyJWT | Signed access tokens. | M2 |
| APScheduler | Worker process for nightly forecast and scheduled reports. | M4 |
| reportlab | PDF export with no system libraries (FR-30). | M5 |
| rapidfuzz | Fuzzy matching of scanned lines to the catalogue (FR-34). | M7 |
| pytesseract + tesseract-ocr (apt) | On-premise open-source OCR (Table 4.9). | M7 |
| cryptography | Encryption of prescription images at rest (NFR-15). | M7 |
| Pillow | Synthetic printed prescription images for evaluation. | M7 |
| matplotlib | Evaluation charts only (not imported by the app). | M4 |
| hypothesis | Property tests for FEFO (dev only). | M2 |
| locust | Load tests (dev only). | M8 |
| Frontend: react, react-dom, react-router, @tanstack/react-query, zod, recharts, vite-plugin-pwa, idb, @zxing/browser | Suggested defaults in CLAUDE.md, plus routing and an IndexedDB wrapper. | M0 onward |

## Milestone plan (approved)

M0 scaffold; M1 data foundation; M2a auth, master data, receiving, stock, FEFO sales, POS;
M2b returns, stocktake, suppliers and POs, transfers, low-stock and near-expiry alerts, audit
viewer; M3 interaction checker; M4 forecasting; M5 decision support; M6 offline (target the
8-hour NFR-05 and measure it); M7 scan-assisted capture; M8 hardening and evidence.
POS uses client sale UUIDs and idempotency keys from M2a so M6 needs no rework.

## M0

| ID | Date | Decision | Reason |
|----|------|----------|--------|
| D-040 | 2026-10-19 | Python dependencies managed with uv and a committed `uv.lock`. | Reproducible installs, fast in CI and Docker. |
| D-041 | 2026-10-19 | Two database roles: `pharmasense_owner` runs migrations and owns objects; `pharmasense_app` is what the API uses. Audit-table privileges are revoked from the app role in migrations. | NFR-08 requires no UPDATE/DELETE for application accounts. |
| D-042 | 2026-10-19 | Errors use RFC 9457 problem details (`application/problem+json`). | CLAUDE.md requires problem-details style errors. |
