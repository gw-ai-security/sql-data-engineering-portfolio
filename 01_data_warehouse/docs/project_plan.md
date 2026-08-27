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
- Requirements reflected in the architecture and scope decisions

---

## Epic 2 — Design Data Architecture

- [x] **Choose Data Management Approach**
- [x] **Design the Layers**
- [x] **Draw the Data Architecture (Draw.io)**

### Deliverables

- [`data_architecture.drawio`](data_architecture.drawio)
- [`architecture_decisions.md`](architecture_decisions.md)

### Current Architecture

```text
CRM CSV ─┐
         ├→ Bronze → Silver → Gold → BI / Ad-hoc SQL / ML
ERP CSV ─┘
```

Layer responsibilities:

- **Bronze:** raw preservation and ingestion
- **Silver:** cleansing, standardization, normalization, derived columns, enrichment
- **Gold:** integration, business logic, analytical modeling and serving

---

## Epic 3 — Project Initialization

- [x] **Create Detailed Project Tasks (Notion)**
- [x] **Define Project Naming Conventions**
- [x] **Create Git Repo & Prepare the Repo Structure**
- [ ] **Create Database & Schemas**

### Deliverables Completed

- [`project_plan.md`](project_plan.md)
- [`naming_conventions.md`](naming_conventions.md)
- GitHub repository structure
- Root and project README documentation

### Next Deliverable

Create the SQL Server database and the following schemas:

```text
bronze
silver
gold
```

The database-creation script will be added when that task is implemented rather than copied from the reference solution in advance.

---

## Epic 4 — Build Bronze Layer

- [ ] **Analysing: Source Systems**
- [ ] **Coding: Data Ingestion**
- [ ] **Validating: Data Completeness & Schema Checks**
- [ ] **Document: Draw Data Flow (Draw.io)**
- [ ] **Commit Code in Git Repo**

### Planned Evidence

- source-system/file inventory
- Bronze table DDL
- ingestion/loading logic
- completeness checks
- schema checks
- first data-flow diagram
- milestone commit

### Definition of Done

Bronze is accepted only when:

- every required source file has a defined target table;
- source data can be loaded reproducibly;
- raw values are preserved without silent business transformation;
- row/schema validation is documented;
- the data flow from source files into Bronze is documented.

---

## Epic 5 — Build Silver Layer

- [ ] **Analysing: Explore & Understand Data**
- [ ] **Document: Draw Data Integration (Draw.io)**
- [ ] **Coding: Data Cleansing**
- [ ] **Validating: Data Correctness Checks**
- [ ] **Document: Extend Data Flow (Draw.io)**
- [ ] **Commit Code in Git Repo**

### Planned Evidence

- source-data profiling notes
- identified data-quality issues
- cleansing and standardization rules
- Silver table DDL
- Silver loading/transformation procedure
- correctness checks
- data-integration documentation
- extended lineage/data-flow diagram
- milestone commit

### Definition of Done

Silver is accepted only when:

- required data-quality issues are identified and addressed;
- transformation rules are explainable and testable;
- source relationships remain traceable;
- technical metadata follows naming standards;
- correctness checks pass before Gold modeling begins.

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

### Definition of Done

Gold is accepted only when:

- facts and dimensions have explicit business meaning and grain;
- CRM/ERP integration rules are documented;
- analytical names are consumer-friendly;
- key relationships are valid;
- the model supports downstream EDA and advanced analytics;
- the data catalog and star-schema documentation are complete.

---

## Progress Summary

| Epic | Progress |
|---|---:|
| Requirements Analysis | 100% |
| Design Data Architecture | 100% |
| Project Initialization | 75% |
| Build Bronze Layer | 0% |
| Build Silver Layer | 0% |
| Build Gold Layer | 0% |

**Current task:** `Create Database & Schemas`

---

## Working Rule

The reference project is used as a learning baseline and later comparison point. Implementation files are not pre-copied into this repository. For each milestone:

1. understand the requirement;
2. attempt the implementation;
3. review correctness and design;
4. compare with the reference approach;
5. refine the final solution;
6. validate and document it;
7. commit the accepted milestone.
