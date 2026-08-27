# Gold Layer — Engineering Learnings

The Gold phase turns trustworthy source-aligned datasets into a small analytical product. The central engineering challenge is not writing three views; it is proving that the views represent the intended business objects at the intended grain without losing or multiplying facts.

## 1. Source tables are not business objects

Silver retains six technical source entities, but Gold begins from business concepts:

```text
crm_cust_info + erp_cust_az12 + erp_loc_a101
                         -> CUSTOMER

crm_prd_info + erp_px_cat_g1v2
                         -> PRODUCT

crm_sales_details        -> SALES
```

This distinction matters because analytical users should think in customers, products and sales—not in the delivery structures of two operational systems.

## 2. Integration starts after data quality is trustworthy

Each layer answers a different question:

```text
Bronze: What did the sources provide?
Silver: Is each source dataset technically trustworthy and join-ready?
Gold:   How do the trusted datasets describe business objects and processes?
```

Moving the boundaries causes hidden defects. For example, the CRM/ERP pedal-category mismatch belongs in Silver because it corrects a derived integration key. Gold consumes that trusted key rather than repeating the correction.

## 3. Grain is the first model decision

Grain defines what one row means and therefore determines uniqueness, joins, measures and meaningful quality checks.

The validated Gold grains are:

- `dim_customers`: one row per CRM customer;
- `dim_products`: one row per current product;
- `fact_sales`: one row per order-number/product-number source sales line.

The fact is not “one row per order.” A single order can contain multiple product lines. Runtime profiling showed that `(order_number, product_key)` is unique for the current 60,398-row fact population.

## 4. Dimensions and facts answer different questions

CUSTOMER and PRODUCT describe relatively stable analytical entities, so they become dimensions. SALES records a transactional business process with dates and additive measures, so it becomes the fact.

The star schema lets a consumer ask questions such as sales by customer country or product category without reconstructing source-system joins.

## 5. Surrogate keys decouple facts from source-facing identifiers

Gold dimensions expose `customer_key` and `product_key`, and the fact references those keys. In this learning project, Baraa generates them with `ROW_NUMBER()` inside views.

That choice is acceptable for a latest-snapshot model because:

- the current ordering expressions are deterministic for the current dimension rows;
- the views are simple and require no persistent key infrastructure;
- the project does not maintain historical fact snapshots across reloads.

The limitation is important: adding or removing dimension rows can renumber keys. A historical production warehouse would normally need durable surrogate-key assignment.

## 6. Source precedence must be explicit

CRM and ERP both provide gender information. The implemented rule is:

```text
Use CRM gender when it is known.
Otherwise use ERP gender.
Otherwise use n/a.
```

This is a source-authority decision, not a technical side effect of join order. A good Data Engineer makes such precedence visible in SQL, documentation and the data catalog.

## 7. LEFT JOIN preserves the analytical population

CRM customer master, current CRM products and Silver sales are the anchor populations for the three Gold views. `LEFT JOIN` preserves those rows during enrichment.

That design does not pretend missing integration is harmless. It makes missing dimension keys or enrichment visible to quality checks instead of silently deleting facts through an `INNER JOIN`.

The current dataset demonstrates the principle: `AW00029483` lacks the ERP demographics row because of the documented CSV EOF behavior. The customer remains in Gold with a `NULL` birthdate and `n/a` gender.

## 8. Join cardinality must be measured

A join can be syntactically valid while still multiplying rows. Before accepting Gold, the project verified:

- ERP customer identifiers are unique;
- ERP category identifiers are unique;
- customer enrichment keeps 18,484 rows;
- current-product enrichment keeps 295 rows;
- fact integration keeps 60,398 rows.

`DISTINCT` was not used to hide fan-out. The joins were accepted because their cardinality was proven.

## 9. Facts must survive enrichment unchanged

Gold integrates and renames; Silver owns technical cleansing. The validation therefore compares Gold dates and measures back to the corresponding Silver sales line.

The accepted result has:

- identical Silver and Gold fact counts;
- no missing customer or product keys;
- no altered dates, sales amounts, quantities or prices.

This is stronger evidence than merely confirming that the view can be queried.

## 10. Current products reflect the project requirement

Silver retains product versions because it derives product history intervals. Gold intentionally filters to `prd_end_dt IS NULL`, producing the 295 current products required by the latest-snapshot analytical model.

Exposing all 397 versions would change the dimension grain and could fan out sales joins. Historical dimensional modeling is outside the current requirement.

## 11. Consumer-friendly semantics are part of the contract

Gold replaces technical source names with analytical names:

```text
cst_key   -> customer_number
prd_nm    -> product_name
sls_sales -> sales_amount
```

This is not cosmetic. A consumer contract should reduce the amount of source-system knowledge required to use the warehouse correctly.

## 12. Views are sufficient here—and have limitations

Views fit the course project because the dataset is small, Gold has no separate physical load and the model always reflects the current Silver snapshot.

The trade-offs are explicit:

- integration and surrogate-key calculation happen at query time;
- keys can change when the dimension population changes;
- production scale could justify materialized serving tables or another strategy.

Those production considerations are documented rather than added prematurely.

## 13. Quality gates test semantics, not only syntax

`ROW_NUMBER()` naturally produces unique values, so checking surrogate-key uniqueness alone would be tautological. Gold quality checks also validate:

- one row per customer business key;
- one row per current product number;
- one fact row per sales-line grain;
- no join fan-out;
- complete dimension connectivity;
- Silver-to-Gold fact preservation;
- unchanged dates and measures.

A successfully created view is only the beginning of validation.

## 14. Data lineage and cataloging complete the model

The end-to-end lineage diagram answers where each Gold object came from. The star-schema diagram explains how consumers join the Gold objects. The data catalog defines every exposed field and records uncertainty rather than inventing unsupported meaning.

SQL alone is not a complete analytical product if only its author understands the grain, rules and lineage.

## 15. What this phase taught about good Data Engineering

A Data Engineer completing Gold should be able to explain:

- why CUSTOMER, PRODUCT and SALES are the business objects;
- what one row means in every view;
- why each join is one-to-one or many-to-one;
- which source has precedence for shared attributes;
- why facts are preserved with `LEFT JOIN`;
- why surrogate keys are useful and what makes the current keys limited;
- how integration was validated independently of view creation;
- where every Gold column originated;
- which project limitations are deliberate rather than accidental.

## Runtime evidence

Gold was deployed twice successfully on 2026-08-27 against the validated local Silver snapshot. Final row counts were 18,484 customers, 295 current products and 60,398 sales lines. All no-results quality checks returned zero rows, and independent cardinality and referential-integrity checks passed.
