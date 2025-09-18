# Healthcare Mini Analytics on AWS

**Stack:** Amazon S3 → AWS Glue (Crawler/ETL) → Amazon Athena (SQL Views) → Amazon QuickSight (SPICE)  
**Deliverable:** Interactive QuickSight dashboard + PDF export: [`quicksight/dashboard.pdf`](quicksight/dashboard.pdf)

---

## Why I built this

I wanted a small, end-to-end healthcare analytics project that:
- runs entirely on **serverless** AWS services,
- keeps logic **in SQL views** for clarity and reuse,
- produces a **shareable BI artifact** in a single day.

This repo is the result: a thin but realistic slice that touches storage, catalog, transformation, modeling, and visualization.

---

## What I did (high level)

1. **Data landing in S3**
   - Uploaded curated Parquet datasets to `s3://<bucket>/processed/` with four folders:
     - `dim_patients/`, `dim_providers/`, `fct_encounters/`, `fct_claims/`.

2. **Cataloging with AWS Glue**
   - Created Glue Database: `yesh-healthcare1`.
   - Ran a **Glue Crawler** on `s3://<bucket>/processed/` to register tables and schemas in the Data Catalog.

3. **Modeling in Athena**
   - Pointed Athena to the Glue DB.
   - Created business-ready **views** (see `sql/01_views.sql`):
     - `v_readmission_rates` — 30-day readmission % by diagnosis category.
     - `v_claims_by_payer` — claim counts and billed vs paid by payer.
     - `v_top_cost_diag` — top diagnoses by total billed amount.

4. **Visualization in QuickSight**
   - Connected QuickSight to **Athena** and granted access to my S3 bucket.
   - Imported the three queries into **SPICE** for speed (SQL also in `sql/02_quicksight_queries.sql`).
   - Built visuals for:
     - readmission by diagnosis category,
     - billed vs paid by payer,
     - top 10 diagnoses by billed amount,
     - (optional) payer mix donut.
   - Exported the dashboard to PDF → committed as [`quicksight/dashboard.pdf`](quicksight/dashboard.pdf).

---

## Data engineering work I did

- **File layout & formats**
  - Organized partition-friendly folders under `/processed/` and used **Parquet** for columnar reads.

- **Metadata management**
  - Used **Glue Crawler** to infer schemas and publish to **AWS Glue Data Catalog**.

- **Transform & model**
  - Kept business rules in **Athena views** (instead of burying them in the BI tool).
  - Applied `COALESCE`, safe casting, and aggregation (~“semantic layer” in SQL).

- **Access & governance**
  - Dealt with **Lake Formation** and **IAM** so Athena/QuickSight could read the data.
  - Verified least-privilege by granting QuickSight service role read access only to the necessary DB/tables/buckets.

- **Performance & cost**
  - Used **SPICE** to cache query results for snappy dashboards and lower Athena query costs.
  - Verified Parquet + pruning reduces scanned bytes.

---

## What I learned (engineering)

- **Serverless ≠ shapeless**: a tiny but well-defined layout (`processed/` + crawler + views) keeps everything discoverable.
- **Views simplify BI**: once the metrics lived in views, building charts was “drag-and-drop” instead of rewriting logic.
- **Governance matters**: most friction was IAM/Lake Formation; understanding service roles avoided dead-ends.
- **SPICE is worth it**: import → instant interactivity without babysitting engines.
- **Parquet pays off**: smaller scans, faster Athena, cheaper per query.

---

## What I learned (healthcare)

- **Readmission** is a quality + cost metric; high 30-day rates around certain diagnoses flag care transition gaps.
- **Payer mix** (Private/Medicare/Medicaid/Self-Pay) directly shapes cash flow and denial management priorities.
- **Billed vs Paid** highlights contract health; big deltas suggest rate issues, coding problems, or denial patterns.

---

## Medical terms I used (clear definitions)

- **Encounter**: a patient visit/stay where care is delivered (ED, inpatient, clinic).  
- **Primary Diagnosis**: the main condition treated during the encounter.  
- **Readmission (30-day)**: an unplanned inpatient return within 30 days of discharge.  
- **Claim**: a bill submitted for reimbursement for services provided.  
- **Payer**: the entity paying the claim (Private insurer, Medicare, Medicaid, or Self-Pay/patient).  
- **Billed Amount** vs **Paid Amount**: requested charge vs actual reimbursement.

---

## Key queries I used

- **Readmission by diagnosis category** → `v_readmission_rates`
- **Claims by payer (billed vs paid)** → `v_claims_by_payer`
- **Top diagnoses by billed** → `v_top_cost_diag`

> Full DDL/SQL: [`sql/01_views.sql`](sql/01_views.sql) and [`sql/02_quicksight_queries.sql`](sql/02_quicksight_queries.sql)

---

## Repro steps (short)

1. Put Parquet here: `s3://<your-bucket>/processed/{dim_patients,dim_providers,fct_claims,fct_encounters}`  
2. Glue → Crawler → Database `yesh-healthcare1` → confirm 4 tables.  
3. Athena → DB `yesh-healthcare1` → run `sql/01_views.sql`.  
4. QuickSight → grant **Athena** + S3 access → New dataset (Athena) → import queries to **SPICE** → build visuals.  
5. Export PDF if needed → place in `quicksight/dashboard.pdf`.

---

## Limitations & next steps

- Dataset is demo-scale and de-identified; production would add **risk adjustment**, **planned vs unplanned** logic, denial reasons, and contract modeling.
- Next steps:
  - Claims **denials** view (categories, overturn rates).
  - **Cohort** analytics (e.g., COPD/CHF) with LOS, ED revisits, readmission.
  - **Glue Workflow** for scheduled refresh + CI/CD for SQL.

---

## Repo layout

