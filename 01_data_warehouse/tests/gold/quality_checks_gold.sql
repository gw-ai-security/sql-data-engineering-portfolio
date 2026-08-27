/*
===============================================================================
Quality Checks: Gold Layer
===============================================================================
Script Purpose:
    Validates Gold dimension grain, fact preservation, join cardinality,
    referential integrity and unchanged Silver measures.

Usage Notes:
    - Run after executing scripts/gold/ddl_gold.sql.
    - For checks marked "Expectation: No Results", investigate every row.
    - Informational count queries explain the current snapshot; they are not
      universal business constants.
===============================================================================
*/

USE DataWarehouse;
GO

-- ====================================================================
-- Checking gold.dim_customers
-- ====================================================================

-- Check surrogate key uniqueness and nullability
-- Expectation: No Results
SELECT
    customer_key,
    COUNT(*) AS row_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING customer_key IS NULL OR COUNT(*) > 1;

-- Check customer business grain
-- Expectation: No Results
SELECT
    customer_number,
    COUNT(*) AS row_count
FROM gold.dim_customers
GROUP BY customer_number
HAVING customer_number IS NULL OR COUNT(*) > 1;

-- Check customer integration did not drop or multiply CRM customers
-- Expectation: No Results
SELECT
    silver_count,
    gold_count
FROM (
    SELECT
        (SELECT COUNT_BIG(*) FROM silver.crm_cust_info) AS silver_count,
        (SELECT COUNT_BIG(*) FROM gold.dim_customers) AS gold_count
) AS counts
WHERE silver_count <> gold_count;

-- Informational: one missing birthdate is expected for AW00029483 because the
-- final ERP demographics CSV row is not loaded by the course BULK INSERT setup.
SELECT
    customer_number,
    gender,
    birthdate,
    country
FROM gold.dim_customers
WHERE customer_number = 'AW00029483';

-- ====================================================================
-- Checking gold.dim_products
-- ====================================================================

-- Check surrogate key uniqueness and nullability
-- Expectation: No Results
SELECT
    product_key,
    COUNT(*) AS row_count
FROM gold.dim_products
GROUP BY product_key
HAVING product_key IS NULL OR COUNT(*) > 1;

-- Check current-product business grain
-- Expectation: No Results
SELECT
    product_number,
    COUNT(*) AS row_count
FROM gold.dim_products
GROUP BY product_number
HAVING product_number IS NULL OR COUNT(*) > 1;

-- Check every intended current Silver product is represented exactly once
-- Expectation: No Results
SELECT
    silver_current_count,
    gold_count
FROM (
    SELECT
        (
            SELECT COUNT_BIG(*)
            FROM silver.crm_prd_info
            WHERE prd_end_dt IS NULL
        ) AS silver_current_count,
        (SELECT COUNT_BIG(*) FROM gold.dim_products) AS gold_count
) AS counts
WHERE silver_current_count <> gold_count;

-- Check category enrichment for current products
-- Expectation: No Results
SELECT
    product_number,
    category_id,
    category,
    subcategory
FROM gold.dim_products
WHERE category_id IS NULL
   OR category IS NULL
   OR subcategory IS NULL;

-- ====================================================================
-- Checking gold.fact_sales
-- ====================================================================

-- Check source sales-line grain after Gold integration
-- Expectation: No Results
SELECT
    order_number,
    product_key,
    COUNT(*) AS row_count
FROM gold.fact_sales
GROUP BY order_number, product_key
HAVING order_number IS NULL
    OR product_key IS NULL
    OR COUNT(*) > 1;

-- Check customer dimension keys
-- Expectation: No Results
SELECT
    f.*
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_customers AS c
    ON c.customer_key = f.customer_key
WHERE f.customer_key IS NULL
   OR c.customer_key IS NULL;

-- Check product dimension keys
-- Expectation: No Results
SELECT
    f.*
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
WHERE f.product_key IS NULL
   OR p.product_key IS NULL;

-- Check Gold integration did not drop or multiply Silver sales rows
-- Expectation: No Results
SELECT
    silver_count,
    gold_count
FROM (
    SELECT
        (SELECT COUNT_BIG(*) FROM silver.crm_sales_details) AS silver_count,
        (SELECT COUNT_BIG(*) FROM gold.fact_sales) AS gold_count
) AS counts
WHERE silver_count <> gold_count;

-- Check Gold did not change Silver dates or measures
-- Expectation: No Results
SELECT
    f.order_number,
    p.product_number,
    f.order_date,
    f.shipping_date,
    f.due_date,
    f.sales_amount,
    f.quantity,
    f.price
FROM gold.fact_sales AS f
INNER JOIN gold.dim_products AS p
    ON p.product_key = f.product_key
INNER JOIN silver.crm_sales_details AS s
    ON s.sls_ord_num = f.order_number
   AND s.sls_prd_key = p.product_number
WHERE f.order_date <> s.sls_order_dt
   OR (f.order_date IS NULL AND s.sls_order_dt IS NOT NULL)
   OR (f.order_date IS NOT NULL AND s.sls_order_dt IS NULL)
   OR f.shipping_date <> s.sls_ship_dt
   OR f.due_date <> s.sls_due_dt
   OR f.sales_amount <> s.sls_sales
   OR f.quantity <> s.sls_quantity
   OR f.price <> s.sls_price;

-- Informational current-snapshot counts
SELECT 'gold.dim_customers' AS object_name, COUNT_BIG(*) AS row_count
FROM gold.dim_customers
UNION ALL
SELECT 'gold.dim_products', COUNT_BIG(*)
FROM gold.dim_products
UNION ALL
SELECT 'gold.fact_sales', COUNT_BIG(*)
FROM gold.fact_sales;
GO
