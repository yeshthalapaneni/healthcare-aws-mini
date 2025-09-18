-- These are the exact SELECTs you can paste into QuickSight's "Use custom SQL"
-- Note the quoted database name because it has a hyphen.

-- Dataset 1: Readmission by diagnosis (prefer the view; fallback uses base table)
-- View version:
SELECT diagnosis_category, readmit_rate_pct, encounters
FROM "yesh-healthcare1"."v_readmission_rates";

-- Fallback (if the view isn't available in QS for some reason):
-- SELECT
--   diagnosis_category,
--   ROUND(AVG(CAST(readmission_30d AS DOUBLE)) * 100, 2) AS readmit_rate_pct,
--   COUNT(*) AS encounters
-- FROM "yesh-healthcare1"."fct_encounters"
-- GROUP BY diagnosis_category;


-- Dataset 2: Claims billed vs paid by payer
SELECT
  COALESCE(payer,'Unknown') AS payer,
  COUNT(*) AS claims,
  ROUND(SUM(COALESCE(billed_amount,0)), 2) AS total_billed,
  ROUND(SUM(COALESCE(paid_amount,0)), 2) AS total_paid
FROM "yesh-healthcare1"."fct_claims"
GROUP BY payer;


-- Dataset 3: Top 10 diagnoses by billed amount
SELECT
  e.diagnosis_desc,
  ROUND(SUM(c.billed_amount), 2) AS total_billed,
  ROUND(SUM(c.paid_amount), 2) AS total_paid
FROM "yesh-healthcare1"."fct_encounters" e
JOIN "yesh-healthcare1"."fct_claims" c
  ON c.encounter_id = e.encounter_id
GROUP BY e.diagnosis_desc
ORDER BY total_billed DESC
LIMIT 10;

