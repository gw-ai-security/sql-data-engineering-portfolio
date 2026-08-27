# Silver Layer — Engineering Learnings

The Silver layer is where raw source-aligned data becomes **clean, standardized and technically trustworthy** while the original source model remains recognizable.

This phase is not about building the final business model. Cross-source business integration, dimensional modeling and analytical serving remain responsibilities of Gold.

## 1. Understand relationships before writing transformations

Before writing Silver SQL, the important questions are:

- What does each source table represent?
- What is the grain of each table?
- Which keys connect tables?
- Are those keys already compatible?
- Which keys require normalization before they can be joined?
- Which source fields contain technical quality problems?

The integration-discovery diagram is therefore not decoration. It is an input to the transformation design.

Examples from this project:

```text
crm_sales_details.sls_cust_id
        -> crm_cust_info.cst_id
```

is directly compatible, while other relationships require preparation:

```text
erp_cust_az12.cid
NASAW00011000
        -> remove NAS prefix
AW00011000
        -> crm_cust_info.cst_key
```

and:

```text
erp_loc_a101.cid
AW-00011000
        -> remove '-'
AW00011000
        -> crm_cust_info.cst_key
```

A good data engineer identifies these compatibility problems before creating joins or downstream models.

## 2. Silver cleans the source model; it does not replace it

The project deliberately keeps the same six logical source tables in Bronze and Silver.

```text
Bronze CRM customer -> Silver CRM customer
Bronze CRM product  -> Silver CRM product
Bronze CRM sales    -> Silver CRM sales
...
```

Silver may:

- remove duplicates;
- filter technically unusable records;
- standardize values;
- correct data types;
- derive technical columns;
- enrich records with warehouse metadata;
- prepare keys for later integration.

Silver should not yet:

- create a customer dimension;
- create a sales fact table;
- merge CRM and ERP into business objects;
- introduce report-specific aggregations.

The distinction prevents the cleansing layer from becoming coupled to one analytical use case.

## 3. Data quality rules must be explicit

"Clean the data" is not an implementable requirement.

Each issue needs a concrete rule.

Examples in this project:

```text
Duplicate customer IDs
-> keep the most recent record by cst_create_date
```

```text
Marital status S / M
-> Single / Married
```

```text
Invalid or missing product cost
-> standardize to 0 according to project baseline
```

```text
Sales date stored as YYYYMMDD integer
-> convert to DATE; invalid representations become NULL
```

```text
Sales amount inconsistent with quantity * price
-> repair using the normalized quantity/price relationship
```

The engineering value is not the `CASE` statement itself. The important part is that the transformation rule is explainable, testable and reproducible.

## 4. Cleaning one field can affect another field

Data quality rules are often dependent.

For example:

```text
Sales = Quantity * Price
```

If `price` is invalid and must first be derived from `sales / quantity`, then recalculating `sales` before normalizing `price` can produce inconsistent results.

Therefore transformation order matters.

Our Silver sales load first derives a normalized price and then uses that normalized value to enforce the sales equation.

General lesson:

> When quality rules depend on each other, define an explicit transformation sequence instead of stacking independent CASE expressions without considering their interaction.

## 5. Prefer safe conversions for dirty source data

Bronze intentionally accepts source representations such as integer-style dates.

A direct `CAST` can terminate a whole load when an apparently valid eight-digit number is not a valid calendar date.

The optimized Silver procedure therefore uses safe date conversion:

```text
source integer
    -> TRY_CONVERT(..., style 112)
    -> valid DATE or NULL
```

The purpose is not to hide bad data. It is to prevent one malformed source value from causing an uncontrolled conversion error while retaining a detectable quality signal (`NULL`) for validation.

## 6. Derived keys prepare integration without performing integration

The CRM product source contains multiple meanings inside one composite key.

Silver derives:

```text
cat_id
prd_key
```

from the source product key.

This makes later relationships possible:

```text
Silver cat_id -> ERP product-category id
Silver prd_key -> Sales product key
```

This is still compatible with the Silver contract because the source table remains a product table. We are preparing technical joinability, not yet building a Gold business model.

## 7. Metadata is part of operational traceability

