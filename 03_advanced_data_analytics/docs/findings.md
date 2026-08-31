# Advanced Analytics Findings - Supplied Dataset Snapshot

These are descriptive results for the supplied learning dataset. They are not claims about a live business, market or production workload.

The upstream validated Gold population is:

- **18,484** customers;
- **295** current products;
- **60,398** sales lines;
- **29,356,250** total sales;
- **60,423** total quantity.

## 1. Sales Over Time

| Year | Sales | Distinct customers | Quantity |
|---:|---:|---:|---:|
| 2010 | **43,419** | 14 | 14 |
| 2011 | **7,075,088** | 2,216 | 2,216 |
| 2012 | **5,842,231** | 3,255 | 3,397 |
| 2013 | **16,344,878** | 17,427 | 52,807 |
| 2014 | **45,642** | 834 | 1,970 |

The dataset begins on 2010-12-29 and ends on 2014-01-28. Therefore 2010 and 2014 are **partial years** and should not be compared with full-year periods as if coverage were equal.

## 2. Category Contribution to Sales

| Category | Sales | Share |
|---|---:|---:|
| Bikes | **28,316,272** | **96.46%** |
| Accessories | **700,262** | **2.39%** |
| Clothing | **339,716** | **1.16%** |

The result shows strong revenue concentration in Bikes for this learning dataset. It does not by itself explain the cause of that concentration.

## 3. Product Cost Segments

| Cost range | Current products |
|---|---:|
| Below 100 | **110** |
| 100-500 | **101** |
| 500-1000 | **45** |
| Above 1000 | **39** |

These counts use all **295 current products** from `gold.dim_products`.

## 4. Customer Segments

| Segment | Customers |
|---|---:|
| New | **14,631** |
| Regular | **2,198** |
| VIP | **1,655** |

The three segments sum to **18,484**, matching the distinct customer population represented in the fact snapshot.

Segmentation is rule-based:

- VIP: lifespan >= 12 months and total sales > 5,000;
- Regular: lifespan >= 12 months and total sales <= 5,000;
- New: lifespan < 12 months.

## 5. Product Performance Segments

The reusable product report is fact-anchored and contains **130 sold products**.

| Segment | Sold products |
|---|---:|
| High-Performer | **66** |
| Mid-Range | **58** |
| Low-Performer | **6** |

The remaining current products in `gold.dim_products` do not appear in the report because they have no sales rows in the fact population used by the report.

## 6. Report Reconciliation Expectations

For the supplied snapshot:

```text
gold.report_customers rows = distinct fact customers = 18,484
gold.report_products rows  = distinct sold fact products = 130
```

Summing `total_sales` or `total_quantity` across either report must reproduce the valid-dated fact totals. The validation script enforces these invariants rather than documenting them as assumptions.

## Interpretation Boundaries

- Performance labels are descriptive comparisons, not forecasts.
- Segment thresholds are project rules, not learned statistical boundaries.
- `GETDATE()` makes age and recency fields time-dependent.
- `DATEDIFF(MONTH, ...)` uses boundary semantics.
- Product-report KPIs describe sold products only.
- The expanding average in cumulative analysis is not a fixed-width moving window.
