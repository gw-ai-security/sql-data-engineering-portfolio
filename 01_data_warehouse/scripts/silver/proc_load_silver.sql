/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Purpose:
    Performs the Silver-layer ETL process by cleaning, standardizing and
    technically enriching Bronze data before it is consumed by the Gold layer.

Silver Layer Contract:
    - Full refresh: TRUNCATE + INSERT.
    - Preserve source-aligned table structure and traceability.
    - Perform data cleansing, standardization, normalization, type correction,
      derived columns and technical enrichment.
    - Do not perform cross-source business integration or Gold-layer modeling.

Operational Behavior:
    - Runs the complete Silver refresh as one transaction.
    - Rolls back the complete refresh if any table load fails.
    - Reports rows loaded and duration per table.
    - Reports total batch duration.
    - Re-throws errors so callers can detect pipeline failure.

Parameters:
    None

Usage:
    EXEC silver.load_silver;
===============================================================================
*/

USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
        @start_time       DATETIME2(3),
        @end_time         DATETIME2(3),
        @batch_start_time DATETIME2(3),
        @batch_end_time   DATETIME2(3),
        @rows_loaded      BIGINT,
        @min_sales_date   DATE = '19000101',
        @max_sales_date   DATE = '20501231';

    BEGIN TRY

        SET @batch_start_time = SYSDATETIME();

        PRINT '================================================';
        PRINT 'Loading Silver Layer';
        PRINT '================================================';

        BEGIN TRANSACTION;


        /* =====================================================================
           CRM SOURCE TABLES
           ===================================================================== */

        PRINT '------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '------------------------------------------------';


        -- ---------------------------------------------------------------------
        -- CRM: Customer Information
        -- Cleansing: deduplication, NULL-key filtering, whitespace cleanup,
        --             marital-status and gender standardization.
        -- ---------------------------------------------------------------------

        SET @start_time = SYSDATETIME();

        PRINT '>> Truncating Table: silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT '>> Inserting Data Into: silver.crm_cust_info';

        ;WITH ranked_customers AS (
            SELECT
                cst_id,
                cst_key,
                cst_firstname,
                cst_lastname,
                cst_marital_status,
                cst_gndr,
                cst_create_date,
                ROW_NUMBER() OVER (
                    PARTITION BY cst_id
                    ORDER BY cst_create_date DESC, cst_key DESC
                ) AS row_rank
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        )
        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            NULLIF(TRIM(cst_key), '') AS cst_key,
            NULLIF(TRIM(cst_firstname), '') AS cst_firstname,
            NULLIF(TRIM(cst_lastname), '') AS cst_lastname,
            CASE
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END AS cst_marital_status,
            CASE
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END AS cst_gndr,
            cst_create_date
        FROM ranked_customers
        WHERE row_rank = 1;

        SET @rows_loaded = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();

        PRINT '>> Rows Loaded: ' + CAST(@rows_loaded AS NVARCHAR(30));
        PRINT '>> Load Duration: '
            + CAST(DATEDIFF_BIG(MILLISECOND, @start_time, @end_time) AS NVARCHAR(30))
            + ' ms';
        PRINT '>> ------------------------------------------------';


        -- ---------------------------------------------------------------------
        -- CRM: Product Information
        -- Cleansing: whitespace cleanup, missing cost handling, product-line
        --             standardization, type correction and historical end-date
        --             derivation.
        -- Derived columns: cat_id and normalized prd_key.
        -- ---------------------------------------------------------------------

        SET @start_time = SYSDATETIME();

        PRINT '>> Truncating Table: silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        PRINT '>> Inserting Data Into: silver.crm_prd_info';

        ;WITH prepared_products AS (
            SELECT
                prd_id,
                NULLIF(TRIM(prd_key), '') AS source_prd_key,
                NULLIF(TRIM(prd_nm), '') AS prd_nm,
                prd_cost,
                NULLIF(TRIM(prd_line), '') AS prd_line,
                prd_start_dt
            FROM bronze.crm_prd_info
        ),
        versioned_products AS (
            SELECT
                *,
                LEAD(prd_start_dt) OVER (
                    PARTITION BY source_prd_key
                    ORDER BY prd_start_dt
                ) AS next_prd_start_dt
            FROM prepared_products
        )
        INSERT INTO silver.crm_prd_info (
            prd_id,
            cat_id,
            prd_key,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT
            prd_id,
            CASE
                WHEN LEN(source_prd_key) >= 5
                    THEN REPLACE(LEFT(source_prd_key, 5), '-', '_')
                ELSE NULL
            END AS cat_id,
            CASE
                WHEN LEN(source_prd_key) >= 7
                    THEN SUBSTRING(source_prd_key, 7, LEN(source_prd_key))
                ELSE NULL
            END AS prd_key,
            prd_nm,
            ISNULL(prd_cost, 0) AS prd_cost,
            CASE
                WHEN UPPER(prd_line) = 'M' THEN 'Mountain'
                WHEN UPPER(prd_line) = 'R' THEN 'Road'
                WHEN UPPER(prd_line) = 'S' THEN 'Other Sales'
                WHEN UPPER(prd_line) = 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line,
            CAST(prd_start_dt AS DATE) AS prd_start_dt,
            CAST(DATEADD(DAY, -1, next_prd_start_dt) AS DATE) AS prd_end_dt
        FROM versioned_products;

        SET @rows_loaded = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();

        PRINT '>> Rows Loaded: ' + CAST(@rows_loaded AS NVARCHAR(30));
        PRINT '>> Load Duration: '
            + CAST(DATEDIFF_BIG(MILLISECOND, @start_time, @end_time) AS NVARCHAR(30))
            + ' ms';
        PRINT '>> ------------------------------------------------';


        -- ---------------------------------------------------------------------
        -- CRM: Sales Details
        -- Cleansing: key whitespace cleanup, YYYYMMDD -> DATE conversion,
        --             business-range validation, invalid-price recovery and
        --             sales consistency repair.
        --
        -- Important: TRY_CONVERT validates whether a value is technically a
        -- valid SQL date, but it does not know whether a year such as 5489 is
        -- plausible for this business dataset. Parsed dates are therefore also
        -- checked against explicit project boundaries.
        -- ---------------------------------------------------------------------

        SET @start_time = SYSDATETIME();

        PRINT '>> Truncating Table: silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        PRINT '>> Inserting Data Into: silver.crm_sales_details';

        ;WITH parsed_sales AS (
            SELECT
                NULLIF(TRIM(sls_ord_num), '') AS sls_ord_num,
                NULLIF(TRIM(sls_prd_key), '') AS sls_prd_key,
                sls_cust_id,
                TRY_CONVERT(
                    DATE,
                    CONVERT(CHAR(8), NULLIF(sls_order_dt, 0)),
                    112
                ) AS parsed_order_dt,
                TRY_CONVERT(
                    DATE,
                    CONVERT(CHAR(8), NULLIF(sls_ship_dt, 0)),
                    112
                ) AS parsed_ship_dt,
                TRY_CONVERT(
                    DATE,
                    CONVERT(CHAR(8), NULLIF(sls_due_dt, 0)),
                    112
                ) AS parsed_due_dt,
                sls_sales,
                sls_quantity,
                sls_price
            FROM bronze.crm_sales_details
        ),
        prepared_sales AS (
            SELECT
                sls_ord_num,
                sls_prd_key,
                sls_cust_id,
                CASE
                    WHEN parsed_order_dt BETWEEN @min_sales_date AND @max_sales_date
                        THEN parsed_order_dt
                    ELSE NULL
                END AS sls_order_dt,
                CASE
                    WHEN parsed_ship_dt BETWEEN @min_sales_date AND @max_sales_date
                        THEN parsed_ship_dt
                    ELSE NULL
                END AS sls_ship_dt,
                CASE
                    WHEN parsed_due_dt BETWEEN @min_sales_date AND @max_sales_date
                        THEN parsed_due_dt
                    ELSE NULL
                END AS sls_due_dt,
                sls_sales,
                sls_quantity,
                CASE
                    WHEN sls_price > 0 THEN sls_price
                    WHEN sls_sales > 0 AND sls_quantity > 0
                        THEN sls_sales / NULLIF(sls_quantity, 0)
                    ELSE NULL
                END AS normalized_price
            FROM parsed_sales
        )
        INSERT INTO silver.crm_sales_details (
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            sls_sales,
            sls_quantity,
            sls_price
        )
        SELECT
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            sls_order_dt,
            sls_ship_dt,
            sls_due_dt,
            CASE
                WHEN sls_quantity > 0 AND normalized_price > 0
                    THEN sls_quantity * normalized_price
                WHEN sls_sales > 0
                    THEN sls_sales
                ELSE NULL
            END AS sls_sales,
            sls_quantity,
            normalized_price AS sls_price
        FROM prepared_sales;

        SET @rows_loaded = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();

        PRINT '>> Rows Loaded: ' + CAST(@rows_loaded AS NVARCHAR(30));
        PRINT '>> Load Duration: '
            + CAST(DATEDIFF_BIG(MILLISECOND, @start_time, @end_time) AS NVARCHAR(30))
            + ' ms';
        PRINT '>> ------------------------------------------------';


        /* =====================================================================
           ERP SOURCE TABLES
           ===================================================================== */

        PRINT '------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '------------------------------------------------';


        -- ---------------------------------------------------------------------
        -- ERP: Customer Demographics
        -- Cleansing: customer-key normalization, future-date handling and
        --             gender standardization.
        -- ---------------------------------------------------------------------

        SET @start_time = SYSDATETIME();

        PRINT '>> Truncating Table: silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT '>> Inserting Data Into: silver.erp_cust_az12';

        INSERT INTO silver.erp_cust_az12 (
            cid,
            bdate,
            gen
        )
        SELECT
            CASE
                WHEN UPPER(TRIM(cid)) LIKE 'NAS%'
                    THEN NULLIF(SUBSTRING(TRIM(cid), 4, LEN(TRIM(cid))), '')
                ELSE NULLIF(TRIM(cid), '')
            END AS cid,
            CASE
                WHEN bdate > CAST(SYSDATETIME() AS DATE) THEN NULL
                ELSE bdate
            END AS bdate,
            CASE
                WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
                ELSE 'n/a'
            END AS gen
        FROM bronze.erp_cust_az12;

        SET @rows_loaded = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();

        PRINT '>> Rows Loaded: ' + CAST(@rows_loaded AS NVARCHAR(30));
        PRINT '>> Load Duration: '
            + CAST(DATEDIFF_BIG(MILLISECOND, @start_time, @end_time) AS NVARCHAR(30))
            + ' ms';
        PRINT '>> ------------------------------------------------';


        -- ---------------------------------------------------------------------
        -- ERP: Customer Location
        -- Cleansing: customer-key normalization, whitespace cleanup and country
        --             standardization.
        -- ---------------------------------------------------------------------

        SET @start_time = SYSDATETIME();

        PRINT '>> Truncating Table: silver.erp_loc_a101';
        TRUNCATE TABLE silver.erp_loc_a101;

        PRINT '>> Inserting Data Into: silver.erp_loc_a101';

        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT
            NULLIF(REPLACE(TRIM(cid), '-', ''), '') AS cid,
            CASE
                WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United States'
                WHEN NULLIF(TRIM(cntry), '') IS NULL THEN 'n/a'
                ELSE TRIM(cntry)
            END AS cntry
        FROM bronze.erp_loc_a101;

        SET @rows_loaded = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();

        PRINT '>> Rows Loaded: ' + CAST(@rows_loaded AS NVARCHAR(30));
        PRINT '>> Load Duration: '
            + CAST(DATEDIFF_BIG(MILLISECOND, @start_time, @end_time) AS NVARCHAR(30))
            + ' ms';
        PRINT '>> ------------------------------------------------';


        -- ---------------------------------------------------------------------
        -- ERP: Product Categories
        -- Cleansing: whitespace cleanup while preserving source-aligned content.
        -- ---------------------------------------------------------------------

        SET @start_time = SYSDATETIME();

        PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';

        INSERT INTO silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT
            NULLIF(TRIM(id), '') AS id,
            NULLIF(TRIM(cat), '') AS cat,
            NULLIF(TRIM(subcat), '') AS subcat,
            NULLIF(TRIM(maintenance), '') AS maintenance
        FROM bronze.erp_px_cat_g1v2;

        SET @rows_loaded = @@ROWCOUNT;
        SET @end_time = SYSDATETIME();

        PRINT '>> Rows Loaded: ' + CAST(@rows_loaded AS NVARCHAR(30));
        PRINT '>> Load Duration: '
            + CAST(DATEDIFF_BIG(MILLISECOND, @start_time, @end_time) AS NVARCHAR(30))
            + ' ms';
        PRINT '>> ------------------------------------------------';


        COMMIT TRANSACTION;

        SET @batch_end_time = SYSDATETIME();

        PRINT '================================================';
        PRINT 'Silver Layer Load Completed Successfully';
        PRINT 'Total Load Duration: '
            + CAST(
                DATEDIFF_BIG(
                    MILLISECOND,
                    @batch_start_time,
                    @batch_end_time
                ) AS NVARCHAR(30)
              )
            + ' ms';
        PRINT '================================================';

    END TRY

    BEGIN CATCH

        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;

        PRINT '================================================';
        PRINT 'ERROR OCCURRED DURING SILVER LAYER LOAD';
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(20));
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR(20));
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR(20));
        PRINT 'Error Procedure: ' + COALESCE(ERROR_PROCEDURE(), 'n/a');
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT '================================================';

        THROW;

    END CATCH;
END;
GO
