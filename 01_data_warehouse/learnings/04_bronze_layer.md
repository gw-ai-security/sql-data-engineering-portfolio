# Phase 4 — Bronze Layer: Engineering Learnings

## Why this phase exists

The Bronze layer creates a controlled landing point between external source systems and the rest of the warehouse.

Its purpose is not to make data beautiful. Its purpose is to make source data **available, traceable, reproducible, inspectable, and safe to analyze downstream**.

The Bronze implementation currently covers:

1. source-system analysis;
2. source-to-table DDL design;
3. CSV ingestion;
4. repeatable load procedure;
5. operational messages and duration measurements;
6. error handling;
7. schema and completeness validation.

The remaining Bronze task is the detailed source-to-Bronze data-flow diagram.

---

## Step 1 — Analyze the source system before writing ingestion code

### Learning

A source is more than a file path and a column list. Before connecting a source to a warehouse, a data engineer needs context about what the data represents, who owns it, how it is produced, and how it can be extracted.

The course frames this as interviewing source-system experts.

### Questions a good data engineer should ask

#### Business context and ownership

- What business process does this source support?
- Who owns the system and the data?
- Which team can explain unexpected values or schema changes?
- How important is this data to downstream processes?

#### Documentation and semantics

- Is there source-system documentation?
- Is there a source data model?
- Are tables and columns defined in a catalog or specification?
- Which identifiers and relationships are meaningful?

#### Technical architecture

- Where is the source hosted?
- Is it a database, API, stream, or file extract?
- Which integration interfaces are available?
- Can the source provide full and/or incremental extracts?

#### Scope and volume

- How much history is available and how much is required?
- What extract size should be expected?
- Are there source-system limits or extraction windows?
- How frequently should data be refreshed?

### Project-specific conclusion

For this project:

```text
Source systems: CRM + ERP
Interface: CSV files in folders
Extraction: pull/file parsing
Processing: batch
Scope: latest dataset
Baseline load: full refresh
```

### Good-engineer principle

Do not design extraction code based only on what is technically possible. Design it based on source capabilities, business requirements, expected volume, and operational constraints.

---

## Step 2 — Derive Bronze DDL from source metadata

The Bronze DDL is source-aligned:

```text
cust_info.csv       → bronze.crm_cust_info
prd_info.csv        → bronze.crm_prd_info
sales_details.csv   → bronze.crm_sales_details
CUST_AZ12.csv       → bronze.erp_cust_az12
LOC_A101.csv        → bronze.erp_loc_a101
PX_CAT_G1V2.csv     → bronze.erp_px_cat_g1v2
```

### Learning: source meaning and source representation are different

A field can represent a date while still arriving as an integer-like value.

Example:

```text
sls_order_dt = 20101229
```

Business meaning:

```text
2010-12-29
```

Source representation:

```text
integer-style YYYYMMDD
```

Bronze should preserve the incoming representation when changing it early could reject or hide source-quality problems. Type correction belongs downstream when the transformation rules are known.

### Learning: Bronze should be permissive

The project intentionally avoids constraints such as primary keys and `NOT NULL` requirements on source columns.

Why?

Because duplicates, missing IDs, inconsistent codes, or malformed values may be exactly the source-quality issues we need to discover.

If Bronze rejects them before they land, the warehouse loses evidence about what the source actually delivered.

### Good-engineer principle

```text
Bronze asks: "What did the source send?"
Silver asks: "What should a technically clean record look like?"
Gold asks:   "What does the business need to consume?"
```

---

## Step 3 — Understand the load strategy, not just BULK INSERT syntax

The project uses:

```text
TRUNCATE TABLE
      ↓
BULK INSERT
```

for each source-aligned Bronze table.

The relevant configuration is:

```text
FIRSTROW = 2
FIELDTERMINATOR = ','
TABLOCK
```

### What this means conceptually

