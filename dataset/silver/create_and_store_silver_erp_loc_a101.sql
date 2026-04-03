/* ===========================================================

   Load Location Data into Silver Layer

   Source      : bronze.erp_loc_a101
   Target      : silver.erp_loc_a101

   Description :
   - Remove hyphens from customer ID (cid)
   - Standardize country names
   - Map country codes to full names (e.g., US → United States)
   - Handle NULL and empty country values
   - Trim whitespace from country field

=========================================================== */

INSERT INTO silver.erp_loc_a101 (
    cid,
    cntry
)
SELECT 
    REPLACE(cid, '-', '') AS cid,
    
    CASE 
        WHEN TRIM(cntry) IN ('USA', 'US') THEN 'United States'
        WHEN TRIM(cntry) = 'DE' THEN 'Germany'
        WHEN TRIM(cntry) IS NULL 
             OR TRIM(cntry) = '' THEN 'n/a'
        ELSE TRIM(cntry)
    END AS cntry

FROM bronze.erp_loc_a101;