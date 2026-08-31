# 03 - Advanced Data Analytics

Status: **In progress**

This project extends the completed Data Warehouse and EDA phases with advanced analytical SQL over the business-ready Gold layer.

The project follows the Advanced Analytics sequence from Data with Baraa's SQL course: change-over-time, cumulative analysis, performance analysis, part-to-whole analysis, data segmentation, and finally two consolidated stakeholder reports for customers and products.

## Analytical Source

The project continues to consume the existing Gold model:

- `gold.dim_customers`
- `gold.dim_products`
- `gold.fact_sales`

No new source ingestion or warehouse rebuild is required.

## Planned Script Sequence

1. [`01_change_over_time_analysis.sql`](scripts/01_change_over_time_analysis.sql)
2. [`02_cumulative_analysis.sql`](scripts/02_cumulative_analysis.sql)
3. [`03_performance_analysis.sql`](scripts/03_performance_analysis.sql)
4. [`04_part_to_whole_analysis.sql`](scripts/04_part_to_whole_analysis.sql)
5. [`05_data_segmentation.sql`](scripts/05_data_segmentation.sql)
6. [`06_customer_report.sql`](scripts/06_customer_report.sql)
7. [`07_product_report.sql`](scripts/07_product_report.sql)

The final reporting step is represented by two scripts because the course builds two separate consolidated reports: one for customers and one for products.

## Project Structure

```text
03_advanced_data_analytics/
├── README.md
├── scripts/
│   ├── 01_change_over_time_analysis.sql
│   ├── 02_cumulative_analysis.sql
│   ├── 03_performance_analysis.sql
│   ├── 04_part_to_whole_analysis.sql
│   ├── 05_data_segmentation.sql
│   ├── 06_customer_report.sql
│   └── 07_product_report.sql
├── docs/
│   └── README.md
└── learnings/
    └── README.md
```

## Working Rule

The SQL files contain only section headers at project start. Queries will be implemented while working through the course rather than pre-filled from the reference solution. Documentation and learning notes will be expanded as each analytical block is completed.

## Scope Boundary

This project focuses on advanced SQL analytics using the existing warehouse. It does not add unrelated tooling or prematurely turn the exercise into a BI, Python or cloud project.
