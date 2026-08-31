# 06 - Customer Report Learnings

Script: [`../scripts/06_customer_report.sql`](../scripts/06_customer_report.sql)

## A report view is a contract

The goal is not merely to return a long `SELECT`. The final view gives downstream users a stable customer-level grain and named metrics without requiring them to reconstruct sales-line aggregations.

## CTE pipeline

```text
base_query
   -> transaction + customer attributes
customer_aggregation
   -> one row per customer
final projection
   -> segments + KPIs
```

Breaking the query into stages makes grain transitions easier to review.

## Count the business entity, not the fact rows

`COUNT(DISTINCT order_number)` is required because one order may contain multiple sales lines. `COUNT(order_number)` would count fact rows, not orders.

## Numeric division

`total_sales`, `total_orders` and `lifespan` are integer-family values. Explicit decimal casting prevents average order value and monthly spend from being silently truncated by integer division.

## Null age handling

`DATEDIFF` returns `NULL` for a missing birthdate. Without an explicit `age IS NULL` branch, a final `ELSE '50 and above'` would incorrectly classify an unknown age as an older customer. The final view uses `Unknown`.

## Dynamic fields

Age and recency use `GETDATE()`. They change when the same view is queried later. That is appropriate for a current-state reporting pattern, but it means they are not immutable facts from the source snapshot.

## Interview-level explanation

> I build the report at explicit customer grain, use distinct counts where the fact grain requires them, protect numeric KPI precision, and validate the view against the underlying fact population and totals.
