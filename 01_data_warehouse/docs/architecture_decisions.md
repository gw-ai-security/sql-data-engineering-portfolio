# Architecture Decisions

This document records design decisions as they are made during implementation.

## ADR-001 — Medallion-style warehouse layers

**Status:** Accepted

**Decision:** Use Bronze, Silver, and Gold layers.

**Rationale:** The project requires raw-source traceability, explicit data-quality processing before analytics, and a business-ready analytical model. Separating these responsibilities reduces coupling and makes validation easier.

## ADR-002 — Full batch loads for the baseline

**Status:** Accepted

**Decision:** Use batch-oriented full loads for Bronze and Silver in the baseline implementation.

**Rationale:** The project scope targets the latest dataset and does not require record historization. Incremental loading and CDC are therefore outside the baseline scope.

## ADR-003 — Gold as the consumer contract

**Status:** Accepted

**Decision:** BI, ad-hoc SQL, and downstream analytical consumers should read from Gold rather than directly from Bronze/Silver.

**Rationale:** Gold is responsible for integration, business logic, and consumer-friendly modeling.

## Future decisions

Additional decisions will be added only when the implementation reaches the relevant milestone.
