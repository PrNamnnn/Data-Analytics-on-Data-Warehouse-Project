/*
===========================================================
Load Cleaned Customer Data into Silver Layer
Source  : bronze.crm_cust_info
Target  : silver.crm_cust_info
Purpose : 
    - Remove duplicates (keep earliest record per customer)
    - Standardize text fields
    - Normalize marital status and gender values
===========================================================
*/



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
    
    -- Clean names (remove extra spaces)
    TRIM(cst_firstname) AS cst_firstname,
    TRIM(cst_lastname)  AS cst_lastname,

    -- Standardize marital status
    CASE 
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
        WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        ELSE 'n/a'
    END AS cst_marital_status,

    -- Standardize gender
    CASE 
        WHEN UPPER(TRIM(cst_gender)) = 'F' THEN 'Female'
        WHEN UPPER(TRIM(cst_gender)) = 'M' THEN 'Male'
        ELSE 'n/a'
    END AS cst_gender,

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

-- Keep only first (earliest) record per customer
WHERE rnk = 1;