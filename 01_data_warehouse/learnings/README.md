# Data Warehouse Learning Journal

This folder records the **engineering lessons** from the completed SQL Data Warehouse project.

The purpose is not to document tools or reproduce course notes. It captures the reasoning that matters in data-engineering work:

- what problem each phase solves;
- what decisions must be made before writing code;
- what can go wrong even when SQL executes successfully;
- what must be observable and testable;
- what a good data engineer should ask, verify, document, and communicate.

The notes follow the six completed project phases and reference the actual repository artifacts.

## Learning Path

1. [Requirements Analysis](01_requirements_analysis.md)
2. [Data Architecture](02_data_architecture.md)
3. [Project Initialization](03_project_initialization.md)
4. [Bronze Layer](04_bronze_layer.md)
5. [Silver Layer](05_silver_layer.md)
6. [Gold Layer](06_gold_layer.md)

## Core Engineering Mindset

Across all phases, the same pattern applies:

```text
Understand the problem
        ↓
Make explicit decisions
        ↓
Implement the smallest correct design
        ↓
Validate the result
        ↓
Make the system understandable to others
        ↓
Version the accepted state
```

A working query is not enough. A data engineer is responsible for whether the right data arrives, whether it is complete, whether downstream users can trust it, whether failures can be diagnosed, and whether another engineer can understand the system later.

## What the Completed Path Covers

- **Requirements:** architecture should follow the actual business and scope constraints.
- **Architecture:** layer responsibilities must be explicit to avoid duplicated logic.
- **Initialization:** standards, repository structure and safe database setup are engineering work, not administration overhead.
- **Bronze:** ingestion must preserve source fidelity, be repeatable, observable and reconcilable.
- **Silver:** technical validity is not enough; data must also be plausible, standardized and join-ready.
- **Gold:** source tables become business objects with explicit grain, source precedence, dimensional relationships and a consumer contract.

## Evidence in This Repository

The learning notes refer to concrete artifacts rather than hypothetical examples:

- requirements and architecture decisions in [`../docs/`](../docs/);
- database and layer SQL in [`../scripts/`](../scripts/);
- Bronze/Silver transformation procedures in `scripts/bronze/` and `scripts/silver/`;
- Gold analytical views in `scripts/gold/`;
- validation queries in [`../tests/`](../tests/);
- architecture, lineage, integration, model and catalog documentation in [`../docs/README.md`](../docs/README.md).

The repository therefore contains both **what was built** and **what was learned from building it**.
