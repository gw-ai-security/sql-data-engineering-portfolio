-- 06 - RANKING ANALYSIS
-- Rank dimensions by aggregated measures to identify top and bottom performers.

USE DataWarehouse;
GO

-- Five products with the highest revenue.
SELECT TOP (5)
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC, p.product_name;

-- Five products with the lowest revenue.
SELECT TOP (5)
    p.product_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue ASC, p.product_name;

-- Five subcategories with the highest revenue.
SELECT TOP (5)
    p.subcategory,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
GROUP BY p.subcategory
ORDER BY total_revenue DESC, p.subcategory;

-- Top five products using a window-function ranking pattern.
SELECT
    product_name,
    total_revenue,
    rank_products
FROM (
    SELECT
        p.product_name,
        SUM(f.sales_amount) AS total_revenue,
        ROW_NUMBER() OVER (
            ORDER BY SUM(f.sales_amount) DESC, p.product_name
        ) AS rank_products
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON p.product_key = f.product_key
    GROUP BY p.product_name
) AS ranked_products
WHERE rank_products <= 5
ORDER BY rank_products;

-- Five subcategories with the lowest revenue.
SELECT TOP (5)
    p.subcategory,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
GROUP BY p.subcategory
ORDER BY total_revenue ASC, p.subcategory;

-- Ten customers who generated the highest revenue.
SELECT TOP (10)
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON c.customer_key = f.customer_key
GROUP BY
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_revenue DESC, c.customer_key;

-- Three customers with the fewest distinct orders.
SELECT TOP (3)
    c.customer_key,
    c.first_name,
    c.last_name,
    COUNT(DISTINCT f.order_number) AS total_orders
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON c.customer_key = f.customer_key
GROUP BY
    c.customer_key,
    c.first_name,
    c.last_name
ORDER BY total_orders ASC, c.customer_key;
