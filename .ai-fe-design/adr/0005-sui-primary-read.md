# ADR-0005: Sui chain is the primary read path

**Status:** Accepted (v2, provisional — confirm at v2→v3 R6)
**Date:** 2026-06-19

## Context
Analyzing the Move contracts (`move/thorium_edr/`) showed every domain object has
an on-chain home in package `0x0cc3f972285b0486b2590b5edc9321813ec32a253a26cffa687da5a1131491af`
(testnet): `edr_registry` (AgentIdentity SBTs; `AgentRegistered`/`IncidentReport`/
`TelemetryReported` events), `talus_xdr_detector` (`DetectionPolicy`,
`ClassificationReported`), `polonium_policy` (`PoloniumConfig`). The agent HTTP API
is a *local* live channel, not the system of record. v1 under-weighted the chain.

## Decision
Treat **Sui as the primary read path**:
- Reads: fullnode JSON-RPC `queryEvents` (by package/module, paged, newest-first)
  + `multiGetObjects` for shared objects + `AgentIdentity` SBTs.
- Writes: on-chain actions (register, report, `update_policy`,
  `command_isolate_host`) via **wallet-signed PTBs**; agent-local actions
  (`/api/izoluj`, VM lifecycle) via the agent HTTP API.
- The agent HTTP API supplies live logs and directly-reachable-agent operations.

## Consequences
- + Trust/provenance is first-class (tx digests, object IDs, blob IDs surfaced).
- + Single canonical data model = the Move event/struct schemas.
- − Client-side aggregation needed (no TSDB; see v2→v3 R3/R4); deep history may
  later need an indexer.
- − RPC rate limits / pagination must be designed for (R6).
- Walrus is **storage only**, not analytics (see comparison in v2→v3 §B).
