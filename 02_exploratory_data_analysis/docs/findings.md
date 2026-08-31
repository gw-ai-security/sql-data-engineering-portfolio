# EDA Findings - Supplied Dataset Snapshot

These findings describe the fixed learning dataset used by this repository. They are not claims about a live business or production workload.

The row population matches the validated Gold snapshot from the upstream Data Warehouse project:

- `gold.dim_customers`: **18,484** rows;
- `gold.dim_products`: **295** current products;
- `gold.fact_sales`: **60,398** sales lines.

## 1. Temporal Coverage

| Metric | Value |
|---|---:|
| First order date | **2010-12-29** |
| Last order date | **2014-01-28** |
| Calendar-month boundaries crossed | **37** |
| Calendar-year boundaries crossed | **4** |

The committed date script uses `DATEDIFF(YEAR, ...)`. In SQL Server this counts year boundaries crossed; it should not be interpreted as four complete elapsed years.

Customer-age calculations use `GETDATE()`, so the resulting ages are intentionally **time-dependent** and will change as the query is rerun in the future.

## 2. Core Measures

| Measure | Value |
|---|---:|
| Total sales | **29,356,250** |
| Total quantity | **60,423** |
| Average selling price | **486.04** |
| Distinct orders | **27,659** |
| Current products | **295** |
| Customers | **18,484** |
| Customers represented in sales | **18,484** |

The difference between **60,398 fact rows** and **27,659 distinct orders** demonstrates why fact grain matters: one order can contain multiple sales lines.

## 3. Customer Distribution

Named customer markets:

| Country | Customers |
|---|---:|
| United States | **7,482** |
| Australia | **3,591** |
| United Kingdom | **1,913** |
| France | **1,810** |
| Germany | **1,780** |
| Canada | **1,571** |

The dimension also contains **337 customers with `NULL` country**. The EDA keeps this bucket visible rather than silently dropping it.

Gender distribution:

| Gender | Customers |
|---|---:|
| Male | **9,341** |
| Female | **9,128** |
| `NULL` | **15** |

## 4. Product Profile

Current products by category:

| Category | Products |
|---|---:|
| Components | **127** |
| Bikes | **97** |
| Clothing | **35** |
| Accessories | **29** |
| `NULL` | **7** |

The category/subcategory/product exploration shows why dimensions have different granularity: a category is a broad grouping, while product name is much more detailed.

## 5. Revenue Concentration

Revenue by directly sold category:

| Category | Revenue |
|---|---:|
| Bikes | **28,316,272** |
| Accessories | **700,262** |
| Clothing | **339,716** |

Bikes account for approximately **96.46%** of total sales in this snapshot. This is a strong concentration signal in the dataset; it is a descriptive result, not a causal explanation.

## 6. Ranking Highlights

Highest-revenue product:

| Product | Revenue |
|---|---:|
| `Mountain-200 Black- 46` | **1,373,454** |

Five highest-revenue products are all `Mountain-200` variants in the supplied snapshot.

Lowest-revenue product:

| Product | Revenue |
|---|---:|
| `Racing Socks- L` | **2,430** |

Highest-revenue customer result:

| Customer | Revenue |
|---|---:|
| Nichole Nara | **13,294** |

The dataset contains at least one tie at **13,294**. A `TOP` query or `ROW_NUMBER()` can return a deterministic row order only if an explicit tie-breaker is supplied. If equal ranks should be preserved semantically, `RANK()` or `DENSE_RANK()` is the more appropriate pattern.

## 7. Sold Quantity by Country

| Country | Quantity |
|---|---:|
| United States | **20,481** |
| Australia | **13,346** |
| Canada | **7,630** |
| United Kingdom | **6,910** |
| Germany | **5,626** |
| France | **5,559** |
| `NULL` | **871** |

This is a magnitude analysis: the same additive measure becomes more informative when split by a business dimension.

## Interpretation Boundaries

- EDA establishes **what** is in the data and **where** differences are visible; it does not establish causality.
- `NULL` dimension groups are kept visible because suppressing them would hide part of the analytical population.
- Age values based on `GETDATE()` are not fixed dataset facts.
- Rankings require explicit thought about ties and the grain of the dimension being ranked.
- Trend, cumulative, performance, segmentation and reporting logic are intentionally deferred to the Advanced Data Analytics project.
