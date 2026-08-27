# Gold Data Catalog

This catalog documents the final analytical contract exposed by the Gold layer. Data types were verified from `DataWarehouse.INFORMATION_SCHEMA.COLUMNS` after deploying the views on 2026-08-27.

## Model overview

| Object | Type | Business purpose | Grain | Silver sources |
|---|---|---|---|---|
| `gold.dim_customers` | View | Consumer-friendly customer attributes enriched across CRM and ERP | One row per CRM customer | `silver.crm_cust_info`, `silver.erp_cust_az12`, `silver.erp_loc_a101` |
| `gold.dim_products` | View | Current product attributes enriched with ERP category data | One row per current product | `silver.crm_prd_info`, `silver.erp_px_cat_g1v2` |
| `gold.fact_sales` | View | Sales-line dates and measures connected to customer and product dimensions | One row per source order/product sales line | `silver.crm_sales_details`, plus both Gold dimensions for surrogate-key resolution |

Logical relationships:

```text
gold.dim_customers.customer_key  1 ── *  gold.fact_sales.customer_key
gold.dim_products.product_key    1 ── *  gold.fact_sales.product_key
```

These are logical relationships validated by diagnostic SQL; the views do not declare physical primary-key or foreign-key constraints.

## `gold.dim_customers`

**Business purpose:** Integrates the CRM customer master with ERP demographics and location attributes.

**Integration logic:** `silver.crm_cust_info` is the anchor and is preserved with `LEFT JOIN`s. ERP rows match through the normalized customer business key. CRM gender has precedence unless it is `n/a`; ERP gender is the fallback.

**Key rule:** `customer_key` is generated with `ROW_NUMBER()` ordered by the unique current `cst_id`. It is suitable for this latest-snapshot learning model but is not a durable historical key.

| Column | SQL Server type | Role | Business description | Source / lineage |
|---|---|---|---|---|
| `customer_key` | `BIGINT` | Surrogate key | Gold identifier used by `fact_sales` to reference a customer | `ROW_NUMBER()` ordered by `silver.crm_cust_info.cst_id` |
| `customer_id` | `INT` | Identifier | CRM internal customer identifier | `silver.crm_cust_info.cst_id` |
| `customer_number` | `NVARCHAR(50)` | Business identifier | Customer business key used to align CRM and ERP records | `silver.crm_cust_info.cst_key` |
| `first_name` | `NVARCHAR(50)` | Attribute | Cleansed customer first name | `silver.crm_cust_info.cst_firstname` |
| `last_name` | `NVARCHAR(50)` | Attribute | Cleansed customer last name | `silver.crm_cust_info.cst_lastname` |
| `country` | `NVARCHAR(50)` | Attribute | Standardized customer country | `silver.erp_loc_a101.cntry`, joined by customer business key |
| `marital_status` | `NVARCHAR(50)` | Attribute | Standardized marital status | `silver.crm_cust_info.cst_marital_status` |
| `gender` | `NVARCHAR(50)` | Attribute | Standardized gender using documented source precedence | CRM `cst_gndr` unless `n/a`; otherwise ERP `gen`; otherwise `n/a` |
| `birthdate` | `DATE` | Date attribute | Customer birth date when available from ERP | `silver.erp_cust_az12.bdate` |
| `create_date` | `DATE` | Date attribute | CRM customer-record creation date | `silver.crm_cust_info.cst_create_date` |

Known current-snapshot enrichment gap: `AW00029483` has no ERP demographics row because the final `CUST_AZ12.csv` record is not loaded by the course `BULK INSERT` line-ending behavior. The CRM customer remains present; `birthdate` is `NULL` and gender falls back to `n/a`.

## `gold.dim_products`

**Business purpose:** Presents the current product population with category, cost and product-line attributes.

**Integration logic:** Current CRM products are filtered with `prd_end_dt IS NULL` and enriched through `silver.crm_prd_info.cat_id = silver.erp_px_cat_g1v2.id`. Silver owns the dataset-specific `CO_PE -> CO_PD` correction; Gold consumes the corrected key.

