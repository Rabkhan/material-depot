-- Define the timestamp we want to check
WITH target_time AS (
    SELECT TIMESTAMP '2025-11-11 14:00:00' AS check_time
),

-- Pair 'In' and 'Out' logs
in_out AS (
    SELECT 
        employee_id,
        action,
        created_at,
        ROW_NUMBER() OVER (PARTITION BY employee_id, action ORDER BY created_at) AS rn
    FROM employee_movement
),

paired AS (
    SELECT 
        i.employee_id,
        i.created_at AS in_time,
        o.created_at AS out_time
    FROM in_out i
    JOIN in_out o 
        ON i.employee_id = o.employee_id 
       AND i.rn = o.rn 
       AND i.action = 'In' 
       AND o.action = 'Out'
)


-- Count employees who were inside at the check_time
SELECT 
    COUNT(DISTINCT p.employee_id) AS employees_inside
FROM 
    paired p, 
    target_time t
WHERE 
    t.check_time >= p.in_time AND t.check_time < p.out_time;