# Silver Data Integration Preparation

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
