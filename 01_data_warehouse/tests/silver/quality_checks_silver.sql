/*
===============================================================================
Quality Checks: Silver Layer
===============================================================================
Purpose:
    Validates that the Silver layer is clean, standardized, internally
    consistent and complete relative to the intended Bronze -> Silver rules.

Validation Strategy:
    1. Run a compact PASS/FAIL summary for automated review.
    2. Reconcile Bronze and Silver row counts according to transformation rules.
    3. Inspect detailed violating rows only when a summary check fails.

Prerequisite:
    EXEC silver.load_silver;

Important:
    An empty result set in a detailed violation query means the check passed.
===============================================================================
*/

USE DataWarehouse;
GO


/* =============================================================================
   1. QUALITY SUMMARY
============================================================================= */

WITH quality_summary AS (

    -- CRM Customer -------------------------------------------------------------
    SELECT
        'silver.crm_cust_info' AS table_name,
        'customer_pk_null_or_duplicate' AS check_name,
        CAST((
            SELECT COUNT(*)
            FROM (
                SELECT cst_id
                FROM silver.crm_cust_info
                GROUP BY cst_id
                HAVING cst_id IS NULL OR COUNT(*) > 1
            ) AS violations
        ) AS BIGINT) AS issue_count

    UNION ALL

    SELECT
        'silver.crm_cust_info',
        'customer_unwanted_spaces',
        COUNT_BIG(*)
    FROM silver.crm_cust_info
    WHERE cst_key <> TRIM(cst_key)
       OR cst_firstname <> TRIM(cst_firstname)
       OR cst_lastname <> TRIM(cst_lastname)

    UNION ALL

    SELECT
        'silver.crm_cust_info',
        'customer_invalid_marital_status',
        COUNT_BIG(*)
    FROM silver.crm_cust_info
    WHERE cst_marital_status NOT IN ('Single', 'Married', 'n/a')
       OR cst_marital_status IS NULL

    UNION ALL

    SELECT
        'silver.crm_cust_info',
        'customer_invalid_gender',
        COUNT_BIG(*)
    FROM silver.crm_cust_info
    WHERE cst_gndr NOT IN ('Female', 'Male', 'n/a')
       OR cst_gndr IS NULL

    UNION ALL

    SELECT
        'silver.crm_cust_info',
        'customer_missing_dwh_create_date',
        COUNT_BIG(*)
    FROM silver.crm_cust_info
    WHERE dwh_create_date IS NULL


    -- CRM Product --------------------------------------------------------------
    UNION ALL

    SELECT
        'silver.crm_prd_info',
        'product_pk_null_or_duplicate',
        CAST((
            SELECT COUNT(*)
            FROM (
                SELECT prd_id
                FROM silver.crm_prd_info
                GROUP BY prd_id
                HAVING prd_id IS NULL OR COUNT(*) > 1
            ) AS violations
        ) AS BIGINT)

    UNION ALL

    SELECT
        'silver.crm_prd_info',
        'product_missing_join_keys',
        COUNT_BIG(*)
    FROM silver.crm_prd_info
    WHERE cat_id IS NULL
       OR prd_key IS NULL

    UNION ALL

    SELECT
        'silver.crm_prd_info',
        'product_unwanted_spaces',
        COUNT_BIG(*)
    FROM silver.crm_prd_info
    WHERE prd_key <> TRIM(prd_key)
       OR prd_nm <> TRIM(prd_nm)
       OR prd_line <> TRIM(prd_line)

    UNION ALL

    SELECT
        'silver.crm_prd_info',
        'product_invalid_cost',
        COUNT_BIG(*)
    FROM silver.crm_prd_info
    WHERE prd_cost IS NULL
       OR prd_cost < 0

    UNION ALL

    SELECT
        'silver.crm_prd_info',
        'product_invalid_line',
        COUNT_BIG(*)
    FROM silver.crm_prd_info
    WHERE prd_line NOT IN ('Mountain', 'Road', 'Other Sales', 'Touring', 'n/a')
       OR prd_line IS NULL

    UNION ALL

    SELECT
        'silver.crm_prd_info',
        'product_invalid_date_order',
        COUNT_BIG(*)
    FROM silver.crm_prd_info
    WHERE prd_end_dt < prd_start_dt

    UNION ALL

    SELECT
        'silver.crm_prd_info',
        'product_missing_dwh_create_date',
        COUNT_BIG(*)
    FROM silver.crm_prd_info
    WHERE dwh_create_date IS NULL


    -- CRM Sales ----------------------------------------------------------------
    UNION ALL

    SELECT
        'silver.crm_sales_details',
        'sales_missing_keys',
        COUNT_BIG(*)
    FROM silver.crm_sales_details
    WHERE sls_ord_num IS NULL
       OR sls_prd_key IS NULL
       OR sls_cust_id IS NULL

    UNION ALL

    SELECT
        'silver.crm_sales_details',
        'sales_date_out_of_business_range',
        COUNT_BIG(*)
    FROM silver.crm_sales_details
    WHERE (sls_order_dt IS NOT NULL AND sls_order_dt NOT BETWEEN '19000101' AND '20501231')
       OR (sls_ship_dt  IS NOT NULL AND sls_ship_dt  NOT BETWEEN '19000101' AND '20501231')
       OR (sls_due_dt   IS NOT NULL AND sls_due_dt   NOT BETWEEN '19000101' AND '20501231')

    UNION ALL

    SELECT
        'silver.crm_sales_details',
        'sales_invalid_date_order',
        COUNT_BIG(*)
    FROM silver.crm_sales_details
    WHERE sls_order_dt > sls_ship_dt
       OR sls_order_dt > sls_due_dt

    UNION ALL

    SELECT
        'silver.crm_sales_details',
        'sales_measure_inconsistency',
        COUNT_BIG(*)
    FROM silver.crm_sales_details
    WHERE sls_sales IS NULL
       OR sls_quantity IS NULL
       OR sls_price IS NULL
       OR sls_sales <= 0
       OR sls_quantity <= 0
       OR sls_price <= 0
       OR sls_sales <> sls_quantity * sls_price

    UNION ALL

    SELECT
        'silver.crm_sales_details',
        'sales_missing_dwh_create_date',
        COUNT_BIG(*)
    FROM silver.crm_sales_details
    WHERE dwh_create_date IS NULL


    -- ERP Customer -------------------------------------------------------------
    UNION ALL

    SELECT
        'silver.erp_cust_az12',
        'erp_customer_missing_id',
        COUNT_BIG(*)
    FROM silver.erp_cust_az12
    WHERE cid IS NULL
       OR TRIM(cid) = ''

    UNION ALL

    SELECT
        'silver.erp_cust_az12',
        'erp_customer_birthdate_out_of_profile_range',
        COUNT_BIG(*)
    FROM silver.erp_cust_az12
    WHERE bdate < '1924-01-01'
       OR bdate > CAST(SYSDATETIME() AS DATE)

    UNION ALL

    SELECT
        'silver.erp_cust_az12',
        'erp_customer_invalid_gender',
        COUNT_BIG(*)
    FROM silver.erp_cust_az12
    WHERE gen NOT IN ('Female', 'Male', 'n/a')
       OR gen IS NULL

    UNION ALL

    SELECT
        'silver.erp_cust_az12',
        'erp_customer_missing_dwh_create_date',
        COUNT_BIG(*)
    FROM silver.erp_cust_az12
    WHERE dwh_create_date IS NULL


    -- ERP Location -------------------------------------------------------------
    UNION ALL

    SELECT
        'silver.erp_loc_a101',
        'erp_location_missing_id',
        COUNT_BIG(*)
    FROM silver.erp_loc_a101
    WHERE cid IS NULL
       OR TRIM(cid) = ''

    UNION ALL

    SELECT
        'silver.erp_loc_a101',
        'erp_location_missing_country',
        COUNT_BIG(*)
    FROM silver.erp_loc_a101
    WHERE cntry IS NULL
       OR TRIM(cntry) = ''

    UNION ALL

    SELECT
        'silver.erp_loc_a101',
        'erp_location_unwanted_spaces',
        COUNT_BIG(*)
    FROM silver.erp_loc_a101
    WHERE cid <> TRIM(cid)
       OR cntry <> TRIM(cntry)

    UNION ALL

    SELECT
        'silver.erp_loc_a101',
        'erp_location_missing_dwh_create_date',
        COUNT_BIG(*)
    FROM silver.erp_loc_a101
    WHERE dwh_create_date IS NULL


    -- ERP Product Category -----------------------------------------------------
    UNION ALL

    SELECT
        'silver.erp_px_cat_g1v2',
        'erp_category_missing_required_values',
        COUNT_BIG(*)
    FROM silver.erp_px_cat_g1v2
    WHERE id IS NULL
       OR cat IS NULL
       OR subcat IS NULL
       OR maintenance IS NULL

    UNION ALL

    SELECT
        'silver.erp_px_cat_g1v2',
        'erp_category_unwanted_spaces',
        COUNT_BIG(*)
    FROM silver.erp_px_cat_g1v2
    WHERE id <> TRIM(id)
       OR cat <> TRIM(cat)
       OR subcat <> TRIM(subcat)
       OR maintenance <> TRIM(maintenance)

    UNION ALL

    SELECT
        'silver.erp_px_cat_g1v2',
        'erp_category_missing_dwh_create_date',
        COUNT_BIG(*)
    FROM silver.erp_px_cat_g1v2
    WHERE dwh_create_date IS NULL
)
SELECT
    table_name,
    check_name,
    issue_count,
    CASE
        WHEN issue_count = 0 THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM quality_summary
