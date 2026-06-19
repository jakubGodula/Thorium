# Questions: v1 → v2

> **How to use this file.** These are the open decisions that block a more precise
> **v2** of the Thorium XDR frontend design. Each question includes:
> - **Analysis** — what was found in the repo / reference material.
> - **Recommendation** — a reasoned default (already decided so v1 could ship).
> - **Answer:** — *you (or your AI agent) fill this in inline.* Accept the
>   recommendation, override it, or refine it.
>
> When every `**Answer:**` is filled, run the v2 prompt from
> [`README.md`](./README.md) §B3 to produce `fe_design_v2.md` +
> `questions_v2_to_v3_qa.md`.
>
> See [`assumptions_v1.md`](./assumptions_v1.md) for the reasoned defaults behind
> each recommendation and the **confirmed on-chain data model** (Sui testnet
> package `0x0cc3…91af`: `edr_registry`, `talus_xdr_detector`, `polonium_policy`).
>
> Legend: 🔴 blocks implementation · 🟡 shapes scope · 🟢 polish/nice-to-have.

---

## A. Framework & dependencies

### Q1 🔴 Svelte vs React — confirm Svelte 5?
**Analysis:** The repo already ships a Svelte 5 + TS + Vite app (`ui/`) with a
~3,560-line `App.svelte` and `@mysten/sui.js` + `@mysten/wallet-standard`. The
prompt says "prefer svelte or react, no hard dependencies, lightweight." There is
also a second `my-app/` SvelteKit skeleton.
**Recommendation:** Stay on **Svelte 5 + Vite** (not SvelteKit) — least churn,
lightest, SSR-free → cleanest IPFS static build. Delete/ignore `my-app/`.
**Answer:** _<!-- fill in -->_

### Q2 🟡 Is a chart/visualization library allowed, or hand-rolled SVG only?
**Analysis:** v1 assumes no chart lib (SVG sparklines) to stay light. Datadog-grade
dashboards usually want time-series charts.
**Recommendation:** Allow **one** tiny dependency-free option (e.g. `layerchart`
or hand-rolled SVG) only if a screen truly needs time-series; otherwise none.
**Answer:** _<!-- fill in -->_

### Q3 🟢 CSS approach — plain CSS tokens vs Tailwind vs UnoCSS?
**Analysis:** Current code is inline-styled. v1 proposes plain CSS custom
properties (`theme.css`) — zero build deps.
**Recommendation:** **Plain CSS tokens** for v1 (IPFS-light, no toolchain).
**Answer:** _<!-- fill in -->_

---

## B. Navigation, IA & scope

### Q4 🟡 Keep horizontal tabs, or move to a Defender-style left rail?
**Analysis:** Current UI uses top tabs (`activeTab`). Defender/Sentinel (the
reference) use a grouped **left navigation rail**. There are already 8 tabs and
the roadmap adds more (YARA, CSPM…), which top tabs won't scale to.
**Recommendation:** v1 keeps top tabs; **v2 = adopt a left rail** with sections
(Overview · Detections [Incidents, Talus, Vulns] · Assets [Endpoints, VMs] ·
Policies [Polonium] · Settings).
**Answer:** _<!-- fill in -->_

### Q5 🟡 What exactly is the **Helium** tab?
**Analysis:** `helium` exists as an `activeTab` but its purpose isn't documented;
it cross-links to Polonium. Could not infer its domain from the code.
**Recommendation:** Treat as **experimental/hidden** in v1 until scoped. Define it
here.
**Answer:** _<!-- fill in -->_

### Q6 🟡 Which screens are in-scope for the first *implemented* milestone?
**Analysis:** All 8 tabs exist in markup but at varying fidelity (Polonium is the
most built-out).
**Recommendation:** Milestone 1 = **Overview, Endpoints, Incidents, VMs** (core
SOC loop). Milestone 2 = Talus, Vulnerabilities, Polonium. Helium last.
**Answer:** _<!-- fill in -->_

---

## C. Data, contract & realtime

