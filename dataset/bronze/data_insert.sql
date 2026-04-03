CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        DECLARE @cnt INT, @start_time DATETIME, @end_time DATETIME, @start_batch DATETIME, @end_batch DATETIME;

        PRINT '========== Bronze Load Started ==========';
        SET @start_batch = GETDATE();

        /*=========================================================
          1. CRM - Customer Info
        =========================================================*/
        PRINT 'Loading: crm_cust_info';

        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_cust_info;

        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\naman\Documents\Learnings\Sql\warehouse\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();

        SELECT @cnt = COUNT(*) FROM bronze.crm_cust_info;
        PRINT 'Rows Loaded (crm_cust_info): ' + CAST(@cnt AS VARCHAR);
        PRINT 'Time Taken to Load Rows (crm_cust_info): ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'Seconds'; 


        /*=========================================================
          2. CRM - Product Info
        =========================================================*/
        PRINT 'Loading: crm_prd_info';

        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_prd_info;

        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\naman\Documents\Learnings\Sql\warehouse\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();

        SELECT @cnt = COUNT(*) FROM bronze.crm_prd_info;
        PRINT 'Rows Loaded (crm_prd_info): ' + CAST(@cnt AS VARCHAR);
        PRINT 'Time Taken to Load Rows (crm_prd_info): ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'Seconds';


        /*=========================================================
          3. CRM - Sales Details
        =========================================================*/
        PRINT 'Loading: crm_sales_details';

        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.crm_sales_details;

        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\naman\Documents\Learnings\Sql\warehouse\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();

        SELECT @cnt = COUNT(*) FROM bronze.crm_sales_details;
        PRINT 'Rows Loaded (crm_sales_details): ' + CAST(@cnt AS VARCHAR);
        PRINT 'Time Taken to Load Rows (crm_sales_details): ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'Seconds';


        /*=========================================================
          4. ERP - Customer
        =========================================================*/
        PRINT 'Loading: erp_cust_az12';

        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_cust_az12;

        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\naman\Documents\Learnings\Sql\warehouse\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();

        SELECT @cnt = COUNT(*) FROM bronze.erp_cust_az12;
        PRINT 'Rows Loaded (erp_cust_az12): ' + CAST(@cnt AS VARCHAR);
        PRINT 'Time Taken to Load Rows (erp_cust_az12): ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'Seconds';


        /*=========================================================
          5. ERP - Product Category
        =========================================================*/
        PRINT 'Loading: erp_px_cat_g1v2';

        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\naman\Documents\Learnings\Sql\warehouse\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();

        SELECT @cnt = COUNT(*) FROM bronze.erp_px_cat_g1v2;
        PRINT 'Rows Loaded (erp_px_cat_g1v2): ' + CAST(@cnt AS VARCHAR);
        PRINT 'Time Taken to Load Rows (erp_px_cat_g1v2): ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'Seconds';


        /*=========================================================
          6. ERP - Location
        =========================================================*/
        PRINT 'Loading: erp_loc_a101';

        SET @start_time = GETDATE();
        TRUNCATE TABLE bronze.erp_loc_a101;

        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\naman\Documents\Learnings\Sql\warehouse\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );
        SET @end_time = GETDATE();

        SELECT @cnt = COUNT(*) FROM bronze.erp_loc_a101;
        PRINT 'Rows Loaded (erp_loc_a101): ' + CAST(@cnt AS VARCHAR);
        PRINT 'Time Taken to Load Rows (erp_loc_a101): ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'Seconds';



        SET @end_batch = GETDATE();
        print 'Total Time taken to load Everything : ' + CAST(DATEDIFF(second, @start_batch, @end_batch) as NVARCHAR) + 'Seconds'; 
        PRINT '========== Bronze Load Completed Successfully ==========';
        
    END TRY
    BEGIN CATCH
        print '========================================================'
        print 'Error occured during loading bronze data'
        print 'Error Number : ' + error_number()
        print 'Error Message : ' + error_message()
        print '========================================================'
    END CATCH
END;
GO
exec bronze.load_bronze
GO