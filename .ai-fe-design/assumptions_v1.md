# Thorium XDR Frontend — Assumptions (v1, for v1→v2)

> Companion to [`fe_design_v1.md`](./fe_design_v1.md) and
> [`questions_v1_to_v2_qa.md`](./questions_v1_to_v2_qa.md).
>
> This file records **every assumption** the v1 design rests on, so the next
> human/agent can confirm or overturn each one when producing **v2**. Each
> assumption has a **confidence** and a **how to confirm** pointer. Where a fact
> was *verified in the repo*, it is marked ✅ **Confirmed** (not an assumption) —
> these are the bedrock v2 can build on without re-checking.
>
> Confidence: 🟢 high · 🟡 medium · 🔴 low / guess.

---

## 0. Method (what was analyzed, 5–10 min pass)

Read: `ui/src/App.svelte` (~3,560 lines) + `ui/src/VMManager.svelte`,
`ui/package.json`, `ui/body_output.txt`; the Mowa agent `thorium_agent.mowa` and
signing service `silicon.mowa`; the **Sui Move contracts** under
`move/thorium_edr/sources/` + `Move.toml`/`Published.toml`; the VM tooling under
`vm/`; and the reference images in `input/`. The Move contracts are the single
most clarifying artifact — they pin the real on-chain data model below.

---

## 1. ✅ Confirmed facts (verified in repo — not assumptions)

These are **ground truth** for v2; do not re-derive.

### 1.1 On-chain package (Sui **testnet**)
- Package `thorium_edr`, **published-at / original-id:**
  `0x0cc3f972285b0486b2590b5edc9321813ec32a253a26cffa687da5a1131491af`
- chain-id `4c78adac` (testnet), version `1`,
  upgrade-cap `0xaf4b4305341e54efd5f66173843722974d8c9b0529b39f3591f3717989a5c9e1`.
- Modules: `edr_registry`, `talus_xdr_detector`, `polonium_policy`.

### 1.2 `edr_registry` — agents, incidents, telemetry, C2
- **`AgentIdentity`** (SBT, `key,store`): `owner_address`, `owner_name`,
  `hostname`, `ipv6_address`, `machine_type`, `hardware_hash` (BLAKE3),
  `public_key` (Ed25519), `is_active`.
- **`CommandQueue`** (shared): `admin`.
- Entry funcs: `register_agent`, `report_incident`, `report_telemetry`,
  `send_command`, `command_isolate_host`.
- **Events the FE can index:**
  - `AgentRegistered{ agent_id, owner_address, owner_name, hostname, ipv6_address, machine_type, hardware_hash, timestamp_ms }`
  - `IncidentReport{ agent_id, severity, process_cmd, action_taken }` — severity ∈ `CRITICAL|HIGH|WARNING`; action e.g. `KILLED_AND_ISOLATED`.
  - `TelemetryReported{ agent_id, cpu_load, ram_usage_pct, disk_usage_pct, timestamp_ms }`
  - `CommandIssued{ queue_id, target_agent, … }`

### 1.3 `talus_xdr_detector` — AI detection
- **`DetectionPolicy`** (shared): `admin`, `anomaly_threshold` (u8, default **85**),
  `authorized_ai_agents: Table<address,bool>`.
- Funcs: `authorize_ai_agent`, `update_threshold`, `submit_classification`
  (verified with `ed25519::ed25519_verify`).
- Event `ClassificationReported{ agent_id, telemetry_hash, anomaly_score, classification, action_taken, timestamp_ms }`.
- Rule: `anomaly_score >= anomaly_threshold` ⇒ `action_taken = "TRIGGER_ISOLATION"`.

### 1.4 `polonium_policy` — policy console
- **`PoloniumConfig`** (shared): `admin`, `walrus_blob_id` (pointer to encrypted
  payload on **Walrus**), `policy_hash` (SHA-256 integrity), `expires_at_ms`.
- The **actual policy config lives encrypted on Walrus**; only the pointer +
  integrity hash + expiry are on-chain. Func `update_policy` (admin-only) emits
  `PolicyUpdated`.

### 1.5 Agent HTTP contract (Mowa)
- `thorium_agent.mowa`: `GET /api/status`, `POST /api/rpc` (JSON-RPC: `get_logs`,
  `vm_create`), `GET /api/logi`, `POST /api/izoluj`, `POST /api/przywroc`,
  `GET /api/vm/lista`, `POST /api/vm/start|stop|usun`. JSON keys are Polish
  (`kod`, `typ`, `tresc`, `klucz_pub`…).
- `silicon.mowa`: `GET /status`, `POST /api/sign` (Ed25519 signing service).

### 1.6 Frontend baseline
- `ui/` = **Svelte 5 + TS + Vite**; deps limited to `@mysten/sui.js@0.54` +
  `@mysten/wallet-standard@0.20`. Current UI = one ~3,560-line `App.svelte` with
  inline styles and a PL/EN string mix; data is **hard-coded dummy**, not yet
  wired to the live contract/chain.
- A second `my-app/` SvelteKit skeleton exists (unused scaffolding).

---

