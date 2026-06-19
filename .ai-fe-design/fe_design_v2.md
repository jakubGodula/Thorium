# Thorium XDR — Frontend Design Spec **v2**

> Status: **v2** · Supersedes [`fe_design_v1.md`](./fe_design_v1.md) (v1 stays as
> history; do not edit it). · Branch: `experimental-aw-fe-v2`.
>
> **What v2 is:** v1 + the user's decisions recorded in
> [`questions_v1_to_v2_qa_AUDIT.md`](./questions_v1_to_v2_qa_AUDIT.md). Confirmed
> facts come from [`assumptions_v1.md`](./assumptions_v1.md) (the on-chain data
> model). Decisions deferred by the user ("ask in v2→v3, output assumptions") are
> **adopted here as working assumptions** and re-surfaced in
> [`questions_v2_to_v3_qa.md`](./questions_v2_to_v3_qa.md). Significant decisions
> are captured as ADRs under [`adr/`](./adr/).

---

## 0. What changed from v1 → v2 (the decisions)

| # | Topic | v1 | **v2 decision** (from AUDIT) |
|---|---|---|---|
| Q1 | Framework | Svelte 5 + Vite | ✅ **Confirmed** Svelte 5 + Vite |
| Q2 | Charts | hand-rolled SVG, ≤1 tiny dep | ✅ **Charting libraries allowed** — may be heavy; must hit Stripe / Bolt.com / ELK / Walrus professional bar |
| Q3 | CSS | plain CSS tokens | ✅ **Tailwind CSS** (override) → [ADR-0002](./adr/0002-styling-tailwind.md) |
| Q4 | Nav/IA | tabs now, left-rail later | ✅ **Keep existing tabs + ADD on-chain telemetry tabs**; drive from **mock data** derived from Sui/Walrus/repo; ship a **separate dockerized mock backend** → [ADR-0004](./adr/0004-mock-backend.md) |
| Q13 | Language | English-first, PL locale | ✅ **English ONLY — strictly no Polish** anywhere in UI |
| Q14 | Brand | placeholder cyan | ✅ **Thorium branding**; add assets + suggested icon → [`brand/`](./brand/) |
| Q2/charts viz | charting engine | — | **ECharts** (rich, ELK/Datadog-grade) + **uPlot** (dense time-series) → [ADR-0003](./adr/0003-charting.md) |
| Q5,Q6,Q7,Q8,Q9,Q9b,Q10,Q10b,Q10c,Q11,Q12,Q15,Q16,Q17,Q18 | various | recommendations | **Adopted as working assumptions** (user: "reasonable"); confirm in v2→v3. Multi-sig = **placeholder only** (Q12). |

> Where v2 is silent, **v1 still applies** (screen specs §5, data contract §6,
> migration plan §10, a11y §9). v2 only states deltas.

---

## 1. Target quality bar (Q2/Q4)

The app must read as a **professional SOC product**, not a demo:

- **Stripe / Bolt.com** → restraint, spacing rhythm, crisp typography, calm empty
  states, instant perceived performance, motion that informs (never decorative).
- **ELK (Kibana) / Datadog** → information density done right: dense tables,
  faceted filters, time-range picker, saved views, rich time-series + topology.
- **SUI / Walrus** → dark, modern web3 aesthetic; on-chain provenance surfaced as
  a first-class trust signal (tx hashes, object IDs, blob IDs are clickable).

"Heavy is OK in early iterations" — prioritize fidelity and the right interaction
model first; optimize bundle/IPFS size in a later pass (tracked in v2→v3).

---

## 2. Tech stack (v2)

```
Svelte 5 + TypeScript + Vite        (confirmed, Q1)
Tailwind CSS v4  + tailwind tokens   (Q3 → ADR-0002)
shadcn-svelte / bits-ui (headless)   primitives for a11y components
ECharts (echarts) + uPlot            charts/time-series (Q2 → ADR-0003)
@mysten/sui.js + @mysten/wallet-standard   chain reads + wallet (existing)
@mysten/walrus (optional, v3)        Walrus blob reads
TanStack-style query layer (light)   polling/cache (or hand-rolled stores)
```

