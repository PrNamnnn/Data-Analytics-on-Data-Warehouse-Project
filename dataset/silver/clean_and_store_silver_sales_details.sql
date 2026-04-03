/*
===========================================================
Load Sales Details into Silver Layer
Source  : bronze.crm_sales_details
Target  : silver.crm_sales_details

Description:
- Clean and validate date fields (invalid → NULL)
- Handle negative or NULL sales values
- Derive missing sales and price values
- Ensure all monetary values are positive
===========================================================
*/

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

    -- Order Date Cleaning
    CASE 
        WHEN sls_order_dt <= 0 OR LEN(sls_order_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,

    -- Ship Date Cleaning
    CASE 
        WHEN sls_ship_dt <= 0 OR LEN(sls_ship_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,

    -- Due Date Cleaning
    CASE 
        WHEN sls_due_dt <= 0 OR LEN(sls_due_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt,

    -- Sales Calculation
    CASE 
        WHEN sls_sales <= 0 OR sls_sales IS NULL 
            THEN sls_quantity * ABS(sls_price)
        ELSE ABS(sls_sales)
    END AS sls_sales,

    sls_quantity,

    -- Price Calculation
    CASE 
        WHEN sls_price <= 0 OR sls_price IS NULL 
            THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE ABS(sls_price)
    END AS sls_price

FROM bronze.crm_sales_details;