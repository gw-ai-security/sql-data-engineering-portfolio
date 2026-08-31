-- 07 - PRODUCT REPORT
-- Create a reusable sold-product analytical view with segmentation and KPIs.

USE DataWarehouse;
GO

CREATE OR ALTER VIEW gold.report_products AS
WITH base_query AS (
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),
product_aggregation AS (
    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,
        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        MIN(order_date) AS first_sale_date,
        MAX(order_date) AS last_sale_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,
        ROUND(
            CAST(SUM(sales_amount) AS DECIMAL(18, 2))
            / NULLIF(SUM(quantity), 0),
            2
        ) AS avg_selling_price
    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,
    last_sale_date,
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    lifespan,
    avg_selling_price,
    CAST(total_sales AS DECIMAL(18, 2)) / NULLIF(total_orders, 0) AS avg_order_revenue,
    CASE
        WHEN lifespan = 0 THEN CAST(total_sales AS DECIMAL(18, 2))
        ELSE CAST(total_sales AS DECIMAL(18, 2)) / lifespan
    END AS avg_monthly_revenue
FROM product_aggregation;
GO

-- Verification example:
-- SELECT TOP (100) * FROM gold.report_products ORDER BY total_sales DESC;
