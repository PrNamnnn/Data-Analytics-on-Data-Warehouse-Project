/*
===========================================================
Load Product Data into Silver Layer
Source  : bronze.crm_prd_info
Target  : silver.crm_prd_info

Description:
- Extract category ID from product key
- Clean and transform product attributes
- Standardize product line values
- Handle NULL cost values
- Generate product end date using LEAD()
===========================================================
*/

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

    -- Extract category id (first 5 chars, replace '-' with '_')
    REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,

    -- Extract actual product key
    SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,

    prd_nm,

    -- Replace NULL cost with 0
    ISNULL(prd_cost, 0) AS prd_cost,

    -- Standardize product line values
    CASE 
        WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
        WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
        WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
        WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
        ELSE 'n/a'
    END AS prd_line,

    prd_start_dt,

    -- Calculate end date (1 day before next start date)
    DATEADD(
        DAY, 
        -1, 
        LEAD(prd_start_dt) OVER (
            PARTITION BY prd_key 
            ORDER BY prd_start_dt
        )
    ) AS prd_end_dt

FROM bronze.crm_prd_info;