ORDER BY table_name, check_name;
GO


/* =============================================================================
   2. BRONZE -> SILVER RECONCILIATION

   Customer master is intentionally deduplicated and NULL customer IDs are
   filtered. All other Silver tables retain one output row per Bronze row.
============================================================================= */

WITH expected_counts AS (
    SELECT
        'silver.crm_cust_info' AS table_name,
        COUNT_BIG(*) AS expected_count
    FROM (
        SELECT DISTINCT cst_id
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    ) AS customers

    UNION ALL

    SELECT 'silver.crm_prd_info', COUNT_BIG(*)
    FROM bronze.crm_prd_info

    UNION ALL

    SELECT 'silver.crm_sales_details', COUNT_BIG(*)
    FROM bronze.crm_sales_details

    UNION ALL

    SELECT 'silver.erp_cust_az12', COUNT_BIG(*)
    FROM bronze.erp_cust_az12

    UNION ALL

    SELECT 'silver.erp_loc_a101', COUNT_BIG(*)
    FROM bronze.erp_loc_a101

    UNION ALL

    SELECT 'silver.erp_px_cat_g1v2', COUNT_BIG(*)
    FROM bronze.erp_px_cat_g1v2
),
actual_counts AS (
    SELECT 'silver.crm_cust_info' AS table_name, COUNT_BIG(*) AS actual_count
    FROM silver.crm_cust_info

    UNION ALL

    SELECT 'silver.crm_prd_info', COUNT_BIG(*)
    FROM silver.crm_prd_info

    UNION ALL

    SELECT 'silver.crm_sales_details', COUNT_BIG(*)
    FROM silver.crm_sales_details

    UNION ALL

    SELECT 'silver.erp_cust_az12', COUNT_BIG(*)
    FROM silver.erp_cust_az12

    UNION ALL

    SELECT 'silver.erp_loc_a101', COUNT_BIG(*)
    FROM silver.erp_loc_a101

    UNION ALL

    SELECT 'silver.erp_px_cat_g1v2', COUNT_BIG(*)
    FROM silver.erp_px_cat_g1v2
)
SELECT
    e.table_name,
    e.expected_count,
    a.actual_count,
    a.actual_count - e.expected_count AS difference,
    CASE
        WHEN a.actual_count = e.expected_count THEN 'PASS'
        ELSE 'FAIL'
    END AS reconciliation_status
