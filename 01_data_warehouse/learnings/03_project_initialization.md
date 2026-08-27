# Phase 3 — Project Initialization: Engineering Learnings

## Why this phase exists

Project initialization converts an architecture idea into a controlled engineering workspace. The important lesson is that reliable data engineering starts before the first ETL statement is written.

This phase covered:

1. detailed project planning;
2. naming conventions;
3. Git repository and repository structure;
4. database and schema initialization.

## Step 1 — Plan complex work before implementing it

The course first creates a rough project plan and only makes it more detailed after the architecture is understood.

This is an important engineering pattern:

```text
Low information → rough plan
More information → refine plan
Implementation → update plan with evidence
```

A plan should not pretend to know decisions that have not yet been analyzed.

### Our implementation pattern

The build phases follow:

```text
Analyze → Code → Validate → Document → Commit
```

This is more important than the project-management tool used to track it.

### Learning

A data engineer should distinguish **activity** from **completion**. "I wrote the SQL" is not the same as "the task is done." A task is complete only after it is validated, documented where necessary, and captured in version control.

## Step 2 — Naming conventions reduce system entropy

Naming rules appear trivial until a project contains many schemas, tables, procedures, tests, diagrams, and developers.

The project defines consistent rules such as:

- English technical names;
- lower snake case;
- source-system prefixes in Bronze/Silver;
- business-friendly names in Gold;
- `_key` for warehouse surrogate keys;
- `dwh_` for warehouse-generated metadata;
- `load_<layer>` for layer-load procedures.

### Why this matters

Consistent naming reduces the amount of context an engineer must remember.

From a name such as:

```text
bronze.crm_cust_info
```

we can infer:

- the warehouse layer;
- the source system;
- the source entity.

From:

```text
gold.dim_customers
```

we can infer that it is a consumer-facing dimension rather than a source-aligned object.

### Engineering principle

Good naming is not cosmetic. It encodes architecture and reduces ambiguity.

## Step 3 — Git is part of the engineering workflow

Git is not only where the finished project is uploaded.

Version control provides:

- history of design changes;
- recoverability;
- traceable evidence of implementation progress;
- a reviewable boundary around accepted milestones.

The repository is therefore updated while the system is built.

### Learning

A useful commit should describe a coherent engineering change, for example:

```text
feat: implement and validate bronze ingestion
```

rather than a vague message such as:

```text
update files
```

The commit history becomes part of the technical documentation.

## Step 4 — Repository structure communicates responsibilities

The repository separates:

```text
scripts/
tests/
docs/
learnings/
```

and further separates warehouse layers.

This helps answer quickly:

- Where is executable implementation code?
- Where are validation queries?
- Where are architecture decisions and diagrams?
- Where are conceptual lessons captured?

### Learning

A repository should make the system easier to understand before someone reads individual files.

## Step 5 — Database and schemas establish technical boundaries

The initialization script creates:

```text
DataWarehouse
├── bronze
├── silver
└── gold
```

The schemas implement the logical architecture inside SQL Server.

### Important operational lesson

The database-initialization script is destructive: if it drops and recreates `DataWarehouse`, existing data is lost.

Therefore destructive scripts need prominent warnings and clear comments.

This is not documentation polish. It is operational risk control.

### What a good data engineer asks before executing destructive DDL

- Which environment am I connected to?
- Does this script drop or truncate existing data?
- Is the operation intended for development only?
- Is any state or evidence lost?
- Do I need a backup or confirmation first?

## Step 6 — Comments should explain intent and risk

Useful comments answer questions that are not obvious from syntax:

- What is this script for?
- What does running it destroy or replace?
- Which phase owns it?
- How is it expected to be executed?

Comments that merely restate `CREATE TABLE` as "create table" add little value.

## What this phase taught about good data engineering

A good data engineer:

1. turns a large system into explicit milestones;
2. refines the plan as knowledge increases;
3. defines naming and folder standards before inconsistency spreads;
4. treats Git as part of engineering, not final publishing;
5. recognizes destructive SQL as an operational risk;
6. structures the repository so another engineer can navigate it;
7. uses comments to communicate purpose, assumptions, and danger.

## Failure modes to avoid

### Coding without a Definition of Done

The project accumulates half-finished artifacts that "work on my machine" but are not validated or documented.

### Inconsistent naming

Source objects, business objects, and metadata become difficult to distinguish.

### One final Git commit

The repository loses the evolution of the system and provides weak evidence of the engineering process.

### Unmarked destructive scripts

A developer can accidentally destroy a database while assuming the file is a harmless setup script.

## Concrete evidence in this repository

- `docs/project_plan.md`
- `docs/naming_conventions.md`
- `scripts/init_database.sql`
- repository commit history
- root and project `README.md`

## Active-recall questions

1. Why should the project plan become more detailed only after architecture decisions are understood?
2. How does a naming convention encode architectural meaning?
3. Why is Git history an engineering artifact rather than merely source backup?
4. What should you check before running a database recreation script?
5. What information should a useful SQL script header communicate?
