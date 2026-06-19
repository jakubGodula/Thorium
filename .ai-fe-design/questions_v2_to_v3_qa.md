# Questions: v2 → v3 (+ assumptions)

> Next round of open decisions, for going from [`fe_design_v2.md`](./fe_design_v2.md)
> to **v3** (the first *implemented* demo). Same flow as before:
>
> - **Assumption (v2):** what v2 already proceeds under (so work isn't blocked).
> - **Question:** what still needs your confirmation/override.
> - **Answer:** — fill inline. When done, save the answered copy as
>   `questions_v2_to_v3_qa_AUDIT.md` (mirroring the v1→v2 convention) and generate
>   `fe_design_v3.md`.
>
> Context: confirmed on-chain model in [`assumptions_v1.md`](./assumptions_v1.md);
> v1→v2 decisions in [`questions_v1_to_v2_qa_AUDIT.md`](./questions_v1_to_v2_qa_AUDIT.md);
> rationale for the big calls in [`adr/`](./adr/).
>
> Legend: 🔴 blocks implementation · 🟡 shapes scope · 🟢 polish.

---

## A. Scope & milestones

### R1 🔴 First implemented milestone (was Q6)
**Assumption (v2):** Milestone 1 = **Overview · Endpoints · Incidents · VMs**, plus
an **Alerts** view and an overall **Datadog-style interface** (monitors, faceted
filters, time-range picker, saved views). Milestone 2 = Talus · Vulnerabilities ·
Polonium · the new Chain Activity / Fleet Telemetry tabs. Helium last.
**Question:** Confirm this split and the "Datadog-style" interface as the v3 target.
Any tab to promote/demote?
**Answer:** _<!-- fill in -->_

### R2 🟡 Helium tab — what is it? (was Q5)
**Assumption (v2):** Hidden/experimental; cross-links to Polonium; no defined
domain found in code.
**Question:** What is Helium's purpose (a Sui-gas/coin view? a key-management
console? something else)? Until answered it stays hidden behind a feature flag.
**Answer:** _<!-- fill in -->_

---

## B. Telemetry & observability model (was Q10c) 🟡

**Assumption (v2):** Per-endpoint gauges + sparkline/time-series from
`TelemetryReported` (`cpu_load`, `ram_usage_pct`, `disk_usage_pct`, u8 %); a fleet
heatmap; no long-range historical store beyond an event scan (no indexer in v2).

### Capability comparison — **Datadog vs ELK (Kibana) vs Walrus** (requested)

| Capability | **Datadog** | **ELK / Kibana** | **Walrus (this stack)** |
|---|---|---|---|
| Primary role | SaaS metrics/APM/logs | Self-hosted search + log analytics | Decentralized **blob storage** (not an analytics engine) |
| Time-series store | Native TSDB, long retention, rollups | Metricbeat → ES indices, ILM rollover | **None** — only `TelemetryReported` events on Sui + sealed blobs on Walrus |
| Query model | Tag-faceted metrics + monitors | Lucene/KQL + aggregations | Sui `queryEvents` (paged) + fetch blob by ID |
| Live dashboards | Host map, heatmaps, SLOs, anomaly | Lens/TSVB viz, dashboards | Build client-side from events; **no server aggregation** |
| Alerting | Monitors, composite, forecast | Watcher/Kibana alerting | On-chain rule: Talus `anomaly_score ≥ threshold` ⇒ isolate |
| Retention/scale | Managed, expensive | Self-managed, ops-heavy | Cheap durable blobs; **analytics must be done in the client/indexer** |

**Recommended assumption (for v3):** Aim for a **Datadog-grade *presentation***
(host map, gauges, faceted alerts, time-range picker) but accept an **ELK-style
"query the raw events" backing** — because **Walrus is storage, not an analytics
engine**, so v3 reads Sui events directly (client-side aggregation) and treats any
real indexer/TSDB as a later add-on. In short: **Datadog UX, event-sourced data,
Walrus for durable evidence blobs only.**

### R3 🔴 Confirm the observability target
**Question:** Accept "Datadog-grade UX + event-sourced (no TSDB) backing for v3"?
If long-range history matters now, we must add an indexer (and which one?).
**Answer:** _<!-- fill in -->_

### R4 🟡 Do we need a client-side aggregation/indexer layer in v3?
**Assumption (v2):** No — scan recent events on demand, aggregate in the browser.
**Question:** Acceptable for the demo, or stand up a light indexer (e.g. a Postgres
+ Sui event poller in the mock backend)?
**Answer:** _<!-- fill in -->_

---

## C. Data sources & realtime

### R5 🔴 Mock-vs-live default for the v3 demo (was Q7)
**Assumption (v2):** v3 demo runs against the **dockerized mock backend**
(ADR-0004); a `config.json` flag switches to a live agent + Sui testnet.
**Question:** Confirm mock-by-default for the demo. Provide a live testnet RPC URL
+ a reachable agent host if you also want a live profile.
**Answer:** _<!-- fill in -->_

### R6 🔴 Sui read endpoint (was Q9b)
**Assumption (v2):** Fullnode JSON-RPC `queryEvents` + `multiGetObjects` against a
public testnet RPC; no indexer/GraphQL.
**Question:** Which RPC URL (default `https://fullnode.testnet.sui.io`)? Any
GraphQL endpoint? Rate limits to design around?
**Answer:** _<!-- fill in -->_

### R7 🟡 Realtime upgrade (was Q8 / ADR-0001)
**Assumption (v2):** Polling now; WS/SSE later.
**Question:** Will the Mowa agent expose a WebSocket/SSE endpoint we can target in
v3, or stay request/response?
**Answer:** _<!-- fill in -->_

