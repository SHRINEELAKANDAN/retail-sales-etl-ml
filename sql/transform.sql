CREATE OR REPLACE SCHEMA RETAIL_DB.ANALYTICS;

CREATE OR REPLACE TABLE RETAIL_DB.ANALYTICS.FACT_SALES AS
SELECT
    invoice_no,
    stock_code,
    description,
    quantity,
    invoice_date,
    unit_price,
    customer_id,
    country,
    sales_amount,
    DATE_TRUNC('MONTH', invoice_date) AS sales_month,
    loaded_at
FROM RETAIL_DB.RAW.SALES_RAW
WHERE customer_id IS NOT NULL
AND quantity > 0
AND unit_price > 0;

--Customer-level ML features
CREATE OR REPLACE TABLE RETAIL_DB.ANALYTICS.CUSTOMER_FEATURES AS
SELECT
    customer_id,
    COUNT(DISTINCT invoice_no) AS total_orders,
    SUM(sales_amount) AS total_spend,
    AVG(sales_amount) AS avg_sales_line,
    COUNT(DISTINCT stock_code) AS unique_products,
    DATEDIFF('DAY', MAX(invoice_date), 
                    (SELECT MAX(invoice_date) FROM RETAIL_DB.ANALYTICS.FACT_SALES)
    ) AS recency_days
FROM RETAIL_DB.ANALYTICS.FACT_SALES
GROUP BY customer_id;