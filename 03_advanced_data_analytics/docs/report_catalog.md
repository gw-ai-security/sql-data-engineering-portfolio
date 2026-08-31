# Advanced Analytics - Report Catalog

This catalog defines the two reusable analytical views created by project 03. The base Gold catalog remains in [`../../01_data_warehouse/docs/data_catalog/gold_data_catalog.md`](../../01_data_warehouse/docs/data_catalog/gold_data_catalog.md).

## `gold.report_customers`

**Purpose:** customer-level behavioral and value summary.

**Grain:** one row per `customer_key` represented in `gold.fact_sales` with a non-null `order_date`.

| Column | Role | Definition |
|---|---|---|
| `customer_key` | key | Gold customer surrogate key |
| `customer_number` | identifier | consumer-facing customer number |
| `customer_name` | dimension | first and last name concatenated for display |
| `age` | derived dimension | `DATEDIFF(YEAR, birthdate, GETDATE())`; approximate around birthdays |
| `age_group` | segment | Under 20, 20-29, 30-39, 40-49, 50 and above, or Unknown |
| `customer_segment` | segment | VIP / Regular / New using lifespan and total-sales thresholds |
| `last_order_date` | date | latest valid order date for the customer |
| `recency` | KPI | month boundaries between `last_order_date` and `GETDATE()` |
| `total_orders` | measure | distinct order numbers |
| `total_sales` | measure | sum of sales amount |
| `total_quantity` | measure | sum of purchased quantity |
| `total_products` | measure | distinct products purchased |
| `lifespan` | KPI input | month boundaries between first and last valid order |
| `avg_order_value` | KPI | `total_sales / total_orders`, calculated with decimal arithmetic |
| `avg_monthly_spend` | KPI | `total_sales / lifespan`; if lifespan is 0, uses total sales |

### Customer segment rules

```text
VIP      = lifespan >= 12 AND total_sales > 5000
Regular  = lifespan >= 12 AND total_sales <= 5000
New      = lifespan < 12
```

A `NULL` age is explicitly categorized as `Unknown` rather than entering an older age group through the final `ELSE` branch.

## `gold.report_products`

**Purpose:** sold-product performance and customer-reach summary.

**Grain:** one row per `product_key` represented in `gold.fact_sales` with a non-null `order_date`.

| Column | Role | Definition |
|---|---|---|
| `product_key` | key | Gold product surrogate key |
| `product_name` | dimension | product display name |
| `category` | dimension | high-level product category |
| `subcategory` | dimension | product subcategory |
| `cost` | measure/attribute | current product cost from Gold dimension |
| `product_segment` | segment | High-Performer / Mid-Range / Low-Performer by total sales |
| `last_sale_date` | date | latest valid sale date for the product |
| `recency` | KPI | month boundaries between `last_sale_date` and `GETDATE()` |
| `total_orders` | measure | distinct order numbers containing the product |
| `total_sales` | measure | total product sales amount |
| `total_quantity` | measure | total product units sold |
| `total_customers` | measure | distinct customers who bought the product |
| `lifespan` | KPI input | month boundaries between first and last valid product sale |
| `avg_selling_price` | KPI | weighted unit revenue: `total_sales / total_quantity` |
| `avg_order_revenue` | KPI | `total_sales / total_orders` |
| `avg_monthly_revenue` | KPI | `total_sales / lifespan`; if lifespan is 0, uses total sales |

### Product segment rules

```text
High-Performer = total_sales > 50000
Mid-Range      = total_sales >= 10000 and <= 50000
Low-Performer  = total_sales < 10000
```

## Time-Dependent Fields

`age` and both `recency` fields use `GETDATE()`. They are therefore **query-time values**, not immutable facts from the historical dataset. This behavior matches the course reporting pattern and is kept explicit rather than presented as a fixed snapshot metric.

## Lifespan Semantics

`DATEDIFF(MONTH, first_date, last_date)` counts calendar-month boundaries crossed. A customer/product with activity only inside one calendar month has `lifespan = 0`. The report formulas therefore handle zero lifespan explicitly.