**Key rule:** `product_key` is generated with `ROW_NUMBER()` ordered by start date and unique current product number. As with the customer key, it is snapshot-scoped rather than historically durable.

| Column | SQL Server type | Role | Business description | Source / lineage |
|---|---|---|---|---|
| `product_key` | `BIGINT` | Surrogate key | Gold identifier used by `fact_sales` to reference a product | `ROW_NUMBER()` ordered by Silver product start date and product number |
| `product_id` | `INT` | Identifier | CRM product-record identifier | `silver.crm_prd_info.prd_id` |
| `product_number` | `NVARCHAR(50)` | Business identifier | Normalized product identifier used by sales | `silver.crm_prd_info.prd_key` |
| `product_name` | `NVARCHAR(50)` | Attribute | Product name | `silver.crm_prd_info.prd_nm` |
| `category_id` | `NVARCHAR(50)` | Identifier | Normalized product-category identifier | `silver.crm_prd_info.cat_id` |
| `category` | `NVARCHAR(50)` | Attribute | Product category | `silver.erp_px_cat_g1v2.cat` |
| `subcategory` | `NVARCHAR(50)` | Attribute | Product subcategory | `silver.erp_px_cat_g1v2.subcat` |
| `maintenance` | `NVARCHAR(50)` | Attribute | Source-provided maintenance indicator; detailed business semantics are not defined in the supplied material | `silver.erp_px_cat_g1v2.maintenance` |
| `cost` | `INT` | Measure-like attribute | Cleansed source product cost | `silver.crm_prd_info.prd_cost` |
| `product_line` | `NVARCHAR(50)` | Attribute | Standardized product-line description | `silver.crm_prd_info.prd_line` |
| `start_date` | `DATE` | Date attribute | Start date of the current product version | `silver.crm_prd_info.prd_start_dt` |

## `gold.fact_sales`

**Business purpose:** Exposes the sales process with consumer-friendly dates and measures, linked to customer and product dimensions.

**Grain:** One row per unique source order-number/product-number sales line. Runtime profiling confirmed that `(sls_ord_num, sls_prd_key)` is unique for all 60,398 Silver rows in the current snapshot.

**Integration logic:** Gold preserves every `silver.crm_sales_details` row with `LEFT JOIN`s and resolves dimension surrogate keys using the trusted Silver customer and product business identifiers. It does not recalculate or reclean measures.

| Column | SQL Server type | Role | Business description | Source / lineage |
|---|---|---|---|---|
| `order_number` | `NVARCHAR(50)` | Business identifier | Sales order identifier | `silver.crm_sales_details.sls_ord_num` |
| `product_key` | `BIGINT` | Foreign key | Logical reference to `gold.dim_products.product_key` | Resolved through Silver sales product number = Gold product number |
| `customer_key` | `BIGINT` | Foreign key | Logical reference to `gold.dim_customers.customer_key` | Resolved through Silver sales customer ID = Gold customer ID |
| `order_date` | `DATE` | Date | Cleansed order date; may be `NULL` when the source date was invalid | `silver.crm_sales_details.sls_order_dt` |
| `shipping_date` | `DATE` | Date | Shipping date | `silver.crm_sales_details.sls_ship_dt` |
| `due_date` | `DATE` | Date | Due date | `silver.crm_sales_details.sls_due_dt` |
| `sales_amount` | `INT` | Measure | Silver-validated sales amount | `silver.crm_sales_details.sls_sales` |
| `quantity` | `INT` | Measure | Sold quantity | `silver.crm_sales_details.sls_quantity` |
| `price` | `INT` | Measure | Silver-validated unit price | `silver.crm_sales_details.sls_price` |

## Consumer and scope notes

- Analytical consumers should query the Gold views rather than reconstruct CRM/ERP integration from Silver.
- Gold contains no date dimension, aggregates, additional facts or persisted marts in the course scope.
- Gold views calculate at query time and expose snapshot-scoped `ROW_NUMBER()` keys.
- Bronze and Silver retain operational/source-oriented naming; Gold provides the business-facing contract.
