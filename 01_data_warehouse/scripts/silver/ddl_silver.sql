/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Purpose:
    Creates the source-aligned tables in the Silver schema.

Silver Layer Contract:
    - Preserve one-to-one source-table traceability from Bronze.
    - Clean and standardize data without applying Gold-layer business modeling.
    - Correct technical data types where required.
    - Add warehouse-generated metadata for load traceability.

Design Notes:
    - Existing Silver tables are dropped and recreated so this DDL is rerunnable
      during development.
    - Source/business keys are validated by quality checks rather than enforced
      as constraints at this stage, keeping the learning project aligned with
      the Data with Baraa baseline.
    - dwh_create_date records when a row is created in the Silver layer.
===============================================================================
*/

USE DataWarehouse;
GO


-- =============================================================================
-- CRM: Customer Information
-- Bronze source: bronze.crm_cust_info
-- =============================================================================

IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_cust_info;
GO

CREATE TABLE silver.crm_cust_info (
    cst_id              INT,
    cst_key             NVARCHAR(50),
    cst_firstname       NVARCHAR(50),
    cst_lastname        NVARCHAR(50),
    cst_marital_status  NVARCHAR(50),
    cst_gndr            NVARCHAR(50),
    cst_create_date     DATE,
    dwh_create_date     DATETIME2(3) NOT NULL
        CONSTRAINT df_silver_crm_cust_info_dwh_create_date DEFAULT SYSDATETIME()
);
GO


-- =============================================================================
-- CRM: Product Information
-- Bronze source: bronze.crm_prd_info
-- Derived in Silver: cat_id and normalized prd_key
-- =============================================================================

IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver.crm_prd_info;
GO

CREATE TABLE silver.crm_prd_info (
    prd_id              INT,
    cat_id              NVARCHAR(50),
    prd_key             NVARCHAR(50),
    prd_nm              NVARCHAR(50),
    prd_cost            INT,
    prd_line            NVARCHAR(50),
    prd_start_dt        DATE,
    prd_end_dt          DATE,
    dwh_create_date     DATETIME2(3) NOT NULL
        CONSTRAINT df_silver_crm_prd_info_dwh_create_date DEFAULT SYSDATETIME()
);
GO


-- =============================================================================
-- CRM: Sales Details
-- Bronze source: bronze.crm_sales_details
-- Date fields are converted from source YYYYMMDD integers to DATE.
-- =============================================================================

IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

CREATE TABLE silver.crm_sales_details (
    sls_ord_num         NVARCHAR(50),
    sls_prd_key         NVARCHAR(50),
    sls_cust_id         INT,
    sls_order_dt        DATE,
    sls_ship_dt         DATE,
    sls_due_dt          DATE,
    sls_sales           INT,
    sls_quantity        INT,
    sls_price           INT,
    dwh_create_date     DATETIME2(3) NOT NULL
        CONSTRAINT df_silver_crm_sales_details_dwh_create_date DEFAULT SYSDATETIME()
);
GO


-- =============================================================================
-- ERP: Customer Demographics
-- Bronze source: bronze.erp_cust_az12
-- =============================================================================

IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver.erp_cust_az12;
GO

CREATE TABLE silver.erp_cust_az12 (
    cid                 NVARCHAR(50),
    bdate               DATE,
    gen                 NVARCHAR(50),
    dwh_create_date     DATETIME2(3) NOT NULL
        CONSTRAINT df_silver_erp_cust_az12_dwh_create_date DEFAULT SYSDATETIME()
);
GO


-- =============================================================================
-- ERP: Customer Location
-- Bronze source: bronze.erp_loc_a101
-- =============================================================================

IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver.erp_loc_a101;
GO

CREATE TABLE silver.erp_loc_a101 (
    cid                 NVARCHAR(50),
    cntry               NVARCHAR(50),
    dwh_create_date     DATETIME2(3) NOT NULL
        CONSTRAINT df_silver_erp_loc_a101_dwh_create_date DEFAULT SYSDATETIME()
);
GO


-- =============================================================================
-- ERP: Product Categories
-- Bronze source: bronze.erp_px_cat_g1v2
-- =============================================================================

IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver.erp_px_cat_g1v2;
GO

CREATE TABLE silver.erp_px_cat_g1v2 (
    id                  NVARCHAR(50),
    cat                 NVARCHAR(50),
    subcat              NVARCHAR(50),
    maintenance         NVARCHAR(50),
    dwh_create_date     DATETIME2(3) NOT NULL
        CONSTRAINT df_silver_erp_px_cat_g1v2_dwh_create_date DEFAULT SYSDATETIME()
);
GO
