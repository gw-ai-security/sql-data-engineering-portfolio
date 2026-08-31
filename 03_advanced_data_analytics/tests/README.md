# Advanced Analytics Validation

Run [`01_validate_advanced_analytics.sql`](01_validate_advanced_analytics.sql) after both report-view scripts.

The script uses SQL Server `THROW` statements so a failed invariant stops execution with an explicit error.

Validation covers:

- existence of `gold.report_customers` and `gold.report_products`;
- uniqueness of `customer_key` and `product_key` at report grain;
- report row count vs. distinct fact population;
- sales reconciliation back to `gold.fact_sales`;
- quantity reconciliation back to `gold.fact_sales`;
- allowed customer/product segment domains;
- non-null keys and non-negative core metrics.

The checks are dynamic rather than hard-coding the supplied row counts, so they remain useful if the same model is reloaded with another compatible snapshot.
