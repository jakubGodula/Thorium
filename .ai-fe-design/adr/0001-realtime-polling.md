# ADR-0001: Realtime via interval polling (WebSocket later)

**Status:** Accepted (v2, provisional — confirm at v2→v3 R7)
**Date:** 2026-06-19

## Context
The roadmap (`input/…21.47.04.jpeg`) lists "SOC Dashboard (Svelte): live state
sync via WebSockets" as *in progress*. But the shipped surfaces are
request/response only: the Mowa agent (`thorium_agent.mowa`) exposes plain HTTP
(`/api/status`, `/api/logi`, …) and Sui reads are RPC `queryEvents`. No socket
endpoint exists today.

## Decision
v2/v3 use **interval polling** behind the data adapter:
- Agent HTTP: poll ~5s (status, logs), configurable.
- Sui events: `queryEvents` newest-first ~10s, dedup by event id/cursor.
Optimistic UI for isolate/restore with toast + revert on error.

## Consequences
- + Works on a static IPFS build with no socket infra.
- + Simple, resilient, easy to mock (ADR-0004).
- − Not truly push; latency ≈ poll interval; more requests.
- → **Upgrade path:** swap the adapter's transport to WebSocket/SSE when the agent
  exposes one (no UI changes). Tracked as v2→v3 **R7**.
