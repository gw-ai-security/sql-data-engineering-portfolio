-- 05 - MAGNITUDE ANALYSIS
-- Compare aggregated measures across business dimensions.
-- Pattern: Aggregate [Measure] BY [Dimension].

USE DataWarehouse;
GO

-- Total customers by country.
SELECT
    country,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Total customers by gender.
SELECT
    gender,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Total current products by category.
SELECT
    category,
    COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category
ORDER BY total_products DESC;

-- Average product cost by category.
-- CAST preserves decimal precision when averaging integer costs.
SELECT
    category,
    AVG(CAST(cost AS DECIMAL(18, 2))) AS avg_cost
FROM gold.dim_products
GROUP BY category
ORDER BY avg_cost DESC;

-- Total revenue by category.
SELECT
    p.category,
    SUM(f.sales_amount) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
GROUP BY p.category
ORDER BY total_revenue DESC;

-- Total revenue by customer. Keep the key in the grain so duplicate names are not merged.
SELECT
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
ORDER BY total_revenue DESC;

-- Distribution of sold quantity by customer country.
SELECT
    c.country,
    SUM(f.quantity) AS total_sold_items
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON c.customer_key = f.customer_key
GROUP BY c.country
ORDER BY total_sold_items DESC;
