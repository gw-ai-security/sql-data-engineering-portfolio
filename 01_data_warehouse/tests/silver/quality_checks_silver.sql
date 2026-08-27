/*
===============================================================================
Quality Checks: Silver Layer
===============================================================================
Script Purpose:
    This script performs quality checks for data consistency, accuracy,
    standardization and relationship integrity across the Silver layer.

Usage Notes:
    - Run these checks after executing: EXEC silver.load_silver;
    - Most checks follow the Data with Baraa course workflow closely.
    - A few checks were expanded where the course applied the same rule to
      multiple columns or where our dataset exposed a real edge case.
    - For checks marked "Expectation: No Results", any returned row requires
      investigation.
===============================================================================
*/

USE DataWarehouse;
GO

-- ====================================================================
-- Checking 'silver.crm_cust_info'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
    cst_id,
    COUNT(*) AS row_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Check for Unwanted Spaces in transformed name columns
-- Expectation: No Results
SELECT
    cst_id,
    cst_firstname,
    cst_lastname
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)
   OR cst_lastname != TRIM(cst_lastname);

-- Data Standardization & Consistency
SELECT DISTINCT
    cst_marital_status
FROM silver.crm_cust_info
ORDER BY cst_marital_status;

SELECT DISTINCT
    cst_gndr
FROM silver.crm_cust_info
ORDER BY cst_gndr;


-- ====================================================================
-- Checking 'silver.crm_prd_info'
-- ====================================================================

-- Check for NULLs or Duplicates in Primary Key
-- Expectation: No Results
SELECT
    prd_id,
    COUNT(*) AS row_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
    prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- Check for NULLs or Negative Values in Cost
-- Expectation: No Results
SELECT
    prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Data Standardization & Consistency
SELECT DISTINCT
    prd_line
FROM silver.crm_prd_info
ORDER BY prd_line;

-- Check for Invalid Date Orders (Start Date > End Date)
-- Expectation: No Results
SELECT
    *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- Check derived integration keys
-- Expectation: No Results
SELECT
    *
FROM silver.crm_prd_info
WHERE cat_id IS NULL
   OR prd_key IS NULL;


-- ====================================================================
-- Checking 'silver.crm_sales_details'
-- ====================================================================

-- Source-date profiling.
-- These queries intentionally show bad Bronze values that Silver must handle.
-- Returned rows are source-quality findings, not Silver validation failures.

SELECT
    sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt <= 0
   OR LEN(sls_order_dt) != 8
   OR sls_order_dt > 20500101
   OR sls_order_dt < 19000101;

SELECT
    sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt <= 0
   OR LEN(sls_ship_dt) != 8
   OR sls_ship_dt > 20500101
   OR sls_ship_dt < 19000101;

SELECT
    sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
   OR LEN(sls_due_dt) != 8
   OR sls_due_dt > 20500101
   OR sls_due_dt < 19000101;

-- Verify that non-NULL Silver sales dates are inside the accepted range.
-- Expectation: No Results
SELECT
    *
FROM silver.crm_sales_details
WHERE (sls_order_dt IS NOT NULL AND (sls_order_dt < '1900-01-01' OR sls_order_dt > '2050-01-01'))
   OR (sls_ship_dt  IS NOT NULL AND (sls_ship_dt  < '1900-01-01' OR sls_ship_dt  > '2050-01-01'))
   OR (sls_due_dt   IS NOT NULL AND (sls_due_dt   < '1900-01-01' OR sls_due_dt   > '2050-01-01'));

-- Check referential integrity of sales product key
-- Expectation: No Results
SELECT DISTINCT
    sls_prd_key
FROM silver.crm_sales_details
WHERE sls_prd_key NOT IN (
    SELECT prd_key
    FROM silver.crm_prd_info
    WHERE prd_key IS NOT NULL
);

-- Check referential integrity of sales customer ID
-- Expectation: No Results
SELECT DISTINCT
    sls_cust_id
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (
    SELECT cst_id
    FROM silver.crm_cust_info
    WHERE cst_id IS NOT NULL
);

-- Check for Invalid Date Orders (Order Date > Shipping/Due Dates)
-- Expectation: No Results
SELECT
    *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;

-- Check Data Consistency: Sales = Quantity * Price
-- Expectation: No Results
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
   OR sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- Informational: count dates mapped to NULL during Silver cleansing
SELECT
    SUM(CASE WHEN sls_order_dt IS NULL THEN 1 ELSE 0 END) AS null_order_dates,
    SUM(CASE WHEN sls_ship_dt IS NULL THEN 1 ELSE 0 END) AS null_ship_dates,
    SUM(CASE WHEN sls_due_dt IS NULL THEN 1 ELSE 0 END) AS null_due_dates
FROM silver.crm_sales_details;


-- ====================================================================
-- Checking 'silver.erp_cust_az12'
-- ====================================================================

-- Birthdate profile review.
-- Future dates are invalid and are transformed to NULL in Silver.
-- Dates before 1924 are a profiling/business-review flag, not automatically
-- treated as incorrect by the transformation.
SELECT DISTINCT
    bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > GETDATE()
ORDER BY bdate;

-- Data Standardization & Consistency
SELECT DISTINCT
    gen
FROM silver.erp_cust_az12
ORDER BY gen;

-- Check normalized ERP customer IDs against CRM customer keys
-- Expectation: No Results
SELECT DISTINCT
    cid
FROM silver.erp_cust_az12
WHERE cid IS NOT NULL
  AND cid NOT IN (
      SELECT cst_key
      FROM silver.crm_cust_info
      WHERE cst_key IS NOT NULL
  );


-- ====================================================================
-- Checking 'silver.erp_loc_a101'
-- ====================================================================

-- Data Standardization & Consistency
SELECT DISTINCT
    cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

-- Check normalized ERP location customer IDs against CRM customer keys
-- Expectation: No Results
SELECT DISTINCT
    cid
FROM silver.erp_loc_a101
WHERE cid IS NOT NULL
  AND cid NOT IN (
      SELECT cst_key
      FROM silver.crm_cust_info
      WHERE cst_key IS NOT NULL
  );


-- ====================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ====================================================================

-- Check for Unwanted Spaces
-- Expectation: No Results
SELECT
    *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
   OR subcat != TRIM(subcat)
   OR maintenance != TRIM(maintenance);

-- Data Standardization & Consistency
SELECT DISTINCT
    maintenance
FROM silver.erp_px_cat_g1v2
ORDER BY maintenance;

-- Check category IDs used by CRM products against ERP category IDs
-- Expectation: No Results
SELECT DISTINCT
    cat_id
FROM silver.crm_prd_info
WHERE cat_id IS NOT NULL
  AND cat_id NOT IN (
      SELECT id
      FROM silver.erp_px_cat_g1v2
      WHERE id IS NOT NULL
  );
GO
