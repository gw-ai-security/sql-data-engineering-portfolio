# Naming Conventions

This document defines the naming standards for the SQL Data Warehouse project. The conventions are established during **Project Initialization** so that schemas, tables, views, columns, stored procedures, files, and documentation remain consistent throughout the project.

---

## 1. General Principles

### Language

Use **English** for technical object names and documentation.

### Naming Style

Use **lower snake case**:

```text
customer_info
sales_details
product_key
```

Rules:

- lowercase letters;
- words separated by underscores (`_`);
- descriptive names;
- avoid unexplained abbreviations unless inherited from a source system;
- avoid SQL reserved words as object names.

### Source vs Warehouse Names

The naming strategy depends on the layer:

- **Bronze / Silver:** keep a clear relationship to the source-system structures.
- **Gold:** use friendly, business-oriented names.

This distinction preserves source traceability while keeping the analytical layer easy to consume.

---

## 2. Schema Names

Warehouse layers are implemented as SQL Server schemas:

```text
bronze
silver
gold
```

Objects must be schema-qualified in SQL whenever practical:

```sql
bronze.crm_cust_info
silver.crm_cust_info
gold.dim_customers
```

---

## 3. Bronze Table Naming

### Pattern

```text
<source_system>_<source_entity>
```

- `<source_system>` identifies the originating system, such as `crm` or `erp`.
- `<source_entity>` retains the recognizable source object/file name.

### Examples from the supplied source systems

```text
crm_cust_info
crm_prd_info
crm_sales_details
erp_cust_az12
erp_loc_a101
erp_px_cat_g1v2
```

### Rule

Do not replace source-specific entity names with business-friendly names in Bronze. Bronze exists partly for source traceability.

---

## 4. Silver Table Naming

Silver remains source-aligned and therefore follows the same table pattern:

```text
<source_system>_<source_entity>
```

Examples:

```text
silver.crm_cust_info
silver.crm_prd_info
silver.erp_loc_a101
```

The table name remains source-recognizable even when columns are cleansed, standardized, normalized, enriched, or technically extended.

---

## 5. Gold Object Naming

Gold uses **business-friendly names** rather than source-system technical names.

### Dimension Views

Pattern:

```text
dim_<entity>
```

Examples:

```text
dim_customers
dim_products
```

### Fact Views

Pattern:

```text
fact_<business_process>
```

Example:

```text
fact_sales
```

### Reporting Views

If a reusable reporting object is created later, use:

```text
report_<subject>
```

Examples:

```text
report_customers
report_products
report_sales_monthly
```

### Gold Naming Principle

Gold names must be understandable to analytical consumers without requiring knowledge of CRM/ERP source abbreviations.

---

## 6. Column Naming

### Bronze Columns

Preserve source column names as closely as practical to retain traceability.

Examples from the source structure include:

```text
cst_id
cst_key
prd_id
sls_ord_num
cid
cntry
```

Source abbreviations are acceptable in Bronze because they are inherited from upstream systems.

### Silver Columns

Silver may retain source-oriented names while correcting data types and values. New warehouse-generated metadata columns must be clearly distinguishable from source columns.

### Gold Columns

Use friendly, descriptive business names:

```text
customer_id
customer_number
first_name
last_name
country
product_name
order_number
sales_amount
```

Avoid exposing cryptic source abbreviations to analytical consumers unless there is a specific business reason.

---

## 7. Surrogate Keys

Warehouse-generated surrogate keys use the suffix:

```text
_key
```

Pattern:

```text
<entity>_key
```

Examples:

```text
customer_key
product_key
```

This makes the distinction between warehouse-generated keys and natural/source identifiers explicit.

Example distinction:

```text
customer_id   -- source/business identifier
customer_key  -- warehouse-generated surrogate key
```

---

## 8. Technical / Metadata Columns

Warehouse-generated technical metadata columns use the prefix:

```text
dwh_
```

Pattern:

```text
dwh_<purpose>
```

Examples:

```text
dwh_load_date
dwh_create_date
```

The prefix communicates that the value was created by the warehouse process rather than supplied by the source system.

---

## 9. Stored Procedure Naming

Layer-loading procedures follow:

```text
load_<layer>
```

Examples:

```text
load_bronze
load_silver
```

When schema-qualified:

```text
bronze.load_bronze
silver.load_silver
```

The exact procedures are created only when the corresponding implementation milestone is reached.

---

## 10. SQL Script Naming

Use descriptive snake-case filenames that communicate responsibility.

Recommended patterns:

```text
init_database.sql
ddl_bronze.sql
proc_load_bronze.sql
ddl_silver.sql
proc_load_silver.sql
ddl_gold.sql
quality_checks_silver.sql
quality_checks_gold.sql
```

The repository structure already provides separate layer directories, so filenames do not need excessive repetition beyond what improves clarity.

---

## 11. Documentation and Diagram Naming

Documentation filenames use lower snake case:

```text
project_requirements.md
project_plan.md
architecture_decisions.md
naming_conventions.md
data_architecture.drawio
data_flow.drawio
data_model.drawio
data_catalog.md
```

Editable diagram sources should be retained in the repository. Exported images may be added alongside them for GitHub rendering.

---

## 12. Naming Review Checklist

Before accepting a new object, verify:

- [ ] Is the name in English?
- [ ] Does it use lower snake case?
- [ ] Is it free of SQL reserved words?
- [ ] Does its naming match the responsibility of the current layer?
- [ ] Is the source system identifiable in Bronze/Silver?
- [ ] Is the name business-friendly in Gold?
- [ ] Are surrogate keys clearly marked with `_key`?
- [ ] Are warehouse-generated metadata columns prefixed with `dwh_`?
- [ ] Is the same terminology used in SQL, documentation, diagrams, and tests?
