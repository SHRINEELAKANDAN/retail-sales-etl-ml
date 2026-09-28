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