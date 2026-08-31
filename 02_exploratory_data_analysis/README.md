# 02 - Exploratory Data Analysis

This project uses T-SQL to profile and explore the **business-ready Gold layer** produced by the completed Data Warehouse project. It turns the warehouse from a modeled dataset into an analytical surface: first understand the structure and domains, then establish key metrics, then compare and rank business dimensions.

> **10-second summary:** six focused SQL scripts inspect metadata, dimensions, date ranges, measures, magnitude and rankings across `gold.dim_customers`, `gold.dim_products` and `gold.fact_sales`. The project is read-only: it analyzes the validated Gold model without rebuilding or modifying the warehouse.

## Why This Project Exists

The Data Warehouse project answers: **Can the source data be ingested, cleaned, integrated and modeled correctly?**

This EDA project answers: **What data is available, what does it describe, and what first business insights can be derived from it?**

The workflow follows the EDA sequence used in Data with Baraa's SQL course while keeping this repository's existing Gold model as the analytical source.

## Analytical Source

| Gold object | Grain | Role |
|---|---|---|
| `gold.dim_customers` | one row per CRM customer | customer attributes and grouping dimensions |
| `gold.dim_products` | one row per current product | product hierarchy, cost and product attributes |
| `gold.fact_sales` | one row per source sales line | order dates and additive sales measures |

The validated warehouse snapshot contains **18,484 customers**, **295 current products** and **60,398 sales lines**. These numbers describe the supplied learning dataset, not production scale.

## EDA Workflow

```text
Gold star schema
      |
      v
1. Database exploration
      |
      v
2. Dimension exploration
      |
      v
3. Date-range exploration
      |
      v
4. Measure exploration
      |
      v
5. Magnitude analysis
      |
      v
6. Ranking analysis
```

This intentionally stops before trend, cumulative, performance, segmentation and reporting analysis. Those belong to [`03_advanced_data_analytics`](../03_advanced_data_analytics/).

## Implemented Scripts

| Step | Script | Analytical question | Main SQL concepts |
|---:|---|---|---|
| 1 | [`01_database_exploration.sql`](scripts/01_database_exploration.sql) | What objects and columns are available? | `INFORMATION_SCHEMA` |
| 2 | [`02_dimension_exploration.sql`](scripts/02_dimension_exploration.sql) | What categorical domains and hierarchies exist? | `DISTINCT`, `ORDER BY` |
| 3 | [`03_date_range_exploration.sql`](scripts/03_date_range_exploration.sql) | What time span does the dataset cover? | `MIN`, `MAX`, `DATEDIFF`, `GETDATE` |
| 4 | [`04_measure_exploration.sql`](scripts/04_measure_exploration.sql) | What are the main business totals and counts? | `SUM`, `AVG`, `COUNT`, `COUNT DISTINCT`, `UNION ALL` |
| 5 | [`05_magnitude_analysis.sql`](scripts/05_magnitude_analysis.sql) | How do measures differ across dimensions? | joins, aggregates, `GROUP BY`, `ORDER BY` |
| 6 | [`06_ranking_analysis.sql`](scripts/06_ranking_analysis.sql) | Which products, subcategories and customers rank highest or lowest? | `TOP`, `ROW_NUMBER`, subquery, aggregation |

## Selected Dataset Findings

The supplied snapshot produces the following reproducible profile:

- order activity ranges from **2010-12-29** to **2014-01-28**;
- **29,356,250** total sales across **27,659 distinct orders**;
- **60,423** items sold;
- **18,484** customers and **295** current products;
- the United States is the largest named customer market with **7,482 customers**;
- Bikes generate **28,316,272** in sales, about **96.46%** of total sales in this snapshot;
- `Mountain-200 Black- 46` is the highest-revenue product at **1,373,454**.

See [`docs/findings.md`](docs/findings.md) for the evidence, caveats and interpretation boundaries.

## How to Run

Prerequisite: complete [`01_data_warehouse`](../01_data_warehouse/) and have the `DataWarehouse` database with the three Gold views available.

In SSMS:

```sql
USE DataWarehouse;
GO
```

Then run the scripts in numeric order. The EDA scripts are analytical `SELECT` queries only; they do not alter warehouse objects or data.

## Documentation

- [`docs/README.md`](docs/README.md) - documentation index
- [`docs/analysis_overview.md`](docs/analysis_overview.md) - analytical model, scope and method
- [`docs/query_catalog.md`](docs/query_catalog.md) - business questions mapped to SQL evidence
- [`docs/findings.md`](docs/findings.md) - reproducible dataset findings and caveats
- [`learnings/README.md`](learnings/README.md) - learning journal for all six EDA scripts

## Skills Demonstrated

This project provides repository-verifiable evidence of:

- structured database discovery before analysis;
- distinguishing dimensions from measures by analytical role;
- reasoning about fact grain before counting business entities;
- temporal boundary analysis;
- aggregate and distinct-count semantics;
- dimension/measure analysis through joins and grouping;
- simple and window-function ranking patterns;
- explicit handling of analytical caveats such as `NULL` groups, date-boundary semantics and ties.

## Scope and Evidence

This is a **learning portfolio project**, not a claim of production analytics experience. The project uses the supplied Data with Baraa dataset and the warehouse implemented in this repository. Only implemented SQL, documented results and repository-verifiable artifacts are presented as evidence.

## Attribution

The project sequence, learning scenario and source dataset originate from **Data with Baraa's SQL course and project materials**. This repository contains my implementation, documentation and engineering learnings. See [`../ACKNOWLEDGEMENTS.md`](../ACKNOWLEDGEMENTS.md).
