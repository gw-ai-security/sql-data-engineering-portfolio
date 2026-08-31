# 03 - Date Range Exploration Learnings

Script: [`../scripts/03_date_range_exploration.sql`](../scripts/03_date_range_exploration.sql)

## What this step solves

Before analyzing change over time, I need to know the time window actually represented by the data.

The script uses:

- `MIN()` for earliest boundaries;
- `MAX()` for latest boundaries;
- `DATEDIFF()` for datepart differences;
- `GETDATE()` for age-at-query-time calculations.

## Main lesson

**A date range is part of the analytical context.**

A total-sales number means something different if it covers one month, three years or ten years. Establishing temporal boundaries prevents later metrics from being interpreted without context.

## `DATEDIFF` is easy to misread

SQL Server `DATEDIFF` counts **boundaries crossed** for the selected datepart.

The current script uses:

```sql
DATEDIFF(YEAR, MIN(order_date), MAX(order_date))
```

For this dataset the dates run from 2010-12-29 to 2014-01-28 and the result is `4`, because four calendar-year boundaries are crossed. That is not the same statement as "four complete elapsed years."

If the business question needs more precise duration, the datepart and interpretation must be chosen accordingly.

## `GETDATE()` makes results dynamic

Customer age is calculated against the current database-server date:

```sql
DATEDIFF(YEAR, birthdate, GETDATE())
```

Therefore age is not a fixed property of the committed dataset. Re-running the same query later can produce a different value.

Also, `DATEDIFF(YEAR, ...)` is an approximate age pattern because it counts year boundaries and does not check whether the birthday has occurred in the current year.

## NULL behavior

`MIN()` and `MAX()` ignore `NULL` values. That is useful, but it means a clean-looking boundary does not prove that every row contains a valid date. Completeness is a separate Data Quality question.

## Interview-level explanation

> I establish date boundaries before time-based analysis and I treat SQL date functions according to their exact semantics. `DATEDIFF` counts datepart boundaries, and calculations based on `GETDATE()` are dynamic rather than fixed dataset facts.
