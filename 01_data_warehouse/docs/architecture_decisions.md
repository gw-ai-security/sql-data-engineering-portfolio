# Architecture Decisions

This document records architectural and implementation decisions for the SQL Data Warehouse project. Decisions are derived from the project requirements, the Data with Baraa reference project, and the implementation work completed so far.

---

## ADR-001 — Use Microsoft SQL Server as the warehouse platform

**Status:** Accepted  
**Phase:** Design Data Architecture

Use **Microsoft SQL Server** as the database platform and **T-SQL** for warehouse implementation.

Consequences:

- SQL Server schemas represent Bronze, Silver, and Gold.
- The project can use `BULK INSERT`, stored procedures, views, and T-SQL-specific functionality.
- Portability to other platforms is not a baseline requirement.

---

## ADR-002 — Use a Bronze / Silver / Gold architecture

**Status:** Accepted  
**Phase:** Design Data Architecture

```text
Sources → Bronze → Silver → Gold → Consumers
```

Responsibilities:

- **Bronze:** source-aligned raw ingestion and traceability
- **Silver:** cleansing, standardization, normalization, type correction, and technical enrichment
- **Gold:** cross-source integration, business rules, dimensional modeling, and analytical serving

This mirrors the Medallion-style architecture used in the reference project and provides separation of concerns.

---

## ADR-003 — Preserve source fidelity in Bronze

**Status:** Accepted  
**Phase:** Design / Bronze

Bronze stores source-oriented structures without cleansing or business transformations.

Consequences:

- source names remain recognizable;
- source-quality problems are allowed to land in Bronze;
- Bronze columns remain nullable unless there is a compelling ingestion reason otherwise;
- primary keys and business validation constraints are intentionally not enforced in the raw layer.

This preserves evidence required for debugging and downstream data-quality analysis.

---

## ADR-004 — Perform technical data preparation in Silver

**Status:** Accepted  
**Phase:** Design Data Architecture

Silver owns technical data preparation, including where required:

- cleansing;
- standardization;
- normalization;
- data-type correction;
- derived columns;
- enrichment;
- warehouse metadata.

Business-facing dimensional modeling and cross-source business logic remain outside Silver.

---

## ADR-005 — Use Gold as the analytical consumer contract

**Status:** Accepted  
**Phase:** Design Data Architecture

Gold exposes business-ready analytical objects for:

- BI and reporting;
- ad-hoc SQL analysis;
- downstream analytical or machine-learning workloads.

Gold is responsible for CRM/ERP integration, business rules, dimensions, facts, and consumer-friendly naming.

---

## ADR-006 — Use batch full loads for the baseline

**Status:** Accepted  
**Phase:** Requirements / Architecture

The project focuses on the latest dataset and does not require historization. Therefore the baseline uses:

- batch processing;
- full source extracts;
- full Bronze reloads;
- full Silver reloads;
- `TRUNCATE` followed by load/insert operations.

The baseline intentionally does not implement CDC, incremental extraction, merge/upsert loading, or SCD Type 2 history.

---

## ADR-007 — Do not implement warehouse historization in the baseline

**Status:** Accepted  
**Phase:** Requirements / Architecture

The warehouse represents the latest required state. This is a scope decision from the project requirements, not a technical limitation.

---

## ADR-008 — Use Git throughout the engineering workflow

**Status:** Accepted  
**Phase:** Project Initialization

Version-control implementation and documentation throughout the build.

```text
Analyze → Code → Validate → Document → Commit
```

This provides traceability, rollback capability, and visible portfolio evidence.

---

## ADR-009 — Use source-aligned Bronze DDL

**Status:** Accepted  
**Phase:** Build Bronze Layer

Six source-aligned tables are created:

```text
bronze.crm_cust_info
bronze.crm_prd_info
bronze.crm_sales_details
bronze.erp_cust_az12
bronze.erp_loc_a101
bronze.erp_px_cat_g1v2
```

The DDL follows the source structures and the reference project. Product start/end dates use `DATETIME` in Bronze, matching the reference sequence; Silver later converts the analytical representation to `DATE`.

