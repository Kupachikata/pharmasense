# Traceability

Maps each requirement in the specification (Tables 3.5 and 3.6) to the code that implements it
and the test or script that checks it. Updated at the end of every milestone.
Status: `-` not started, `partial`, `done`.

## Functional requirements

| ID | Requirement (short) | Milestone | Code | Test / evidence | Status |
|----|---------------------|-----------|------|-----------------|--------|
| FR-01 | Authenticate users and enforce role-based access for seven roles. | M2a |  |  | - |
| FR-02 | Manage branches, users and roles. | M2a |  |  | - |
| FR-03 | Maintain a product master with active ingredients and ATC class for... | M2a |  |  | - |
| FR-04 | Record each received batch with batch number and expiry date, per b... | M2a |  |  | - |
| FR-05 | Allocate stock first-expiry-first-out (FEFO) when a sale is completed. | M2a |  |  | - |
| FR-06 | Record patients with allergies, chronic conditions and current medi... | M3 |  |  | - |
| FR-07 | Process prescription and OTC sales in one flow; link Rx sales to a ... | M2a |  |  | - |
| FR-08 | Issue receipts; process returns and voids with manager approval. | M2b |  |  | - |
| FR-09 | Manage suppliers, price lists, purchase orders and goods-received n... | M2b |  |  | - |
| FR-10 | Run full and cycle stocktakes, flag variances and post approved adj... | M2b |  |  | - |
| FR-11 | Raise low-stock and near-expiry alerts per branch. | M2b |  |  | - |
| FR-12 | Screen every basket before completion against pair, allergy and con... | M3 |  |  | - |
| FR-13 | Grade every alert S1–S4 and show mechanism, rationale and managem... | M3 |  |  | - |
| FR-14 | Interrupt the dispenser for S1 and S2; show S3 and S4 as passive no... | M3 |  |  | - |
| FR-15 | Require a reason code and authentication to override S1 or S2; log ... | M3 |  |  | - |
| FR-16 | Maintain the interaction knowledge base: add, edit and retire rules... | M3 |  |  | - |
| FR-17 | Keep screening available offline from a cached rule set and reconci... | M6 |  |  | - |
| FR-18 | Report alert and override statistics by severity, branch and user. | M3 |  |  | - |
| FR-19 | Build a weekly feature table per product and branch from sales, sto... | M4 |  |  | - |
| FR-20 | Train and evaluate models with time-ordered validation against base... | M4 |  |  | - |
| FR-21 | Produce weekly forecasts with a median and an upper quantile for ea... | M4 |  |  | - |
| FR-22 | Explain forecasts through feature importance. | M4 |  |  | - |
| FR-23 | Run forecasting on a schedule; fall back to a baseline when the mod... | M4 |  |  | - |
| FR-24 | Import external signals (outbreak flags, rainfall) by file upload o... | M4 |  |  | - |
| FR-25 | Compute safety stock, reorder point and a suggested order quantity ... | M5 |  |  | - |
| FR-26 | Score and rank suppliers on fill rate, on-time delivery and price. | M5 |  |  | - |
| FR-27 | Recommend inter-branch transfers with a score and the reasons behin... | M5 |  |  | - |
| FR-28 | Support the transfer workflow: request, approve, dispatch, receive ... | M2b |  |  | - |
| FR-29 | Provide real-time dashboards (sales, stock health, expiry exposure,... | M5 |  |  | - |
| FR-30 | Generate scheduled smart reports with a plain-language summary of c... | M5 |  |  | - |
| FR-31 | Allow drill-down from a dashboard indicator to the underlying trans... | M5 |  |  | - |
| FR-32 | Keep an audit trail of changes to critical records, viewable by the... | M2b |  |  | - |
| FR-33 | Read linear barcodes and GS1 DataMatrix codes with a camera or scan... | M7 |  |  | - |
| FR-34 | Capture a prescription image by camera or upload and produce draft ... | M7 |  |  | - |
| FR-35 | Add scanned lines to the basket only after a pharmacist confirms ea... | M7 |  |  | - |

## Non-functional requirements

| ID | Requirement (short) | Milestone | Code / config | Test / evidence | Status |
|----|---------------------|-----------|---------------|-----------------|--------|
| NFR-01 | Performance: Interaction screening returns in 1 second or less at t... | M3 |  |  | - |
| NFR-02 | Performance: A completed sale is visible in dashboard KPIs within 5... | M5 |  |  | - |
| NFR-03 | Capacity: Supports at least 10 branches, 50 concurrent users, 5,000... | M8 |  |  | - |
| NFR-04 | Availability: Server availability of at least 99% a month; point of... | M6 |  |  | - |
| NFR-05 | Offline tolerance: Dispensing with interaction screening works for ... | M6 |  |  | - |
| NFR-06 | Security: TLS 1.2 or higher; passwords stored with a salted slow ha... | M8 |  |  | - |
| NFR-07 | Privacy and compliance: Data minimisation; consent flag; national I... | M1 |  |  | - |
| NFR-08 | Integrity and audit: Audit and override tables are append-only for ... | M1 |  |  | - |
| NFR-09 | Usability: System Usability Scale score of at least 70; a new dispe... | M8 |  |  | - |
| NFR-10 | Explainability: Every alert, forecast and recommendation displays i... | M5 |  |  | - |
| NFR-11 | Maintainability: Modular services with at least 70% unit-test cover... | M8 |  |  | - |
| NFR-12 | Portability: Runs in containers on Ubuntu LTS; supported on current... | M0 |  |  | - |
| NFR-13 | Backup and recovery: Encrypted nightly off-site backup; recovery po... | M8 |  |  | - |
| NFR-14 | Localisation: Prices and reports in USD and local currency; local f... | M5 |  |  | - |
| NFR-15 | Image privacy: Prescription images are processed on the pharmacy’... | M7 |  |  | - |
