# Silver Layer — Engineering Learnings

The Silver layer is where raw source-aligned data becomes **clean, standardized and technically trustworthy** while the original source model remains recognizable.

This phase is not the final business model. Cross-source integration, dimensions, facts, aggregations and analytical serving remain responsibilities of Gold.

## 1. Understand the data before transforming it

Baraa's workflow is consistent throughout Silver:

```text
Explore Bronze data
        ↓
Detect a concrete quality issue
        ↓
Define a transformation rule
        ↓
Test the transformed result
        ↓
Load Silver
        ↓
Run the quality check again
```

The important lesson is that cleansing rules should come from observed source problems and business rules, not from arbitrary assumptions.

## 2. Silver keeps the source model recognizable

The project keeps the same six logical tables in Bronze and Silver.

```text
bronze.crm_cust_info      -> silver.crm_cust_info
bronze.crm_prd_info       -> silver.crm_prd_info
bronze.crm_sales_details  -> silver.crm_sales_details
...
```

Silver cleans and prepares data. It does not yet build `dim_customers`, `dim_products` or `fact_sales`.

## 3. Primary-key quality comes first

For customer data, the first important checks are:

- is the candidate key NULL?
- does the same key occur more than once?

When duplicates exist, Baraa uses the creation date to keep the most recent customer record:

```text
ROW_NUMBER()
PARTITION BY cst_id
ORDER BY cst_create_date DESC
        ↓
keep rank = 1
```

The broader lesson is that deduplication requires an explicit rule for deciding **which record wins**.

## 4. String cleansing should be evidence-driven

The course checks string columns for leading and trailing spaces before applying `TRIM()`.

In this dataset, customer first and last names require trimming, while some other string columns do not.

A good Data Engineer does not transform every string automatically without understanding why.

## 5. Standardization reduces ambiguity

Silver converts source codes into consistent readable values.

Examples:

```text
S -> Single
M -> Married
```

```text
F / Female -> Female
M / Male   -> Male
other      -> n/a
```

```text
M -> Mountain
R -> Road
S -> Other Sales
T -> Touring
```

Standardization is valuable because downstream consumers should not repeatedly interpret multiple representations of the same concept.

## 6. Derived columns can prepare later integration

The CRM product key contains multiple pieces of information. Silver derives:

```text
cat_id
prd_key
```

from the original source `prd_key`.

These fields later enable relationships with:

```text
silver.erp_px_cat_g1v2.id
silver.crm_sales_details.sls_prd_key
```

This is preparation for integration, not yet the final Gold integration itself.

## 7. Data enrichment can add useful information

For product history, the course derives `prd_end_dt` from the next `prd_start_dt` using `LEAD()`.

Conceptually:

```text
current start date
next start date
        ↓
end date = next start date - 1 day
```

The source does not directly provide that complete information, so Silver enriches the dataset with a useful derived value.

## 8. Business rules matter more than SQL syntax

Sales, quantity and price are related by the rule:

```text
Sales = Quantity × Price
```

The source contains NULL, negative and inconsistent values. Baraa explicitly frames the correction rule as something that should come from the business/source experts, not from the Data Engineer inventing semantics alone.

That is a central professional lesson:

> Data Engineers implement business rules; they should not silently invent them.

## 9. Technical validity and business validity are different

The course checks integer-style sales dates for:

- zero or negative values;
- incorrect length;
- values outside an accepted business range.

Our dataset exposed a concrete example: the raw integer `5489` was accepted by SQL Server's direct character-to-date conversion as `5489-01-01`, but a sales order in the year 5489 is not plausible for this project.

Therefore our Silver load stays close to Baraa's `CASE` + `CAST` approach but adds the same 1900–2050 boundary that he discusses during data-quality analysis to all three sales date fields.

```text
Can SQL represent the date?
        !=
Is the date plausible for this dataset?
```

## 10. Metadata describes the pipeline, not the business

Every Silver table has:

```text
dwh_create_date
```

