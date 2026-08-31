# Exploratory Data Analysis - Documentation Index

This folder documents the **implemented state** of the EDA project. It is intentionally separated from the SQL scripts: the scripts are executable evidence, while these documents explain scope, analytical reasoning, reproducible findings and interpretation limits.

## Documentation Map

| Artifact | Purpose |
|---|---|
| [`analysis_overview.md`](analysis_overview.md) | Gold analytical source, grains, dimension/measure model, six-step EDA method and scope boundary |
| [`query_catalog.md`](query_catalog.md) | maps each business/data question to the SQL script and concepts used |
| [`findings.md`](findings.md) | key metrics, distributions, rankings and caveats for the supplied dataset snapshot |

## Related Evidence

- Project overview and execution order: [`../README.md`](../README.md)
- Executable SQL: [`../scripts/`](../scripts/)
- Learning journal: [`../learnings/README.md`](../learnings/README.md)
- Upstream Gold model: [`../../01_data_warehouse/docs/data_model/`](../../01_data_warehouse/docs/data_model/)
- Gold data catalog: [`../../01_data_warehouse/docs/data_catalog/gold_data_catalog.md`](../../01_data_warehouse/docs/data_catalog/gold_data_catalog.md)

## Documentation Rule

Documentation must match the SQL that is actually committed. If a query, metric definition, analytical grain, dataset boundary or scope changes, the README, query catalog, findings and corresponding learning note should be updated in the same milestone.

This project does not add unsupported claims such as production readiness, business impact or operational scale. Results refer only to the supplied learning dataset.