### R8 🟡 Walrus / Seal access (was Q10)
**Assumption (v2):** Sealed rows shown locked; decrypt on demand via agent/wallet;
no browser Seal SDK in v2/v3.
**Question:** Should the browser fetch+decrypt Walrus blobs directly (needs
`@mysten/walrus` + Seal capability), or proxy through the agent?
**Answer:** _<!-- fill in -->_

---

## D. Identity, policy & actions

### R9 🔴 Auth / RBAC (was Q11)
**Assumption (v2):** Wallet-connect gates write actions; Move enforces `admin`
on-chain; no app-level RBAC/SSO.
**Question:** Do v3 demos need roles (analyst/admin/auditor) in the UI, or is
wallet-only fine?
**Answer:** _<!-- fill in -->_

### R10 🟡 Talus admin controls (was Q10b)
**Assumption (v2):** Read-only `anomaly_threshold` + recent classifications in v3.
**Question:** Expose admin `update_threshold` / `authorize_ai_agent` (wallet-signed)
in v3, or keep read-only?
**Answer:** _<!-- fill in -->_

### R11 🟡 Multi-sig (was Q12)
**Assumption (v2):** **Placeholder only** (read-only indicator); no signing flow —
contract not shipped.
**Question:** Confirm placeholder for v3. (When the 2-of-3 / WebAuthn contract
lands, we design the flow.)
**Answer:** _<!-- fill in -->_

---

## E. Deployment & ops

### R12 🔴 IPFS runtime config (was Q15)
**Assumption (v2):** Boot-time `config.json` (one immutable CID → many backends).
**Question:** Confirm. What keys? (proposed: `agentApiBase`, `suiRpcUrl`,
`packageId`, `network`, `walrusGateway`, `mock:boolean`).
**Answer:** _<!-- fill in -->_

### R13 🟡 IPFS provider / naming (was Q16)
**Assumption (v2):** A licensed pinning provider (unnamed) + DNSLink/ENS for a
stable name; CID shown in footer.
**Question:** Which provider/license? Is there an ENS name or DNSLink domain?
**Answer:** _<!-- fill in -->_

### R14 🟢 Error/telemetry reporting (was Q17)
**Assumption (v2):** None (privacy + decentralization).
**Question:** Keep none, or add self-hosted error capture later?
**Answer:** _<!-- fill in -->_

---

## F. Build & demo (feeds the separate `.ignored/fe-demo` prompt)

### R15 🟡 Mock backend tech (ADR-0004)
**Assumption (v2):** Tiny Node (Express/Fastify) or `json-server` + a fixture
generator, in Docker Compose; serves the Mowa contract + a Sui event mock (+
optional Walrus mock).
**Question:** Any preference (language/framework), or pick the lightest?
**Answer:** _<!-- fill in -->_

### R16 🟢 Charting engine confirm (ADR-0003)
**Assumption (v2):** **ECharts** (rich) + **uPlot** (dense time-series), lazy-loaded.
**Question:** OK, or prefer LayerChart/Observable Plot/Recharts-equivalent?
**Answer:** _<!-- fill in -->_

### R17 🟢 Brand assets (was Q14)
**Assumption (v2):** Suggested shield+Th-atom mark in [`brand/`](./brand/); cyan
`#38bdf8` primary + mint `#5eead4` secondary.
**Question:** Approve the suggested mark/colors, or supply official brand assets?
**Answer:** _<!-- fill in -->_

---

## G. ⭐ Critical Demo Case (CC*) — see [`input/DEMO.md`](./input/DEMO.md)

### R18 🔴 How should the CC* alert be presented? (v2 decided one; pick the v3 winner)
**Assumption (v2):** persistent top **Critical Incident banner** → **Incident
Command drawer** (kill-chain timeline + on-chain evidence) + pulsing "NOT WORTHY"
badge on the pod. (ADR-0007.)
**Question:** Keep that, or choose another of these 3–5 Stripe-grade patterns?
1. **Top banner → Incident Command drawer** (v2 default).
2. **Full-screen "War Room" takeover** when CRITICAL (focuses the whole app).
3. **Toast/notification stack** (top-right) with an "Open incident" action.
4. **Command-palette / spotlight** alert (⌘K-style) surfacing the incident.
5. **Live map/topology beacon** — the pod pulses red on a fleet map, click to expand.
**Answer:** _<!-- fill in -->_

### R19 🔴 Confirm the CC* path itself (v2 assumed it; v3 to confirm)
**Assumption (v2):** CC* exactly as in `input/DEMO.md` (connect → healthy w/ Sui
interaction + OK telemetry → kernel/DDoS attack → marked NOT WORTHY → NOT-OK
telemetry/logs visible → prominent alert → placeholder response actions).
**Question:** Confirm this is THE demo path. Any change to the steps, the
"not worthy" semantics, or the response-action placeholders (notify on-call, Slack,
freeze/isolate/kill, connect to Claude Code/dev)?
**Answer:** _<!-- fill in -->_

---

### After answering
1. Save answers; copy this answered file to `questions_v2_to_v3_qa_AUDIT.md`.
2. Generate `fe_design_v3.md` = v2 + these decisions.
3. Open `questions_v3_to_v4_qa.md` if anything remains open.
4. (Separately) build `.ignored/fe-demo` per the v3 spec.
5. `git add .ai-fe-design/ && git commit && git push origin HEAD:experimental-aw-fe-v2`.
