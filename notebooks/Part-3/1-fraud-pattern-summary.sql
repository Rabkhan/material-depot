SELECT
  f.user_id,
  COALESCE(COUNT(t.id),0) AS transaction_count,

  ROUND(COALESCE(SUM((t.amount / POWER(10, cd.exponent) / fr.rate)::numeric), 0), 2) AS total_amount_usd,
  ROUND(COALESCE(AVG((t.amount / POWER(10, cd.exponent) / fr.rate)::numeric), 0), 2) AS avg_amount_usd,

  ROUND(100.0 * COALESCE(SUM(CASE WHEN cd.is_crypto THEN 1 ELSE 0 END),0) / NULLIF(COUNT(t.id),0),2) AS pct_crypto,
  COUNT(DISTINCT t.merchant_category) AS distinct_merchant_categories,

  SUM(CASE WHEN t.merchant_country IS NOT NULL AND u.country IS NOT NULL AND t.merchant_country <> u.country THEN 1 ELSE 0 END) AS cross_country_txns,
  
  MIN(t.created_date) AS first_transaction_date,
  MAX(t.created_date) AS last_transaction_date,
  
  -- Calculating total days between first and last transaction
  CASE WHEN MIN(t.created_date) IS NULL OR MAX(t.created_date) IS NULL THEN 0
       ELSE ROUND(EXTRACT(EPOCH FROM (MAX(t.created_date) - MIN(t.created_date))) / 86400)::int
  END AS days_active,
  u.failed_sign_in_attempts

FROM fraudsters f

LEFT JOIN transactions t ON f.user_id = t.user_id
LEFT JOIN users u ON f.user_id = u.id

LEFT JOIN currency_details cd ON t.currency = cd.currency
LEFT JOIN fx_rates fr ON t.currency = fr.ccy AND fr.base_ccy = 'USD'
GROUP BY f.user_id, u.failed_sign_in_attempts
ORDER BY transaction_count DESC;