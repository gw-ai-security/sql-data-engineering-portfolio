# Architecture Decisions

This document records the architectural decisions that have been made so far for the SQL Data Warehouse project. Decisions are derived from the project requirements and the current project phase; future implementation choices will be added only when the relevant milestone is reached.

---

## ADR-001 — Use Microsoft SQL Server as the warehouse platform

**Status:** Accepted  
**Phase:** Design Data Architecture

### Context

The project requirement is to build a modern data warehouse in SQL Server and use SQL as the primary implementation language.

### Decision

Use **Microsoft SQL Server** as the database platform and **T-SQL** for warehouse implementation.

### Consequences

- The project can use SQL Server schemas, views, stored procedures, `BULK INSERT`, and T-SQL-specific functionality.
- The implementation is intentionally platform-specific at this stage.
- Portability to PostgreSQL, Snowflake, Databricks, or other platforms is not a baseline requirement.

---

## ADR-002 — Use a Bronze / Silver / Gold architecture

**Status:** Accepted  
**Phase:** Design Data Architecture

### Context

The project requires raw-source traceability, data cleansing before analysis, integration of CRM and ERP data, and a business-ready analytical model.

### Decision

Use three logical warehouse layers:

```text
Sources → Bronze → Silver → Gold → Consumers
```

### Rationale

This structure creates clear separation of concerns:

- Bronze protects raw source fidelity.
- Silver owns cleansing and standardization.
- Gold owns business integration and analytical serving.

The design makes responsibilities easier to understand, test, debug, and document.

---

## ADR-003 — Preserve raw source data in Bronze

**Status:** Accepted  
**Phase:** Design Data Architecture

### Decision

Bronze stores source data in SQL tables with **no business or cleansing transformations**.

Source-specific names and structures remain recognizable so that records can be traced back to their original files.

### Rationale

Raw preservation supports:

- traceability;
- debugging;
- source-to-target comparison;
- reproducibility of downstream transformations.

### Consequence

Poor-quality or technically inconvenient source values may intentionally exist in Bronze. Their correction belongs downstream.

---

## ADR-004 — Perform technical data preparation in Silver

**Status:** Accepted  
**Phase:** Design Data Architecture

### Decision

Silver is responsible for technical preparation of source-aligned data, including where required:

- cleansing;
- standardization;
- normalization;
- data-type correction;
- derived columns;
- enrichment;
- technical warehouse metadata.

### Boundary

Business-facing dimensional modeling and cross-source business logic do **not** belong in Silver.

### Rationale

Keeping Silver source-aligned prevents technical cleansing logic from becoming coupled to a particular report or analytical use case.

---

## ADR-005 — Use Gold as the analytical consumer contract

**Status:** Accepted  
**Phase:** Design Data Architecture

### Decision

Gold exposes **business-ready analytical views** and is the preferred interface for downstream users.

Gold is responsible for:

- CRM/ERP integration;
- business rules;
- dimensional modeling;
- dimensions and facts;
- analytical aggregations where justified;
- friendly business-oriented names.

### Consumers

Typical Gold consumers are:

- BI and reporting tools;
- ad-hoc SQL analysts;
- downstream analytical or machine-learning processes.

### Consequence

Consumers should not depend directly on Bronze source tables for business reporting.

---

## ADR-006 — Use batch full loads for the baseline

**Status:** Accepted  
**Phase:** Design Data Architecture

### Context

The project specification focuses on the latest dataset and explicitly states that historization is not required.

### Decision

For the baseline implementation:

- processing is batch-oriented;
- Bronze uses full reloads;
- Silver uses full reloads;
- the baseline reload pattern is `TRUNCATE` + `INSERT`.

### Rationale

This is sufficient for the supplied project scenario and keeps the implementation focused on SQL warehouse fundamentals.

### Consequences

The baseline does not demonstrate:

- CDC;
- incremental extraction;
- merge/upsert pipelines;
- SCD Type 2 history.

These may be evaluated later as explicit extensions, but they are not required to satisfy the current project requirements.

---

## ADR-007 — Do not implement record historization in the baseline

**Status:** Accepted  
**Phase:** Requirements / Architecture

### Decision

The warehouse represents the latest required business state. Full source-record historization is out of scope.

### Rationale

This decision follows the project specification rather than a technical limitation.

### Important distinction

The project may still contain source attributes that describe dates or historical business events. The excluded capability is warehouse-level tracking of every changed version of a source record.

---

## ADR-008 — Use Git as part of the engineering workflow

**Status:** Accepted  
**Phase:** Project Initialization

### Decision

Version-control code and documentation throughout the project rather than uploading a completed project only at the end.

Each build epic follows the pattern:

```text
Analyze → Code → Validate → Document → Commit
```

### Rationale

This provides:

- change history;
- rollback capability;
- traceable project evidence;
- a more credible portfolio artifact.

---

## Decisions Not Yet Made

The following decisions are intentionally deferred until the corresponding implementation phase:

- exact Bronze table DDL;
- source-file ingestion implementation details;
- Silver cleansing rules per column;
- source precedence rules for conflicting CRM/ERP values;
- Gold fact-table grain;
- surrogate-key implementation details;
- final dimension/fact definitions;
- data-quality thresholds and reconciliation checks;
- indexing or performance optimizations.

Deferring these decisions prevents the architecture document from pretending that implementation analysis has already been completed.