FROM expected_counts AS e
JOIN actual_counts AS a
    ON a.table_name = e.table_name
ORDER BY e.table_name;
GO


/* =============================================================================
   3. DETAILED VIOLATION QUERIES
   Run these when the summary above reports FAIL.
============================================================================= */


-- =============================================================================
-- silver.crm_cust_info
-- =============================================================================

-- NULL or duplicate customer IDs
-- Expectation: no rows
SELECT
    cst_id,
    COUNT(*) AS row_count
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING cst_id IS NULL
    OR COUNT(*) > 1;

-- Unwanted spaces
-- Expectation: no rows
SELECT *
FROM silver.crm_cust_info
WHERE cst_key <> TRIM(cst_key)
   OR cst_firstname <> TRIM(cst_firstname)
   OR cst_lastname <> TRIM(cst_lastname);

-- Standardized customer values
SELECT DISTINCT cst_marital_status
FROM silver.crm_cust_info
ORDER BY cst_marital_status;

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info
ORDER BY cst_gndr;


-- =============================================================================
-- silver.crm_prd_info
-- =============================================================================

-- NULL or duplicate product IDs
-- Expectation: no rows
SELECT
    prd_id,
    COUNT(*) AS row_count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING prd_id IS NULL
    OR COUNT(*) > 1;

