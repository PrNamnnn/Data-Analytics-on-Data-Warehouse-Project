/* ===================================================
    CUSTOMER REPORT
===================================================

 PURPOSE:
This report provides a comprehensive view of customer behavior 
by consolidating key metrics, transaction data, and segmentation insights.
It is designed to support business decisions related to customer value,
retention, and engagement.

-----------------------------------------------------

 HIGHLIGHTS:

1 CUSTOMER DATA COLLECTION
- Captures essential customer attributes:
  • First Name, Last Name
  • Age (derived from birth_date)
  • Transaction details (orders, sales, quantity)

-----------------------------------------------------

2️ CUSTOMER SEGMENTATION
- Customers are classified based on spending behavior and tenure:

  • VIP      → High spenders with long-term engagement
  • Regular  → Moderate spenders with consistent history
  • New      → Recently acquired or low-tenure customers

- Additional segmentation based on age groups for demographic analysis

-----------------------------------------------------

3️ CUSTOMER-LEVEL METRICS
- Aggregated metrics calculated per customer:

  • Total Orders        → Number of distinct orders placed
  • Total Sales         → Total revenue generated
  • Total Quantity      → Total items purchased
  • Total Products      → Unique products purchased
  • Lifespan (Months)   → Duration between first and last purchase

-----------------------------------------------------

4️ KEY PERFORMANCE INDICATORS (KPIs)

- Recency:
  → Number of months since the last purchase
  → Helps identify inactive or churn-risk customers

- Average Order Value (AOV):
  → Total Sales ÷ Total Orders
  → Indicates spending behavior per transaction

- Average Monthly Spend:
  → Total Sales ÷ Customer Lifespan (in months)
  → Measures long-term customer value

-----------------------------------------------------

 USE CASES:
- Identify high-value customers (VIPs)
- Monitor customer retention and churn
- Analyze purchasing behavior and trends
- Support marketing and personalization strategies

=================================================== */

CREATE VIEW gold.report_customers as

/* ===================================================
   CUSTOMER REPORT (CLEAN VERSION)
=================================================== */

WITH overall AS (
    SELECT 
        c.customer_key,
        c.customer_number,
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        DATEDIFF(YEAR, c.birth_date, GETDATE()) AS age,
        fs.order_number,
        fs.product_key,
        fs.order_date,
        fs.quantity,
        fs.sales_amount
    FROM gold.fact_sales fs
    LEFT JOIN gold.dim_customers c
        ON fs.customer_key = c.customer_key
    WHERE fs.order_date IS NOT NULL
),

customer_agg AS (
    SELECT 
        customer_key,
        customer_name,
        customer_number,
        age,
        COUNT(DISTINCT order_number) AS total_orders,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,
        COUNT(DISTINCT product_key) AS total_products,
        MAX(order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM overall
    GROUP BY 
        customer_key,
        customer_name,
        customer_number,
        age
)

SELECT
    customer_key,
    customer_number,
    customer_name,
    age,

    -- Age Group Fix
    CASE 
        WHEN age < 20 THEN 'Under 20'
        WHEN age BETWEEN 20 AND 29 THEN '20-29'
        WHEN age BETWEEN 30 AND 39 THEN '30-39'
        WHEN age BETWEEN 40 AND 49 THEN '40-49'
        ELSE '50 & above' 
    END AS age_group,

    -- Customer Segmentation
    CASE
        WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
        ELSE 'New'
    END AS customer_segment,

    -- Recency Fix (based on last order)
    DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,

    total_orders,
    total_sales,
    total_quantity,
    total_products,
    last_order_date,
    lifespan,

    -- Avoid integer division
    CASE 
        WHEN total_orders = 0 THEN 0 
        ELSE CAST(total_sales AS FLOAT) / total_orders 
    END AS avg_order_value,

    -- Avg Monthly Spend Fix
    CASE 
        WHEN lifespan = 0 THEN total_sales
        ELSE CAST(total_sales AS FLOAT) / lifespan
    END AS avg_monthly_spend

FROM customer_agg;