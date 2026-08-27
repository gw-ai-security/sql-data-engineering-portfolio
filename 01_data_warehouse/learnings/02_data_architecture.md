# Phase 2 — Data Architecture: Engineering Learnings

## Why this phase exists

Architecture turns requirements into explicit system boundaries. The value is not the diagram itself; the value is deciding **where each responsibility belongs** and making those decisions visible before implementation becomes difficult to change.

For this project the high-level flow is:

```text
CRM + ERP CSV sources
        ↓
Bronze
        ↓
Silver
        ↓
Gold
        ↓
BI / Ad-hoc SQL / downstream analytics
```

## Step 1 — Choose a data-management approach deliberately

The course compares multiple warehouse approaches before selecting a Medallion-style design. The important learning is not that Bronze/Silver/Gold is always best. The important learning is that the architecture should match the project requirements and complexity.

For this baseline project, a three-layer architecture is sufficient because we need:

- raw-source traceability;
- a place for technical cleansing and standardization;
- a separate business-facing analytical model.

### Engineering principle

Choose the simplest architecture that creates the required boundaries. Do not add layers because they sound enterprise-grade.

## Step 2 — Define each layer before coding

### Bronze — raw preservation

Purpose:

- preserve source data as closely as practical;
- support traceability and debugging;
- create a reproducible landing point inside the warehouse.

Characteristics:

- SQL tables;
- batch/full load;
- source-aligned structure;
- no cleansing transformations;
- no business model.

### Silver — technical preparation

Purpose:

- cleanse and standardize data;
- prepare reliable source-aligned datasets for integration.

Planned responsibilities:

- missing/invalid-value handling;
- standardization and normalization;
- type correction;
- derived technical columns;
- enrichment;
- warehouse metadata.

### Gold — business-ready serving

Purpose:

- integrate CRM and ERP;
- apply business logic;
- expose a consumer-friendly analytical model.

Planned responsibilities:

- dimensions and facts;
- star-schema modeling;
- business rules;
- analytical views and aggregations.

## Step 3 — Separation of concerns is an engineering control

One of the strongest lessons in this phase is **Separation of Concerns**.

Each layer should have a clear responsibility that is not duplicated elsewhere.

Examples:

```text
Bronze → ingestion / raw preservation
Silver → cleansing / standardization
Gold   → business integration / analytical model
```

This implies rules:

- do not load selected sources directly into Silver while others pass through Bronze;
- do not hide data cleansing inside Gold;
- do not put business-specific integration logic into Silver merely because it is convenient;
- do not let downstream users depend directly on raw Bronze structures for business reporting.

### Why this matters

Without clear boundaries, pipelines become difficult to debug because the same responsibility may exist in several places. A change then has unpredictable effects across the system.

A good architecture reduces the number of places where a given kind of logic can live.

## Step 4 — Define the load behavior explicitly

A table-based layer requires a decision about how it is refreshed.

For this project the baseline is:

```text
Full extraction
+ Batch processing
+ Full load
+ TRUNCATE and reload
```

This follows the project scope: we need the latest state and do not need warehouse historization.

The learning is broader than this specific pattern:

> Every persistent layer needs an explicit loading contract.

Questions include:

- full or incremental?
- append, upsert, merge, or truncate/reload?
- what history is retained?
- what happens if the same load runs twice?

## Step 5 — Define who should consume each layer

A layer is not just a technical structure; it also has an audience.

Bronze contains raw source problems and is primarily an engineering layer. Silver may be useful for technical analysts, but business users should receive a cleaner, business-oriented interface. Gold is designed for analytical consumers.

### Learning

Data access should follow semantic maturity. The easiest layer to access is not necessarily the correct layer to expose.

## Step 6 — Architecture diagrams are communication artifacts

A useful architecture diagram should answer, without opening SQL scripts:

- Where does data come from?
- Where does it land first?
- Where is it cleaned?
- Where is it integrated?
- Which layer is consumed?
- What processing pattern is used?

Visual polish is secondary. Clear boundaries and correct connections matter more.

## What this phase taught about good data engineering

A good data engineer or data architect:

1. defines responsibilities before implementation;
2. prevents the same logic from leaking across multiple layers;
3. makes load and historization decisions explicit;
4. distinguishes technical layers from consumer contracts;
5. designs for debugging and traceability, not only the happy path;
6. can explain the entire data flow in a diagram before explaining individual SQL statements.

## Failure modes to avoid

### Layer skipping

If some sources bypass Bronze, ingestion logic exists in multiple places and traceability becomes inconsistent.

### Premature business logic

Putting business rules into Silver makes technical cleansing depend on a particular analytical use case.

### Raw data exposed as business data

A technically accessible table is not automatically a suitable consumer interface.

### Architecture by fashion

Using Medallion because it is popular is weaker than being able to explain which requirements its boundaries solve.

## Concrete evidence in this repository

- `docs/data_architecture.drawio`
- `docs/data_architecture.webp`
- `docs/architecture_decisions.md`
- `docs/project_requirements.md`

## Active-recall questions

1. What responsibility belongs uniquely to each of Bronze, Silver, and Gold?
2. Why is direct Source → Silver loading inconsistent with this architecture?
3. Why is a full reload reasonable in this specific project?
4. What is the difference between an engineering layer and a consumer contract?
5. How does Separation of Concerns reduce debugging complexity?
