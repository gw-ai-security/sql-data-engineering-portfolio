/*
===============================================================================
Test: Validate Bronze Schema
===============================================================================
Purpose:
    Validate that the expected Bronze tables were created and inspect their
    column definitions after executing the Bronze DDL script.

Expected:
    - 6 Bronze base tables
    - Correct column names and order
    - Correct SQL data types
    - Expected NVARCHAR lengths
    - Source columns remain nullable in Bronze
===============================================================================
*/

USE DataWarehouse;
GO

-- =============================================================================
-- 1. Validate Bronze Tables
-- Expected: 6 tables
-- =============================================================================

SELECT
    TABLE_CATALOG,
    TABLE_SCHEMA,
    TABLE_NAME,
    TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'bronze'
ORDER BY TABLE_NAME;
GO

/* Expected tables:

bronze.crm_cust_info
bronze.crm_prd_info
bronze.crm_sales_details
bronze.erp_cust_az12
bronze.erp_loc_a101
bronze.erp_px_cat_g1v2

*/

-- =============================================================================
-- 2. Validate Bronze Column Definitions
-- =============================================================================

SELECT
    TABLE_NAME,
    ORDINAL_POSITION,
    COLUMN_NAME,
    DATA_TYPE,
    CHARACTER_MAXIMUM_LENGTH,
    IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'bronze'
ORDER BY TABLE_NAME, ORDINAL_POSITION;
GO
