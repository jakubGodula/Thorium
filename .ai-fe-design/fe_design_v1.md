# Thorium XDR — Frontend Design Spec **v1**

> Status: **v1 (draft for implementation)** · Owner: FE team / AI agent · Source of
> truth for the Thorium XDR web console. Produced from analysis of `ui/`,
> `thorium_agent.mowa`, `silicon.mowa`, and the reference images in `input/`.
>
> Open decisions are tracked in [`questions_v1_to_v2_qa.md`](./questions_v1_to_v2_qa.md).

---

## 0. TL;DR

Thorium XDR is a **Web3-native Extended Detection & Response (XDR) console**. It
is a security operations center (SOC) dashboard for fleets of endpoints running
the Thorium agent (written in the **Mowa** language), where the agent registry,
incident actions, and policies live **on the Sui blockchain**, and forensic
artifacts live in **Walrus** (object storage) sealed with **Seal** ("Foka").

The frontend's job: give a SOC analyst the **clarity of Stripe/Datadog**, the
**capability surface of Microsoft Defender / Sentinel / zScaler**, and the
**on-chain trust** of SUI/Walrus — as a **lightweight, dependency-minimal Svelte
app deployable to IPFS**.

This v1 formalizes the *already-existing* `ui/src/App.svelte` (a ~3,560-line
monolith) into a precise, componentized, design-system-driven spec.

---

## 1. Product context (what Thorium is)

| Layer | Tech | Notes |
|---|---|---|
| Endpoint agent | **Mowa** language, headless HTTP API | `thorium_agent.mowa` exposes `/api/*` |
| Telemetry | **eBPF** | process `execve` interception, FIM on `/etc/shadow` |
| Identity / registry | **Sui** blockchain | agents = SBTs, C2 registration, `edr_registry` |
| Response (SOAR) | Mowa playbooks | quarantine, IP block, process kill, isolate/restore |
| Forensics / storage | **Walrus** + **Seal** ("Foka") | logs frozen as evidence, encrypted vuln registry |
| AI detection | **Talus** | behavioral detection insights |
| Policy | **Polonium** | on-chain policy console, multi-sig critical actions |
| Crypto signing | **Silicon** (`silicon.mowa`) | `/api/sign` Ed25519 signing service |

**Roadmap snapshot** (from `input/…21.47.04.jpeg`): Done = eBPF telemetry, C2 on
Sui, SOAR engine, FIM. In progress = Walrus forensics, Cross-Device XDR, **SOC
Dashboard (Svelte)** ← *this is us*. Planned = YARA, CSPM/CVE scanner, Multi-Sig.
R&D = Mowa→eBPF JIT, Spatial SOC (3D kill-chains), BPF LSM pre-execution.

---

## 2. Goals & non-goals for v1

**Goals**
- One coherent design system (dark, high-density, "Defender-grade") replacing the
  inline-styled monolith.
- Componentized architecture (no 3,500-line single file).
- Faithful to the **existing JSON/RPC contract** — the UI must keep working
  against `thorium_agent.mowa` and the Sui wallet integration.
- IPFS-deployable static build (hash routing, relative paths, no SSR).
- Locale: consolidate the current PL/EN mix → **English-first, i18n-ready**.

**Non-goals (v1)**
- 3D Spatial SOC (R&D), live multi-sig signing flows, real YARA offloading.
- Backend/agent changes. FE consumes the contract as-is.
- Auth/RBAC beyond wallet-connect (tracked as a v2 question).

---

## 3. Design system

Target feel: **Datadog density + Stripe restraint + Defender information
architecture**, on a dark SOC palette consistent with the existing UI.

### 3.1 Color tokens (CSS custom properties → `ui/src/lib/theme.css`)

```css
:root {
  /* surfaces (deep navy, matches current app) */
  --bg-0:#0a0e1a; --bg-1:#0f1424; --bg-2:#161c2e; --bg-3:#1d2436;
  --border:rgba(255,255,255,.08); --border-strong:rgba(255,255,255,.14);

  /* text */
  --text-0:#f1f5f9; --text-1:#94a3b8; --text-2:#64748b;

  /* brand / accent */
  --accent:#38bdf8;        /* Thorium cyan glow */
  --accent-2:#6366f1;      /* indigo */

  /* severity (SOC standard) */
  --sev-critical:#ef4444; --sev-high:#f97316; --sev-warning:#f59e0b;
  --sev-medium:#eab308;   --sev-low:#22c55e;  --sev-info:#38bdf8;

  /* status */
  --ok:#22c55e; --isolated:#ef4444; --pending:#f59e0b; --offline:#64748b;

  /* radii / shadow / spacing scale (4px base) */
  --r-sm:6px; --r-md:10px; --r-lg:14px;
  --shadow:0 8px 24px rgba(0,0,0,.35);
  --s1:4px; --s2:8px; --s3:12px; --s4:16px; --s5:24px; --s6:32px;
}
```

