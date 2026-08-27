# Source Systems and Bronze Mapping

This document captures the source-system analysis completed before Bronze ingestion. It complements the high-level architecture by showing exactly which source files feed which Bronze tables.

## Source systems

The project receives flat-file extracts from two operational systems:

- **CRM** — customer, product, and sales transaction data
- **ERP** — customer demographics, customer location, and product category data

All sources are supplied as CSV files and are loaded in batch mode.

## Source inventory

| Source | File | Columns | Logical source records | Course BULK INSERT baseline | Bronze target |
|---|---|---:|---:|---:|---|
| CRM | `cust_info.csv` | 7 | 18,494 | 18,493 | `bronze.crm_cust_info` |
| CRM | `prd_info.csv` | 7 | 397 | 397 | `bronze.crm_prd_info` |
| CRM | `sales_details.csv` | 9 | 60,398 | 60,398 | `bronze.crm_sales_details` |
| ERP | `CUST_AZ12.csv` | 3 | 18,484 | 18,483 | `bronze.erp_cust_az12` |
| ERP | `LOC_A101.csv` | 2 | 18,484 | 18,484 | `bronze.erp_loc_a101` |
| ERP | `PX_CAT_G1V2.csv` | 4 | 37 | 37 | `bronze.erp_px_cat_g1v2` |

## File schemas

### CRM — `cust_info.csv`

```text
cst_id
cst_key
cst_firstname
cst_lastname
cst_marital_status
cst_gndr
cst_create_date
```

### CRM — `prd_info.csv`

```text
prd_id
prd_key
prd_nm
prd_cost
prd_line
prd_start_dt
prd_end_dt
```

### CRM — `sales_details.csv`

```text
sls_ord_num
sls_prd_key
sls_cust_id
sls_order_dt
sls_ship_dt
sls_due_dt
sls_sales
sls_quantity
sls_price
```

The three sales date fields are represented in the source as integer-like `YYYYMMDD` values. They remain source-shaped in Bronze and are converted to proper dates downstream in Silver.

### ERP — `CUST_AZ12.csv`

```text
CID
BDATE
GEN
```

### ERP — `LOC_A101.csv`

```text
CID
CNTRY
```

### ERP — `PX_CAT_G1V2.csv`

```text
ID
CAT
SUBCAT
MAINTENANCE
```

## Bronze ingestion rules

The Bronze layer follows the course baseline:

```text
CSV file
  -> BULK INSERT
  -> source-aligned Bronze table
```

Configuration:

- `FIRSTROW = 2` to skip the CSV header
- `FIELDTERMINATOR = ','`
- `TABLOCK`
- full refresh with `TRUNCATE TABLE` before every load
- no cleansing or business transformations in Bronze

## CSV EOF observation

A full CSV parser counts one more logical data record in `cust_info.csv` and `CUST_AZ12.csv` than SQL Server loads with the simple course `BULK INSERT` configuration. Both supplied files end without a final line terminator and their final field is empty.

The repository therefore records both values instead of silently redefining the source count:

- **logical source records** — records detected by a full CSV parser;
- **course BULK INSERT baseline** — records loaded by the exact course loading pattern.

The Bronze validation script reports this difference explicitly. The baseline project does not modify the supplied source files.

## Layer boundary

Bronze does not attempt to fix issues discovered during source analysis. Examples such as leading/trailing spaces, missing IDs, inconsistent codes, invalid date representations, or questionable measures are intentionally preserved for Silver-layer analysis and cleansing.
