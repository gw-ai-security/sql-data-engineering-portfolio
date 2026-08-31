# 05 - Magnitude Analysis Learnings

Script: [`../scripts/05_magnitude_analysis.sql`](../scripts/05_magnitude_analysis.sql)

## What this step solves

Magnitude analysis combines the concepts learned earlier:

```text
Aggregate [Measure] BY [Dimension]
```

A total measure becomes more informative once it is split across categories.

Examples in the script include:

- customers by country;
- customers by gender;
- products by category;
- average cost by category;
- revenue by category;
- revenue by customer;
- sold quantity by country.

## Main lesson

`GROUP BY` defines the analytical buckets. The aggregate function calculates the measure inside each bucket.

For example:

```sql
SELECT
    country,
    COUNT(customer_key)
FROM gold.dim_customers
GROUP BY country;
```

means:

```text
Build one group per country
        ↓
Count customers inside each group
```

## Joining facts to dimensions

Revenue is stored in the fact, while category and customer attributes are stored in dimensions. The analysis therefore joins the star schema rather than duplicating descriptive attributes in the fact.

```text
fact_sales
   ├── product_key  -> dim_products
   └── customer_key -> dim_customers
```

This is exactly what the Gold dimensional model is designed to support.

## Why `LEFT JOIN` is useful for exploration

A `LEFT JOIN` anchored on the fact keeps fact rows visible even if a dimension lookup is missing.

If an unmatched dimension exists, grouping can expose it as a `NULL` bucket. An `INNER JOIN` would instead remove the fact row and could make totals shrink silently.

The important principle is not "always use LEFT JOIN"; it is **know whether the join is allowed to change the analytical population**.

## Grouping keys matter

The customer-revenue query groups by:

- `customer_key`;
- `first_name`;
- `last_name`.

Including the key preserves customer identity even if two customers share the same name. Grouping only by names could merge distinct customers.

## Analytical interpretation

Magnitude analysis is descriptive:

> Category A is larger than Category B by this measure.

It does not explain why that difference exists. Causal explanations require additional evidence.

## Interview-level explanation

> I think of magnitude analysis as measure-by-dimension. I first choose the business measure, then the grouping grain, then verify that any joins preserve the intended population before comparing the resulting groups.
