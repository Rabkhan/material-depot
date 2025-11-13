/*
Problem 2: Write a query to identify users whose first transaction was a successful card payment over $10USD equivalent
*/

WITH RankedTransactions AS (
    -- Getting all transactions for every user.
   
    SELECT
        t.user_id,
        t.state,
        t.type,
        t.amount,
        t.currency,
        t.created_date,
        ROW_NUMBER() OVER(PARTITION BY t.user_id ORDER BY t.created_date ASC) as transaction_number
    FROM
        transactions t
    -- WHERE t.state = 'COMPLETED' AND t.type= 'CARD_PAYMENT'
)

SELECT DISTINCT rt.user_id, 
    rt.amount, 
    rt.state, 
    rt.state,
    rt.created_date, transaction_number

FROM RankedTransactions rt

-- currency's decimal exponent
JOIN currency_details cd ON rt.currency = cd.currency

--  Getting the exchange rate, specifically to USD
JOIN fx_rates fx ON rt.currency = fx.ccy AND fx.base_ccy = 'USD'

WHERE rt.transaction_number = 1 
    AND rt.state = 'COMPLETED' 
    AND rt.type = 'CARD_PAYMENT'
    AND (rt.amount / POWER(10, cd.exponent) / fx.rate) > 10;









/**

Below query has problem with conversion rate calc.

WITH user_first_txn AS (
    SELECT
        t.user_id,
        MIN(t.created_date) AS first_txn_date
    FROM transactions t
    GROUP BY t.user_id
)
SELECT
    t.user_id,
    t.id AS transaction_id,
    t.created_date,
    t.currency,
    t.amount,
    ROUND((t.amount / f.rate)::numeric, 2) AS amount_usd
FROM transactions t
JOIN user_first_txn uft 
    ON t.user_id = uft.user_id 
   AND t.created_date = uft.first_txn_date
JOIN fx_rates f 
    ON t.currency = f.ccy
WHERE 
    f.base_ccy = 'USD'
    AND UPPER(t.type) = 'CARD_PAYMENT'
    AND UPPER(t.state) = 'COMPLETED'
    AND (t.amount / f.rate) > 10
ORDER BY amount_usd DESC;



+++++++

WITH user_first_txn AS (
    SELECT
        t.user_id,
        MIN(t.created_date) AS first_txn_date
    FROM transactions t
    GROUP BY t.user_id
)
SELECT
    t.user_id,
    t.id AS transaction_id,
    t.created_date,
    t.currency,
    t.amount,
    (t.amount / f.rate) AS amount_usd
FROM transactions t
JOIN user_first_txn uft 
    ON t.user_id = uft.user_id 
   AND t.created_date = uft.first_txn_date
JOIN fx_rates f 
    ON t.currency = f.ccy
WHERE 
    f.base_ccy = 'USD'
    AND t.type = 'CARD_PAYMENT'
    AND t.state = 'COMPLETED'
    AND (t.amount / f.rate) >10;

*/

