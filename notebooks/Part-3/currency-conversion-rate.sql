-- 1) Quick counts: how many rows and how many distinct base_ccy values
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT base_ccy) AS distinct_base_ccy
FROM fx_rates;

-- 2) How many rows per base_ccy (to see if USD is the only base)
SELECT base_ccy, COUNT(*) AS cnt
FROM fx_rates
GROUP BY base_ccy
ORDER BY cnt DESC;

-- 3) List any problematic rows (NULL or zero rate)
SELECT *
FROM fx_rates
WHERE rate IS NULL OR rate = 0
ORDER BY ccy;

-- 4) Full fx_rates table (ordered)
SELECT base_ccy, ccy, rate
FROM fx_rates
ORDER BY base_ccy, ccy;

-- 5) Conversion diagnostics: for each currency show both interpretations using 100 units
--    - usd_via_div  = 100 / rate  (use this if rate = currency per 1 USD -> 1 USD = rate * ccy)
--    - usd_via_mul  = 100 * rate  (use this if rate = USD per 1 currency -> 1 ccy = rate * USD)
SELECT
  base_ccy,
  ccy,
  rate,
  -- inverse of rate (helpful to inspect)
  ROUND((1.0 / NULLIF(rate,0))::numeric, 8) AS inv_rate,
  -- USD equivalent of 100 units assuming USD = X / rate
  ROUND((100.0 / NULLIF(rate,0))::numeric, 6) AS usd_if_div,
  -- USD equivalent of 100 units assuming USD = X * rate
  ROUND((100.0 * rate)::numeric, 6) AS usd_if_mul
FROM fx_rates
ORDER BY ccy;

-- 6) Focused check for common currency suspects (EUR, INR, GBP, JPY, BTC)
SELECT
  base_ccy, ccy, rate,
  ROUND((100.0 / NULLIF(rate,0))::numeric, 6) AS usd_if_div,
  ROUND((100.0 * rate)::numeric, 6) AS usd_if_mul
FROM fx_rates
WHERE upper(ccy) IN ('EUR','INR','GBP','JPY','BTC','ETH')
ORDER BY ccy;

-- 7) Example: show a few transaction rows with their currency and amount (so you can manually cross-check)
SELECT id, user_id, currency, amount, created_date, type, state
FROM transactions
ORDER BY created_date DESC
LIMIT 20;
