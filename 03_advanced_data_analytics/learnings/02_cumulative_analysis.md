# 02 - Cumulative Analysis Learnings

Script: [`../scripts/02_cumulative_analysis.sql`](../scripts/02_cumulative_analysis.sql)

## Two-stage reasoning

The query first reduces 60,398 sales lines to one row per month. Only then does it apply window functions.

```text
sales lines
   -> monthly aggregates
   -> ordered window
   -> running metrics
```

That order matters. Applying the window at fact grain would answer a different question.

## Running total

`SUM(total_sales) OVER (...)` keeps one row per month while accumulating all preceding months. An explicit `ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW` frame makes the intended expanding window visible.

## Expanding average

The `moving_average_price` column uses the same expanding frame. It is therefore the average from the beginning of the series through the current row, not a fixed three-month rolling average.

## Numeric precision

`price` is stored as an integer in the Gold fact. Casting before `AVG` avoids silent integer truncation and makes the KPI definition explicit.

## Interview-level explanation

> I aggregate to the reporting grain first, then apply a window function across those aggregates. I define the frame explicitly so it is clear whether the metric is cumulative, expanding or fixed-width rolling.
