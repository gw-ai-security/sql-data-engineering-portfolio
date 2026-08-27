# Data Integration Preparation and Business Objects

The published [Data Integration Model](Data%20Integration%20Model.webp) documents the source relationships and derived keys prepared in Silver. It is an integration-discovery artifact, not a Gold dimensional model.

Implemented relationship preparation:

| Silver relationship | Preparation rule |
|---|---|
| `crm_sales_details.sls_prd_key -> crm_prd_info.prd_key` | remove the first six characters from the CRM source product key |
| `crm_sales_details.sls_cust_id -> crm_cust_info.cst_id` | use the cleansed CRM customer identifier |
| `erp_cust_az12.cid -> crm_cust_info.cst_key` | remove a leading `NAS` prefix |
| `erp_loc_a101.cid -> crm_cust_info.cst_key` | remove hyphens |
| `crm_prd_info.cat_id -> erp_px_cat_g1v2.id` | derive the first five source-key characters and replace `-` with `_` |

## Dataset-specific category correction

The general product-category derivation produces `CO_PE` for seven CRM pedal products. The supplied ERP category master has no `CO_PE`; it identifies `Components / Pedals` as `CO_PD`. Silver therefore applies one explicit, source-backed correction after the baseline derivation:

```text
CO_PE -> CO_PD
```

All other category keys follow the general derivation shown in the diagram. Runtime validation confirms that the prepared product/category relationship has no unmatched keys.

Cross-source business integration, source precedence, dimensions and facts remain Gold responsibilities.

## Gold business-object discovery

The [Business Objects Integration Model](Business%20Objects%20Integration%20Model.webp) captures the analysis performed before the Gold star schema was built. It groups the six trusted Silver entities into three business concepts:

| Business object | Silver contributors | Integration keys | Gold result |
|---|---|---|---|
| CUSTOMER | `silver.crm_cust_info`, `silver.erp_cust_az12`, `silver.erp_loc_a101` | CRM `cst_key` = normalized ERP `cid`; sales `sls_cust_id` = CRM `cst_id` | `gold.dim_customers` |
| PRODUCT | `silver.crm_prd_info`, `silver.erp_px_cat_g1v2` | CRM `cat_id` = ERP category `id`; sales `sls_prd_key` = CRM normalized `prd_key` | `gold.dim_products` |
| SALES | `silver.crm_sales_details` | Customer and product identifiers resolve Gold surrogate keys | `gold.fact_sales` |

The discovery artifact is intentionally pre-modeling documentation: it explains why the three business objects were chosen before classifying CUSTOMER and PRODUCT as dimensions and SALES as the fact.

## Rules carried into Gold

- `silver.crm_cust_info` is the customer anchor; ERP demographics and location enrich it through `LEFT JOIN`s.
- CRM gender is authoritative when known; ERP is the fallback.
- `silver.crm_prd_info` is filtered to current versions with `prd_end_dt IS NULL` before category enrichment.
- `silver.crm_sales_details` defines the fact grain and is preserved during surrogate-key resolution.
- Gold consumes trusted Silver keys and measures; it does not repeat Silver cleansing.

The deployed model, logical relationships and final columns are documented in the [Gold star schema](../data_model/gold_star_schema.drawio) and [Gold data catalog](../data_catalog/gold_data_catalog.md).