Dependency philosophy flips from v1: **lightweight is now a later optimization
goal, not a v2 constraint.** Still: no SSR (IPFS), tree-shake, lazy-load chart
engine per route.

### 2.1 Tailwind token mapping
Port v1 §3.1 color tokens into `tailwind.config`/`@theme` (Tailwind v4 CSS-first):
`bg-0..3`, `border`, `text-0..2`, `accent`/`accent-2`, severity scale
(`critical/high/warning/medium/low/info`), status (`ok/isolated/pending/offline`),
radii, shadow. Components use Tailwind utilities; tokens remain the single source
of truth so re-theming = edit the theme block. Keep `prefers-reduced-motion`.

---

## 3. Information architecture (v2)

**Keep all existing tabs** (no left-rail migration yet — Q4): `Overview`,
`Endpoints`, `Incidents`, `VMs`, `Talus AI`, `Vulnerabilities`, `Polonium`,
`Helium`. **Add new On-Chain / telemetry tabs:**

1. **Chain Activity** (`chain`) — live on-chain event explorer for package
   `0x0cc3…91af`: a unified, filterable stream of `AgentRegistered`,
   `IncidentReport`, `TelemetryReported`, `ClassificationReported` (Talus),
   `PolicyUpdated` (Polonium). Each row links to the Sui explorer (tx digest /
   object ID). Facets: module, event type, agent, severity, time range.
2. **Fleet Telemetry** (`telemetry`) — fleet health from `TelemetryReported`:
   per-endpoint `cpu_load` / `ram_usage_pct` / `disk_usage_pct` gauges +
   time-series (ECharts), heatmap of fleet load, top-N noisy endpoints. (Datadog
   "host map" inspiration; see comparison in v2→v3 §Telemetry.)
3. **Alerts** (`alerts`) — *assumption (Q6)*: a Datadog-style alerts/monitors view
   layered over `IncidentReport` + Talus `ClassificationReported` (severity,
   status: open/ack/resolved, assignee, on-chain evidence). Triage-centric.

> All three are **mock-data-driven** initially (ADR-0004), with the exact event
> shapes from `assumptions_v1.md` §1 so the wire format is real even when the data
> is synthetic.

---

## 4. Data & backend strategy (Q4, Q7, Q8, Q9, Q9b)

**Working assumption (confirm in v2→v3):** the app reads from **two sources behind
one typed adapter** (`ui/src/lib/data/`):

- **Sui chain (primary read):** `queryEvents` by package/module +
  `multiGetObjects` for shared objects (`DetectionPolicy`, `PoloniumConfig`) and
  `AgentIdentity` SBTs. → [ADR-0005](./adr/0005-sui-primary-read.md).
- **Agent HTTP (live/local):** the Mowa `/api/*` contract for live logs, isolate/
  restore, VM lifecycle.

**Mock backend (NEW, Q4) → [ADR-0004](./adr/0004-mock-backend.md):** a separate,
dockerized project that emulates *both* sources so the FE runs fully offline for
demos and CI:

- `mock-backend/` (its own Docker Compose service) exposing:
  - The **Mowa REST/JSON-RPC contract** (`/api/status`, `/api/rpc`, `/api/logi`,
    `/api/izoluj`, `/api/przywroc`, `/api/vm/*`) with fixtures matching real wire
    keys.
  - A **Sui event mock** (`/sui/queryEvents`, `/sui/getObject`) returning
    synthetic `AgentRegistered` / `IncidentReport` / `TelemetryReported` /
    `ClassificationReported` / `PolicyUpdated` payloads, generated from the Move
    schemas in `assumptions_v1.md` §1.
  - Optional **Walrus mock** (`/walrus/:blobId`) returning sealed/placeholder blobs.
- Tech suggestion: tiny Node (Express/Fastify) or `json-server` + a generator
  script, or Prism from an OpenAPI doc. Containerized so `docker compose up` gives
  a working backend; the FE points `config.json` at it.
