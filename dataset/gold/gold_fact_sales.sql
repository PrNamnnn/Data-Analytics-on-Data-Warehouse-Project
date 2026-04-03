/*
=============================================================
View: gold.fact_sales
Purpose:
    - Create Sales Fact Table
    - Link with Product and Customer Dimensions
    - Provide metrics for analysis
=============================================================
*/

CREATE OR ALTER VIEW gold.fact_sales AS
SELECT 
    sd.sls_ord_num     AS order_number,
    pr.product_key,
    cu.customer_key,
    sd.sls_cust_id     AS customer_id,
    sd.sls_order_dt    AS order_date,
    sd.sls_ship_dt     AS ship_date,
    sd.sls_due_dt      AS due_date,
    sd.sls_sales       AS sales_amount,
    sd.sls_quantity    AS quantity,
    sd.sls_price       AS price

FROM silver.crm_sales_details sd

LEFT JOIN gold.dim_products pr
    ON pr.product_number = sd.sls_prd_key

LEFT JOIN gold.dim_customers cu
    ON cu.customer_id = sd.sls_cust_id;