### 3.2 Typography
- UI font: system stack (`-apple-system, "Segoe UI", Roboto, …`) — no web-font
  dependency (IPFS-friendly).
- Mono (hashes, addresses, commands, logs): `ui-monospace, "JetBrains Mono", Menlo`.
- Scale: 11/12 (meta) · 13/14 (body) · 16/18 (section) · 22 (page) · 28 (hero).
- Truncate on-chain values (`0x1a2b…3c4d`, `blake3:4110df0…`) with copy-on-click.

### 3.3 Base components (build in `ui/src/lib/components/`)
| Component | Purpose |
|---|---|
| `Card.svelte` | Panel surface (`--bg-1`, border, radius, optional header/actions). |
| `StatTile.svelte` | KPI: value, title, trend (↑/↓ + positive/negative color). |
| `SeverityPill.svelte` | `CRITICAL/HIGH/WARNING/MEDIUM/LOW/INFO` colored chip. |
| `StatusBadge.svelte` | Agent state: Active / Isolated / Pending / Offline. |
| `DataTable.svelte` | Dense, sortable, sticky-header table (Datadog-style). |
| `MonoAddr.svelte` | Truncated mono hash/address with copy + Sui explorer link. |
| `Drawer.svelte` | Right-side slide-over for logs/hardware/incident detail. |
| `Tabs.svelte` | Top nav tab bar (replaces inline `activeTab` ternary soup). |
| `Toast.svelte` | Action feedback (isolate/restore/sign results). |
| `Sparkline.svelte` | Tiny inline trend (no chart lib; SVG path). |

### 3.4 Layout shell
- **Top bar**: `🛡️ Thorium XDR` logo + live chain badge
  (`● Sui Testnet Connected — 0xa::edr_registry`) + wallet connect button + search.
- **Primary nav**: horizontal tabs (current model) for v1. *v2 question:* migrate
  to a Defender-style left rail with grouped sections.
- **Content**: 12-col responsive grid, 1280px comfortable, graceful to 1024px.
- **Density default**: "comfortable"; offer a "compact" toggle later (v2).

---

## 4. Information architecture (screens)

These map 1:1 to the existing `activeTab` values, refined and named in English.
Order = nav order.

1. **Overview** (`overview`) — default landing.
2. **Endpoints** (`endpoints`) — fleet inventory (SBT agents).
3. **Incidents** (`incidents`) — on-chain incident feed + triage.
4. **VMs** (`vms`) — VM lifecycle manager.
5. **Talus AI** (`talus`) — AI detection insights.
6. **Vulnerabilities** (`vulnerabilities`) — Seal/Walrus-encrypted vuln registry.
7. **Polonium** (`polonium`) — policy configuration console.
8. **Helium** (`helium`) — (existing; secondary — scope confirmed in v2 Q).

> Naming: keep tab IDs identical to current code to avoid churn; only labels change.

---

## 5. Screen specs

### 5.1 Overview
**Purpose:** at-a-glance SOC posture. Mirrors `body_output.txt`.

- **KPI row** (4× `StatTile`):
  - Active Agents — `24` ↑ 3 this week
  - Critical Threats — `1` · "Require attention" (negative)
  - Files Quarantined — `142` · "Last 30 days"
  - Total Processed (PTB) — `8,932` · "Transactions batched" (positive)
- **Monitored Endpoints (SBT)** — compact `DataTable`: agent id (`MonoAddr`),
  hw hash, `StatusBadge`, load %, row actions → View Logs · View Hardware ·
  Isolate/Restore (disabled when wallet not connected).
- **Live Incident Feed (On-Chain)** — `Card` with Refresh; list of incidents:
  `SeverityPill` + command (mono) + agent + action taken + relative time +
  Investigate → opens Incident drawer.

### 5.2 Endpoints
Full-page version of the endpoints table. Columns: Agent (SBT id), Hostname,
Owner, Machine type, IP, Hardware fingerprint, Status, Load, Last seen, Policy
(Polonium), Actions. Filter bar: status, owner, machine type, search.
Row → endpoint detail drawer (status + hardware + recent logs from `/api/logi`).

