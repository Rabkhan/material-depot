/*
I've created one sample table 'employee_movement'
CREATE TABLE employee_logs (
    employee_id VARCHAR(10),
    action VARCHAR(5),
    created_at TIMESTAMP
); 

And then used insert query for the data.

*/


-- Q1 - Find out how many people were inside the office at a given timestamp

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


/*

Q2 - For each employee, calculate the total time (in hours) they have spent inside the office so far

*/

WITH in_out AS 
(
    SELECT 
        employee_id,
        action,
        created_at,
        ROW_NUMBER() OVER (PARTITION BY employee_id, action ORDER BY created_at) AS rn
    FROM employee_movement
),

paired AS
(
SELECT 
    i.employee_id,
	i.action, o.action,
    i.created_at AS in_time,
    o.created_at AS out_time
FROM in_out i
JOIN in_out o 
    ON i.employee_id = o.employee_id 
   AND i.rn = o.rn 
   AND i.action = 'In' 
   AND o.action = 'Out'
ORDER BY i.employee_id, in_time
)

SELECT 
    employee_id,
    ROUND(SUM(
        EXTRACT(HOUR FROM (out_time - in_time))
        + EXTRACT(MINUTE FROM (out_time - in_time)) / 60.0
        + EXTRACT(SECOND FROM (out_time - in_time)) / 3600.0
    ), 2) AS total_hours
FROM paired
GROUP BY employee_id
ORDER BY employee_id;

/*
Q3 - Calculate the time spent by each employee between 2 given timestamps. Eg - {{start_timestamp}} to {{end_timestamp}}
*/

WITH in_out AS (
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

SELECT 
    employee_id,
    ROUND(SUM(
        CASE 
            WHEN out_time > TIMESTAMP '2025-11-11 09:00:00'
             AND in_time < TIMESTAMP '2025-11-11 17:00:00'
            THEN 
                EXTRACT(HOUR FROM (LEAST(out_time, TIMESTAMP '2025-11-11 17:00:00') - 
                                    GREATEST(in_time, TIMESTAMP '2025-11-11 09:00:00')))
              + EXTRACT(MINUTE FROM (LEAST(out_time, TIMESTAMP '2025-11-11 17:00:00') - 
                                      GREATEST(in_time, TIMESTAMP '2025-11-11 09:00:00'))) / 60.0
              + EXTRACT(SECOND FROM (LEAST(out_time, TIMESTAMP '2025-11-11 17:00:00') - 
                                      GREATEST(in_time, TIMESTAMP '2025-11-11 09:00:00'))) / 3600.0
            ELSE 0
        END
    ), 2) AS hours_in_window
FROM paired
GROUP BY employee_id
ORDER BY employee_id;
