# 03 - Advanced Data Analytics

**Status: Complete**

This project is the final analytical phase of the SQL portfolio. It consumes the validated Gold star schema from the Data Warehouse project and turns exploratory SQL into **time analysis, benchmarking, segmentation and reusable customer/product reporting views**.

> **10-second summary:** five analytical scripts use date functions, CTEs and window functions to answer higher-level business questions; two final scripts publish `gold.report_customers` and `gold.report_products`; a validation script checks report grain and reconciles sales/quantity back to `gold.fact_sales`.

## Analytical Source and Output

Base Gold model:

- `gold.dim_customers`
- `gold.dim_products`
- `gold.fact_sales`

Derived analytical views created by this project:

- `gold.report_customers` - one row per customer represented in valid-dated sales
- `gold.report_products` - one row per product represented in valid-dated sales

The first five scripts are read-only analysis. The final two scripts create or alter reusable views.

## Workflow

```text
Gold star schema
      |
      v
1. Change over time
      |
      v
2. Cumulative analysis
      |
      v
3. Performance analysis
      |
      v
4. Part-to-whole analysis
      |
      v
5. Data segmentation
      |
      v
6. Customer report
      |
      v
7. Product report
      |
      v
Report validation
```

This follows the Advanced Analytics roadmap from the Data with Baraa project while keeping targeted refinements for precision, rerunnability and documentation.

## Implemented Scripts

| Step | Script | Main analytical pattern |
|---:|---|---|
| 1 | [`01_change_over_time_analysis.sql`](scripts/01_change_over_time_analysis.sql) | sales/customer/quantity trends across year and month grains |
| 2 | [`02_cumulative_analysis.sql`](scripts/02_cumulative_analysis.sql) | expanding running total and average with window frames |
| 3 | [`03_performance_analysis.sql`](scripts/03_performance_analysis.sql) | product performance vs. own historical average and previous year |
| 4 | [`04_part_to_whole_analysis.sql`](scripts/04_part_to_whole_analysis.sql) | category contribution to total sales |
| 5 | [`05_data_segmentation.sql`](scripts/05_data_segmentation.sql) | cost-band and customer-value segmentation |
| 6 | [`06_customer_report.sql`](scripts/06_customer_report.sql) | reusable customer metrics, age groups, segments and KPIs |
| 7 | [`07_product_report.sql`](scripts/07_product_report.sql) | reusable sold-product metrics, performance segments and KPIs |

## Selected Reproducible Findings

For the supplied dataset snapshot:

### Customer segmentation

| Segment | Customers |
|---|---:|
| New | **14,631** |
| Regular | **2,198** |
| VIP | **1,655** |

### Sold-product performance segmentation

| Segment | Products |
|---|---:|
| High-Performer | **66** |
| Mid-Range | **58** |
| Low-Performer | **6** |

The product report contains **130 sold products**. This is intentionally different from the **295 current products** in `gold.dim_products`: the report starts from `gold.fact_sales`, so products without sales are not present.

See [`docs/findings.md`](docs/findings.md) for additional results and interpretation boundaries.

## Report Contracts

### `gold.report_customers`

Provides:

- customer identity;
- approximate age and age group;
- VIP / Regular / New segment;
- last order date and recency;
- order, sales, quantity and product counts;
- customer lifespan;
- average order value;
- average monthly spend.

### `gold.report_products`

Provides:

- product identity and hierarchy;
- High-Performer / Mid-Range / Low-Performer segment;
- last sale date and recency;
- order, sales, quantity and unique-customer counts;
- product sales lifespan;
- weighted average selling price;
- average order revenue;
- average monthly revenue.

Column-level definitions and caveats: [`docs/report_catalog.md`](docs/report_catalog.md).

## Validation

Run [`tests/01_validate_advanced_analytics.sql`](tests/01_validate_advanced_analytics.sql) after both report views are created.

The validation script checks:

- both views exist;
- customer/product keys are unique at report grain;
- report row counts match distinct fact populations;
- total sales reconcile back to `gold.fact_sales`;
- total quantity reconciles back to `gold.fact_sales`;
- segment values stay within documented domains;
- core report keys and measures are non-null/non-negative where required.

This prevents a report view from being accepted merely because it compiles.

## How to Run

Prerequisite: complete projects 01 and 02 and have the validated `DataWarehouse` Gold layer available.

Run in numeric order:

```text
scripts/01_change_over_time_analysis.sql
scripts/02_cumulative_analysis.sql
scripts/03_performance_analysis.sql
scripts/04_part_to_whole_analysis.sql
scripts/05_data_segmentation.sql
scripts/06_customer_report.sql
scripts/07_product_report.sql
tests/01_validate_advanced_analytics.sql
```

The scripts explicitly select `DataWarehouse`. `CREATE OR ALTER VIEW` makes the two report scripts rerunnable.

## Documentation

- [`docs/README.md`](docs/README.md) - documentation index
- [`docs/analysis_overview.md`](docs/analysis_overview.md) - analytical architecture, grains and methods
- [`docs/query_catalog.md`](docs/query_catalog.md) - questions mapped to executable SQL
- [`docs/report_catalog.md`](docs/report_catalog.md) - report-view contract and KPI definitions
- [`docs/findings.md`](docs/findings.md) - verified snapshot findings and caveats
- [`learnings/README.md`](learnings/README.md) - seven-part analytical learning journal
- [`tests/README.md`](tests/README.md) - validation scope

## Correctness and Design Notes

Targeted refinements made during final QA:

- decimal casts prevent silent integer truncation in `AVG` and division-based KPIs;
- formatted month labels are ordered by the underlying date rather than alphabetically;
- performance analysis distinguishes the first observed year from a true "No Change" result;
- stable product keys are retained in performance partitions;
- part-to-whole percentages remain numeric rather than presentation strings;
- report views use `CREATE OR ALTER VIEW` for rerunnability;
- null customer ages map to `Unknown` instead of being incorrectly classified as `50 and above`;
- the product report exposes a weighted average selling price (`total_sales / total_quantity`).

## Scope and Interpretation Boundaries

- `DATEDIFF` counts datepart boundaries; `lifespan` is not an exact elapsed-month fraction.
- `age` uses `DATEDIFF(YEAR, birthdate, GETDATE())`, so it is approximate around birthdays.
- `age` and `recency` are time-dependent because the views use `GETDATE()`.
- the cumulative average is an expanding window from the beginning of the series, not a fixed three-month window.
- customer/product segments are rule-based analytical categories, not predictive models.
- the product report is fact-anchored and therefore covers sold products only.

## Skills Demonstrated

- analytical date-grain selection;
- CTE decomposition;
- window aggregates and explicit window frames;
- `LAG` for prior-period comparison;
- partition-aware benchmarking;
- percentage-of-total analysis;
- rule-based segmentation;
- reusable SQL view design;
- KPI definition and numeric precision;
- analytical report validation and reconciliation.

## Attribution

The analytical roadmap, learning scenario and source dataset originate from **Data with Baraa's SQL Data Analytics project**. This repository contains my implementation, final QA, documentation and targeted correctness refinements. See [`../ACKNOWLEDGEMENTS.md`](../ACKNOWLEDGEMENTS.md).
