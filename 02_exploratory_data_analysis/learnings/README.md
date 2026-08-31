# Exploratory Data Analysis - Learning Journal

This folder records the reasoning learned while implementing the six EDA scripts. It does not reproduce the course transcript. Each note connects the analytical concept to the actual SQL in this repository and highlights the mistakes that can produce plausible but wrong results.

## Learning Path

1. [Database Exploration](01_database_exploration.md)
2. [Dimension Exploration](02_dimension_exploration.md)
3. [Date Range Exploration](03_date_range_exploration.md)
4. [Measure Exploration](04_measure_exploration.md)
5. [Magnitude Analysis](05_magnitude_analysis.md)
6. [Ranking Analysis](06_ranking_analysis.md)

## Core Analytical Mindset

```text
Understand the structure
        ↓
Understand the dimension domains
        ↓
Understand the time boundary
        ↓
Establish the core measures
        ↓
Split measures by dimensions
        ↓
Rank dimensions by measures
```

The recurring lesson is that SQL syntax is only part of the task. Correct analysis depends on understanding:

- what one row represents;
- whether a field is acting as a dimension or measure;
- whether `COUNT` is counting rows or business entities;
- whether a join changes the population;
- whether `NULL` groups should remain visible;
- whether date functions match the intended meaning;
- how ties should behave in rankings.

## Evidence

Every note references an implemented SQL script in [`../scripts/`](../scripts/). Dataset-level findings are documented separately in [`../docs/findings.md`](../docs/findings.md).

The repository therefore shows both **the queries that were implemented** and **the reasoning required to use them correctly**.