`dwh_create_date` is not business data. It is warehouse-generated metadata.

It answers a different question:

```text
Business date:
When did the customer/order/product event happen?

Warehouse metadata:
When did this record enter the Silver layer?
```

Metadata can later support:

- troubleshooting;
- identifying load gaps;
- pipeline auditing;
- incremental-load analysis;
- lineage and operational diagnostics.

The important concept is that engineers often add fields that describe the **data pipeline**, not the business entity.

## 8. Full-load pipelines still need atomicity thinking

The project uses:

```text
TRUNCATE Silver
    -> INSERT transformed Bronze data
```

This is simple and appropriate for the project scope, but it introduces a failure question:

> What happens if four Silver tables were refreshed and the fifth table fails?

Without transactional handling, consumers could observe a partially refreshed layer.

Our optimized procedure runs the complete Silver refresh in a transaction and rolls it back if any table load fails.

This is a deliberate portfolio improvement over the minimum course implementation.

Trade-off:

- atomic refresh improves consistency;
- long transactions can increase locking and resource usage at production scale.

Therefore "wrap everything in one transaction" is not a universal rule. The correct strategy depends on volume, concurrency, SLA and recovery design.

## 9. Observability should follow common standards across layers

A pipeline should make it possible to answer:

- Which table is loading now?
- How many rows were written?
- How long did the table take?
- How long did the complete Silver batch take?
- Which statement failed?
- Did the caller receive a real failure signal?

Our Silver procedure records row counts and millisecond-level durations and re-throws failures after logging diagnostic details.

Millisecond measurement matters in this local project because many loads finish in less than one second; measuring only seconds would repeatedly show `0` and provide little useful information.

A broader lesson from the course is that operational conventions should remain consistent across pipeline layers. If one layer introduces a better logging or error-handling standard, the other layer loaders should eventually be aligned as well.

## 10. A successful load is not proof of good data

The Silver procedure completing successfully proves only that SQL Server executed the transformations.

It does not prove:

- keys are unique;
- values are standardized;
- dates are logically ordered;
- measures are consistent;
- derived keys are populated;
- all intended records reached Silver.

This is why implementation and validation are separate artifacts.

Our Silver checks validate three levels:

```text
1. Quality-rule summary
2. Bronze -> Silver reconciliation
3. Detailed violating records
```

## 11. Reconciliation must understand transformation semantics

Simple source-target equality is not always correct.

For most project tables:

```text
Bronze rows = Silver rows
```

But customer cleansing intentionally removes NULL customer IDs and deduplicates customer records.

Therefore the correct expectation is:

```text
Silver customer rows
=
unique non-NULL Bronze customer IDs
```

A good reconciliation test models what the transformation is supposed to do rather than blindly asserting equal row counts everywhere.

## 12. Quality checks should produce actionable evidence

A large collection of ad-hoc `SELECT` statements is useful during exploration, but difficult to review repeatedly.

Our optimized quality-check script therefore provides:

```text
check_name | issue_count | PASS / FAIL
```

first, followed by detailed queries that show violating records.

This separates two questions:

```text
Did the layer pass?
```

from:

```text
Which records caused the failure?
```

That structure is closer to how automated data-quality systems operate, while remaining pure SQL for this project.

## 13. What a good Data Engineer should be able to explain here

After completing Silver, the important capability is not memorizing the SQL script.

You should be able to explain:

- why Silver exists separately from Bronze and Gold;
- why the source model remains recognizable;
- how you discovered the required cleansing rules;
- why some keys require normalization before later integration;
- why transformation order matters;
- why safe casting matters with dirty data;
- what `dwh_create_date` tells you and what it does not tell you;
- why a full refresh needs failure/recovery thinking;
- why successful execution is different from data-quality success;
- how Bronze-to-Silver reconciliation changes when deduplication/filtering is intentional;
- which parts of the current design are appropriate for this project but would need redesign at larger production scale.

## Current Status

The optimized Silver DDL, transformation procedure and quality-check scripts are prepared in the repository.

They are **not considered accepted evidence until they have been executed against the current Bronze data and the quality/reconciliation checks have been reviewed**.
