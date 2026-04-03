/*
=============================================================
View: gold.dim_customers
Purpose:
    - Create Customer Dimension Table
    - Merge CRM and ERP customer data
    - Standardize gender information
=============================================================
*/

CREATE OR ALTER VIEW gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY c1.cst_id) AS customer_key,
    c1.cst_id              AS customer_id,
    c1.cst_key             AS customer_number,
    c1.cst_firstname       AS first_name,
    c1.cst_lastname        AS last_name,
    c1.cst_marital_status  AS marital_status,

    -- Gender resolution logic
    CASE 
        WHEN COALESCE(e1.gender, 'n/a') = 'n/a' 
            THEN c1.cst_gender
        ELSE e1.gender 
    END AS gender,

    c1.cst_create_date     AS create_date,
    e1.bdate               AS birth_date,
    e2.cntry               AS country

FROM silver.crm_cust_info c1
LEFT JOIN silver.erp_cust_az12 e1
    ON c1.cst_key = e1.cid
LEFT JOIN silver.erp_loc_a101 e2
    ON c1.cst_key = e2.cid;