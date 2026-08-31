# 04 - Measure Exploration Learnings

Script: [`../scripts/04_measure_exploration.sql`](../scripts/04_measure_exploration.sql)

## What this step solves

Measure exploration establishes the high-level "big numbers" of the dataset before breaking them down by categories.

The script calculates:

- total sales;
- total quantity;
- average price;
- sales-line count;
- distinct order count;
- product count;
- customer count;
- customers represented in sales;
- one consolidated metric result with `UNION ALL`.

## Main lesson: know what `COUNT` is counting

The most important lesson in this script is the difference between:

```sql
COUNT(order_number)
```

and:

```sql
COUNT(DISTINCT order_number)
```

`gold.fact_sales` has one row per sales line, not one row per order. Therefore the first expression counts populated fact rows, while the second counts business orders.

For the current snapshot:

```text
fact rows       = 60,398
distinct orders = 27,659
```

Both numbers are correct; they answer different questions.

## Dimension vs. measure is about meaning

Measures answer questions such as:

- How much?
- How many?
- What is the average?

A numeric identifier does not become a meaningful measure simply because `SUM()` or `AVG()` can technically be applied to it.

## Why the `UNION ALL` metric report is useful

Each metric query returns the same two-column shape:

```text
measure_name | measure_value
```

`UNION ALL` stacks them into one compact business profile.

This is useful for initial exploration because it gives a fast snapshot without building a reporting layer.

## Why `UNION ALL` instead of `UNION`

The metric names are intentionally different and duplicate elimination is unnecessary. `UNION ALL` therefore expresses the intent more directly and avoids the duplicate-removal step of `UNION`.

## Failure modes to remember

- counting fact rows when the business question asks for orders;
- counting names rather than stable keys when names are not guaranteed unique;
- treating `AVG(price)` as if it were a weighted business KPI without checking the intended definition;
- using a metric because it is easy to aggregate rather than because it answers a meaningful question.

## Interview-level explanation

> Before slicing the data, I establish the core measures and verify their grain. In particular, I distinguish row counts from business-entity counts with `COUNT(DISTINCT ...)` where necessary.
