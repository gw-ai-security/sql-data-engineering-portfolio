# Advanced Data Analytics - Documentation Index

This folder documents the completed Advanced Data Analytics project. SQL files remain the executable evidence; these documents explain **why the queries are structured as they are, what the report views mean, which results are reproducible, and where interpretation must stop**.

## Documentation Map

| Artifact | Purpose |
|---|---|
| [`analysis_overview.md`](analysis_overview.md) | analytical architecture, grains, sequence and SQL patterns |
| [`query_catalog.md`](query_catalog.md) | business/analytical questions mapped to scripts and concepts |
| [`report_catalog.md`](report_catalog.md) | column and KPI contract for `gold.report_customers` and `gold.report_products` |
| [`findings.md`](findings.md) | reproducible snapshot findings and caveats |

## Related Evidence

- Project overview: [`../README.md`](../README.md)
- Executable SQL: [`../scripts/`](../scripts/)
- Report validation: [`../tests/01_validate_advanced_analytics.sql`](../tests/01_validate_advanced_analytics.sql)
- Learning journal: [`../learnings/README.md`](../learnings/README.md)
- Upstream Gold model: [`../../01_data_warehouse/docs/data_model/gold_star_schema.webp`](../../01_data_warehouse/docs/data_model/gold_star_schema.webp)
- Upstream Gold data catalog: [`../../01_data_warehouse/docs/data_catalog/gold_data_catalog.md`](../../01_data_warehouse/docs/data_catalog/gold_data_catalog.md)

## Documentation Rule

Documentation must describe the committed SQL, not an intended future state. Changes to metric definitions, view columns, segmentation thresholds, grains or filenames require the corresponding README/catalog/learning note to be updated in the same milestone.
