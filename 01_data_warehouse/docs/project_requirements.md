# Project Requirements

## Objective

Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

## Specifications

### Data sources

Import data from two source systems:

- CRM
- ERP

The source data is provided as CSV files stored in folders.

### Data quality

Cleanse and resolve data-quality issues before the data is used for analysis.

### Integration

Combine both source systems into a single, user-friendly analytical data model.

### Scope

Use the latest dataset only. Historical versioning of source records is not required for the baseline project.

### Documentation

Document the data model clearly enough to support both business stakeholders and analytics users.

## Derived architecture constraints

- SQL Server is the target warehouse platform.
- Source ingestion is file-based and batch-oriented.
- Raw source fidelity must be preserved before transformation.
- Analytical consumers should use the business-ready Gold layer rather than raw source data.
