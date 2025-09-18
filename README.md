# Healthcare Mini Analytics (AWS) 

**Stack:** Amazon S3 → AWS Glue (Crawler/ETL) → Amazon Athena (SQL & Views) → Amazon QuickSight (SPICE)

## What this shows
- **30-day readmission** by diagnosis category
- **Billed vs Paid** by payer (reimbursement view)
- **Top diagnoses** by billed amount


---

## Why this project
A small, explainable, end-to-end analytics slice you can build and share in a day:
- **Serverless** (no clusters to manage)
- **SQL-first** modeling (Athena views)
- **Shareable dashboard** (QuickSight)

---

## Architecture


---

## Reproduce (high-level)
1. **S3:** Upload parquet files to `s3://<yesh-healthcare1>/processed/...`
2. **Glue:** Crawler → create database `yesh-healthcare1`, tables:
   - `dim_patients`, `dim_providers`, `fct_claims`, `fct_encounters`
3. **Athena:** Workgroup `primary`
   - Run the view DDLs in [`sql/01_views.sql`](sql/01_views.sql)
   - Sanity checks:
     ```sql
     SHOW TABLES IN "yesh-healthcare1";
     SELECT * FROM "yesh-healthcare1"."fct_encounters" LIMIT 5;
     ```
4. **QuickSight:**
   - *Manage → Security & permissions:* enable **Athena**; allow your **S3** bucket(s)
   - *Datasets → New dataset → Athena:*
     - Catalog: `AwsDataCatalog`
     - Database: `yesh-healthcare1`
     - Use the views **or** paste the SELECTs from [`sql/02_quicksight_queries.sql`](sql/02_quicksight_queries.sql) (Use custom SQL)
   - Build visuals (bar/donut/KPIs), optional **Import to SPICE**, then **Share → Publish dashboard**.

> If Lake Formation is enabled, grant `AWSServiceRoleForAmazonQuickSight` **SELECT** on DB/tables.

---

## Files
- `sql/01_views.sql` — Athena `CREATE VIEW` statements
- `sql/02_quicksight_queries.sql` — the exact SELECTs used for QuickSight custom SQL
- `img/*.png` — dashboard screenshots (add `img/qs_overview.png`)
- `quicksight/dashboard.pdf` — (optional) exported PDF
- `glue/healthcare1-etl.py` — (optional) Glue job script you used

---

## Notes & tips
- Format **percentages** and **currency** in QuickSight for clean visuals.
- For datasets with hyphens in the DB name, fully qualify and **quote** names, e.g.:
  ```sql
  SELECT * FROM "yesh-healthcare1"."v_readmission_rates";

