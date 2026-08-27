# Data Warehouse Learning Journal

This folder records the **engineering lessons** learned while implementing the SQL Data Warehouse project.

The purpose is not to document tools or reproduce course notes. It captures the reasoning that matters in real data-engineering work:

- what problem a phase is solving;
- what decisions must be made before writing code;
- what can go wrong even when SQL executes successfully;
- what must be observable and testable;
- what a good data engineer should ask, verify, document, and communicate.

The notes follow the actual project phases and are updated as the warehouse is built.

## Learning Path

1. [Requirements Analysis](01_requirements_analysis.md)
2. [Data Architecture](02_data_architecture.md)
3. [Project Initialization](03_project_initialization.md)
4. [Bronze Layer](04_bronze_layer.md)

Future files will be added when the corresponding phases are implemented:

- `05_silver_layer.md`
- `06_gold_layer.md`

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

## Evidence in This Repository

The learning notes refer to concrete project artifacts rather than hypothetical examples:

- requirements and architecture decisions in `docs/`;
- database and layer DDL in `scripts/`;
- ingestion procedures in `scripts/bronze/`;
- validation queries in `tests/`;
- diagrams and lineage documentation in `docs/`.

The repository therefore contains both **what was built** and **what was learned from building it**.
