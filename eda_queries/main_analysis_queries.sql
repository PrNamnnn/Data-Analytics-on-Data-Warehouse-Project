/* ===================================================
   📌 1. METADATA EXPLORATION
=================================================== */

-- All tables
SELECT * 
FROM INFORMATION_SCHEMA.TABLES;

-- Columns of dim_customers
SELECT * 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_customers';

-- Product hierarchy
SELECT DISTINCT 
    category_type, subcategory, product_name 
FROM gold.dim_products
ORDER BY 1,2,3;


/* ===================================================
   📅 2. DATE EXPLORATION
=================================================== */

-- Orders date range
SELECT 
    MIN(order_date) AS oldest_date,
    MAX(order_date) AS latest_date,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS total_months
FROM gold.fact_sales;

-- Customer age range
SELECT 
    MIN(birth_date) AS oldest_customer,
    MAX(birth_date) AS youngest_customer,
    DATEDIFF(YEAR, MIN(birth_date), GETDATE()) AS max_age,
    DATEDIFF(YEAR, MAX(birth_date), GETDATE()) AS min_age
FROM gold.dim_customers;


/* ===================================================
   📊 3. CUSTOMER MEASURE EXPLORATION
=================================================== */

SELECT 
    customer_id,
    SUM(sales_amount) AS total_sales,
    COUNT(*) AS num_visits
FROM gold.fact_sales
GROUP BY customer_id
ORDER BY total_sales DESC, num_visits DESC;


/* ===================================================
   📈 4. KEY BUSINESS METRICS
=================================================== */

-- Combined KPI View
SELECT 'Total Sales'        AS metric, SUM(sales_amount)              FROM gold.fact_sales
UNION ALL
SELECT 'Total Quantity',         SUM(quantity)                  FROM gold.fact_sales
UNION ALL
SELECT 'Average Price',          AVG(price)                     FROM gold.fact_sales
UNION ALL
SELECT 'Total Orders',           COUNT(DISTINCT order_number)   FROM gold.fact_sales
UNION ALL
SELECT 'Total Customers',        COUNT(customer_id)             FROM gold.dim_customers
UNION ALL
SELECT 'Total Products',         COUNT(product_id)              FROM gold.dim_products;


/* ===================================================
   🌍 5. DIMENSIONAL ANALYSIS
=================================================== */

-- Customers by country
SELECT 
    country,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY country
ORDER BY total_customers DESC;

-- Customers by gender
SELECT 
    gender,
    COUNT(customer_key) AS total_customers
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers DESC;

-- Products by category
SELECT 
    category_type,
    COUNT(product_key) AS total_products
FROM gold.dim_products
GROUP BY category_type
ORDER BY total_products DESC;

-- Avg cost per category
SELECT 
    category_type,
    AVG(cost) AS avg_cost
FROM gold.dim_products
GROUP BY category_type
ORDER BY avg_cost DESC;


/* ===================================================
   💰 6. REVENUE ANALYSIS
=================================================== */

-- Revenue by category
SELECT 
    p.category_type,
    SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products p 
    ON fs.product_key = p.product_key
GROUP BY p.category_type
ORDER BY total_revenue DESC;

-- Revenue by customer
SELECT 
    c.customer_key,
    c.first_name,
    c.last_name,
    SUM(fs.sales_amount) AS total_revenue
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers c 
    ON c.customer_key = fs.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY total_revenue DESC;

-- Quantity distribution by country
SELECT 
    c.country,
    SUM(fs.quantity) AS total_quantity
FROM gold.fact_sales fs
LEFT JOIN gold.dim_customers c 
    ON c.customer_key = fs.customer_key
GROUP BY c.country
ORDER BY total_quantity DESC;


/* ===================================================
   🏆 7. PRODUCT PERFORMANCE
=================================================== */

-- Top 5 products
SELECT TOP 5
    p.product_name,
    SUM(fs.sales_amount) AS total_sales
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products p 
    ON fs.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_sales DESC;

-- Bottom 5 products
SELECT TOP 5
    p.product_name,
    SUM(fs.sales_amount) AS total_sales
FROM gold.fact_sales fs
LEFT JOIN gold.dim_products p 
    ON fs.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_sales ASC;


/* ===================================================
   📆 8. TIME SERIES ANALYSIS
=================================================== */

-- Monthly trends
SELECT 
    YEAR(order_date)  AS year,
    MONTH(order_date) AS month,
    SUM(sales_amount) AS total_sales,
    COUNT(customer_key) AS customer_count,
    SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY year, month;


/* ===================================================
   📈 9. CUMULATIVE ANALYSIS
=================================================== */

WITH monthly_data AS (
    SELECT 
        DATETRUNC(MONTH, order_date) AS order_month,
        SUM(sales_amount) AS total_sales,
        COUNT(customer_key) AS customer_count
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
    GROUP BY DATETRUNC(MONTH, order_date)
)

SELECT 
    order_month,
    total_sales,
    customer_count,
    SUM(total_sales) OVER (ORDER BY order_month) AS cumulative_sales,
    SUM(customer_count) OVER (ORDER BY order_month) AS cumulative_customers
FROM monthly_data
ORDER BY order_month;


/* ===================================================
   ⚡ 10. ADVANCED ANALYSIS
=================================================== */

-- Category contribution
WITH category_sales AS (
    SELECT 
        p.category_type,
        SUM(fs.sales_amount) AS total_sales
    FROM gold.fact_sales fs
    LEFT JOIN gold.dim_products p 
        ON fs.product_key = p.product_key
    GROUP BY p.category_type
)

SELECT *,
    CONCAT(
        ROUND(total_sales * 100.0 / SUM(total_sales) OVER (), 2),
        '%'
    ) AS contribution_pct
FROM category_sales
ORDER BY total_sales DESC;


/* ===================================================
   🧩 11. SEGMENTATION
=================================================== */

-- Product segmentation
WITH product_segments AS (
    SELECT 
        product_name,
        category_type,
        CASE 
            WHEN cost < 100 THEN 'Below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS segment
    FROM gold.dim_products
)

SELECT 
    segment,
    COUNT(*) AS product_count
FROM product_segments
GROUP BY segment;


/* ===================================================
   👥 12. CUSTOMER SEGMENTATION
=================================================== */

WITH customer_seg AS (
    SELECT 
        c.customer_key,
        SUM(fs.sales_amount) AS total_spend,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS tenure,
        CASE 
            WHEN SUM(fs.sales_amount) > 5000 AND 
                 DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) >= 12 
                 THEN 'VIP'
            WHEN SUM(fs.sales_amount) <= 5000 AND 
                 DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) >= 12 
                 THEN 'Regular'
            ELSE 'New'
        END AS segment
    FROM gold.dim_customers c
    LEFT JOIN gold.fact_sales fs 
        ON fs.customer_key = c.customer_key
    GROUP BY c.customer_key
)

SELECT 
    segment,
    COUNT(*) AS customer_count
FROM customer_seg
GROUP BY segment;