-- Missing derived integration keys
-- Expectation: no rows
SELECT *
FROM silver.crm_prd_info
WHERE cat_id IS NULL
   OR prd_key IS NULL;

-- Unwanted spaces
-- Expectation: no rows
SELECT *
FROM silver.crm_prd_info
WHERE prd_key <> TRIM(prd_key)
   OR prd_nm <> TRIM(prd_nm)
   OR prd_line <> TRIM(prd_line);

-- Invalid cost
-- Expectation: no rows
SELECT *
FROM silver.crm_prd_info
WHERE prd_cost IS NULL
   OR prd_cost < 0;

-- Invalid product date order
-- Expectation: no rows
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- Standardized product lines
SELECT DISTINCT prd_line
FROM silver.crm_prd_info
ORDER BY prd_line;


-- =============================================================================
-- silver.crm_sales_details
-- =============================================================================

-- Technically valid DATE values can still be implausible for the business.
-- Expectation: no rows
SELECT *
FROM silver.crm_sales_details
WHERE (sls_order_dt IS NOT NULL AND sls_order_dt NOT BETWEEN '19000101' AND '20501231')
   OR (sls_ship_dt  IS NOT NULL AND sls_ship_dt  NOT BETWEEN '19000101' AND '20501231')
   OR (sls_due_dt   IS NOT NULL AND sls_due_dt   NOT BETWEEN '19000101' AND '20501231');

-- Invalid date order
-- Expectation: no rows
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
   OR sls_order_dt > sls_due_dt;

-- Sales = Quantity * Price and all measures are positive/non-NULL
-- Expectation: no rows
SELECT DISTINCT
    sls_sales,
    sls_quantity,
    sls_price
FROM silver.crm_sales_details
WHERE sls_sales IS NULL
   OR sls_quantity IS NULL
   OR sls_price IS NULL
   OR sls_sales <= 0
   OR sls_quantity <= 0
   OR sls_price <= 0
   OR sls_sales <> sls_quantity * sls_price
ORDER BY sls_sales, sls_quantity, sls_price;

-- Informational: dates intentionally nulled because the source was zero,
-- malformed, technically invalid or outside the accepted business range.
SELECT
    SUM(CASE WHEN sls_order_dt IS NULL THEN 1 ELSE 0 END) AS null_order_dates,
    SUM(CASE WHEN sls_ship_dt IS NULL THEN 1 ELSE 0 END) AS null_ship_dates,
    SUM(CASE WHEN sls_due_dt IS NULL THEN 1 ELSE 0 END) AS null_due_dates
FROM silver.crm_sales_details;


-- =============================================================================
-- silver.erp_cust_az12
-- =============================================================================

-- Birthdate profiling rule used in the course project
-- Expectation: no rows
SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01'
   OR bdate > CAST(SYSDATETIME() AS DATE)
ORDER BY bdate;

-- Standardized gender values
SELECT DISTINCT gen
FROM silver.erp_cust_az12
ORDER BY gen;


-- =============================================================================
-- silver.erp_loc_a101
-- =============================================================================

-- Standardized country values
SELECT DISTINCT cntry
FROM silver.erp_loc_a101
ORDER BY cntry;

-- Missing/blank customer or country values
-- Expectation: no rows
SELECT *
FROM silver.erp_loc_a101
WHERE cid IS NULL
   OR TRIM(cid) = ''
   OR cntry IS NULL
   OR TRIM(cntry) = '';


-- =============================================================================
-- silver.erp_px_cat_g1v2
-- =============================================================================

-- Unwanted spaces
-- Expectation: no rows
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE id <> TRIM(id)
   OR cat <> TRIM(cat)
   OR subcat <> TRIM(subcat)
   OR maintenance <> TRIM(maintenance);

-- Source-domain inspection
SELECT DISTINCT maintenance
FROM silver.erp_px_cat_g1v2
ORDER BY maintenance;
GO
