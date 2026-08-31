# 07 - Product Report Learnings

Script: [`../scripts/07_product_report.sql`](../scripts/07_product_report.sql)

## Fact-anchored reporting changes the population

The report begins from `gold.fact_sales` and enriches with `gold.dim_products`. Therefore it answers questions about **products that were sold**.

The supplied Gold dimension has 295 current products, but only 130 product keys occur in the fact snapshot. A reviewer should not interpret 130 report rows as missing data without understanding the report grain.

## Weighted average selling price

The final implementation defines:

```text
avg_selling_price = total_sales / total_quantity
```

This weights each sold unit equally. It is different from averaging line-level unit prices, where every sales line would receive equal weight regardless of quantity.

The metric choice is documented so another analyst can reproduce it.

## Rerunnable view deployment

`CREATE OR ALTER VIEW` lets the report script be executed repeatedly during development without a manual drop step.

## KPI precision

Average selling price, average order revenue and average monthly revenue use decimal arithmetic to avoid integer truncation.

## Validation

The final test script verifies that:

- one row exists per sold product key;
- report sales and quantity reconcile to the fact;
- segment values stay inside the documented domain.

## Interview-level explanation

> I define the report population from its anchor table, document the metric formula, make the view rerunnable, and reconcile aggregated measures back to the fact so the reporting layer cannot silently lose or duplicate sales.
