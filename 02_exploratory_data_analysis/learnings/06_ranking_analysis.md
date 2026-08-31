# 06 - Ranking Analysis Learnings

Script: [`../scripts/06_ranking_analysis.sql`](../scripts/06_ranking_analysis.sql)

## What this step solves

Ranking analysis orders dimension members by an aggregated measure to identify top and bottom performers.

Pattern:

```text
Rank [Dimension] BY Aggregate [Measure]
```

The script applies this to products, subcategories and customers.

## Simple ranking: `TOP` + `ORDER BY`

For a straightforward Top-N question:

```sql
SELECT TOP 5 ...
ORDER BY total_revenue DESC;
```

is easy to read and appropriate.

Changing `DESC` to ascending order turns the same pattern into a Bottom-N query.

The critical rule is that `TOP` is meaningful only together with a deliberate `ORDER BY`. Without ordering, "top five" has no analytical definition.

## Window-function ranking

The script also demonstrates:

```sql
ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount) DESC)
```

inside a subquery, followed by:

```sql
WHERE rank_products <= 5
```

This pattern is longer than `TOP`, but it is more extensible when later queries need additional ranking logic or attributes.

## `ROW_NUMBER` vs. `RANK` vs. `DENSE_RANK`

Tie behavior is part of the business definition:

- `ROW_NUMBER()` forces every row to have a unique sequence number;
- `RANK()` gives tied values the same rank and leaves gaps;
- `DENSE_RANK()` gives tied values the same rank without gaps.

The current script uses `ROW_NUMBER()`. The course material discusses `ROW_NUMBER()` and `RANK()` as ranking alternatives; the correct choice depends on the required tie semantics. If the requirement is "include all products tied for fifth place," a tie-aware ranking function would be more appropriate.

## Stable identity matters

The product ranking groups by `product_name`. That is sufficient for the supplied dataset, but in a production model product names are not always unique. A robust general pattern would retain a stable product key together with the display name.

The customer rankings already follow that stronger pattern by grouping with `customer_key` plus the names.

## Reusing the same analytical shape

One useful lesson from the project is that many business questions differ only in:

```text
dimension + measure + sort direction + N
```

For example:

```text
product     + revenue      + DESC + 5
subcategory + revenue      + ASC  + 5
customer    + revenue      + DESC + 10
customer    + order count  + ASC  + 3
```

Understanding that reusable shape is more valuable than memorizing six separate queries.

## Interview-level explanation

> For simple Top-N analysis I use `TOP` with an explicit `ORDER BY`. For more flexible reporting I use ranking window functions, and I choose `ROW_NUMBER`, `RANK` or `DENSE_RANK` based on the required tie semantics.
