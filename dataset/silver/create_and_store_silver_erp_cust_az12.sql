/*
===========================================================
Load Customer Data (ERP AZ12) into Silver Layer
Source  : bronze.erp_cust_az12
Target  : silver.erp_cust_az12

Description:
- Clean customer ID (remove 'AW' prefix)
- Validate birthdate (future dates → NULL)
- Standardize gender values
===========================================================
*/

INSERT INTO silver.erp_cust_az12 (
    cid,
    bdate,
    gender
)

SELECT
    -- Customer ID Cleaning
    CASE 
        WHEN cid LIKE '%AW%' 
            THEN SUBSTRING(cid, 4, LEN(cid))
        ELSE cid 
    END AS cid,

    -- Birthdate Validation
    CASE 
        WHEN bdate > GETDATE() 
            THEN NULL 
        ELSE bdate 
    END AS bdate,

    -- Gender Standardization
    CASE 
        WHEN TRIM(gender) LIKE '%F%' THEN 'Female'
        WHEN TRIM(gender) LIKE '%M%' THEN 'Male'
        ELSE 'n/a'
    END AS gender

FROM bronze.erp_cust_az12;