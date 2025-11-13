WITH processed_users AS (
    SELECT 
        LEFT(u.phone_country, 2) AS short_phone_country,
        u.id
    FROM users u
)
SELECT 
    t.user_id,
    t.merchant_country,
    SUM(t.amount / fx.rate / POWER(10, cd.exponent)) AS amount
FROM transactions t
JOIN fx_rates fx
    ON fx.ccy = t.currency
   AND fx.base_ccy = 'EUR'
JOIN currency_details cd
    ON cd.currency = t.currency
JOIN processed_users pu
    ON pu.id = t.user_id
WHERE 
    t.source = 'GAIA'
    AND pu.short_phone_country = t.merchant_country
GROUP BY 
    t.user_id,
    t.merchant_country
ORDER BY 
    amount DESC;
