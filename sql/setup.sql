CREATE OR REPLACE WAREHOUSE retail_wh
WAREHOUSE_SIZE = 'XSMALL'
AUTO_SUSPEND = 60
AUTO_RESUME = TRUE;

CREATE OR REPLACE DATABASE retail_db;

CREATE OR REPLACE SCHEMA raw;

USE WAREHOUSE retail_wh;
USE DATABASE retail_db;
USE SCHEMA raw;


CREATE OR REPLACE TABLE SALES_RAW (
    invoice_no VARCHAR,
    stock_code VARCHAR,
    description VARCHAR,
    quantity NUMBER,
    invoice_date TIMESTAMP,
    unit_price FLOAT,
    customer_id VARCHAR,
    country VARCHAR,
    sales_amount FLOAT,
    loaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP()
);

