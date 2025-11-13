-- PostgreSQL schema example --
/*
CREATE TABLE IF NOT EXISTS transactions (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    currency CHAR(3) NOT NULL,
    amount BIGINT NOT NULL,
    state VARCHAR(25) NOT NULL,
    created_date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    merchant_category VARCHAR(100),
    merchant_country VARCHAR(3),
    entry_method VARCHAR(4) NOT NULL,
    type VARCHAR(20) NOT NULL,
    source VARCHAR(20) NOT NULL
);
*/
DROP TABLE IF EXISTS transactions;

CREATE TABLE IF NOT EXISTS  transactions ( Sr INTEGER, 
    currency VARCHAR(3),
    amount BIGINT,
    state VARCHAR(25),
    created_date TIMESTAMP WITHOUT TIME ZONE,
    merchant_category VARCHAR(100),
    merchant_country VARCHAR(3),
    entry_method VARCHAR(10),
    user_id UUID,
    type VARCHAR(20),
    source VARCHAR(20),
    id UUID PRIMARY KEY
);
ALTER TABLE transactions ALTER COLUMN merchant_country TYPE VARCHAR(100);



/*
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    has_email BOOLEAN NOT NULL,
    phone_country VARCHAR(300),
    terms_version DATE,
    created_date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    state VARCHAR(25) NOT NULL,
    country CHAR(2),
    birth_year INTEGER,
    kyc VARCHAR(20),
    failed_sign_in_attempts INTEGER
);
*/

DROP TABLE IF EXISTS users
CREATE TABLE IF NOT EXISTS users (
    sr INTEGER,
    failed_sign_in_attempts INTEGER NOT NULL,
    kyc VARCHAR(20) NOT NULL,
    birth_year INTEGER,
    country CHAR(2) NOT NULL,
    state VARCHAR(25) NOT NULL,
    created_date TIMESTAMP WITHOUT TIME ZONE NOT NULL,
    terms_version DATE,
    phone_country VARCHAR(300),
    has_email BOOLEAN NOT NULL,
    id UUID UNIQUE NOT NULL
);


CREATE TABLE IF NOT EXISTS fx_rates (
    base_ccy VARCHAR(3),
    ccy VARCHAR(10),
    rate DOUBLE PRECISION
);


DROP TABLE IF EXISTS currency_details
CREATE TABLE IF NOT EXISTS currency_details (
    currency VARCHAR(10) PRIMARY KEY,
    iso_code INTEGER,
    exponent INTEGER,
    is_crypto BOOLEAN NOT NULL
);


CREATE TABLE IF NOT EXISTS countries (
    code VARCHAR(2) PRIMARY KEY,
    name TEXT NOT NULL,
    code3 VARCHAR(3) NOT NULL,
    numcode INTEGER,
    phonecode INTEGER
);
ALTER TABLE countries ALTER COLUMN code3 DROP NOT NULL;


CREATE TABLE IF NOT EXISTS fraudsters (
    user_id UUID PRIMARY KEY
);
