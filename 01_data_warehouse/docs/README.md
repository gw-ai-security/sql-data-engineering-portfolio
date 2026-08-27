# Data Warehouse Documentation Index

This directory contains the version-controlled documentation for the completed SQL Data Warehouse project. The documents are separated by purpose so that architecture, lineage, integration logic, analytical modeling, and data definitions do not get mixed together.

## 1. Requirements and Decisions

| Artifact | Purpose |
|---|---|
| [`project_requirements.md`](project_requirements.md) | Functional/non-functional requirements, baseline scope and definition of done |
| [`architecture_decisions.md`](architecture_decisions.md) | Accepted architecture and implementation decisions with consequences |
| [`naming_conventions.md`](naming_conventions.md) | Naming rules for schemas, SQL objects, columns, procedures, scripts and documentation |
| [`project_plan.md`](project_plan.md) | Six-epic project plan and completion evidence |
| [`source_systems.md`](source_systems.md) | CRM/ERP source inventory, mappings, row counts and known source-file behavior |

## 2. High-Level Architecture

- [`data_architecture.drawio`](data_architecture.drawio) — editable architecture source
- [`data_architecture.webp`](data_architecture.webp) — GitHub-renderable preview

The architecture defines the layer contract:

```text
Sources → Bronze → Silver → Gold → Analytical consumers
```

## 3. Data Flow and Lineage

Directory: [`data_flow/`](data_flow/)

| Artifact | Scope |
|---|---|
| [`bronze_data_flow.webp`](data_flow/bronze_data_flow.webp) | Source → Bronze lineage |
| [`bronze_silver_data_flow.webp`](data_flow/bronze_silver_data_flow.webp) | Source → Bronze → Silver lineage |
| [`bronze_silver_gold_data_flow.drawio`](data_flow/bronze_silver_gold_data_flow.drawio) | Editable end-to-end Source → Bronze → Silver → Gold lineage |
| [`bronze_silver_gold_data_flow.webp`](data_flow/bronze_silver_gold_data_flow.webp) | Rendered end-to-end lineage |

The final lineage makes the change in responsibility explicit: Bronze/Silver remain source-oriented, while Gold groups trusted Silver data into CUSTOMER, PRODUCT and SALES business objects.

## 4. Integration Documentation

Directory: [`data_integration/`](data_integration/)

- [`data_integration/README.md`](data_integration/README.md) — integration keys, source relationships and Gold business-object discovery
- [`data_integration/data_integration_model.webp`](data_integration/data_integration_model.webp) — Silver integration-preparation model
- [`data_integration/business_object_integration_model.webp`](data_integration/business_object_integration_model.webp) — Silver entities grouped into CUSTOMER, PRODUCT and SALES

These artifacts explain **how technical source entities relate** before and during Gold integration. They are distinct from the final dimensional model.

## 5. Gold Data Model

Directory: [`data_model/`](data_model/)

- [`data_model/gold_star_schema.drawio`](data_model/gold_star_schema.drawio) — editable logical Star Schema
- [`data_model/gold_star_schema.webp`](data_model/gold_star_schema.webp) — rendered Star Schema

The Gold model consists of:

```text
dim_customers ─┐
                ├── fact_sales
 dim_products ──┘
```

PK/FK labels in the diagram represent logical analytical relationships between views rather than physical database constraints.

## 6. Gold Data Catalog

- [`data_catalog/gold_data_catalog.md`](data_catalog/gold_data_catalog.md)

The catalog defines each Gold object's purpose and grain and documents every exposed column with SQL Server type, role, business description, and source lineage.

## 7. Related Implementation Evidence

- SQL: [`../scripts/`](../scripts/)
- Tests: [`../tests/`](../tests/)
- Engineering learning journal: [`../learnings/README.md`](../learnings/README.md)
- Project overview and execution order: [`../README.md`](../README.md)

## Documentation Rule

Documentation must describe the implemented state. If SQL, layer responsibilities, integration rules, grain, row-count expectations, or filenames change, the corresponding diagrams, catalog, plan, and README references must be updated in the same milestone.
