-- 03 - PERFORMANCE ANALYSIS
-- Compare yearly product sales with each product's historical average and prior year.

USE DataWarehouse;
GO

WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_key,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales AS f
    LEFT JOIN gold.dim_products AS p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY
        YEAR(f.order_date),
        p.product_key,
        p.product_name
),
performance_reference AS (
    SELECT
        order_year,
        product_key,
        product_name,
        current_sales,
        AVG(CAST(current_sales AS DECIMAL(18, 2))) OVER (
            PARTITION BY product_key
        ) AS avg_sales,
        LAG(current_sales) OVER (
            PARTITION BY product_key
            ORDER BY order_year
        ) AS py_sales
    FROM yearly_product_sales
)
SELECT
    order_year,
    product_key,
    product_name,
    current_sales,
    avg_sales,
    current_sales - avg_sales AS diff_avg,
    CASE
        WHEN current_sales > avg_sales THEN 'Above Avg'
        WHEN current_sales < avg_sales THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    py_sales,
    current_sales - py_sales AS diff_py,
    CASE
        WHEN py_sales IS NULL THEN 'No Prior Year'
        WHEN current_sales > py_sales THEN 'Increase'
        WHEN current_sales < py_sales THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change
FROM performance_reference
ORDER BY product_name, order_year;
