/*
=============================================================
View: gold.dim_products
Purpose:
    - Create Product Dimension Table
    - Combine product data with category information
    - Filter only active products (no end date)
=============================================================
*/

CREATE OR ALTER VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY p.prd_start_dt) AS product_key,
    p.prd_id           AS product_id,
    p.prd_key          AS product_number,
    p.prd_nm           AS product_name,
    p.cat_id           AS category_id,
    c.cat              AS category_type,
    c.subcat           AS subcategory,
    c.maintenance      AS maintenance,
    p.prd_cost         AS cost,
    p.prd_line         AS product_line,
    p.prd_start_dt     AS start_date
FROM silver.crm_prd_info p
LEFT JOIN silver.erp_px_cat_g1v2 c
    ON p.cat_id = c.id
WHERE p.prd_end_dt IS NULL;