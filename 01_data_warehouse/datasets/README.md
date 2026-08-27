# Source Datasets

The SQL Data Warehouse project uses six CSV source files from the **Data with Baraa SQL Data Warehouse Project**. The files represent two operational source systems: CRM and ERP.

## Expected layout

```text
datasets/
├── source_crm/
│   ├── cust_info.csv
│   ├── prd_info.csv
│   └── sales_details.csv
└── source_erp/
    ├── CUST_AZ12.csv
    ├── LOC_A101.csv
    └── PX_CAT_G1V2.csv
```

## Source-to-Bronze mapping

| Source system | CSV file | Bronze target |
|---|---|---|
| CRM | `cust_info.csv` | `bronze.crm_cust_info` |
| CRM | `prd_info.csv` | `bronze.crm_prd_info` |
| CRM | `sales_details.csv` | `bronze.crm_sales_details` |
| ERP | `CUST_AZ12.csv` | `bronze.erp_cust_az12` |
| ERP | `LOC_A101.csv` | `bronze.erp_loc_a101` |
| ERP | `PX_CAT_G1V2.csv` | `bronze.erp_px_cat_g1v2` |

## Local setup

The full course CSV files are supplied in the Data with Baraa project package. Copy them into the repository folders above before running the Bronze loader.

The current loader assumes this local repository location:

```text
C:\dev\sql-data-engineering-portfolio\01_data_warehouse\datasets\
```

Therefore, with the repository cloned to `C:\dev\sql-data-engineering-portfolio`, no additional path change is required after the source CSVs are copied into the expected folders.

If the repository is cloned elsewhere, update the `FROM` paths in:

```text
scripts/bronze/proc_load_bronze.sql
```

## SQL Server access requirement

`BULK INSERT` reads files from the filesystem visible to the **SQL Server service**, not from the SSMS client process. The SQL Server service account must therefore have read access to the dataset folders.

This path/access requirement is deployment configuration; it does not change the Bronze transformation rules.