- The actual build of this mock + the running demo lands in the **separate
  `.ignored/fe-demo` prompt** (point 5 of the user's plan). v2 only specifies it.

**Realtime (Q8) → [ADR-0001](./adr/0001-realtime-polling.md):** interval polling in
v2 (agent ~5s, chain `queryEvents` ~10s); WebSocket/SSE is the upgrade path once
the agent exposes a socket. Recorded as an ADR per the user's request.

---

## 5. Localization (Q13) — **English only**

- **Strictly no Polish in any UI string.** Replace every remaining PL label in
  `App.svelte` (e.g. "Wnioski detekcji Talus AI" → "Talus AI Detections",
  "Zarządzanie Politykami Polonium" → "Polonium Policy Management", "Czas" →
  "Time", "Raz w tygodniu" → "Weekly").
- The Mowa wire contract keeps Polish keys (`kod`, `typ`, `tresc`, `izoluj`…) —
  these are **mapped to typed English view-models in the adapter** and never
  surface to the UI. No i18n framework needed for v2 (single locale = en).

---

## 6. Branding (Q14) → [`brand/`](./brand/)

- Added a suggested **Thorium mark**: a shield (XDR/defense) fused with the
  atomic/element motif of *Thorium* (symbol **Th**, atomic number 90) — see
  [`brand/thorium-mark.svg`](./brand/thorium-mark.svg) and
  [`brand/favicon.svg`](./brand/favicon.svg).
- Palette: keep the existing **Thorium cyan** `--accent:#38bdf8` as primary;
  pair with a Walrus-adjacent mint `#5eead4` as secondary accent for on-chain/
  provenance UI. Subtle glow, `prefers-reduced-motion`-aware (unchanged from v1).
- These are **suggestions** — swap when official brand tokens arrive (v2→v3 Q14).
- Wire the mark into `ui/public/` (favicon) + the top-bar logo.

---

## 7. Component & screen deltas

- Adopt **shadcn-svelte/bits-ui** headless primitives for the v1 §3.3 base
  components (Card, DataTable, Drawer, Tabs, Toast…), styled with Tailwind tokens.
- Charts: a `Chart.svelte` wrapper lazy-loading ECharts; a `TimeSeries.svelte`
  using uPlot for dense telemetry. Used by Fleet Telemetry, Chain Activity, Alerts,
  and the Overview KPI sparklines (upgraded from hand-rolled SVG).
- All v1 screens (§5) stand; their PL strings are Englished (§5 here), and the
  three new on-chain tabs (§3) are added to the nav.

---

## 8. Deferred-but-adopted assumptions (carry to v2→v3)

Each was answered "ask in v2→v3, output assumptions; recommendation is reasonable."
v2 proceeds under the v1 recommendation; details + the explicit assumption live in
[`questions_v2_to_v3_qa.md`](./questions_v2_to_v3_qa.md):

- **Q5 Helium** — kept hidden/experimental; scope TBD.
- **Q6 Milestone scope** — Overview·Endpoints·Incidents·VMs first, **+ Alerts +
  Datadog-style interface** as the assumed shape.
- **Q7 Mock vs live** — typed mock layer + `config.json` switch (now realized via
  the dockerized mock backend).
- **Q8 Realtime** — polling now, WS later (ADR-0001).
- **Q9/Q9b Sui read path** — chain-primary via fullnode `queryEvents` (ADR-0005).
- **Q10 Walrus/Seal** — sealed rows locked, decrypt on demand.
- **Q10b Talus admin** — read-only threshold/keys in v2; admin writes later.
- **Q10c Telemetry depth** — gauges + sparkline now; includes a **Datadog vs ELK
  vs Walrus** capability comparison (in v2→v3) to set the target.
- **Q11 Auth** — wallet-connect gates writes; no RBAC yet.
- **Q12 Multi-sig** — **placeholder only**.
- **Q15/Q16 IPFS** — boot-time `config.json`; provider/ENS TBD.
- **Q17 Error reporting** — none in v2.
- **Q18 Ownership** — AI-agent-driven, committed on `experimental-aw-fe-v2`.

---

## 9. Next steps
1. Answer [`questions_v2_to_v3_qa.md`](./questions_v2_to_v3_qa.md) inline (same
   flow as before; see [`README.md`](./README.md)).
2. **Separate prompt (point 5):** build `.ignored/fe-demo` = the v3 implementation
   (Svelte+Tailwind+ECharts app) **+** the dockerized mock backend (§4), driven by
   this v2 spec.
3. Then iterate v3 design from the answers.
