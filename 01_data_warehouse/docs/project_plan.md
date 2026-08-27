# Project Plan

This document mirrors the implementation plan used to manage the SQL Data Warehouse project. The completed build is organized into six epics and follows the same engineering cycle throughout:

```text
Analyze → Code → Validate → Document → Commit
```

The Notion board was used as the working project-management view during implementation; this file is the version-controlled completion record and evidence index.

---

## Epic 1 — Requirements Analysis

- [x] **Analyse & Understand the Requirements**

### Deliverables

- [`project_requirements.md`](project_requirements.md)
- Requirements reflected in architecture and scope decisions

---

## Epic 2 — Design Data Architecture

- [x] **Choose Data Management Approach**
- [x] **Design the Layers**
- [x] **Draw the Data Architecture (Draw.io)**

### Deliverables

- [`data_architecture.drawio`](data_architecture.drawio)
- [`data_architecture.webp`](data_architecture.webp)
- [`architecture_decisions.md`](architecture_decisions.md)

### Final Architecture

```text
CRM CSV ─┐
         ├→ Bronze → Silver → Gold → BI / Ad-hoc SQL / ML
ERP CSV ─┘
```

---

## Epic 3 — Project Initialization

- [x] **Create Detailed Project Tasks (Notion)**
- [x] **Define Project Naming Conventions**
- [x] **Create Git Repo & Prepare the Repo Structure**
- [x] **Create Database & Schemas**

### Deliverables

- [`project_plan.md`](project_plan.md)
- [`naming_conventions.md`](naming_conventions.md)
- [`../scripts/init_database.sql`](../scripts/init_database.sql)
- GitHub repository structure
- Root and project README documentation

The initialization script creates:

```text
DataWarehouse
├── bronze
├── silver
└── gold
```

---

## Epic 4 — Build Bronze Layer

- [x] **Analysing: Source Systems**
- [x] **Coding: Data Ingestion**
- [x] **Validating: Data Completeness & Schema Checks**
- [x] **Document: Draw Data Flow**
- [x] **Commit Code in Git Repo — Bronze milestone**

### Completed Evidence

- [`source_systems.md`](source_systems.md) — CRM/ERP file inventory and mappings
- [`../scripts/bronze/ddl_bronze.sql`](../scripts/bronze/ddl_bronze.sql) — six source-aligned Bronze tables
- [`../scripts/bronze/proc_load_bronze.sql`](../scripts/bronze/proc_load_bronze.sql) — batch/full-load ingestion procedure
- [`../tests/bronze/01_validate_bronze_schema.sql`](../tests/bronze/01_validate_bronze_schema.sql) — schema validation
- [`../tests/bronze/02_validate_bronze_load.sql`](../tests/bronze/02_validate_bronze_load.sql) — row-count, mapping, and repeatability validation
- [`data_flow/bronze_data_flow.webp`](data_flow/bronze_data_flow.webp) — source-to-Bronze lineage

### Accepted Bronze Design

```text
CSV sources
   ↓
TRUNCATE target
   ↓
BULK INSERT
   ↓
Bronze source-aligned tables
```

Loader configuration:

```text
FIRSTROW = 2
FIELDTERMINATOR = ','
TABLOCK
```

No cleansing or business transformations occur in Bronze.

---

## Epic 5 — Build Silver Layer

- [x] **Analysing: Explore & Understand Data**
- [x] **Document: Draw Data Integration**
- [x] **Coding: Data Cleansing**
- [x] **Validating: Data Correctness Checks**
- [x] **Document: Extend Data Flow (Draw.io)**
- [x] **Commit Code in Git Repo**

### Completed Evidence

- [`../learnings/05_silver_layer.md`](../learnings/05_silver_layer.md) — profiling findings, transformation rules and engineering rationale
- [`../scripts/silver/ddl_silver.sql`](../scripts/silver/ddl_silver.sql) — six Silver tables
- [`../scripts/silver/proc_load_silver.sql`](../scripts/silver/proc_load_silver.sql) — full-refresh cleansing and standardization
- [`../tests/silver/quality_checks_silver.sql`](../tests/silver/quality_checks_silver.sql) — correctness and relationship diagnostics
- [`data_integration/README.md`](data_integration/README.md) — integration-key preparation and business-object context
- [`data_integration/data_integration_model.webp`](data_integration/data_integration_model.webp) — source integration model
- [`data_flow/bronze_silver_data_flow.webp`](data_flow/bronze_silver_data_flow.webp) — extended Silver lineage

---

## Epic 6 — Build Gold Layer

- [x] **Analysing: Explore Business Objects**
- [x] **Coding: Data Integration**
- [x] **Validating: Data Integration Checks**
- [x] **Document: Draw Data Model of Star Schema (Draw.io)**
- [x] **Document: Create Data Catalog**
- [x] **Document: Extend Data Flow (Draw.io)**
- [x] **Commit Code in Git Repo**

### Completed Evidence

- [`data_integration/README.md`](data_integration/README.md) and [`data_integration/business_object_integration_model.webp`](data_integration/business_object_integration_model.webp) — SALES, PRODUCT and CUSTOMER business-object discovery
- [`../scripts/gold/ddl_gold.sql`](../scripts/gold/ddl_gold.sql) — `dim_customers`, `dim_products` and `fact_sales` views
- [`../tests/gold/quality_checks_gold.sql`](../tests/gold/quality_checks_gold.sql) — grain, fan-out, row-preservation and referential checks
- [`data_model/gold_star_schema.drawio`](data_model/gold_star_schema.drawio) and [`data_model/gold_star_schema.webp`](data_model/gold_star_schema.webp) — logical Star Schema
- [`data_catalog/gold_data_catalog.md`](data_catalog/gold_data_catalog.md) — object/column definitions and lineage
- [`data_flow/bronze_silver_gold_data_flow.drawio`](data_flow/bronze_silver_gold_data_flow.drawio) and [`data_flow/bronze_silver_gold_data_flow.webp`](data_flow/bronze_silver_gold_data_flow.webp) — final end-to-end lineage
- [`../learnings/06_gold_layer.md`](../learnings/06_gold_layer.md) — Gold engineering learning journal

---

## Final Progress Summary

| Epic | Progress |
|---|---:|
| Requirements Analysis | 100% |
| Design Data Architecture | 100% |
| Project Initialization | 100% |
| Build Bronze Layer | 100% |
| Build Silver Layer | 100% |
| Build Gold Layer | 100% |

**Current status:** Data Warehouse project complete. Final repository QA has aligned documentation, naming, structure and published artifacts with the implemented state.

**Next portfolio milestone:** Project 02 — Exploratory Data Analysis.

---

## Working Rule

The reference project is used as the learning baseline and comparison point. For each milestone:

1. understand the requirement;
2. implement the solution;
3. review correctness and design;
4. compare with the reference approach;
5. refine only where the data or engineering evidence justifies it;
6. validate and document the accepted state;
7. commit the milestone.