with a database-generated default timestamp.

It answers:

> When was this row created in the Silver layer?

It does not answer when the underlying business event happened.

This distinction becomes important for debugging, auditing and later incremental-load designs.

## 11. Full refreshes must be rerunnable

The project uses:

```text
TRUNCATE TABLE
        ↓
INSERT transformed Bronze data
```

before every Silver load.

This prevents duplicates when the procedure is executed repeatedly and matches the baseline full-load architecture chosen for this project.

## 12. Observability should be consistent across layers

Baraa explicitly reuses the Bronze procedure standard in Silver:

- current layer and source-system messages;
- current table being truncated/loaded;
- per-table load duration;
- total batch duration;
- `TRY...CATCH` error information.

Our version remains close to that standard. Two small robustness additions are retained:

- `SET NOCOUNT ON` to suppress unnecessary row-count messages;
- `THROW` after the error is printed so an external caller can detect that the procedure failed.

The wider lesson is that pipeline standards should remain consistent across layers instead of evolving independently in each script.

## 13. Successful execution is not proof of good data

A procedure can execute successfully while the resulting data is still wrong.

Silver therefore needs explicit quality checks for:

- NULL and duplicate keys;
- unwanted spaces;
- standardized domain values;
- invalid date values and date order;
- sales/quantity/price consistency;
- relationship integrity between prepared keys.

The quality-check file intentionally remains close to the course's exploratory SQL style rather than introducing a separate testing framework at this stage.

## 14. Relationship checks validate integration readiness

During the Silver analysis Baraa verifies that prepared keys can actually connect the datasets.

Examples:

```text
sales.sls_prd_key -> product.prd_key
sales.sls_cust_id -> customer.cst_id
erp customer cid  -> CRM cst_key
erp location cid  -> CRM cst_key
product cat_id    -> ERP category id
```

These checks are useful because a transformation that looks syntactically correct is not sufficient if it destroys joinability.

The relationship check exposed one dataset-specific source-code mismatch. Seven CRM pedal products use the prefix `CO-PE`, which produces the baseline category key `CO_PE`, while the ERP category master contains `CO_PD` for `Components / Pedals` and no `CO_PE` row. Silver therefore retains the baseline derivation for all products and applies one explicit exception:

```text
CO_PE -> CO_PD
```

This is a correction to a derived integration key supported by both source systems, not final CRM/ERP business integration.

## 15. What a good Data Engineer should be able to explain here

After Silver, you should be able to explain:

- why Silver exists separately from Bronze and Gold;
- how quality problems were discovered before transformation;
- how duplicate records are resolved and why;
- why some columns are transformed while others are deliberately left unchanged;
- how source codes are standardized;
- why derived keys are required for later integration;
- why business experts are needed for ambiguous correction rules;
- why technical date validity is not enough;
- what `dwh_create_date` represents;
- why full-load procedures truncate before inserting;
- why the load procedure and the quality-check script are separate artifacts;
- why relationship integrity must be tested before Gold integration.

## Current Status

The Silver scripts in the repository have been realigned closely with the Data with Baraa reference implementation. The retained changes are intentionally limited to project-safety and correctness improvements that have a clear reason:

1. explicit `USE DataWarehouse` context;
2. `SET NOCOUNT ON`;
3. corrected Silver error messaging plus `THROW`;
4. application of the course's 1900–2050 sales-date boundary to all three sales date columns;
5. the dataset-backed `CO_PE -> CO_PD` correction for the derived product-category key;
6. a small expansion of quality checks to cover relationships, the `SO69215` regression and transformations actually performed during the course.

The Silver DDL, stored procedure, full refresh and quality checks were executed successfully against the current local Bronze data on 2026-08-27. The six Silver row counts were 18,484; 397; 60,398; 18,483; 18,484; and 37 in source-table order. All checks documented as "Expectation: No Results" returned zero rows after the category-key correction. The 15 retained birthdates before 1924 remain an informational business-review finding rather than an automatic cleansing rule.
