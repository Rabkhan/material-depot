
/*To Handle multiple duplicates user_id*/

DROP TABLE IF EXISTS ecom_data_staging;

-- Creating staging table
CREATE TABLE ecom_data_staging (
    user_id BIGINT,
    "Attribute-1" TEXT,
    "Attribute-2" TEXT,
    "Attribute-3" TEXT,
    "Attribute-4" TEXT,
    "Attribute-5" TEXT,
    week1gmv INTEGER DEFAULT 0,
    week2gmv INTEGER DEFAULT 0,
    week3gmv INTEGER DEFAULT 0,
    week4gmv INTEGER DEFAULT 0,
    week5gmv INTEGER DEFAULT 0,
    week6gmv INTEGER DEFAULT 0,
    week7gmv INTEGER DEFAULT 0,
    week8gmv INTEGER DEFAULT 0,
    week9gmv INTEGER DEFAULT 0,
    week10gmv INTEGER DEFAULT 0,
    week11gmv INTEGER DEFAULT 0,
    week12gmv INTEGER DEFAULT 0
);

-- importing data into staging 
copy ecom_data_staging FROM '/Users/rabkhan/Desktop/Projects/assignment/ecom_data.csv' DELIMITER ',' CSV HEADER;

-- creating ecom table for data to be moved and used here 
DROP TABLE IF EXISTS ecom_data;

CREATE TABLE ecom_data (
    user_id BIGINT PRIMARY KEY,
    "Attribute-1" TEXT,
    "Attribute-2" TEXT,
    "Attribute-3" TEXT,
    "Attribute-4" TEXT,
    "Attribute-5" TEXT,
    week1gmv INTEGER NOT NULL DEFAULT 0,
    week2gmv INTEGER NOT NULL DEFAULT 0,
    week3gmv INTEGER NOT NULL DEFAULT 0,
    week4gmv INTEGER NOT NULL DEFAULT 0,
    week5gmv INTEGER NOT NULL DEFAULT 0,
    week6gmv INTEGER NOT NULL DEFAULT 0,
    week7gmv INTEGER NOT NULL DEFAULT 0,
    week8gmv INTEGER NOT NULL DEFAULT 0,
    week9gmv INTEGER NOT NULL DEFAULT 0,
    week10gmv INTEGER NOT NULL DEFAULT 0,
    week11gmv INTEGER NOT NULL DEFAULT 0,
    week12gmv INTEGER NOT NULL DEFAULT 0
);

/*consolidating duplicates for attribute columns by taking 
the first non-null/non-zero value, and summing the numeric columns.
*/

INSERT INTO ecom_data
SELECT
    user_id,
    -- For text columns, take the first non-null/non-empty value using MIN or MAX
    COALESCE(MAX(NULLIF("Attribute-1", '0')), '') AS "Attribute-1",
    COALESCE(MAX(NULLIF("Attribute-2", '0')), '') AS "Attribute-2",
    COALESCE(MAX(NULLIF("Attribute-3", '0')), '') AS "Attribute-3",
    COALESCE(MAX(NULLIF("Attribute-4", '0')), '') AS "Attribute-4",
    COALESCE(MAX(NULLIF("Attribute-5", '0')), '') AS "Attribute-5",
    -- Sum numeric columns (replace NULL with 0 to avoid null sums)
    COALESCE(SUM(week1gmv), 0) AS week1gmv,
    COALESCE(SUM(week2gmv), 0) AS week2gmv,
    COALESCE(SUM(week3gmv), 0) AS week3gmv,
    COALESCE(SUM(week4gmv), 0) AS week4gmv,
    COALESCE(SUM(week5gmv), 0) AS week5gmv,
    COALESCE(SUM(week6gmv), 0) AS week6gmv,
    COALESCE(SUM(week7gmv), 0) AS week7gmv,
    COALESCE(SUM(week8gmv), 0) AS week8gmv,
    COALESCE(SUM(week9gmv), 0) AS week9gmv,
    COALESCE(SUM(week10gmv), 0) AS week10gmv,
    COALESCE(SUM(week11gmv), 0) AS week11gmv,
    COALESCE(SUM(week12gmv), 0) AS week12gmv
FROM ecom_data_staging
GROUP BY user_id;

-- Testing data
SELECT * from ecom_data limit 10;
