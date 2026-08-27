# Project Requirements

## 1. Objective

Develop a modern data warehouse using **Microsoft SQL Server** to consolidate sales data from multiple operational sources and prepare it for analytical reporting and informed decision-making.

The warehouse must provide a clear path from raw source files to business-ready analytical data while preserving traceability and resolving data-quality issues before consumption.

---

## 2. Source Requirements

### 2.1 Source Systems

The baseline project uses two source systems:

- **CRM**
- **ERP**

### 2.2 Source Interface

Source data is provided as **CSV files stored in folders**.

This establishes a file-based ingestion interface for the baseline implementation.

### 2.3 Source Scope

The source datasets represent the latest available state required for the project. The baseline does not require source-record historization.

---

## 3. Functional Requirements

### FR-01 — Ingest source data

Import the CRM and ERP CSV datasets into SQL Server.

**Acceptance intent:**
- all required source files can be represented in the warehouse;
- the raw data remains traceable to its source system;
- ingestion does not silently transform source values in the raw layer.

### FR-02 — Resolve data-quality issues

Cleanse and resolve data-quality problems before analytical consumption.

Expected transformation categories include, where required by the source data:

- handling missing values;
- duplicate detection/removal;
- invalid-value handling;
- data-type correction;
- trimming/standardizing text values;
- normalization and standardization;
- derivation of required technical or analytical columns;
- data enrichment.

### FR-03 — Integrate CRM and ERP data

Combine information from both source systems into a coherent, user-friendly analytical model.

**Acceptance intent:**
- related business entities from CRM and ERP can be connected;
- downstream users do not need to understand source-specific technical structures to query business-ready data;
- integration rules are explicit and testable.

### FR-04 — Support analytical consumption

Provide business-ready data optimized for analytical queries and reporting.

Expected consumer types include:

- BI and reporting tools;
- ad-hoc SQL users;
- downstream analytical or machine-learning workloads.

### FR-05 — Document the solution

Provide documentation that allows technical and analytical users to understand:

- project requirements;
- architecture and layer responsibilities;
- naming standards;
- data flow and lineage;
- analytical data model;
- data definitions/catalog information;
- known limitations and scope decisions.

---

## 4. Non-Functional Requirements

### NFR-01 — Traceability

Raw source data must be preserved before cleansing and business transformation so that downstream issues can be traced back to their origin.

### NFR-02 — Separation of Concerns

Responsibilities must be separated across warehouse layers:

- **Bronze:** ingestion and raw preservation;
- **Silver:** cleansing, standardization, normalization, derived columns, enrichment;
- **Gold:** source integration, business logic, analytical modeling, and serving.

### NFR-03 — Consistency

SQL objects, columns, procedures, files, and documentation must follow the project naming conventions.

### NFR-04 — Testability

Each implemented layer must be validated before it becomes an accepted upstream dependency for the next layer.

### NFR-05 — Version Control

Code and documentation must be maintained in Git and committed at meaningful project milestones.

---

## 5. Baseline Scope Decisions

The following constraints are part of the baseline project design:

- Target platform: **Microsoft SQL Server**.
- Source ingestion: **file-based**.
- Processing style: **batch**.
- Bronze and Silver baseline load strategy: **full load**.
- Baseline reload method: **`TRUNCATE` + `INSERT`**.
- Historization / Slowly Changing Dimension Type 2: **not required**.
- Change Data Capture (CDC): **out of scope**.
- Incremental loading: **out of scope for the baseline**.
- Gold is exposed primarily through **business-ready SQL views**.

These are deliberate project constraints rather than general recommendations for every production warehouse.

---

## 6. Out of Scope for the Baseline

The following are intentionally excluded unless added later as explicit portfolio extensions:

- real-time or streaming ingestion;
- CDC-based pipelines;
- SCD Type 2 historization;
- orchestration platforms such as Airflow;
- cloud infrastructure;
- Python-based ingestion;
- dbt;
- containerization;
- production alerting/monitoring platforms.

The purpose of the baseline is to demonstrate strong SQL data-engineering fundamentals before adding additional tooling.

---

## 7. Definition of Done for a Project Task

A task is considered complete only when the relevant evidence exists:

1. the requirement or problem is understood;
2. the implementation is completed independently;
3. the result is validated;
4. relevant edge cases or failure conditions are considered;
5. code and documentation follow project standards;
6. the design or implementation can be explained and justified;
7. the milestone is committed to Git where applicable.

---

## 8. Traceability to Project Epics

| Requirement Area | Primary Epic |
|---|---|
| Requirements definition | Requirements Analysis |
| Warehouse/layer design | Design Data Architecture |
| Standards and repository setup | Project Initialization |
| Raw-source ingestion | Build Bronze Layer |
| Data cleansing and standardization | Build Silver Layer |
| Integration and analytical model | Build Gold Layer |
| Validation | Bronze / Silver / Gold build epics |
| Documentation | Architecture + each build epic |
