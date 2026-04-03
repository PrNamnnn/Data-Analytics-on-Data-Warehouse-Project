/*
===============================================================================
PRODUCT REPORT
===============================================================================
*/

IF OBJECT_ID('gold.report_products', 'V') IS NOT NULL
    DROP VIEW gold.report_products;
GO

CREATE VIEW gold.report_products AS

WITH base_query AS (
    /*---------------------------------------------------------------------------
    1) Base Layer: Join fact + dimension tables
    ---------------------------------------------------------------------------*/
    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,
        p.product_key,
        p.product_name,
        p.category_type,
        p.subcategory,
        p.cost
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
),

product_agg AS (
    /*---------------------------------------------------------------------------
    2) Aggregation Layer: Product-level metrics
    ---------------------------------------------------------------------------*/
    SELECT
        product_key,
        product_name,
        category_type,
        subcategory,
        cost,

        MIN(order_date) AS first_sale_date,
        MAX(order_date) AS last_sale_date,

        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan,

        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,

        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,

        -- Better avg selling price (safe division)
        ROUND(
            SUM(sales_amount) / NULLIF(SUM(quantity), 0), 
        2) AS avg_selling_price

    FROM base_query
    GROUP BY
        product_key,
        product_name,
        category_type,
        subcategory,
        cost
)

SELECT 
    product_key,
    product_name,
    category_type,
    subcategory,
    cost,

    first_sale_date,
    last_sale_date,

    -- Recency (correct)
    DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months,

    -- Segmentation (clean thresholds)
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,

    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,

    /*---------------------------------------------------------------------------
    KPIs
    ---------------------------------------------------------------------------*/

    -- Average Order Revenue (fix integer division)
    CASE 
        WHEN total_orders = 0 THEN 0
        ELSE CAST(total_sales AS FLOAT) / total_orders
    END AS avg_order_revenue,

    -- Average Monthly Revenue
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE CAST(total_sales AS FLOAT) / lifespan
    END AS avg_monthly_revenue

FROM product_agg;