The sales date fields remain `INT` in Bronze because the CRM extract represents them as `YYYYMMDD`-style numeric values and also contains invalid raw representations that must not be silently corrected during ingestion.

---

## ADR-010 — Use `BULK INSERT` for Bronze file ingestion

**Status:** Accepted  
**Phase:** Build Bronze Layer

The Bronze loader uses SQL Server `BULK INSERT` for all six CSV files with:

```text
FIRSTROW = 2
FIELDTERMINATOR = ','
TABLOCK
```

Each target is truncated immediately before loading, implementing the project's full-refresh strategy.

The loader is encapsulated in:

```text
bronze.load_bronze
```

The procedure measures table-level and total batch duration and uses `TRY...CATCH` plus `THROW` for error visibility.

### Portability constraint

The current `BULK INSERT` paths are local deployment configuration. SQL Server must be able to access the paths through its service account. Another machine must adapt those paths or deploy the source files to an equivalent accessible location.

---

## ADR-011 — Validate Bronze schema and load separately

**Status:** Accepted  
**Phase:** Build Bronze Layer

Bronze validation is split into two concerns:

1. **Schema validation** — expected tables, columns, SQL data types, lengths, and nullability.
2. **Load validation** — loaded row counts, sample-field mapping, and full-load repeatability.

This is an extension of the manual schema/count checks shown in the reference project and makes the validation reproducible in Git.

### CSV reconciliation note

For `cust_info.csv` and `CUST_AZ12.csv`, a full CSV parser detects one more logical record than the simple course `BULK INSERT` pattern loads. The repository records both the logical source count and the course load baseline rather than silently treating them as identical.

The supplied source files are not modified in the baseline.

---

## ADR-012 — Keep Silver source-aligned with minimal data-backed corrections

**Status:** Accepted
**Phase:** Build Silver Layer

Silver keeps the same six logical source entities as Bronze and uses a full refresh with `TRUNCATE TABLE` followed by transformed `INSERT` statements. It corrects technical data types, standardizes source codes, derives integration-ready keys and adds `dwh_create_date DATETIME2 DEFAULT GETDATE()`.

The implementation follows the Data with Baraa baseline with three small robustness/correctness refinements:

- sales dates outside the accepted 1900–2050 range are mapped to `NULL` for order, ship and due dates;
- the derived CRM pedal category `CO_PE` is mapped to ERP's observed `CO_PD` (`Components / Pedals`);
- `SET NOCOUNT ON` and `THROW` preserve a clear caller-visible failure state.

Silver does not create dimensions, facts, cross-source business entities, incremental loading, historization or an external test framework.

---

## ADR-013 — Expose Gold as a latest-snapshot star schema of views

**Status:** Accepted
**Phase:** Build Gold Layer

Gold exposes exactly three business-ready SQL Server views:

```text
gold.dim_customers
gold.dim_products
gold.fact_sales
```

Accepted modeling decisions:

- CUSTOMER and PRODUCT are dimensions; SALES is the fact;
- the customer dimension is anchored on the CRM customer master and enriched from ERP demographics and location through `LEFT JOIN`s;
- CRM gender has precedence when known, with ERP as the fallback;
- the product dimension contains current products only (`prd_end_dt IS NULL`) and consumes category keys already corrected in Silver;
- the fact preserves the Silver sales-line grain and resolves customer/product surrogate keys through the Gold dimensions;
- `ROW_NUMBER()` surrogate keys follow the course baseline and are deterministic for the current snapshot because their final ordering keys are unique;
- quality checks validate business grain, fan-out, fact preservation, dimension connectivity and unchanged Silver measures.

The view-based design avoids a separate Gold loading procedure and is appropriate for the current small latest-snapshot dataset. `ROW_NUMBER()` keys are not durable when the dimension population changes, and view calculations occur at query time; those are documented learning-project limitations rather than reasons to add persistent marts or historical key infrastructure.

---

## Decisions Not Yet Made

No decisions required by the current Bronze/Silver/Gold baseline remain open. Production-scale indexing, materialization, incremental loading and durable historical surrogate-key strategies are intentionally outside the project scope.