- `FIRSTROW = 2` skips the CSV header.
- `FIELDTERMINATOR = ','` defines how fields are separated.
- `TABLOCK` allows a table-level lock during the bulk operation.
- `TRUNCATE TABLE` ensures the next run replaces the previous snapshot instead of appending duplicates.

### Learning: rerun behavior must be deliberate

A pipeline is not reliable only because its first run succeeds.

You should know what happens when it runs again.

For this project:

```text
Run 1 → current Bronze snapshot
Run 2 → previous snapshot removed → current snapshot loaded again
```

Row counts should remain stable if the source is unchanged.

This is a simple form of repeatability.

### Good-engineer questions

- Does a rerun duplicate data?
- Does a failed run leave a partially refreshed layer?
- Is the load full, append-only, upsert, merge, or replace?
- Is the behavior documented and testable?

---

## Step 4 — Encapsulate repeated pipeline logic

Once the six loads were working, they were placed inside:

```text
bronze.load_bronze
```

### Learning

Frequently repeated operational logic should have one controlled execution entry point.

Instead of manually selecting six blocks, the operator runs:

```sql
EXEC bronze.load_bronze;
```

This reduces manual variation and makes the expected pipeline sequence explicit.

### Important lesson from implementation

Creating or altering a stored procedure does **not** execute it.

```text
CREATE OR ALTER PROCEDURE
→ defines what should happen

EXEC bronze.load_bronze
→ actually runs the load
```

This distinction matters operationally. "The command executed successfully" may only mean the procedure definition was accepted, not that any data moved.

---

## Step 5 — Make the pipeline observable

A successful pipeline should tell us more than "completed."

The current loader records or reports:

- which source-system group is being processed;
- which table is being truncated;
- which table is being loaded;
- start/end timestamps for each table load;
- load duration per table;
- total batch duration;
- error number, state, line, and message if the batch fails.

### Core operational questions

A data engineer should be able to answer:

```text
Which pipeline stage is running?
Which table is currently being processed?
How long did each table load take?
How long did the whole batch take?
Where did a failure occur?
What error was returned?
```

### Why timing matters

The first purpose of duration measurements is not sophisticated performance tuning. It is establishing **visibility**.

Without measurements, an engineer cannot distinguish:

- a normally slow load;
- a sudden regression;
- one problematic table;
- time spent across the complete batch.

In this project the timings are printed during execution rather than persisted in a logging table. That is sufficient for the current learning scope, but it introduces the broader idea of pipeline observability.

### Good-engineer principle

Do not wait for a failure before deciding which operational information would have been useful.

---

## Step 6 — Error handling must preserve failure semantics

The Bronze loader uses `TRY...CATCH` and reports error details.

Our implementation also uses `THROW` after reporting the error.

### Why this matters

An error message alone is not enough if the calling process receives the impression that execution succeeded.

A robust pipeline should:

1. provide context for diagnosis;
2. still signal failure to the caller.

### Good-engineer questions

- Which table failed?
- At which line/stage did it fail?
- Was the error swallowed or propagated?
- What state was already modified before the failure?
- Is rerunning safe?

The last two questions become increasingly important in more complex pipelines.

---

## Step 7 — Validate data movement independently from execution success

One of the strongest lessons from the Bronze implementation is:

```text
SQL command succeeded
≠
Data load is correct
```

We therefore added explicit validation rather than trusting the absence of errors.

### Schema validation

Check that:

- all six Bronze tables exist;
- expected columns exist in the correct order;
- data types and string lengths match the intended DDL;
- source columns remain nullable as designed.

### Completeness validation

Compare expected source/load counts with actual Bronze counts.

The purpose is to detect silent data loss or unexpected duplication.

### Field-mapping validation

Inspect sample records to verify that CSV fields landed in the intended columns.

A bad delimiter or mismatched table definition may still produce rows while placing values in the wrong fields.

### Repeatability validation

Run the full-load procedure again and verify that unchanged source files do not produce accumulating duplicates.

