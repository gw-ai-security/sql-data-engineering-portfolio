-- 04 MEASURE EXPLORATION

-- Measures are aggregated

-- Find the Total Sales
SELECT SUM(sales_amount) total_sales FROM gold.fact_sales

-- Find how many items are sold
SELECT SUM(quantity) total_quantity FROM gold.fact_sales

-- Find the average selling price
SELECT AVG(price) avg_price FROM gold.fact_sales

-- Find the Total number of orders
SELECT COUNT(order_number) total_orders FROM gold.fact_sales
SELECT COUNT(DISTINCT order_number) total_orders FROM gold.fact_sales

-- Find the total number of products
SELECT COUNT(product_name) AS total_products_by_name FROM gold.dim_products
SELECT COUNT(DISTINCT product_key) AS total_products_by_key FROM gold.dim_products

-- Find the total number of customers
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers

-- Find the toal number of customers that has placed an order
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM gold.fact_sales


-- Generate a Report that shows all key metrics of the business

SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity' AS measure_name, SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL
SELECT 'Average Price', AVG(price) FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Orders', COUNT(DISTINCT order_number) total_orders FROM gold.fact_sales
UNION ALL
SELECT 'Total Nr. Products', COUNT(DISTINCT product_key) AS total_products_by_key FROM gold.dim_products
UNION ALL
SELECT 'Total Nr.Customers', COUNT(customer_key) AS total_customers FROM gold.dim_customers
