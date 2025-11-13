-- behaviour of known fraudsters
WITH fraud_profile AS (
    SELECT
        AVG(transaction_count)               AS avg_txn_count,
        AVG(avg_amount_usd)                  AS avg_txn_value,
        AVG(distinct_merchant_categories)    AS avg_merchants,
        AVG(cross_country_txns)              AS avg_cross_country,
        AVG(days_active)                     AS avg_days_active
    FROM user_txn_summary s
    JOIN fraudsters f ON s.user_id = f.user_id
),

-- Scoring all non-fraud users against that profile
scored_users AS (
    SELECT
        s.user_id,
        s.transaction_count,
        s.total_amount_usd,
        s.avg_amount_usd,
        s.distinct_merchant_categories,
        s.cross_country_txns,
        s.days_active,
        s.failed_sign_in_attempts,

-- Each CASE adds 1 point when the user behaves more like a fraudster
        (
            (CASE WHEN s.transaction_count            > fp.avg_txn_count       THEN 1 ELSE 0 END) +
            (CASE WHEN s.avg_amount_usd               > fp.avg_txn_value       THEN 1 ELSE 0 END) +
            (CASE WHEN s.distinct_merchant_categories > fp.avg_merchants       THEN 1 ELSE 0 END) +
            (CASE WHEN s.cross_country_txns           > fp.avg_cross_country   THEN 1 ELSE 0 END) +
            (CASE WHEN s.days_active                  < fp.avg_days_active/2   THEN 1 ELSE 0 END)
        ) AS suspicion_score -- Our suscpicion score model

    FROM user_txn_summary s, fraud_profile fp
    WHERE s.user_id NOT IN (SELECT user_id FROM fraudsters)
)

-- Show the top suspicious users
SELECT
    user_id,
    suspicion_score,
    transaction_count,
    total_amount_usd,
    avg_amount_usd,
    distinct_merchant_categories,
    cross_country_txns,
    days_active,
    failed_sign_in_attempts
FROM scored_users
ORDER BY suspicion_score DESC, total_amount_usd DESC
LIMIT 5;
