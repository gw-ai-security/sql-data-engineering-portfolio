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

The current repository does not duplicate the full course dataset files. Use the source files supplied with the Data with Baraa project package and place them in the layout above if you want the repository to be self-contained locally.

## Local SQL Server path

`BULK INSERT` reads files from the filesystem visible to the **SQL Server service**, not from the SSMS client process. The paths in `scripts/bronze/proc_load_bronze.sql` therefore reflect the current local development environment and must be adapted when the repository is used on another machine.

This is a deployment configuration detail, not a warehouse transformation rule.
