-- 03 - DATE RANGE EXPLORATION

-- Identify the earliest and latest dates (boundaries)
-- Understand the scope of data and the timespan
-- MIN/MAX[Date Dimension]

-- Find the date of the first and last Order
-- How many years of sales are availbale


SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(
        YEAR,
        MIN(order_date),
        MAX(order_date)
    ) AS years_of_sales
FROM gold.fact_sales;

-- Find the youngest and the oldest customer

SELECT
MIN(birthdate) AS oldest_birhtdate,
DATEDIFF(year, MIN(birthdate), GETDATE()) AS oldest_age,
MAX(birthdate) AS youngest_birthdate,
DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_age
FROM gold.dim_customers
