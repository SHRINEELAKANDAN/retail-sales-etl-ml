SELECT
    customer_segment,
    COUNT(*) AS customers,
    ROUND(AVG(total_spend), 2) AS avg_total_spend,
    ROUND(AVG(total_orders), 2) AS avg_total_orders,
    ROUND(AVG(recency_days), 2) AS avg_recency_days,
FROM RETAIL_DB.ANALYTICS.CUSTOMER_SEGMENTATION
GROUP BY customer_segment
ORDER BY customer_segment;