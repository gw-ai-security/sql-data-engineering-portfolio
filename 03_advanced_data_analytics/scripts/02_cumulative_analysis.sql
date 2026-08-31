-- 02 - CUMULATIVE ANALYSIS
-- Calculate an expanding running total and expanding average over monthly aggregates.

USE DataWarehouse;
GO

WITH monthly_sales AS (
    SELECT
        DATETRUNC(MONTH, order_date) AS order_month,
        SUM(sales_amount) AS total_sales,
        AVG(CAST(price AS DECIMAL(18, 2))) AS avg_price
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date)
)
SELECT
    order_month,
    total_sales,
    SUM(total_sales) OVER (
        ORDER BY order_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_sales,
    AVG(avg_price) OVER (
        ORDER BY order_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS moving_average_price
FROM monthly_sales
ORDER BY order_month;
