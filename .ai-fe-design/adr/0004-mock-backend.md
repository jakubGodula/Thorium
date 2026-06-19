# ADR-0004: Dockerized mock backend (agent + Sui + Walrus)

**Status:** Accepted (v2, provisional — confirm at v2→v3 R5/R15)
**Date:** 2026-06-19

## Context
The user (Q4) wants the new on-chain/telemetry tabs driven by **mock data**
"figured out from Walrus / Sui contracts / repo / docs," and is open to "another
project (in a docker cluster, mocking REST responses) just to visualize a working
app + mock backend for the initial version." The real agent/chain may be
unavailable during FE dev, and a static IPFS demo needs deterministic data.

## Decision
Ship a **separate, dockerized `mock-backend/`** that emulates all read/write
sources behind the FE's data adapter:
- **Mowa agent contract** — `/api/status`, `/api/rpc` (`get_logs`, `vm_create`),
  `/api/logi`, `/api/izoluj`, `/api/przywroc`, `/api/vm/*` with fixtures using the
  real (Polish-keyed) wire format.
- **Sui event mock** — `/sui/queryEvents`, `/sui/getObject` returning synthetic
  `AgentRegistered` / `IncidentReport` / `TelemetryReported` /
  `ClassificationReported` / `PolicyUpdated`, generated from the Move schemas in
  `assumptions_v1.md` §1 (package `0x0cc3…91af`).
- **Walrus mock** (optional) — `/walrus/:blobId` returning sealed/placeholder blobs.
- `docker compose up` → working backend; FE `config.json` points at it; a flag
  switches to live testnet + a real agent.

The build of this backend + the running demo is the **separate `.ignored/fe-demo`
prompt** (user's point 5). This ADR fixes the contract it must implement.

## Consequences
- + FE runs fully offline; deterministic demos and CI.
- + One code path (adapter) for mock and live — switch via config.
- − A second project to maintain; fixtures must track contract changes.
- − Wire fixtures keep Polish keys (mapped to English in the adapter, ADR/§5).
