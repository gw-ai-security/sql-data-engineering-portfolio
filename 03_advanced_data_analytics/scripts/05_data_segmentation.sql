-- 05 - DATA SEGMENTATION
-- Group products and customers into analytically meaningful rule-based segments.

USE DataWarehouse;
GO

-- Segment current products into cost ranges.
WITH product_segments AS (
    SELECT
        product_key,
        product_name,
        cost,
        CASE
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM gold.dim_products
)
SELECT
    cost_range,
    COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC;

/*
Customer segmentation rules:
- VIP: at least 12 months of purchase history and more than 5,000 total sales.
- Regular: at least 12 months of purchase history and 5,000 or less total sales.
- New: less than 12 months of purchase history.
*/
WITH customer_spending AS (
    SELECT
        customer_key,
        SUM(sales_amount) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY customer_key
),
segmented_customers AS (
    SELECT
        customer_key,
        CASE
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
            ELSE 'New'
        END AS customer_segment
    FROM customer_spending
)
SELECT
    customer_segment,
    COUNT(customer_key) AS total_customers
FROM segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;
