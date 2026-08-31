-- 03 - DATE RANGE EXPLORATION
-- Identify temporal boundaries and the time span represented by the dataset.

USE DataWarehouse;
GO

-- Find the first and last order dates and the number of calendar-year boundaries crossed.
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date,
    DATEDIFF(
        YEAR,
        MIN(order_date),
        MAX(order_date)
    ) AS years_of_sales
FROM gold.fact_sales;

-- Find the oldest and youngest customer birthdates.
-- DATEDIFF(YEAR, ...) counts year boundaries and is therefore an approximate age.
SELECT
    MIN(birthdate) AS oldest_birthdate,
    DATEDIFF(YEAR, MIN(birthdate), GETDATE()) AS oldest_age_approx,
    MAX(birthdate) AS youngest_birthdate,
    DATEDIFF(YEAR, MAX(birthdate), GETDATE()) AS youngest_age_approx
FROM gold.dim_customers;
