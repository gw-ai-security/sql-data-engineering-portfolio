/*
===============================================================================
Test: Validate Bronze Layer Load
===============================================================================
Purpose:
    Validate that the Bronze ingestion process loaded all source records
    completely and that CSV fields are mapped to the expected target columns.

Validation Scope:
    1. Data completeness / source-to-target row counts
    2. Basic content and column-mapping inspection
    3. Full-load repeatability

Prerequisite:
    Execute the Bronze load procedure first:

        EXEC bronze.load_bronze;

Expected:
    - All six tables return PASS in the row-count validation.
    - Sample records show values in the correct columns.
    - Re-running bronze.load_bronze does not increase row counts because the
      load strategy is TRUNCATE + BULK INSERT.
===============================================================================
*/

USE DataWarehouse;
GO


/* =============================================================================
   1. DATA COMPLETENESS
   Compare expected CSV record counts with Bronze table counts.
   Header rows are excluded from the expected source counts.
============================================================================= */

WITH expected_counts AS (
    SELECT *
    FROM (
-- Expected counts follow the Data with Baraa course dataset/load baseline.
-- CSV header rows are excluded because BULK INSERT starts at FIRSTROW = 2.
        VALUES
            ('bronze.crm_cust_info',       CAST(18493 AS BIGINT)),
            ('bronze.crm_prd_info',        CAST(397   AS BIGINT)),
            ('bronze.crm_sales_details',   CAST(60398 AS BIGINT)),
            ('bronze.erp_cust_az12',       CAST(18483 AS BIGINT)),
            ('bronze.erp_loc_a101',        CAST(18484 AS BIGINT)),
            ('bronze.erp_px_cat_g1v2',     CAST(37    AS BIGINT))
    ) AS e(table_name, expected_count)
),

actual_counts AS (
    SELECT
        'bronze.crm_cust_info' AS table_name,
        COUNT_BIG(*) AS actual_count
    FROM bronze.crm_cust_info

    UNION ALL

    SELECT
        'bronze.crm_prd_info',
        COUNT_BIG(*)
    FROM bronze.crm_prd_info

    UNION ALL

    SELECT
        'bronze.crm_sales_details',
        COUNT_BIG(*)
    FROM bronze.crm_sales_details

    UNION ALL

    SELECT
        'bronze.erp_cust_az12',
        COUNT_BIG(*)
    FROM bronze.erp_cust_az12

    UNION ALL

    SELECT
        'bronze.erp_loc_a101',
        COUNT_BIG(*)
    FROM bronze.erp_loc_a101

    UNION ALL

    SELECT
        'bronze.erp_px_cat_g1v2',
        COUNT_BIG(*)
    FROM bronze.erp_px_cat_g1v2
)

SELECT
    e.table_name,
    e.expected_count,
    a.actual_count,
    a.actual_count - e.expected_count AS difference,
    CASE
        WHEN a.actual_count = e.expected_count THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM expected_counts AS e
LEFT JOIN actual_counts AS a
    ON e.table_name = a.table_name
ORDER BY e.table_name;
GO


/* =============================================================================
   2. BASIC CONTENT / COLUMN-MAPPING VALIDATION
   Inspect sample records to detect shifted or incorrectly mapped CSV fields.

   Examples of problems this can reveal:
       - First name loaded into customer key
       - Product key loaded into the wrong column
       - Incorrect FIELDTERMINATOR
       - Incorrect table column ordering
============================================================================= */


-- CRM: Customer Information
SELECT TOP (10)
    cst_id,
    cst_key,
    cst_firstname,
    cst_lastname,
    cst_marital_status,
    cst_gndr,
    cst_create_date
FROM bronze.crm_cust_info
ORDER BY cst_id;
GO


-- CRM: Product Information
SELECT TOP (10)
    prd_id,
    prd_key,
    prd_nm,
    prd_cost,
    prd_line,
    prd_start_dt,
    prd_end_dt
FROM bronze.crm_prd_info
ORDER BY prd_id;
GO


-- CRM: Sales Details
SELECT TOP (10)
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,
    sls_order_dt,
    sls_ship_dt,
    sls_due_dt,
    sls_sales,
    sls_quantity,
    sls_price
FROM bronze.crm_sales_details;
GO


-- ERP: Customer Demographics
SELECT TOP (10)
    cid,
    bdate,
    gen
FROM bronze.erp_cust_az12;
GO


-- ERP: Customer Location
SELECT TOP (10)
    cid,
    cntry
FROM bronze.erp_loc_a101;
GO


-- ERP: Product Categories
SELECT TOP (10)
    id,
    cat,
    subcat,
    maintenance
FROM bronze.erp_px_cat_g1v2;
GO


/* =============================================================================
   3. FULL-LOAD REPEATABILITY CHECK
===============================================================================

Manual test:

    1. Execute:
           EXEC bronze.load_bronze;

    2. Run this validation script.

    3. Execute again:
           EXEC bronze.load_bronze;

    4. Run this validation script again.

Expected:
    All row counts remain unchanged.

Reason:
    Each load first executes TRUNCATE TABLE and then BULK INSERT, so repeated
    executions refresh the Bronze snapshot rather than append duplicate data.

============================================================================= */