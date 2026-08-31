# 03 - Performance Analysis Learnings

Script: [`../scripts/03_performance_analysis.sql`](../scripts/03_performance_analysis.sql)

## Main idea

Performance needs a reference. "Sales = 100,000" is a magnitude; "100,000 is above this product's historical average and higher than last year" is a performance statement.

The script creates two references:

- average yearly sales for the same product;
- previous observed year's sales for the same product.

## Partition by stable identity

Window calculations partition by `product_key`, not only by product name. Names are display attributes; stable keys define entity identity.

## `LAG` and the first period

The first year observed for a product has no previous value. `LAG` correctly returns `NULL`.

A common bug is to let that `NULL` fall into an `ELSE 'No Change'` branch. The final query distinguishes it explicitly as `No Prior Year`.

## Average precision

Yearly `current_sales` is integer-valued. Casting before the window `AVG` prevents fractional averages from being truncated.

## Interview-level explanation

> I first aggregate at product/year grain, then use partitioned windows to calculate entity-specific benchmarks. I treat the first-period `NULL` from `LAG` as missing history, not as zero change.
