# Thorium XDR — Demo Generator **gen-v1**

> **Targets design version:** `fe_design_v2.md` (pinned). Can also be run against a
> later design (e.g. v3) — see "Re-targeting" at the end.
> **Produces:** a clickable demo + a living (running) demo + a deployable
> (IPFS-ready) build + a contract-driven mock (Prism) + the OpenAPI spec.
>
> This file is **model-agnostic**: any capable coding agent (Claude Code,
> Antigravity, Codex, Cursor) can execute it verbatim. It is a *procedure*, not a
> conversation — make reasoned decisions, do not stop to ask.

---

## 0. Inputs (read these first, in order)
1. `.ai-fe-design/fe_design_v2.md` — the design to realize (screens, IA, stack).
2. `.ai-fe-design/assumptions_v1.md` §1 — the **confirmed on-chain data model**
   (event/object schemas) — the data the demo visualizes.
3. `.ai-fe-design/adr/` — binding decisions (Tailwind, ECharts+uPlot, polling,
   Prism mock, Sui-primary read).
4. `./openapi/thorium-xdr.openapi.yaml` — the contract for the mock + FE adapter.
5. `./ASSUMPTIONS.md` — demo-scope assumptions you may rely on.

## 1. Output location & naming (pinned-matrix convention)
Generate into a **gitignored** workspace, named by *design × generator* version:
```
.ignored/fe-demo/demo_designV2_genV1/
├── app/            # the Svelte 5 + TS + Vite + Tailwind demo
├── mock/           # copy of ../mock (Prism + docker-compose) + openapi
├── config.json     # runtime config (points app at the mock by default)
└── README.md       # how to run / deploy this exact demo
```
`.ignored/` is untracked, so the demo never pollutes the design history. Only this
generator (under `.ai-fe-design/demo-gen/`) is versioned in git.

## 2. Tech (from design v2 + ADRs — do not deviate)
- Svelte 5 + TypeScript + Vite. **English only** (no Polish in UI).
- **Tailwind CSS v4** (theme = v1 §3.1 tokens). shadcn-svelte / bits-ui primitives.
- **ECharts** (rich) + **uPlot** (dense time-series), lazy-loaded per route.
- IPFS-ready: `base: './'`, **hash routing**, no SSR, relative assets.
- One data adapter (`src/lib/data/`) behind which live BOTH the agent API and the
  Sui mock; switch via `config.json` (`mock: true` by default).

## 3. Build steps (do them in order)

### 3a. Scaffold
- `npm create vite@latest app -- --template svelte-ts`; add Tailwind v4, ECharts,
  uPlot, `@mysten/sui.js`, `@mysten/wallet-standard`.
- Port the v1 §3.1 tokens into the Tailwind theme. Wire `brand/favicon.svg` and
  `brand/thorium-mark.svg` (from `.ai-fe-design/brand/`).

### 3b. Data layer (contract-first)
- Generate typed clients/types from `openapi/thorium-xdr.openapi.yaml`
  (e.g. `openapi-typescript`).
- `src/lib/data/adapter.ts`: map raw wire (Polish keys, Sui `parsedJson`) →
  English view-models (`AgentStatus`, `Incident`, `TelemetryPoint`,
  `Classification`, `PolicyConfig`). **No Polish escapes this file.**
- Polling per ADR-0001 (agent ~5s, Sui ~10s). `config.json` drives base URLs.

### 3c. Shell + nav
- `Shell.svelte` (top bar: Thorium mark, chain badge `Sui Testnet · 0x0cc3…91af`,
  wallet-connect button, search) + the existing tabs **plus** the new on-chain
  tabs from design v2 §3: **Chain Activity**, **Fleet Telemetry**, **Alerts**.
- Hash router (`#/overview`, `#/telemetry`, …).

### 3d. Screens (build, clickable on mock data)
Implement every screen in design v1 §5 + v2 §3, English-only, fed by the adapter:
Overview · Endpoints · Incidents · VMs · Talus AI · Vulnerabilities · Polonium ·
Chain Activity · Fleet Telemetry · Alerts · (Helium hidden behind a flag).
Use ECharts/uPlot for KPIs, fleet heatmap, telemetry series, on-chain event stream.

### 3e. Mock
- Copy `../mock/*` + `../openapi/*` into `mock/`. `docker compose up` must serve
  the contract on `:4010` (see mock/README).

### 3f. Living + deployable
- **Living demo:** `npm run dev` (app) + Prism (mock) → fully clickable offline.
  Add a root `npm run demo` (concurrently runs both) and document it.
- **Deployable demo:** `npm run build` → static `dist/`; verify it loads from a
  file:// path / IPFS gateway (relative `base`, hash routes). Document the
  `ipfs add -r dist` step; keep `config.json` editable post-build.

## 4. Acceptance criteria (the demo is "done" when…)
- [ ] `npm run demo` boots app+mock; every tab renders with realistic data.
- [ ] No Polish anywhere in the rendered UI.
- [ ] Isolate/Restore + VM actions call the mock and show optimistic toasts.
- [ ] Chain Activity streams the 5 event types; Fleet Telemetry charts cpu/ram/disk.
- [ ] `npm run build` output loads from an IPFS gateway with no server rewrites.
- [ ] Swapping `config.json` to a live agent + Sui RPC works without code changes.
- [ ] Looks professional (Stripe/ELK/Walrus bar) — not a wireframe.

## 5. Assumptions & deviations
Demo-scope assumptions are pre-authorized in `./ASSUMPTIONS.md`. If you must
deviate from the design, record it in the generated `README.md` under
"Deviations" — do **not** edit the design docs.

## 6. Re-targeting a newer design (gen-v1 → design v3)
This generator is pinned to v2 but forward-runnable. To run against a future
`fe_design_v3.md`: read v3 instead of v2 in §0, regenerate types from whatever
OpenAPI v3 ships (or extend this one), and output to
`.ignored/fe-demo/demo_designV3_genV1/`. If v3 needs capabilities gen-v1 lacks
(e.g. stateful mock, WebSocket, multi-sig flow), **fork to `gen-v2/`** rather than
mutating gen-v1 — keep the matrix honest.