### 5.3 Incidents
Triage queue. List/table of incidents with `SeverityPill`, command, agent,
detected-by (eBPF/FIM/Talus/YARA), action (`KILLED_AND_ISOLATED`, `BLOCKED`,
`QUARANTINED`), on-chain tx, time. Detail drawer: full command, kill-chain
context, evidence link (Walrus), response actions, "freeze to Walrus" button.

### 5.4 VMs
Lifecycle manager (existing `VMManager.svelte`). Create VM (name, port, owner,
type), list, start, stop, delete. Backed by `/api/vm/*` + `/api/rpc vm_create`.
Show per-VM status, port, owner, type.

### 5.5 Talus AI
AI detection insights ("Wnioski detekcji Talus AI" → "Talus AI Detections").
Cards per insight: detection summary, confidence, recommended response action,
affected agent, accept/dismiss.

### 5.6 Vulnerabilities
"Agent Vulnerability Registry (Seal-encrypted via Walrus)". Table of CVEs/
weaknesses per endpoint; locked rows require Seal decrypt; severity, package,
NVD link, assigned Polonium policy. (Ties to planned CSPM/CVE scanner.)

### 5.7 Polonium (Policy Console)
On-chain policy management. Policies: malware-signature policy, AI behavioral
policy. Controls: enable/disable, thresholds, scan cadence, expiration (note the
"dynamic risk calculator" that shortens policy TTL to 24h on active CRITICAL).
Audit log table of policy operations (time, operation, status). Multi-sig =
read-only indicator in v1 (planned feature).

### 5.8 Helium
Existing secondary tab — keep rendering, mark **"experimental"**; full scope is a
v2 question.

---

## 6. Data contract (consume as-is)

The frontend talks to the Mowa agent's headless HTTP API. **Do not change the
contract in v1.** Base URL is configurable (`VITE_THORIUM_API`, default the
agent host).

### 6.1 Endpoints (`thorium_agent.mowa`)
| Method | Path | Purpose |
|---|---|---|
| GET | `/api/status` | Agent status + hardware fingerprint + identity |
| POST | `/api/rpc` | JSON-RPC 2.0: `get_logs`, `vm_create`, … |
| GET | `/api/logi` | Raw log buffer (text/plain) |
| POST | `/api/izoluj` | Isolate host |
| POST | `/api/przywroc` | Restore host |
| GET | `/api/vm/lista` | List VMs |
| POST | `/api/vm/start` | Start VM |
| POST | `/api/vm/stop` | Stop VM |
| POST | `/api/vm/usun` | Delete VM |

Signing service (`silicon.mowa`): `GET /status`, `POST /api/sign` (Ed25519).

### 6.2 Shapes (from the Mowa `slownik()` builders)

```ts
// GET /api/status
interface AgentStatus {
  status: string;            // "Aktywny" | "Active" | "Isolated" …
  fingerprint: string;       // blake3 hardware hash
  klucz_pub: string;         // Ed25519 public key
  hostname: string;
  ip_address: string;        // v4 or v6 (fde4:8dba:82e1::11)
  owner_name: string;        // e.g. "Jakub"
  machine_type: string;      // "Workstation" | "Server"
  hardware: unknown;         // odczytaj_hardware()
}

// POST /api/rpc  (JSON-RPC 2.0)
interface RpcReq  { jsonrpc:"2.0"; id:number; method?:string; params?:any;
                    get_logs?:any; vm_create?:any }
interface RpcResp { jsonrpc:"2.0"; id:number;
                    result?:any; error?:{code:number;message:string} }
// result for get_logs: { logs:string; status:string; fingerprint:string }
// result for vm_create: { status:"created"; msg:string }

interface Vm { name:string; port:string|number; owner:string; type:string;
               status?:string }

// UI view-models (derive from the above)
interface Incident { id:string; agent:string; severity:"CRITICAL"|"HIGH"|
  "WARNING"|"MEDIUM"|"LOW"; cmd:string; action:string; time:string }
```

> **FE adapter rule:** isolate all `/api/*` calls in `ui/src/lib/api.ts`; map raw
> (Polish-keyed) responses into typed view-models there so screens stay clean.

---

## 7. Architecture & file plan (`ui/`)

Tech is fixed by the repo: **Svelte 5 + TypeScript + Vite**, deps kept to
`@mysten/sui.js` + `@mysten/wallet-standard` only. **No CSS framework, no chart
lib** in v1 (hand-rolled SVG sparklines) — stay lightweight for IPFS.