## 2. Architecture assumptions (the important inference)

> **A1 🟢 — The FE is fundamentally a Sui on-chain reader, with the Mowa agent
> API as a complementary local/realtime source.**
> Evidence: every domain object (agents, incidents, telemetry, AI classifications,
> policies) has a Move struct/event, and the C2 reads chain events. So the
> dashboard's source of truth = **Sui events + shared objects** at package
> `0x0cc3…91af`; the agent HTTP API adds live logs, isolate/restore, and VM ops
> for a *directly reachable* agent. v1 §6 under-weighted the chain path — v2
> should make Sui the primary read path. → confirm in **Q9**.

- **A2 🟡** FE reads chain via a Sui JSON-RPC / GraphQL endpoint + event queries
  (`queryEvents` by package/module), no custom indexer in v1. Large histories may
  later need an indexer. → **Q8/Q9**.
- **A3 🟡** Write actions split: on-chain writes (register, report, policy update,
  `command_isolate_host`) go through **wallet-signed PTBs**; agent-local actions
  (`/api/izoluj`, VM lifecycle) go through the agent HTTP API. `silicon.mowa`
  `/api/sign` is for agent/AI-key signing, **not** the browser wallet. → **Q9/Q11**.
- **A4 🟢** Walrus blobs (Polonium config, sealed forensics/vulns) are referenced
  by `walrus_blob_id`; v1 shows them as pointers/locked, decrypt-on-demand. The
  browser does **not** hold Seal decrypt keys in v1. → **Q10**.

---

## 3. Product / scope assumptions

- **A5 🟢** Target user = SOC analyst/admin; primary job = triage incidents +
  manage fleet + tune policies. Look = Defender/Sentinel IA, Stripe/Datadog
  polish, SUI/Walrus dark aesthetic (from `input/conversation.txt`).
- **A6 🟡** Network = Sui **testnet** for now (per `Published.toml`); mainnet is a
  later switch. The chain badge should reflect the active network. → **Q15/Q16**.
- **A7 🟡** v1 implementation milestone = the core SOC loop (Overview, Endpoints,
  Incidents, VMs); Talus/Vulnerabilities/Polonium second; Helium last. → **Q6**.
- **A8 🔴** **Helium** tab purpose is unknown from code — assumed experimental/
  hidden until scoped. → **Q5**.
- **A9 🟡** Multi-sig "critical actions" and YARA/CSPM are *roadmap-planned*, not
  shipped; v1 shows them as placeholders/read-only. → **Q12**.
- **A10 🟡** Telemetry fields are coarse (`cpu_load`, `ram_usage_pct`,
  `disk_usage_pct` as u8 percentages) — enough for sparklines/gauges, not rich
  time-series; no historical store assumed beyond event scan. → **Q2/Q8**.

## 4. Technical assumptions

- **A11 🟢** Stay on Svelte 5 + Vite (not SvelteKit); delete/ignore `my-app/`. → **Q1**.
- **A12 🟢** No CSS framework, no chart lib in v1; plain CSS tokens + hand-rolled
  SVG. One tiny viz dep only if a screen demands it. → **Q2/Q3**.
- **A13 🟢** Static build, **hash routing**, `base:'./'`, runtime `config.json`
  fetched at boot so one IPFS CID can target different agent hosts / package IDs /
  networks. → **Q15**.
- **A14 🟡** Realtime = interval polling (agent `/api/*` ~5s; chain `queryEvents`
  ~10s) in v1; WebSocket is the v2 target once the agent exposes a socket
  (roadmap mentions it but the contract today is request/response only). → **Q8**.
- **A15 🟢** All raw-response mapping (Polish keys → typed view-models, chain
  events → view-models) is isolated in `ui/src/lib/api.ts` + `sui.ts`. App code
  never sees raw shapes.
- **A16 🟢** English-first UI, PL kept as a locale; Move/agent strings stay as-is
  and are mapped at the adapter boundary. → **Q13**.
- **A17 🟡** Auth = Sui wallet-connect gates write actions; no RBAC/SSO in v1
  (Move enforces `admin` on-chain regardless). → **Q11**.

## 5. Things explicitly NOT assumed (need an answer before building)

- Exact Sui RPC/GraphQL endpoint(s) and whether an indexer is provided.
- The official brand palette / logo / accent (placeholder cyan `#38bdf8` used).
- The licensed IPFS provider + whether ENS/DNSLink is wanted.
- Whether incident/agent data for v1 dev should be **live chain** or **mock**.
- Helium's domain. Multi-sig timeline.

---

## 6. How these feed v2
1. The next agent answers [`questions_v1_to_v2_qa.md`](./questions_v1_to_v2_qa.md)
   inline. Each answer should either **confirm** or **override** the matching
   `Axx` assumption above (the question's "Recommendation" mirrors the assumption).
2. `fe_design_v2.md` then promotes confirmed assumptions into the spec body
   (esp. **A1**: make Sui the primary read path, with the package ID + event
   schemas from §1 as the canonical data contract).
3. `questions_v2_to_v3_qa.md` captures whatever §5 ("not assumed") remains open.
