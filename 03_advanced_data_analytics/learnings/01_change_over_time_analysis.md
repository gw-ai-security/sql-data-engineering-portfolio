# 01 - Change Over Time Learnings

Script: [`../scripts/01_change_over_time_analysis.sql`](../scripts/01_change_over_time_analysis.sql)

## Main lesson

Time analysis starts by choosing a **date grain**. Yearly and monthly sales are not different functions; they are the same measures aggregated at different temporal grains.

```text
Measure: sales
Dimension: time
Grain: year / month
```

## Date values vs. display strings

`YEAR`, `MONTH` and `DATETRUNC` preserve useful date semantics. `FORMAT` returns text and is best treated as presentation output.

A formatted label such as `2013-Apr` should not be trusted for chronological sorting by itself. The final script sorts the formatted result using the underlying minimum order date for each period.

## Partial-period risk

The dataset begins in late December 2010 and ends in January 2014. A yearly chart can therefore look like 2010 and 2014 performed poorly even though those years contain only partial coverage.

The query can be correct while the interpretation is wrong if time coverage is ignored.

## Interview-level explanation

> I choose the time grain based on the question, aggregate the same measures at that grain, and keep real date values for logic. I also check whether boundary periods are complete before comparing them with full periods.
