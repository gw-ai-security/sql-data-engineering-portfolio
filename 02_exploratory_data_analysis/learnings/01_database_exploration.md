# 01 - Database Exploration Learnings

Script: [`../scripts/01_database_exploration.sql`](../scripts/01_database_exploration.sql)

## What this step solves

Before analyzing values, I need to understand the database I have been given. Database exploration is the equivalent of inspecting a new codebase before changing it: identify the objects, schemas, naming and available columns first.

The script queries SQL Server metadata through:

- `INFORMATION_SCHEMA.TABLES`;
- `INFORMATION_SCHEMA.COLUMNS`.

## Main lesson

**Metadata is data about the database.**

Querying `INFORMATION_SCHEMA` is often faster and more systematic than clicking through SSMS when I need an overview of an unfamiliar database.

The progression is:

```text
What objects exist?
        ↓
Which schemas are they in?
        ↓
Which columns exist?
        ↓
What are their types and metadata?
        ↓
Only then inspect business values
```

## Why this matters for Data Engineering

A Data Engineer frequently joins an existing environment rather than starting from an empty database. Early metadata exploration helps answer:

- Is this a small analytical model or a large operational schema?
- Are objects tables or views?
- What naming conventions are used?
- Which columns can be join keys?
- Which objects look like facts, dimensions, staging or source-aligned tables?

## Failure mode to remember

The current column query filters only on:

```sql
WHERE TABLE_NAME = 'dim_customers'
```

That is sufficient in the current project because the relevant object name is unambiguous. In a larger database, the same table name can exist in multiple schemas. A safer discovery query can also constrain `TABLE_SCHEMA`.

## Interview-level explanation

If asked how I start with an unfamiliar database:

> I first inspect metadata and schema structure, then identify likely facts, dimensions, keys and grains, and only after that profile values and measures. This reduces the risk of writing analytically correct-looking queries against the wrong objects.
