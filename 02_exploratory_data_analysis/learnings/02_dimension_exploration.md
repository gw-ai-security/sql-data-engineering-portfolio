# 02 - Dimension Exploration Learnings

Script: [`../scripts/02_dimension_exploration.sql`](../scripts/02_dimension_exploration.sql)

## What this step solves

Dimension exploration answers:

> What categories, labels and descriptive groups actually exist in the data?

The script profiles:

- customer country;
- product category;
- product subcategory;
- product name.

## Main lesson

A dimension is defined by its **analytical role**, not by whether the column contains text.

Dimensions are used to group, classify or identify data. `DISTINCT` is therefore a basic but powerful profiling tool because it reveals:

- the domain of a dimension;
- unexpected values;
- `NULL` categories;
- relative granularity.

For the product hierarchy:

```text
category
   ↓
subcategory
   ↓
product_name
```

each level is more detailed than the previous one.

## Why granularity matters

If a question asks for sales by category, grouping by product name answers a different question. Good analysis begins by selecting the dimension level that matches the business question.

The dataset illustrates this clearly: there are only a few high-level categories but hundreds of current products.

## SQL lesson

`DISTINCT` removes duplicate combinations across the selected columns. With:

```sql
SELECT DISTINCT category, subcategory, product_name
```

SQL returns unique hierarchy combinations, not "distinct category independently, distinct subcategory independently, distinct product independently."

## Maintainability note

The script uses:

```sql
ORDER BY 1, 2, 3
```

Ordinal ordering is valid SQL Server syntax and concise for exploration. In long-lived production queries, explicit column names are often clearer because reordering the `SELECT` list can otherwise change the sort semantics.

## Interview-level explanation

> I use dimension exploration to learn the valid domains and hierarchy of categorical data before building grouped metrics. It helps me choose the correct grain and also exposes unexpected or missing categories early.
