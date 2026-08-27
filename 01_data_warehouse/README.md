# 01 — SQL Data Warehouse

Build a modern SQL Server data warehouse that consolidates sales data from CRM and ERP CSV sources and exposes business-ready analytical data.

## Planned lifecycle

1. Requirements analysis
2. Data architecture design
3. Project initialization
4. Bronze layer
5. Silver layer
6. Gold layer
7. Validation and documentation

## Layer responsibilities

- **Bronze:** preserve source data as-is in SQL tables.
- **Silver:** cleanse, standardize, normalize, derive, and enrich data while remaining source-aligned.
- **Gold:** integrate business entities, apply business logic, and expose analytical models/views.

See [`docs/project_requirements.md`](docs/project_requirements.md) and [`docs/data_architecture.drawio`](docs/data_architecture.drawio).
