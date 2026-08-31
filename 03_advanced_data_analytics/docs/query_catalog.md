# Advanced Analytics - Query Catalog

This catalog maps each implemented analytical question to its executable SQL evidence.

## 01 - Change Over Time

Script: [`../scripts/01_change_over_time_analysis.sql`](../scripts/01_change_over_time_analysis.sql)

| Question | SQL pattern |
|---|---|
| How do sales, customers and quantity change by year? | `YEAR`, aggregates, `GROUP BY` |
| How do they change by year/month? | multi-column date grain |
| How can month/year be represented as real date values? | `DATETRUNC` |
| How can a display label be formatted without breaking chronological order? | `FORMAT` + sort by underlying date |

## 02 - Cumulative Analysis

Script: [`../scripts/02_cumulative_analysis.sql`](../scripts/02_cumulative_analysis.sql)

| Question | SQL pattern |
|---|---|
| What is monthly sales? | monthly pre-aggregation |
| What is sales accumulated through each month? | `SUM(...) OVER` expanding frame |
| How does average monthly price evolve cumulatively? | `AVG(...) OVER` expanding frame |

## 03 - Performance Analysis

Script: [`../scripts/03_performance_analysis.sql`](../scripts/03_performance_analysis.sql)

| Question | SQL pattern |
|---|---|
| What are yearly sales by product? | CTE + yearly aggregation |
| Is current product sales above/below its own historical average? | partitioned window `AVG` + `CASE` |
| How did product sales change from the previous observed year? | `LAG` + difference + `CASE` |

## 04 - Part-to-Whole

Script: [`../scripts/04_part_to_whole_analysis.sql`](../scripts/04_part_to_whole_analysis.sql)

| Question | SQL pattern |
|---|---|
| How much does each category contribute to total sales? | category aggregate + `SUM(...) OVER ()` + percentage |

## 05 - Data Segmentation

Script: [`../scripts/05_data_segmentation.sql`](../scripts/05_data_segmentation.sql)

| Question | SQL pattern |
|---|---|
| How many products fall into each cost band? | `CASE` + `GROUP BY` |
| How many customers are VIP, Regular or New? | customer aggregation + lifespan/spend rules + grouped segment count |

## 06 - Customer Report

Script: [`../scripts/06_customer_report.sql`](../scripts/06_customer_report.sql)

| Output | Definition |
|---|---|
| Grain | one customer represented in valid-dated sales |
| Segmentation | age group + VIP/Regular/New |
| Measures | orders, sales, quantity, distinct products, lifespan |
| KPIs | recency, average order value, average monthly spend |
| Persistence | `gold.report_customers` view |

## 07 - Product Report

Script: [`../scripts/07_product_report.sql`](../scripts/07_product_report.sql)

| Output | Definition |
|---|---|
| Grain | one sold product represented in valid-dated sales |
| Segmentation | High-Performer/Mid-Range/Low-Performer |
| Measures | orders, sales, quantity, unique customers, lifespan |
| KPIs | weighted average selling price, recency, average order revenue, average monthly revenue |
| Persistence | `gold.report_products` view |

## Validation

Script: [`../tests/01_validate_advanced_analytics.sql`](../tests/01_validate_advanced_analytics.sql)

The report outputs are checked for uniqueness, population alignment, measure reconciliation and segment-domain validity.
