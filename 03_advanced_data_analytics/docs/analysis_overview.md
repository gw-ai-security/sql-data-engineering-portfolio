# Advanced Analytics - Analysis Overview

## Purpose

Projects 01 and 02 establish a trustworthy analytical model and understand its contents. Project 03 asks more demanding questions of the same data:

```text
What changed?
What accumulated?
How did an entity perform against a reference?
How much does each part contribute?
Which analytical segment does an entity belong to?
How can the results be exposed as a reusable report contract?
```

## Analytical Architecture

```text
gold.dim_customers ----┐
                        |
gold.dim_products ----- +--> advanced analytical queries
                        |             |
gold.fact_sales --------┘             +--> gold.report_customers
                                      +--> gold.report_products
```

The warehouse's three base Gold views remain the source of truth. Project 03 does not repeat Bronze/Silver cleansing or CRM/ERP integration logic.

## Grain Matters at Every Step

The base fact grain is one source sales line per order/product combination. Advanced analyses deliberately change grain:

| Analysis | Result grain |
|---|---|
| Change over time | one row per selected period |
| Cumulative analysis | one row per month |
| Performance analysis | one row per product per year |
| Part-to-whole | one row per product category |
| Product cost segmentation | one row per cost segment |
| Customer segmentation | one row per customer segment |
| Customer report | one row per customer represented in valid-dated sales |
| Product report | one row per product represented in valid-dated sales |

A query can be syntactically correct while answering the wrong question if its grain is wrong.

## 1. Change Over Time

Pattern:

```text
Aggregate [Measure] BY [Date Grain]
```

The script demonstrates year, year/month and `DATETRUNC` month/year grains. `FORMAT` is included only for display labels; chronological ordering still uses the underlying date.

Key lesson: date values should remain dates for analytical logic. Strings are presentation artifacts.

## 2. Cumulative Analysis

The query uses two analytical levels:

1. aggregate sales and average price to month grain;
2. apply window functions over the monthly result.

The running total uses an explicit frame:

```text
UNBOUNDED PRECEDING -> CURRENT ROW
```

The average uses the same expanding frame. It is therefore a cumulative/expanding average, not a fixed-width three-month moving average.

Decimal casting is explicit because SQL Server `AVG(INT)` returns an integer-family result and can silently lose fractional precision.

## 3. Performance Analysis

Yearly sales are calculated per stable `product_key`, then compared with:

- the product's average yearly sales using `AVG(...) OVER (PARTITION BY product_key)`;
- the previous observed year using `LAG(...)`.

The first year for a product has no prior-year reference. The final implementation labels that condition `No Prior Year` rather than incorrectly treating the `NULL` comparison as `No Change`.

## 4. Part-to-Whole

Pattern:

```text
category sales / overall sales * 100
```

The query first aggregates by category, then uses `SUM(total_sales) OVER ()` to expose the whole alongside every part. Percentage output remains numeric so downstream consumers can sort, filter or format it without parsing a `%` string.

## 5. Data Segmentation

Two rule-based segmentations are implemented:

### Product cost bands

- Below 100
- 100-500
- 500-1000
- Above 1000

### Customer value/lifespan segments

- **VIP:** lifespan >= 12 months and total spending > 5,000
- **Regular:** lifespan >= 12 months and total spending <= 5,000
- **New:** lifespan < 12 months

These are deterministic business rules, not statistical clusters or predictive classifications.

## 6. Customer Report

The report is built as a two-stage CTE pipeline:

```text
fact + customer attributes
        -> customer aggregation
        -> segment + KPI projection
        -> gold.report_customers
```

The aggregation grain is one customer. `COUNT(DISTINCT order_number)` is used because the underlying fact has one row per sales line rather than one row per order.

## 7. Product Report

The report follows the same pattern at product grain:

```text
fact + product attributes
        -> product aggregation
        -> segment + KPI projection
        -> gold.report_products
```

Because the base is `gold.fact_sales`, the view represents **sold products**. It intentionally does not fabricate zero-sales rows for products that never occur in the fact.

`avg_selling_price` is defined as weighted unit revenue:

```text
total_sales / total_quantity
```

This differs from an unweighted average of line-level unit prices and is documented as an explicit metric choice.

## Report Validation

The final validation script checks the analytical contract, not merely syntax:

- view existence;
- one row per report key;
- fact-to-report population reconciliation;
- sales and quantity preservation;
- allowed segment domains;
- invalid key/metric conditions.

The same engineering principle used in Gold modeling therefore carries into the reporting layer: **compilation is not proof of correctness**.