### Good-engineer principle

Tests should verify the **contract of the pipeline**, not merely that the SQL parser accepts the statements.

---

## Step 8 — Reconciliation requires precision about what is being counted

During validation we encountered a useful edge case: two supplied CSV files have a logical final record that behaves differently under the simple course `BULK INSERT` baseline because of the file ending/empty final field.

The important learning is not the particular line-ending issue. It is how to react to a discrepancy.

Bad response:

```text
Change the expected value until the test becomes green.
```

Better response:

```text
Determine what each count means.
Document the source count.
Document the observed loader baseline.
Explain the difference.
Do not silently redefine the source truth.
```

Our validation therefore distinguishes:

- logical source records;
- observed course-load baseline;
- actual loaded records.

### Good-engineer principle

When two systems disagree, first define the semantics of both measurements. A green test with the wrong expectation is worse than an explained discrepancy.

---

## Step 9 — Local file paths are configuration, not business logic

`BULK INSERT` reads files from the filesystem visible to the SQL Server service.

The current repository paths are local development configuration.

### Learning

The SSMS client and SQL Server engine are not the same process. A path visible to the developer is not automatically visible to the database server.

In a remote, containerized, or cloud environment, source placement and service-account permissions would need explicit design.

### Good-engineer principle

Separate what is **environment-specific configuration** from what is **warehouse transformation logic**.

---

## Step 10 — Data lineage completes the Bronze deliverable

The project documents the source-to-Bronze data flow and later extends it through Silver and Gold.

The goal is to make this understandable without opening SQL code:

```text
CRM
├── cust_info.csv       → bronze.crm_cust_info
├── prd_info.csv        → bronze.crm_prd_info
└── sales_details.csv   → bronze.crm_sales_details

ERP
├── CUST_AZ12.csv       → bronze.erp_cust_az12
├── LOC_A101.csv        → bronze.erp_loc_a101
└── PX_CAT_G1V2.csv     → bronze.erp_px_cat_g1v2
```

### Learning

Lineage documentation answers a different question from architecture documentation.

Architecture:

> What are the major components and responsibilities?

Lineage/data flow:

> Where did this specific dataset come from and where does it go next?

Both are useful, but they solve different communication problems.

---

# What this phase taught about good data engineering

A good data engineer:

1. understands source systems before implementing extraction;
2. preserves raw evidence instead of prematurely fixing data;
3. defines rerun behavior explicitly;
4. uses repeatable execution entry points for pipeline operations;
5. makes pipeline progress, runtime, and failures observable;
6. validates row completeness and schema mapping independently from execution success;
7. investigates mismatches instead of manipulating expectations to get green tests;
8. distinguishes configuration problems from transformation logic;
9. documents lineage so another engineer can trace data without reverse-engineering SQL;
10. thinks about failure, diagnosis, and reruns while building the happy path.

# Concrete evidence in this repository

- `docs/source_systems.md`
- `scripts/bronze/ddl_bronze.sql`
- `scripts/bronze/proc_load_bronze.sql`
- `tests/bronze/01_validate_bronze_schema.sql`
- `tests/bronze/02_validate_bronze_load.sql`
- `docs/data_architecture.drawio`

# Active-recall questions

1. Why should Bronze preserve poor-quality source values instead of correcting them immediately?
2. What is the difference between a field's business meaning and its source representation?
3. Why does `TRUNCATE + BULK INSERT` make repeated full loads predictable?
4. Why does successfully creating `bronze.load_bronze` not mean the Bronze tables were loaded?
5. Which operational questions do start/end timestamps and stage messages help answer?
6. Why should a caught error usually still be propagated to the caller?
7. Why is `COUNT(*)` validation necessary even when `BULK INSERT` reports success?
8. What can sample-row inspection detect that a row count cannot?
9. Why is changing an expected count just to make a test pass dangerous?
10. What is the difference between high-level architecture and data lineage?
