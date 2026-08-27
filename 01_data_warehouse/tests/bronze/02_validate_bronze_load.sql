/*
===============================================================================
Test: Validate Bronze Layer Load
===============================================================================
Purpose:
    Validate the Bronze ingestion result against the Data with Baraa course
    baseline and inspect whether CSV fields are mapped to the expected columns.

Validation Scope:
    1. Loaded row counts vs. course BULK INSERT baseline
    2. Visibility of logical source-row counts for reconciliation context
    3. Basic content and column-mapping inspection
    4. Full-load repeatability

Prerequisite:
    EXEC bronze.load_bronze;

Important:
    The simple BULK INSERT pattern used in the course starts at FIRSTROW = 2 and
    relies on the supplied CSV line endings. For two supplied files
    (cust_info.csv and CUST_AZ12.csv), SQL Server loads one fewer record than a
    full CSV parser counts logically. This script does not hide that difference:
    it reports both the course load baseline and the logical source-row count.
===============================================================================
*/

USE DataWarehouse;
GO

/* =============================================================================
   1. ROW-COUNT VALIDATION
============================================================================= */

WITH expected_counts AS (
    SELECT *
    FROM (
        VALUES
            -- table_name, course_load_baseline, logical_source_records
            ('bronze.crm_cust_info',       CAST(18493 AS BIGINT), CAST(18494 AS BIGINT)),
            ('bronze.crm_prd_info',        CAST(397   AS BIGINT), CAST(397   AS BIGINT)),
            ('bronze.crm_sales_details',   CAST(60398 AS BIGINT), CAST(60398 AS BIGINT)),
            ('bronze.erp_cust_az12',       CAST(18483 AS BIGINT), CAST(18484 AS BIGINT)),
            ('bronze.erp_loc_a101',        CAST(18484 AS BIGINT), CAST(18484 AS BIGINT)),
            ('bronze.erp_px_cat_g1v2',     CAST(37    AS BIGINT), CAST(37    AS BIGINT))
    ) AS e(table_name, expected_loaded_count, logical_source_count)
),
actual_counts AS (
    SELECT 'bronze.crm_cust_info' AS table_name, COUNT_BIG(*) AS actual_count
    FROM bronze.crm_cust_info

    UNION ALL
    SELECT 'bronze.crm_prd_info', COUNT_BIG(*) FROM bronze.crm_prd_info

    UNION ALL
    SELECT 'bronze.crm_sales_details', COUNT_BIG(*) FROM bronze.crm_sales_details

    UNION ALL
    SELECT 'bronze.erp_cust_az12', COUNT_BIG(*) FROM bronze.erp_cust_az12

    UNION ALL
    SELECT 'bronze.erp_loc_a101', COUNT_BIG(*) FROM bronze.erp_loc_a101

    UNION ALL
    SELECT 'bronze.erp_px_cat_g1v2', COUNT_BIG(*) FROM bronze.erp_px_cat_g1v2
)
SELECT
    e.table_name,
    e.logical_source_count,
    e.expected_loaded_count,
    a.actual_count,
    a.actual_count - e.expected_loaded_count AS baseline_difference,
    a.actual_count - e.logical_source_count AS source_reconciliation_difference,
    CASE
        WHEN a.actual_count = e.expected_loaded_count THEN 'PASS'
        ELSE 'FAIL'
    END AS course_baseline_status,
    CASE
        WHEN e.expected_loaded_count = e.logical_source_count THEN 'FULL_MATCH'
        ELSE 'KNOWN_CSV_EOF_DIFFERENCE'
    END AS reconciliation_note
FROM expected_counts AS e
LEFT JOIN actual_counts AS a
    ON e.table_name = a.table_name
ORDER BY e.table_name;
GO

/* =============================================================================
   2. BASIC CONTENT / COLUMN-MAPPING VALIDATION
   Inspect representative records to detect shifted CSV fields or incorrect
   source-to-target mappings.
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
    1. EXEC bronze.load_bronze;
    2. Run this validation script.
    3. EXEC bronze.load_bronze; again.
    4. Run this validation script again.

Expected:
    The loaded row counts remain unchanged because every load uses
    TRUNCATE TABLE + BULK INSERT rather than appending duplicate records.
============================================================================= */
