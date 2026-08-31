# 04 - Part-to-Whole Analysis Learnings

Script: [`../scripts/04_part_to_whole_analysis.sql`](../scripts/04_part_to_whole_analysis.sql)

## Main pattern

Part-to-whole analysis compares a grouped measure with the total of that same measure:

```text
category sales / all-category sales * 100
```

The query first creates one row per category, then `SUM(total_sales) OVER ()` exposes the overall total without collapsing the category rows.

## Why the window function helps

A normal aggregate would return one total row. The window aggregate repeats the overall total alongside every category, which makes the ratio easy to calculate.

## Keep analytical numbers numeric

Appending `%` with `CONCAT` is convenient for display but converts the result to text. The final query keeps `percentage_of_total` numeric so it remains sortable, filterable and reusable by another consumer.

## Interview-level explanation

> I aggregate the parts first, use a window total for the whole, then divide each part by that whole. I keep the result numeric and leave presentation formatting to the consumer.
