# 05 - Data Segmentation Learnings

Script: [`../scripts/05_data_segmentation.sql`](../scripts/05_data_segmentation.sql)

## Segmentation is a business rule

A `CASE` expression can turn continuous measures into categories, but the thresholds must have explicit meaning.

The project implements:

- product cost bands;
- customer segments based on purchase lifespan and total spending.

These are deterministic rules, not machine-learning clusters.

## Rules must be exhaustive and non-overlapping

The customer rules are ordered so each customer enters exactly one segment:

```text
lifespan >= 12 AND spending > 5000  -> VIP
lifespan >= 12 AND spending <= 5000 -> Regular
otherwise                            -> New
```

## Lifespan semantics

`DATEDIFF(MONTH, first_order, last_order)` counts calendar-month boundaries. A customer whose first and last purchase occur in the same calendar month has lifespan `0`.

That definition is acceptable for the course segment rule, but it should not be confused with an exact fractional-month duration.

## Interview-level explanation

> I define segmentation rules from explicit measures, verify that the conditions are exhaustive and mutually exclusive, and document the exact date/threshold semantics so the labels are reproducible.