### Q7 🔴 Is the data real (live agent) or mocked for v1?
**Analysis:** `App.svelte` uses hard-coded dummy `agents`/`incidents`. The
`thorium_agent.mowa` contract (`/api/*`) is real but may not be running during FE
dev.
**Recommendation:** Build against a **typed mock layer in `api.ts`** that matches
§6.2 shapes, with a `VITE_THORIUM_API` switch to hit the live agent. Same code path.
**Answer:** _<!-- fill in -->_

### Q8 🔴 Realtime transport: polling vs WebSocket/SSE?
**Analysis:** Roadmap says "SOC Dashboard (Svelte): live state sync via
WebSockets, incident-tree in progress." But the current Mowa API exposes only
request/response HTTP (`/api/status`, `/api/logi`).
**Recommendation:** v1 = **interval polling** (5s, configurable). Note WS as the
v2 target once the agent exposes a socket. Confirm whether a WS endpoint exists.
**Answer:** _<!-- fill in -->_

### Q9 🔴 How much goes through Sui directly vs the agent HTTP API?
**Analysis (now grounded in the Move contracts):** The package is **published on
Sui testnet** at `0x0cc3f972285b0486b2590b5edc9321813ec32a253a26cffa687da5a1131491af`
(chain-id `4c78adac`). Every domain object has an on-chain home:
`edr_registry` (AgentIdentity SBTs + `AgentRegistered`/`IncidentReport`/
`TelemetryReported` events), `talus_xdr_detector` (`DetectionPolicy` +
`ClassificationReported`), `polonium_policy` (`PoloniumConfig`). So the chain is
the real source of truth; the agent HTTP API adds live logs + isolate/restore +
VM ops for a directly reachable agent. The current `App.svelte` uses dummy data
and isn't wired to either yet.
**Recommendation:** v2 makes **Sui the primary read path** (query events by
package/module + read shared objects); the agent API is the live/local
complement. On-chain **writes** (register, report, `update_policy`,
`command_isolate_host`) = wallet-signed PTBs; agent-local writes (`/api/izoluj`,
VM lifecycle) = agent HTTP. Confirm this split. (See `assumptions_v1.md` §A1–A3.)
**Answer:** _<!-- fill in -->_

### Q9b 🔴 Which Sui read endpoint — JSON-RPC `queryEvents`, GraphQL, or an indexer?
**Analysis:** No indexer is present in the repo. `@mysten/sui.js@0.54` can
`queryEvents`/`getObject` against a fullnode, but deep incident history may need
an indexer/GraphQL.
**Recommendation:** v1/v2 use fullnode JSON-RPC `queryEvents` (paged, newest-first)
+ `multiGetObjects` for shared objects; flag an indexer as a scaling follow-up.
Provide the preferred testnet RPC URL (and any GraphQL endpoint).
**Answer:** _<!-- fill in -->_

### Q10 🟡 Walrus/Seal ("Foka") — does FE fetch & decrypt directly?
**Analysis:** Vulnerabilities + forensic logs are "Seal-encrypted via Walrus."
Unclear if the browser holds decrypt capability or the agent proxies it.
**Recommendation:** v1 shows sealed rows as **locked**, decrypt via agent/wallet
on demand; direct browser Seal SDK is a v2 question.
**Answer:** _<!-- fill in -->_

### Q10b 🟡 Talus — does the FE let an admin edit the on-chain `anomaly_threshold`?
**Analysis:** `talus_xdr_detector` exposes admin-only `update_threshold` and
`authorize_ai_agent`; default threshold = 85; `submit_classification` is called by
the off-chain AI (Ed25519-verified). The Talus screen could surface a read-only
view, or an admin control to retune the threshold / manage authorized AI keys.
**Recommendation:** v1 = read-only (threshold + recent `ClassificationReported`);
v2 = admin can `update_threshold` / `authorize_ai_agent` via wallet. Confirm.
**Answer:** _<!-- fill in -->_

