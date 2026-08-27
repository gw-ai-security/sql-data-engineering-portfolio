# Phase 1 — Requirements Analysis: Engineering Learnings

## Why this phase exists

A data warehouse should not be designed from technology preferences alone. The architecture must be derived from the problem, the sources, the expected consumers, and the scope.

The project requirements already constrain major technical decisions:

- Microsoft SQL Server is the target platform.
- Sales data comes from two source systems: CRM and ERP.
- The sources are provided as CSV files.
- Data-quality issues must be resolved before analytical use.
- CRM and ERP must eventually be integrated into one analytical model.
- The baseline only needs the latest state; historization is not required.
- The final data product must be documented for analytical and business users.

## Step 1 — Understand before designing

### Learning

There is no single universally correct warehouse architecture. Building first and asking questions later creates unnecessary work and often leads to solving the wrong problem.

### Engineering principle

```text
Requirements → Architecture
not
Technology → Architecture → justification afterwards
```

### What a good data engineer asks

- What business outcome should the warehouse support?
- Who will consume the data?
- Which source systems are authoritative for which information?
- What form does the source data arrive in?
- How clean or unreliable is it expected to be?
- Is history required or is the current state sufficient?
- What documentation must be delivered with the data product?

## Step 2 — Translate business requirements into engineering constraints

A requirement such as "latest dataset only" is not just documentation text. It changes implementation scope.

For this project it means that the baseline does not need to solve:

- CDC;
- incremental extraction;
- SCD Type 2 historization;
- retention of every previous version of a source record.

This prevents unnecessary complexity.

Likewise, "clean data before analysis" creates an architectural requirement: raw ingestion and analytical consumption cannot be treated as the same responsibility.

## Step 3 — Separate requirements from implementation choices

### Requirement

"Combine CRM and ERP into a user-friendly model for analytics."

### Later implementation choice

Use Bronze, Silver, and Gold layers and build a dimensional Gold model.

The distinction matters. Requirements state **what must be achieved**. Architecture and code decide **how it will be achieved**.

A good engineer does not present an implementation preference as though it were a business requirement.

## Step 4 — Treat documentation as part of the product

The project explicitly requires documentation for business and analytics users. Documentation is therefore not cleanup work after coding.

It is part of the deliverable.

This changes the engineering mindset from:

```text
Code = product
```

to:

```text
Code + model + lineage + definitions + limitations = data product
```

## What this phase taught about good data engineering

A good data engineer:

1. does not start coding before understanding scope;
2. extracts technical consequences from business statements;
3. avoids overengineering requirements that do not exist;
4. records assumptions and explicit exclusions;
5. keeps consumers and business use in mind before defining storage structures;
6. treats documentation as an engineering responsibility.

## Failure modes to avoid

### Building unnecessary history

If the requirement says current state only, adding complex SCD2 logic increases cost without adding required value.

### Assuming raw data is analysis-ready

The requirement already warns that source quality must be resolved. Treating raw files as trustworthy analytical data would violate the project contract.

### Designing only for ingestion

Moving CSV files into SQL Server is not the final objective. The end state must support analytical reporting and decision-making.

## Concrete evidence in this repository

- `docs/project_requirements.md`
- `docs/architecture_decisions.md`
- `README.md`

## Active-recall questions

1. Why is "no historization required" an architecture constraint rather than a missing feature?
2. Which project requirement forces us to separate raw ingestion from analytical consumption?
3. What is the difference between a requirement and an architecture decision?
4. Why is documentation part of the data product rather than optional project polish?
5. What would we risk if we started implementing before clarifying the source systems and consumers?
