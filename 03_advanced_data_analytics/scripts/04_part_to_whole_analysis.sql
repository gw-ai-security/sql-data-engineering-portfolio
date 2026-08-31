-- 04 - PART-TO-WHOLE ANALYSIS
-- Measure each product category's contribution to total sales.

USE DataWarehouse;
GO

WITH category_sales AS (
    SELECT
        p.category,
        SUM(f.sales_amount) AS total_sales
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON p.product_key = f.product_key
    GROUP BY p.category
)
SELECT
    category,
    total_sales,
    SUM(total_sales) OVER () AS overall_sales,
    ROUND(
        CAST(total_sales AS DECIMAL(19, 4))
        / NULLIF(SUM(CAST(total_sales AS DECIMAL(19, 4))) OVER (), 0)
        * 100,
        2
    ) AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;
