# Advanced Data Analytics - Learning Journal

This journal records the analytical reasoning behind the completed project rather than reproducing course notes.

## Learning Path

1. [Change Over Time](01_change_over_time_analysis.md)
2. [Cumulative Analysis](02_cumulative_analysis.md)
3. [Performance Analysis](03_performance_analysis.md)
4. [Part-to-Whole Analysis](04_part_to_whole_analysis.md)
5. [Data Segmentation](05_data_segmentation.md)
6. [Customer Report](06_customer_report.md)
7. [Product Report](07_product_report.md)

## Core Analytical Pattern

```text
Choose the question
        ↓
Define the grain
        ↓
Choose dimension + measure
        ↓
Aggregate once at the correct level
        ↓
Apply comparison/window/segment logic
        ↓
Validate the output contract
```

The recurring lesson is that advanced SQL is not mainly about longer queries. The difficult part is preserving the intended grain while changing analytical context through time, windows, comparisons, segmentation and reusable report views.

The learning notes reference the actual scripts in [`../scripts/`](../scripts/) and the report contracts in [`../docs/report_catalog.md`](../docs/report_catalog.md).
