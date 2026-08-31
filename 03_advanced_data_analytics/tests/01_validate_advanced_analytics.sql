-- ADVANCED ANALYTICS VALIDATION
-- Run after 06_customer_report.sql and 07_product_report.sql.

USE DataWarehouse;
GO

-- Views must exist.
IF OBJECT_ID('gold.report_customers', 'V') IS NULL
    THROW 51001, 'Validation failed: gold.report_customers does not exist.', 1;

IF OBJECT_ID('gold.report_products', 'V') IS NULL
    THROW 51002, 'Validation failed: gold.report_products does not exist.', 1;

-- Report grains must be unique.
IF EXISTS (
    SELECT customer_key
    FROM gold.report_customers
    GROUP BY customer_key
    HAVING COUNT(*) > 1
)
    THROW 51003, 'Validation failed: duplicate customer_key in gold.report_customers.', 1;

IF EXISTS (
    SELECT product_key
    FROM gold.report_products
    GROUP BY product_key
    HAVING COUNT(*) > 1
)
    THROW 51004, 'Validation failed: duplicate product_key in gold.report_products.', 1;

-- Fact-to-report populations must be preserved at the intended grains.
DECLARE @fact_customer_count BIGINT = (
    SELECT COUNT(DISTINCT customer_key)
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
);
DECLARE @report_customer_count BIGINT = (
    SELECT COUNT(*)
    FROM gold.report_customers
);

IF @fact_customer_count <> @report_customer_count
    THROW 51005, 'Validation failed: customer report row count does not match distinct fact customers.', 1;

DECLARE @fact_product_count BIGINT = (
    SELECT COUNT(DISTINCT product_key)
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
);
DECLARE @report_product_count BIGINT = (
    SELECT COUNT(*)
    FROM gold.report_products
);

IF @fact_product_count <> @report_product_count
    THROW 51006, 'Validation failed: product report row count does not match distinct sold products.', 1;

-- Aggregated sales and quantity must reconcile back to the fact.
DECLARE @fact_sales BIGINT = (
    SELECT SUM(CAST(sales_amount AS BIGINT))
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
);
DECLARE @customer_report_sales BIGINT = (
    SELECT SUM(CAST(total_sales AS BIGINT))
    FROM gold.report_customers
);
DECLARE @product_report_sales BIGINT = (
    SELECT SUM(CAST(total_sales AS BIGINT))
    FROM gold.report_products
);

IF @fact_sales <> @customer_report_sales
    THROW 51007, 'Validation failed: customer report total sales do not reconcile to fact_sales.', 1;

IF @fact_sales <> @product_report_sales
    THROW 51008, 'Validation failed: product report total sales do not reconcile to fact_sales.', 1;

DECLARE @fact_quantity BIGINT = (
    SELECT SUM(CAST(quantity AS BIGINT))
    FROM gold.fact_sales
    WHERE order_date IS NOT NULL
);
DECLARE @customer_report_quantity BIGINT = (
    SELECT SUM(CAST(total_quantity AS BIGINT))
    FROM gold.report_customers
);
DECLARE @product_report_quantity BIGINT = (
    SELECT SUM(CAST(total_quantity AS BIGINT))
    FROM gold.report_products
);

IF @fact_quantity <> @customer_report_quantity
    THROW 51009, 'Validation failed: customer report quantity does not reconcile to fact_sales.', 1;

IF @fact_quantity <> @product_report_quantity
    THROW 51010, 'Validation failed: product report quantity does not reconcile to fact_sales.', 1;

-- Segment domains must stay within the documented contracts.
IF EXISTS (
    SELECT 1
    FROM gold.report_customers
    WHERE customer_segment NOT IN ('VIP', 'Regular', 'New')
)
    THROW 51011, 'Validation failed: unexpected customer_segment value.', 1;

IF EXISTS (
    SELECT 1
    FROM gold.report_products
    WHERE product_segment NOT IN ('High-Performer', 'Mid-Range', 'Low-Performer')
)
    THROW 51012, 'Validation failed: unexpected product_segment value.', 1;

-- Core report keys and metrics must not be null or negative.
IF EXISTS (
    SELECT 1
    FROM gold.report_customers
    WHERE customer_key IS NULL
       OR total_orders < 0
       OR total_sales < 0
       OR total_quantity < 0
       OR total_products < 0
       OR lifespan < 0
)
    THROW 51013, 'Validation failed: invalid customer report key or metric.', 1;

IF EXISTS (
    SELECT 1
    FROM gold.report_products
    WHERE product_key IS NULL
       OR total_orders < 0
       OR total_sales < 0
       OR total_quantity < 0
       OR total_customers < 0
       OR lifespan < 0
)
    THROW 51014, 'Validation failed: invalid product report key or metric.', 1;

PRINT 'Advanced analytics report validation passed.';
