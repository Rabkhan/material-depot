DROP TABLE IF EXISTS user_txn_summary;

CREATE TABLE user_txn_summary AS 
(
  SELECT
    t.user_id,
    -- how many transactions the user has in total
    COUNT(t.id) AS transaction_count,

    -- total USD equivalent of all their transactions
    ROUND(SUM(t.amount * fr.rate)::numeric, 2) AS total_amount_usd,

    -- average USD amount per transaction
    ROUND(AVG(t.amount * fr.rate)::numeric, 2) AS avg_amount_usd,

    -- share of their transactions done in crypto currencies
    ROUND(
      100.0 * SUM(CASE WHEN cd.is_crypto THEN 1 ELSE 0 END)::numeric 
      / NULLIF(COUNT(t.id), 0), 2
    ) AS pct_crypto,

    -- how many different merchant categories they have used
    COUNT(DISTINCT t.merchant_category) AS distinct_merchant_categories,

    -- how many of their transactions happened outside their own country
    SUM(
      CASE 
        WHEN t.merchant_country IS NOT NULL 
             AND u.country IS NOT NULL 
             AND t.merchant_country <> u.country 
        THEN 1 ELSE 0 
      END
    ) AS cross_country_txns,

    -- first and last transaction dates
    MIN(t.created_date) AS first_transaction_date,
    MAX(t.created_date) AS last_transaction_date,

    -- difference in days between first and last transaction (account activity span)
    (MAX(t.created_date)::date - MIN(t.created_date)::date) AS days_active,

    -- failed sign-in attempts taken from the users table
    u.failed_sign_in_attempts

  FROM transactions t
  JOIN users u 
       ON t.user_id = u.id
  JOIN fx_rates fr 
       ON t.currency = fr.ccy 
      AND fr.base_ccy = 'USD'
  LEFT JOIN currency_details cd 
       ON t.currency = cd.currency

  GROUP BY t.user_id, u.failed_sign_in_attempts
)

-- show the top 100 most active users just to inspect
/*
SELECT *
FROM user_txn_summary
ORDER BY transaction_count DESC
LIMIT 100;
*/
