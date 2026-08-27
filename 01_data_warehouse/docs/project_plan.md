# Project Plan

This document mirrors the implementation plan used to manage the SQL Data Warehouse project. The plan is organized into six epics and follows the same engineering cycle throughout the build:

```text
Analyze → Code → Validate → Document → Commit
```

The Notion board remains the working project-management view; this file provides a version-controlled snapshot of the plan and current milestone status.

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

### Current Architecture

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
- [`data_flow/bronze_data_flow.webp`](data_flow/bronze_data_flow.webp) — source-to-Bronze lineage diagram

### Current Bronze Design

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

### Remaining Bronze Work

No technical Bronze milestone work remains. The repository contains the ingestion, validation, documentation and committed data-flow artifact.

### Definition of Done

Bronze is accepted only when:

- every required source file has a defined target table;
- source data can be loaded reproducibly;
- raw values are preserved without silent business transformation;
- schema and load validation are documented;
- the data flow from source files into Bronze is documented;
- the milestone is committed in Git.

---

## Epic 5 — Build Silver Layer

- [x] **Analysing: Explore & Understand Data**
- [x] **Document: Draw Data Integration**
- [x] **Coding: Data Cleansing**
- [x] **Validating: Data Correctness Checks**
- [ ] **Document: Extend Data Flow (Draw.io)**
- [x] **Commit Code in Git Repo**

### Completed Evidence

- [`../learnings/05_silver_layer.md`](../learnings/05_silver_layer.md) — profiling findings, rules and engineering rationale
- [`../scripts/silver/ddl_silver.sql`](../scripts/silver/ddl_silver.sql) — six Silver tables
- [`../scripts/silver/proc_load_silver.sql`](../scripts/silver/proc_load_silver.sql) — full-refresh cleansing and standardization
- [`../tests/silver/quality_checks_silver.sql`](../tests/silver/quality_checks_silver.sql) — correctness and relationship diagnostics
- [`data_integration/README.md`](data_integration/README.md) and the linked model — Silver key-preparation rules and diagram
- committed Silver implementation history

### Remaining Silver Work

- extend the detailed data-flow documentation beyond the existing high-level architecture and integration model;
- preserve an editable diagram source when that artifact is created.

---

## Epic 6 — Build Gold Layer

- [ ] **Analysing: Explore Business Objects**
- [ ] **Coding: Data Integration**
- [ ] **Validating: Data Integration Checks**
- [ ] **Document: Draw Data Model of Star Schema (Draw.io)**
- [ ] **Document: Create Data Catalog**
- [ ] **Document: Extend Data Flow (Draw.io)**
- [ ] **Commit Code in Git Repo**

### Planned Evidence

- business-entity analysis
- fact-table grain decision
- customer/product dimension definitions
- CRM/ERP integration rules
- Gold analytical views
- integration and referential checks
- star-schema diagram
- Gold data catalog
- end-to-end data-flow/lineage documentation
- milestone commit

---

## Progress Summary

| Epic | Progress |
|---|---:|
| Requirements Analysis | 100% |
| Design Data Architecture | 100% |
| Project Initialization | 100% |
| Build Bronze Layer | 100% |
| Build Silver Layer | 83% |
| Build Gold Layer | 0% |

**Current task:** `Document: Extend Silver Data Flow (Draw.io)`

---

## Working Rule

The reference project is used as the learning baseline and comparison point. For each milestone:

1. understand the requirement;
2. implement the solution;
3. review correctness and design;
4. compare with the reference approach;
5. refine the accepted solution;
6. validate and document it;
7. commit the milestone.
