-- Database: "yesh-healthcare1"

CREATE OR REPLACE VIEW v_readmission_rates AS
SELECT
  diagnosis_category,
  ROUND(AVG(CAST(readmission_30d AS DOUBLE)) * 100, 2) AS readmit_rate_pct,
  COUNT(*) AS encounters
FROM fct_encounters
GROUP BY diagnosis_category;

CREATE OR REPLACE VIEW v_claims_by_payer AS
SELECT
  payer,
  COUNT(*) AS claims,
  ROUND(SUM(billed_amount), 2) AS total_billed,
  ROUND(SUM(paid_amount), 2) AS total_paid
FROM fct_claims
GROUP BY payer;

CREATE OR REPLACE VIEW v_top_cost_diag AS
SELECT
  e.diagnosis_code,
  e.diagnosis_desc,
  ROUND(SUM(c.billed_amount), 2) AS total_billed,
  ROUND(SUM(c.paid_amount), 2) AS total_paid
FROM fct_encounters e
JOIN fct_claims c ON c.encounter_id = e.encounter_id
GROUP BY e.diagnosis_code, e.diagnosis_desc
ORDER BY total_billed DESC
LIMIT 10;

