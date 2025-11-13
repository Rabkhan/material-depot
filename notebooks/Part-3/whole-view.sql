SELECT 
    t.id AS transaction_id,
    t.user_id,
    u.phone_country,
    u.country AS user_country_iso2,
    c.name AS user_country_name,
    c.code3 AS user_country_iso3,
    f.user_id IS NOT NULL AS is_fraudster,

    t.source,
    t.merchant_country,
    t.currency,
    cd.iso_code AS currency_iso_code,
    cd.exponent,
    cd.is_crypto,
    fx.rate AS fx_rate_to_eur,
    (t.amount / NULLIF(fx.rate,0) / POWER(10, cd.exponent)) AS eur_amount_estimate,
    
    t.amount,
    t.state,
    t.created_date,
    t.entry_method,
    t.type,
    t.merchant_category

FROM transactions t
LEFT JOIN users u 
    ON t.user_id = u.id
LEFT JOIN countries c 
    ON u.country = c.code    -- user country ISO2 → country table
LEFT JOIN fx_rates fx 
    ON fx.ccy = t.currency AND fx.base_ccy = 'EUR'
LEFT JOIN currency_details cd 
    ON cd.currency = t.currency
LEFT JOIN fraudsters f 
    ON f.user_id = t.user_id

--Optional filters e:
--WHERE t.source = 'GAIA'     
LIMIT 100;
