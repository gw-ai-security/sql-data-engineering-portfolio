-- 04 - MEASURE EXPLORATION
-- Establish the core business measures before slicing them by dimensions.

USE DataWarehouse;
GO

-- Total sales.
SELECT SUM(sales_amount) AS total_sales
FROM gold.fact_sales;

-- Total quantity sold.
SELECT SUM(quantity) AS total_quantity
FROM gold.fact_sales;

-- Average line-level selling price.
-- CAST avoids SQL Server integer AVG truncation because price is stored as INT.
SELECT AVG(CAST(price AS DECIMAL(18, 2))) AS avg_price
FROM gold.fact_sales;

-- Compare sales-line count with distinct business orders.
SELECT COUNT(order_number) AS sales_line_count
FROM gold.fact_sales;

SELECT COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_sales;

-- Product counts.
SELECT COUNT(product_name) AS total_product_rows
FROM gold.dim_products;

SELECT COUNT(DISTINCT product_key) AS total_products
FROM gold.dim_products;

-- Customer counts.
SELECT COUNT(customer_key) AS total_customers
FROM gold.dim_customers;

SELECT COUNT(DISTINCT customer_key) AS customers_with_sales
FROM gold.fact_sales;

-- Consolidated business metric snapshot.
SELECT 'Total Sales' AS measure_name, CAST(SUM(sales_amount) AS DECIMAL(18, 2)) AS measure_value
FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity', CAST(SUM(quantity) AS DECIMAL(18, 2))
FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(CAST(price AS DECIMAL(18, 2)))
FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders', CAST(COUNT(DISTINCT order_number) AS DECIMAL(18, 2))
FROM gold.fact_sales
UNION ALL
SELECT 'Total Products', CAST(COUNT(DISTINCT product_key) AS DECIMAL(18, 2))
FROM gold.dim_products
UNION ALL
SELECT 'Total Customers', CAST(COUNT(customer_key) AS DECIMAL(18, 2))
FROM gold.dim_customers;
