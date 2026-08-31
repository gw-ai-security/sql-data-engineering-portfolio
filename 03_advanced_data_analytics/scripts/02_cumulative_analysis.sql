-- 02 - CUMULATIVE ANALYSIS
-- Running totals and moving analytical measures over time.
-- Aggregate Data progressively over time
-- Understand growth or decline over Time
-- [Cumulative Measure] by [Date Dimension]

-- Calculate the total sales per month
-- and the running total of sales over time
SELECT
order_date,
total_sales,
-- window function - running total by window
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
AVG(avg_price) OVER (ORDER BY order_date) AS moving_average_price
FROM
(
SELECT
DATETRUNC(month, order_date) AS order_date,
SUM(sales_amount) AS total_sales,
AVG(price) AS avg_price
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
)t


-- Cumulative Aggregation shows progess
