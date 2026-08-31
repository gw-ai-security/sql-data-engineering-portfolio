# EDA Analysis Overview

## Purpose

The EDA phase is the first analytical consumer of the completed Gold layer. Its purpose is to build a reliable mental model of the dataset before attempting more complex analytics.

The sequence is deliberate:

```text
Structure
  -> domains
  -> time boundaries
  -> key measures
  -> measure by dimension
  -> ranked dimensions
```

This mirrors the six-step EDA roadmap in the course material: database exploration, dimensions, dates, measures, magnitude and ranking.

## Analytical Contract

The EDA consumes three Gold views from the completed Data Warehouse project.

| Object | Grain | Typical dimensions | Typical measures |
|---|---|---|---|
| `gold.dim_customers` | one row per CRM customer | country, gender, marital status, customer identity | customer count |
| `gold.dim_products` | one row per current product | category, subcategory, product name, product line | product count, cost |
| `gold.fact_sales` | one row per source sales line | order date, customer key, product key, order number | sales amount, quantity, price |

The fact grain is important: `gold.fact_sales` is **not one row per order**. An order can contain multiple product lines. Therefore:

```text
COUNT(order_number)          -> sales-line count with an order number
COUNT(DISTINCT order_number) -> business order count
```

The second expression is the correct metric when the question is "How many orders?"

## Dimensions vs. Measures

The project follows an analytical-role definition rather than a data-type shortcut.

A **dimension** is used to group, classify or identify data.

Examples:

- country;
- category;
- subcategory;
- product;
- customer;
- dates;
- identifiers when aggregation has no business meaning.

A **measure** is a value for which aggregation or calculation is analytically meaningful.

Examples:

- sales amount;
- quantity;
- price;
- cost;
- counts derived from business entities.

A numeric field is not automatically a measure. `customer_key` is numeric, but averaging customer keys has no useful business meaning; the key behaves as an identifier/dimension.

## Six-Step Method

### 1. Database exploration

Start with metadata rather than assumptions. `INFORMATION_SCHEMA.TABLES` and `INFORMATION_SCHEMA.COLUMNS` expose objects, schemas, names, types and column metadata.

Goal: understand the shape and naming of the database before querying business values.

### 2. Dimension exploration

Use `DISTINCT` to discover the domain and granularity of dimensions.

Examples:

- named customer countries;
- category -> subcategory -> product hierarchy.

Goal: learn what groups actually exist and how coarse or detailed each dimension is.

### 3. Date-range exploration

Use `MIN` and `MAX` to establish temporal boundaries, then use `DATEDIFF` to describe the interval.

Goal: know the historical coverage before interpreting time-dependent metrics.

Important SQL Server nuance: `DATEDIFF` counts **datepart boundaries crossed**, not elapsed fractional units. A `DATEDIFF(YEAR, ...)` result should not automatically be described as "full years of history."

### 4. Measure exploration

Aggregate core measures independently before slicing them by dimensions.

Goal: establish the "big numbers" of the dataset and verify grain-sensitive counts such as orders.

The consolidated `UNION ALL` query gives a compact metric inventory in one result set.

### 5. Magnitude analysis

Pattern:

```text
Aggregate [Measure] BY [Dimension]
```

Examples:

- customer count by country;
- product count by category;
- average cost by category;
- revenue by category;
- revenue by customer;
- quantity sold by country.

Goal: compare the size or importance of categories.

### 6. Ranking analysis

Pattern:

```text
Rank [Dimension] BY Aggregate [Measure]
```

The project demonstrates both:

- simple ranking with `TOP` + `ORDER BY`;
- a window-function pattern with `ROW_NUMBER()` inside a subquery.

Goal: identify top and bottom performers and prepare the reasoning used later in more complex analytical reports.

## Join Reasoning

Magnitude and ranking queries join facts to dimensions through Gold surrogate keys:

```text
fact_sales.product_key  -> dim_products.product_key
fact_sales.customer_key -> dim_customers.customer_key
```

`LEFT JOIN` keeps the fact population visible even if a dimension lookup were missing. In grouped results, unmatched dimension rows would appear as a `NULL` bucket instead of disappearing silently.

## Scope Boundary

EDA stops after ranking. The following are intentionally deferred to project 03:

- change-over-time/trend analysis;
- cumulative analysis;
- performance-vs-baseline analysis;
- part-to-whole analysis;
- segmentation;
- consolidated customer/product reports.

Keeping that boundary makes the progression from basic exploration to advanced SQL analytics explicit.
