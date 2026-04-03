/* ===========================================================

   SILVER LAYER FULL LOAD SCRIPT (IDEMPOTENT)

   Source Layer : bronze
   Target Layer : silver

   Description :
   This script performs a full reload of all Silver layer tables.
   Each table is truncated before loading to ensure fresh and 
   consistent data on every execution.

   Transformations Included:
   - Data cleaning (TRIM, NULL handling)
   - Standardization of categorical values
   - Deduplication using ROW_NUMBER()
   - Derivation of calculated fields
   - Date validation and conversion
   - Surrogate transformations (e.g., category extraction)

   Execution Order:
   1. crm_cust_info
   2. crm_prd_info
   3. crm_sales_details
   4. erp_px_cat_g1v2
   5. erp_cust_az12
   6. erp_loc_a101

   Note:
   - Uses TRUNCATE for fast reload
   - Ensure no FK constraints block truncation

=========================================================== */
CREATE OR ALTER PROCEDURE silver.load_silver 
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        DECLARE @cnt INT, @start_time DATETIME, @end_time DATETIME, @start_batch DATETIME, @end_batch DATETIME;
        PRINT '========== Silver Load Started ==========';
        SET @start_batch = GETDATE();
        ------------------------------------------------------------
        -- 1. Load Customer Info
        ------------------------------------------------------------
        PRINT 'Loading: crm_cust_info';

        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.crm_cust_info;

        INSERT INTO silver.crm_cust_info (
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gender,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),

            CASE 
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'n/a'
            END,

            CASE 
                WHEN UPPER(TRIM(cst_gender)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gender)) = 'M' THEN 'Male'
                ELSE 'n/a'
            END,

            cst_create_date
        FROM (
            SELECT *,
                   ROW_NUMBER() OVER (
                       PARTITION BY cst_id 
                       ORDER BY cst_create_date
                   ) AS rnk
            FROM bronze.crm_cust_info
            WHERE cst_id IS NOT NULL
        ) t
        WHERE rnk = 1;
        SET @end_time = GETDATE();

        PRINT 'Time Taken to Load Rows (crm_cust_info): ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'Seconds';


        ------------------------------------------------------------
        -- 2. Load Product Info
        ------------------------------------------------------------
        PRINT 'Loading: crm_prd_info';

        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.crm_prd_info;

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
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_'),
            SUBSTRING(prd_key, 7, LEN(prd_key)),
            prd_nm,
            ISNULL(prd_cost, 0),

            CASE 
                WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
                ELSE 'n/a'
            END,

            prd_start_dt,

            DATEADD(
                DAY, 
                -1, 
                LEAD(prd_start_dt) OVER (
                    PARTITION BY prd_key 
                    ORDER BY prd_start_dt
                )
            )
        FROM bronze.crm_prd_info;
        SET @end_time = GETDATE();

        PRINT 'Time Taken to Load Rows (crm_prd_info): ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'Seconds';


        ------------------------------------------------------------
        -- 3. Load Sales Details
        ------------------------------------------------------------
        PRINT 'Loading: crm_sales_details';

        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.crm_sales_details;

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

            CASE 
                WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END,

            CASE 
                WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END,

            CASE 
                WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END,

            CASE 
                WHEN sls_sales <= 0 OR sls_sales IS NULL 
                    THEN sls_quantity * ABS(sls_price)
                ELSE ABS(sls_sales)
            END,

            sls_quantity,

            CASE 
                WHEN sls_price <= 0 OR sls_price IS NULL 
                    THEN sls_sales / NULLIF(sls_quantity, 0)
                ELSE ABS(sls_price)
            END

        FROM bronze.crm_sales_details;

        SET @end_time = GETDATE();

        PRINT 'Time Taken to Load Rows (crm_sales_details): ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'Seconds';


        ------------------------------------------------------------
        -- 4. Load Product Category
        ------------------------------------------------------------
        PRINT 'Loading: erp_px_cat_g1v2';

        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        INSERT INTO silver.erp_px_cat_g1v2 (
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT *
        FROM bronze.erp_px_cat_g1v2;
        SET @end_time = GETDATE();

        PRINT 'Time Taken to Load Rows (erp_px_cat_g1v2): ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'Seconds';


        ------------------------------------------------------------
        -- 5. Load ERP Customer
        ------------------------------------------------------------
        PRINT 'Loading: erp_cust_az12';

        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.erp_cust_az12;

        INSERT INTO silver.erp_cust_az12 (
            cid,
            bdate,
            gender
        )
        SELECT
            CASE 
                WHEN cid LIKE '%AW%' 
                    THEN SUBSTRING(cid, 4, LEN(cid))
                ELSE cid 
            END,

            CASE 
                WHEN bdate > GETDATE() THEN NULL 
                ELSE bdate 
            END,

            CASE 
                WHEN TRIM(gender) LIKE '%F%' THEN 'Female'
                WHEN TRIM(gender) LIKE '%M%' THEN 'Male'
                ELSE 'n/a'
            END

        FROM bronze.erp_cust_az12;
        SET @end_time = GETDATE();

        PRINT 'Time Taken to Load Rows (erp_cust_az12): ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'Seconds';


        ------------------------------------------------------------
        -- 6. Load Location
        ------------------------------------------------------------
        PRINT 'Loading: erp_loc_a101';

        SET @start_time = GETDATE();
        TRUNCATE TABLE silver.erp_loc_a101;

        INSERT INTO silver.erp_loc_a101 (
            cid,
            cntry
        )
        SELECT 
            REPLACE(cid, '-', ''),
    
            CASE 
                WHEN TRIM(cntry) IN ('USA', 'US') THEN 'United States'
                WHEN TRIM(cntry) = 'DE' THEN 'Germany'
                WHEN TRIM(cntry) IS NULL 
                     OR TRIM(cntry) = '' THEN 'n/a'
                ELSE TRIM(cntry)
            END

        FROM bronze.erp_loc_a101;
        SET @end_time = GETDATE();

        PRINT 'Time Taken to Load Rows (erp_loc_a101): ' + CAST(DATEDIFF(second, @start_time, @end_time) AS VARCHAR) + 'Seconds';

        SET @end_batch = GETDATE();
        print 'Total Time taken to load Everything : ' + CAST(DATEDIFF(second, @start_batch, @end_batch) as NVARCHAR) + 'Seconds'; 
        PRINT '========== Silver Load Completed Successfully ==========';


    END TRY
    BEGIN CATCH
        print '========================================================'
        print 'Error occured during loading bronze data'
        print 'Error Number : ' + error_number()
        print 'Error Message : ' + error_message()
        print '========================================================'
    END CATCH
END
GO
EXEC silver.load_silver
GO