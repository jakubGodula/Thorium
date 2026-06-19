# Architecture Decision Records (ADR)

Lightweight records of the significant, hard-to-reverse decisions behind the
Thorium XDR frontend. One file per decision. Format: Context · Decision · Status ·
Consequences. Supersede rather than rewrite.

| ADR | Decision | Status |
|---|---|---|
| [0001](./0001-realtime-polling.md) | Realtime via interval polling now, WebSocket later | Accepted (v2) |
| [0002](./0002-styling-tailwind.md) | Tailwind CSS for styling (override v1 plain-CSS) | Accepted (v2) |
| [0003](./0003-charting.md) | ECharts + uPlot for charts/time-series | Accepted (v2) |
| [0004](./0004-mock-backend.md) | Dockerized mock backend emulating agent + Sui + Walrus | Accepted (v2) |
| [0005](./0005-sui-primary-read.md) | Sui chain is the primary read path; agent API complements | Accepted (v2) |

> These encode v2 decisions from
> [`questions_v1_to_v2_qa_AUDIT.md`](../questions_v1_to_v2_qa_AUDIT.md). Items the
> user deferred ("ask in v2→v3") are **provisional** here and re-confirmed in
> [`questions_v2_to_v3_qa.md`](../questions_v2_to_v3_qa.md).