### Q10c 🟢 Telemetry visualization depth (cpu/ram/disk)?
**Analysis:** `TelemetryReported` carries only `cpu_load`, `ram_usage_pct`,
`disk_usage_pct` (u8 %) + `timestamp_ms`. Enough for gauges + short sparklines
from a recent event scan, not rich long-range time-series (no historical store).
**Recommendation:** v1 = per-endpoint gauges + sparkline from last N events; defer
long-range charts (and any indexer) to v2. Confirm acceptable.
**Answer:** _<!-- fill in -->_

---

## D. Identity, auth & multi-sig

### Q11 🔴 Auth model — wallet-connect only, or also RBAC/SSO?
**Analysis:** Only Sui wallet connect exists. Defender/Sentinel imply org roles
(analyst/admin). Actions are gated on "wallet connected."
**Recommendation:** v1 = **wallet-connect gates actions**; no RBAC. Capture
roles as a v2 need (analyst vs admin vs auditor).
**Answer:** _<!-- fill in -->_

### Q12 🟡 Multi-sig critical actions — UI now or placeholder?
**Analysis:** Roadmap: "Multi-Sig for Critical Actions (2-of-3 admins, WebAuthn)"
is *Planned*, not done. Polonium references it.
**Recommendation:** v1 = **read-only indicator/placeholder**; full signing flow
deferred to when the contract lands.
**Answer:** _<!-- fill in -->_

---

## E. Localization & content

### Q13 🟡 Primary language — English-first with PL locale?
**Analysis:** UI mixes Polish ("Wnioski detekcji", "Zarządzanie Politykami",
"Czas") and English. Mowa API keys are Polish (`kod`, `tresc`, `izoluj`).
**Recommendation:** **English-first UI**, keep PL as a selectable locale; API
keys stay Polish but are mapped to typed VMs in `api.ts`. Confirm target audience.
**Answer:** _<!-- fill in -->_

### Q14 🟢 Brand specifics — exact logo, accent hex, and "glow" intensity?
**Analysis:** Current accent is a cyan glow; no formal brand guide found.
**Recommendation:** Use `--accent:#38bdf8` as placeholder; request official brand
tokens. Keep glow subtle + `prefers-reduced-motion` aware.
**Answer:** _<!-- fill in -->_

---

## F. Deployment & ops

### Q15 🔴 IPFS runtime config — build-time env vs fetched `config.json`?
**Analysis:** A single CID may need to target different agent hosts. v1 offers
either `VITE_THORIUM_API` (build-time) or a boot-time `config.json` fetch.
**Recommendation:** **`config.json` fetched at boot** → one immutable CID, many
deployments. Confirm acceptable.
**Answer:** _<!-- fill in -->_

### Q16 🟡 IPFS gateway / pinning provider + ENS/DNSLink?
**Analysis:** Prompt says "deploy as a usual website on IPFS for which we have a
license." Provider not named.
**Recommendation:** Document the licensed provider here; add DNSLink/ENS for a
stable name. Surface CID in footer.
**Answer:** _<!-- fill in -->_

### Q17 🟢 Telemetry/error reporting in a decentralized app?
**Analysis:** No analytics present; a SOC tool may want self-hosted error logs.
**Recommendation:** v1 = none (privacy + IPFS). Optional self-hosted Sentry later.
**Answer:** _<!-- fill in -->_

---

## G. Process

### Q18 🟢 Who owns implementation — FE team, or an AI agent loop?
**Analysis:** This workspace supports both (Claude Code / Antigravity / Codex).
**Recommendation:** AI-agent-driven implementation against this spec, FE review on
PRs into `experimental-aw-fe`.
**Answer:** _<!-- fill in -->_

### Q19 🟢 Anything in v1 you explicitly reject / want removed?
**Recommendation:** None — list overrides here so v2 drops them cleanly.
**Answer:** _<!-- fill in -->_

---

### After answering
1. Save this file (answers inline).
2. Generate `fe_design_v2.md` = v1 + decisions above.
3. Open `questions_v2_to_v3_qa.md` with the next round.
4. `git add .ai-fe-design/ && git commit && git push` on your v2 branch.
