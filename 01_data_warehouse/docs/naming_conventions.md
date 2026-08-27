# Naming Conventions

Baseline conventions for the SQL warehouse project.

## General

- Use English names.
- Use `lower_snake_case` for SQL objects and columns.
- Prefer descriptive names over unexplained abbreviations.
- Keep naming consistent across scripts, documentation, and diagrams.

## Schemas

- `bronze`
- `silver`
- `gold`

## Source-aligned tables

Bronze and Silver objects should retain a clear relationship to the source system and source entity.

Example pattern:

```text
crm_customer_info
erp_customer_info
```

Exact table names will be finalized when the source systems are analyzed.

## Gold objects

Use dimensional-model prefixes where applicable:

```text
dim_<entity>
fact_<process>
```

Reporting views may use a `report_` prefix where appropriate.
