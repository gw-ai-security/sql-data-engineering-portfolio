-- 02 - DIMENSION EXPLORATION
-- Discover dimension domains and product hierarchy granularity.

USE DataWarehouse;
GO

-- Explore all countries represented in the customer dimension.
SELECT DISTINCT
    country
FROM gold.dim_customers
ORDER BY country;

-- Explore the product hierarchy from category to individual product.
SELECT DISTINCT
    category,
    subcategory,
    product_name
FROM gold.dim_products
ORDER BY category, subcategory, product_name;
