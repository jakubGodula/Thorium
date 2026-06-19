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

## H. Exhaustive round (depth for v3)

### R20 🟡 Onboarding — how does a user "connect a new observed pod" in the UI?
**Assumption:** a guided "Connect pod" flow (wallet-signed `register_agent`) +
a copy-paste agent install snippet; in the demo it's the CC* step 1.
**Answer:** _<!-- fill in -->_

### R21 🟡 Empty / loading / error states for every screen?
**Assumption:** skeleton loaders, empty states with a primary action, and a
chain/agent-unreachable banner. Define per screen in v3.
**Answer:** _<!-- fill in -->_

### R22 🟡 Incident lifecycle & status model (open/ack/resolved/false-positive)?
**Assumption:** Alerts view carries a status + assignee overlay on top of on-chain
`IncidentReport` (status stored where? client-only for demo).
**Answer:** _<!-- fill in -->_

### R23 🟡 Time handling — timezones, "X ago" vs absolute, time-range picker scope?
**Assumption:** relative + absolute on hover; UTC default; Datadog-style range picker.
**Answer:** _<!-- fill in -->_

### R24 🟢 Density & theming — compact mode, light theme, per-user prefs?
**Assumption:** dark only in v2/v3; compact toggle later.
**Answer:** _<!-- fill in -->_

### R25 🟢 Keyboard / command palette (⌘K) scope?
**Assumption:** ⌘K to navigate + jump to an incident/pod; nice-to-have for v3.
**Answer:** _<!-- fill in -->_

### R26 🟡 Mobile / responsive expectations for a SOC console?
**Assumption:** desktop-first 1280px+, graceful to 1024; no mobile target in v3.
**Answer:** _<!-- fill in -->_

### R27 🟡 Real response actions — which (if any) become real in v3 vs placeholder?
**Assumption:** all CC* response actions stay placeholders in v3 (notify on-call,
Slack, freeze/isolate/kill, Claude Code) until backends exist.
**Answer:** _<!-- fill in -->_

### R28 🟢 Performance budget / bundle size target (when does "heavy is OK" end)?
**Assumption:** no hard budget for v2/v3 demo; optimization pass post-demo.
**Answer:** _<!-- fill in -->_

---

## ⭐ Final Chapter (OPTIONAL) — CC* presentation playbook

> Optional deep-dive requested for v2→v3: **all the ways to present the CC\* alert**,
> how each can be done differently, and where to look for the "best" answer. v2 chose
> **#1** (R18); this catalogs the full design space so v3 can choose deliberately.

### The five candidate presentations (and variants)
1. **Top banner → Incident Command drawer** *(v2 default)*
   - Variants: sticky vs floating banner · drawer right vs bottom-sheet · collapse to
     a beacon vs persistent · auto-open drawer on CRITICAL vs click-to-open.
   - Best for: keeping context while triaging; least disruptive.
2. **Full-screen "War Room" takeover** on CRITICAL
   - Variants: modal vs dedicated route · auto-dismiss vs require-ack · single-pod vs
     fleet view · with/without live kill-chain replay.
   - Best for: maximum drama in a live demo; risk: hijacks the app.
3. **Toast / notification stack** (top-right)
   - Variants: stacked vs single · auto-expire vs sticky-until-ack · inline expand vs
     "open incident" · sound/no-sound.
   - Best for: many concurrent alerts; risk: easy to miss the big one.
4. **Command-palette / spotlight (⌘K)** surfacing the incident
   - Variants: auto-invoked on CRITICAL · suggested actions inline · keyboard-first.
   - Best for: power users; risk: invisible to a cold audience.
5. **Live map / topology beacon** — pod pulses red on a fleet map
   - Variants: geo map vs cluster/namespace topology vs 3D (R&D "Spatial SOC") ·
     click-to-expand vs hover.
   - Best for: spatial "where" story; pairs well with #1.

### Cross-cutting levers (apply to any choice)
Motion (entrance, pulse cadence, climax flash) · sound (subtle vs none) · the
**before→after** device ("Healthy 40s ago" → "Auto-isolated in 2s") · severity color
+ icon (never color alone) · on-chain proof inline (tx digest, event JSON) · the
"speed of automation" payoff (Δt detection→isolation) · reduced-motion fallback.

### How to decide the best (references / methods)
- **Comparators to study:** Stripe Radar / Dashboard alerts, Linear's notifications,
  Datadog incident + monitor status pages, PagerDuty/Opsgenie incident timelines,
  Vercel/Sentry issue alerts, Grafana/Kibana alerting.
- **UX methods:** 5-second test (does the story land?), first-click test, A/B the
  banner-vs-takeover on a small panel, severity-perception study, WCAG-AA contrast
  audit, motion-sickness/reduced-motion check.
- **Sources/agencies for deeper UX:** NN/g (Nielsen Norman Group) on alerts &
  notifications, Refactoring UI (visual hierarchy), Material/Apple HIG on critical
  alerts, IBM Carbon + Atlassian patterns for status/notifications. *(Add the exact
  links your team prefers here.)*

### R18-followup 🔴 v3 pick
Given the catalog above, confirm the v3 CC* presentation (keep #1, or combine — e.g.
**#1 banner+drawer paired with #5 map beacon**). Record motion/sound choices.
**Answer:** _<!-- fill in -->_

---

### After answering
1. Save answers; copy this answered file to `questions_v2_to_v3_qa_AUDIT.md`.
2. Generate `fe_design_v3.md` = v2 + these decisions.
3. Open `questions_v3_to_v4_qa.md` if anything remains open.
4. (Separately) build `.ignored/fe-demo` per the v3 spec.
5. `git add .ai-fe-design/ && git commit && git push origin HEAD:experimental-aw-fe-v2`.
