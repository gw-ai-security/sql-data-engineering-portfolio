-- 07 - PRODUCT REPORT
-- Consolidated product metrics, behavior, segmentation and KPIs.

/*
===============================================================================
Product Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.

Highlights:
    1. Gathers essential fields such as product name, category, subcategory,
       and cost.
    2. Segments products by revenue into:
        - High-Performer
        - Mid-Range
        - Low-Performer
    3. Aggregates product-level metrics:
        - total orders
        - total sales
        - total quantity sold
        - total customers (unique)
        - lifespan (in months)
        - average selling price
    4. Calculates valuable KPIs:
        - recency (months since last sale)
        - average order revenue
        - average monthly revenue

===============================================================================
*/

GO

CREATE OR ALTER VIEW gold.report_products AS

-- 1) Base Query
-------------------------------------------------------------------------------
WITH base_query AS (

    SELECT
        f.order_number,
        f.order_date,
        f.customer_key,
        f.sales_amount,
        f.quantity,

        p.product_key,
        p.product_name,
        p.category,
        p.subcategory,
        p.cost

    FROM gold.fact_sales f

    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key

    WHERE f.order_date IS NOT NULL
),

-- 2) Product-level Aggregation
-------------------------------------------------------------------------------
product_aggregation AS (

    SELECT
        product_key,
        product_name,
        category,
        subcategory,
        cost,

        COUNT(DISTINCT order_number) AS total_orders,
        COUNT(DISTINCT customer_key) AS total_customers,
        SUM(sales_amount) AS total_sales,
        SUM(quantity) AS total_quantity,

        MIN(order_date) AS first_sale_date,
        MAX(order_date) AS last_sale_date,

        DATEDIFF(
            MONTH,
            MIN(order_date),
            MAX(order_date)
        ) AS lifespan,

        CASE
            WHEN SUM(quantity) = 0 THEN 0
            ELSE SUM(sales_amount) / SUM(quantity)
        END AS avg_selling_price

    FROM base_query

    GROUP BY
        product_key,
        product_name,
        category,
        subcategory,
        cost
)

-- 3) Final Product Report
-------------------------------------------------------------------------------
SELECT
    product_key,
    product_name,
    category,
    subcategory,
    cost,

    -- Product Segmentation
    CASE
        WHEN total_sales > 50000 THEN 'High-Performer'
        WHEN total_sales >= 10000 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END AS product_segment,

    -- Recency
    last_sale_date,
    DATEDIFF(
        MONTH,
        last_sale_date,
        GETDATE()
    ) AS recency,

    -- Aggregated Measures
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    lifespan,
    avg_selling_price,

    -- Average Order Revenue
    CASE
        WHEN total_orders = 0 THEN 0
        ELSE total_sales / total_orders
    END AS avg_order_revenue,

    -- Average Monthly Revenue
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END AS avg_monthly_revenue

FROM product_aggregation;

GO



SELECT * FROM gold.report_products