```
ui/src/
├── main.ts
├── app.css                 # imports theme.css + resets
├── lib/
│   ├── theme.css           # tokens (§3.1)
│   ├── api.ts              # fetch wrappers for /api/*  (adapter)
│   ├── sui.ts              # wallet-standard connect, registry reads
│   ├── stores.ts           # writable stores: agents, incidents, vms, wallet
│   ├── format.ts           # truncateAddr, relTime, severity maps
│   └── components/         # Card, StatTile, SeverityPill, DataTable, Drawer …
├── routes/                 # one Svelte file per screen (§5)
│   ├── Overview.svelte  Endpoints.svelte  Incidents.svelte  Vms.svelte
│   ├── Talus.svelte  Vulnerabilities.svelte  Polonium.svelte  Helium.svelte
├── Shell.svelte            # top bar + tabs + <slot/>
└── App.svelte              # router (hash-based) + Shell, ~80 lines
```

**Routing:** hash-based (`#/overview`, `#/incidents/INC-991`) so it works from
`ipfs://…` / `dweb.link` with no server rewrites. Keep `activeTab` semantics.

**State:** Svelte stores; poll `/api/status` + `/api/logi` on an interval
(default 5s, configurable); optimistic UI for isolate/restore with Toast + revert
on error.

---

## 8. IPFS deployment

- `vite build` → static `dist/`. Set `base: './'` in `vite.config.ts` so all
  asset URLs are **relative** (required behind an IPFS CID path).
- Hash routing only (no `history` API / no server-side rewrites).
- No runtime env server; runtime config via a small `config.json` fetched at
  boot (so the same CID can point at different agent hosts) **or** build-time
  `VITE_THORIUM_API`. (Pick one — v2 question.)
- Pin via the licensed IPFS provider; surface the CID + chain badge in the footer.
- CSP-friendly: no inline `eval`, no remote fonts/CDNs.

---

## 9. Accessibility & quality bar
- Keyboard: tabs, drawers, tables fully operable; visible focus rings.
- Color is never the only severity signal — pair with label/icon.
- Respect `prefers-reduced-motion` (the cyan "glow" animations).
- Contrast ≥ WCAG AA on `--text-1` over `--bg-1`.
- `svelte-check` clean; no `any` leaking out of `api.ts`.

---

## 10. Migration plan (from the current monolith)
1. Extract tokens from inline styles → `theme.css`; delete duplicated inline CSS.
2. Build the 10 base components (§3.3); replace ad-hoc markup screen by screen.
3. Split `App.svelte` (3,560 lines) into `Shell.svelte` + 8 route files.
4. Centralize all fetches into `api.ts`; type the responses (§6.2).
5. English-first labels + i18n seam (keep PL strings as the `pl` locale).
6. Verify build is IPFS-clean (`base:'./'`, hash routes, relative assets).

Definition of done (v1): all 8 tabs render from components, isolate/restore/VM
actions work against the live agent, build loads correctly from an IPFS gateway.

---

## 11. Suggested next steps / prompts
See [`README.md`](./README.md) §"Suggested next prompts". In short:
- Run a **Claude design / v0 / Figma Make** pass on §3 to generate the token file
  + base components.
- Then a per-screen deep-dive (Overview first) using §6 shapes.
- Then implement §10 migration, screen by screen, behind the live contract.

---

## 12. Open questions
All deferred decisions are enumerated in
[`questions_v1_to_v2_qa.md`](./questions_v1_to_v2_qa.md). Answer them inline to
generate **v2**.

---

## Addendum (2026-06-19) — ⭐ Critical Demo Case "CC*"
> Added retroactively so the critical demo path spans the full version history
> (v1 → v2 → v3). v1 records it; v2 specifies the presentation; v3 may revise it.

CC* is the headline narrative — an **observed pod** is connected & blockchain-
attested, runs healthy (Sui interaction + OK telemetry visible in the UI), is
**attacked (kernel/DDoS)**, marked **NOT WORTHY**, and a **prominent, Stripe-grade
alert** drives response (with placeholder actions: notify on-call, Slack, freeze/
isolate/kill, connect to Claude Code). Full narrative + acceptance criteria:
[`input/DEMO.md`](./input/DEMO.md). It maps onto the v1 data contract (§6) and
screens (§5): Endpoints/Incidents/Overview must surface the pod's healthy→isolated
lifecycle. **Every version and demo must make CC\* prominent and flawless.**
