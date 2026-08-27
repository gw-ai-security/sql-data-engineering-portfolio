/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Purpose:
    Loads raw CRM and ERP CSV source files into the Bronze layer.

Load Strategy:
    - Batch processing
    - Full load
    - TRUNCATE TABLE + BULK INSERT
    - No transformations

Source Systems:
    - CRM
    - ERP

Behavior:
    - Existing Bronze data is removed before every load.
    - Each source file is loaded into its corresponding source-aligned table.
    - Runtime is measured for every table and for the complete batch.
    - Errors are caught, reported, and re-thrown to the caller.

Parameters:
    None

Usage:
    EXEC bronze.load_bronze;

Important:
    BULK INSERT paths are resolved by the SQL Server service. The local paths
    below reflect the current development environment and must be adapted when
    the project is run on another machine.
===============================================================================
*/

USE DataWarehouse;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @start_time       DATETIME,
        @end_time         DATETIME,
        @batch_start_time DATETIME,
        @batch_end_time   DATETIME;

    BEGIN TRY

        SET @batch_start_time = GETDATE();

        PRINT '================================================';
        PRINT 'Loading Bronze Layer';
        PRINT '================================================';

        PRINT '------------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '------------------------------------------------';

        -- CRM: Customer Information
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;
        PRINT '>> Inserting Data Into: bronze.crm_cust_info';

        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\admin\Desktop\SQL Course\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds';
        PRINT '>> ------------------------------------------------';

        -- CRM: Product Information
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;
        PRINT '>> Inserting Data Into: bronze.crm_prd_info';

        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\admin\Desktop\SQL Course\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds';
        PRINT '>> ------------------------------------------------';

        -- CRM: Sales Details
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;
        PRINT '>> Inserting Data Into: bronze.crm_sales_details';

        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\admin\Desktop\SQL Course\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds';
        PRINT '>> ------------------------------------------------';

        PRINT '------------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '------------------------------------------------';

        -- ERP: Customer Location
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;
        PRINT '>> Inserting Data Into: bronze.erp_loc_a101';

        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\admin\Desktop\SQL Course\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds';
        PRINT '>> ------------------------------------------------';

        -- ERP: Customer Demographics
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;
        PRINT '>> Inserting Data Into: bronze.erp_cust_az12';

        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\admin\Desktop\SQL Course\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds';
        PRINT '>> ------------------------------------------------';

        -- ERP: Product Categories
        SET @start_time = GETDATE();
        PRINT '>> Truncating Table: bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        PRINT '>> Inserting Data Into: bronze.erp_px_cat_g1v2';

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\admin\Desktop\SQL Course\sql-data-warehouse-project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT '>> Load Duration: '
            + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(20))
            + ' seconds';
        PRINT '>> ------------------------------------------------';

        SET @batch_end_time = GETDATE();

        PRINT '================================================';
        PRINT 'Bronze Layer Load Completed Successfully';
        PRINT 'Total Load Duration: '
            + CAST(DATEDIFF(SECOND, @batch_start_time, @batch_end_time) AS NVARCHAR(20))
            + ' seconds';
        PRINT '================================================';

    END TRY

    BEGIN CATCH

        PRINT '================================================';
        PRINT 'ERROR OCCURRED DURING BRONZE LAYER LOAD';
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(20));
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR(20));
        PRINT 'Error Line: ' + CAST(ERROR_LINE() AS NVARCHAR(20));
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT '================================================';

        THROW;

    END CATCH;
END;
GO
