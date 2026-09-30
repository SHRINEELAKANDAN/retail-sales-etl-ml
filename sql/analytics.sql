SELECT
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_spend), 2) AS avg_total_spend,
    ROUND(AVG(total_orders), 2) AS avg_total_orders,
    ROUND(AVG(avg_sales_line), 2) AS avg_line_value,
    ROUND(AVG(unique_products), 2) AS avg_unique_products,
    ROUND(AVG(recency_days), 2) AS avg_recency_days
FROM RETAIL_DB.ANALYTICS.CUSTOMER_SEGMENTATION
GROUP BY customer_segment
ORDER BY avg_total_spend DESC;





SELECT
    customer_segment,
    COUNT(*) AS customers
FROM RETAIL_DB.ANALYTICS.CUSTOMER_SEGMENTATION
GROUP BY customer_segment
ORDER BY customer_segment;

-- Monthly Revenue trend Analysis
SELECT 
    DATE_TRUNC('MONTH', invoice_date) AS sales_month,
    ROUND(SUM(sales_amount), 2) AS total_revenue,
    COUNT(DISTINCT invoice_no) AS total_orders,
    COUNT(DISTINCT customer_id) AS active_customers
FROM FACT_SALES
GROUP BY DATE_TRUNC('MONTH', invoice_date)
ORDER BY sales_month;

-- Top 10 Products by Revenue
SELECT
    stock_code,
    description,
    ROUND(SUM(sales_amount), 2) AS total_revenue,
    SUM(quantity) AS total_quantity_sold,
    COUNT(DISTINCT invoice_no) AS total_orders
FROM FACT_SALES
WHERE description IS NOT NULL
GROUP BY stock_code, description
ORDER BY total_revenue DESC
LIMIT 10;

-- Top countries by Revenue
SELECT
    country,
    ROUND(SUM(sales_amount), 2) AS total_revenue,
    COUNT(DISTINCT customer_id) AS unique_customers,
    COUNT(DISTINCT invoice_no) AS total_orders
FROM FACT_SALES
WHERE country IS NOT NULL
GROUP BY country
ORDER BY total_revenue DESC;

-- Coustomer segment distribution
SELECT 
    COUNT(*) AS customer_count,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(),
        2
    ) AS customer_percentage
FROM CUSTOMER_SEGMENTATION
GROUP BY customer_segment
ORDER BY customer_count;

-- Data quality row count check
SELECT
    'RAW_SALES' AS table_name,
     COUNT(*) AS row_count
FROM RETAIL_DB.RAW.SALES_RAW

UNION ALL

SELECT
    'FACT_SALES' AS table_name,
     COUNT(*) AS row_count
FROM RETAIL_DB.ANALYTICS.FACT_SALES;


--Optional data quality metrics check

SELECT
    COUNT(*) AS total_rows,
    COUNT_IF(customer_id IS NULL) AS missing_customer_id,
    COUNT_IF(quantity <= 0) AS invalid_quantity,
    COUNT_IF(unit_price <= 0) AS invalid_unit_price,
    COUNT_IF(sales_amount <= 0) AS invalid_sales_amount
FROM RETAIL_DB.RAW.SALES_RAW;
