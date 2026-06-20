# AGENTS.md — orientation for any AI coding agent

> Portable entrypoint for **any** model/tool (Claude Code, Antigravity, Codex,
> Cursor, …) working in `.ai-fe-design/`. (Claude Code users can also use the
> `fe-demo-gen` skill.) Read this first.

## 🚀 Capability #1: generate the FE demo (do this when asked to "build/run the demo")
Any agent (Claude Code / Codex / Antigravity) can generate a runnable, deployable
demo with living mocks from these specs:
- Claude Code: run the `/fe-demo-gen` skill.
- Otherwise: follow `demo-gen/gen-v1/PROMPT.md` verbatim (self-contained).
- Read `input/DEMO.md` first (the ⭐ CC* critical demo path — top priority).
- Output → `.ignored/fe-demo/demo_designV2_genV1/` (app `:5173` + mock `:4010`,
  one `npm run demo`); its README lists every missing/mocked integration.

## ⭐ CC* — the critical demo case (binding)
`input/DEMO.md` defines the headline path (observed pod → healthy → attack →
NOT WORTHY → prominent Stripe-grade alert). Every design version and demo MUST make
it prominent and flawless. Decision: `adr/0007-cc-critical-demo-path.md`.

## What this workspace is
The versioned **frontend design** for the **Thorium XDR** console — a Web3-native
security/XDR SOC dashboard (Sui blockchain registry, Walrus storage, eBPF agents
written in the Mowa language). The frontend is Svelte 5 + Vite, deployed static to
IPFS.

## ⏱ CURRENT STATE (bump this every round)
- **Design:** `fe_design_v5.md` (v1–v4 are history). **Branch:** `experimental-aw-fe-v3`.
- **Open Q&A:** `questions_v5_to_v6_qa_LONG.md` (driven by CR-3) + the short
  `questions_v5_to_v6_qa.md`. **Vision RFI:** `questions_v4_to_v5_qa_LONG.md`.
- **Canonical app (tracked, per L-C2):** `.ai-fe-design/delivery/delivery-v2/app`
  (build/run there). Latest deployment: see `ai_internal_audit_log/deployments.md`.

## The two loops (don't confuse them)
1. **Design loop** — `fe_design_v1 → … → v5 …`. Driven by Q&A files. Current: **v5**
   done; `questions_v5_to_v6_qa_LONG.md` open.
2. **Demo loop** — `demo-gen/gen-v1 → gen-v2 …`, each pinned to a design version,
   producing runnable demos. See `demo-gen/README.md` (the design ⊗ generator
   matrix).

## Read order
1. `README.md` — the flow + conventions.
2. `fe_design_v5.md` — current design (v1–v4 are history).
3. `assumptions_v1.md` §1 — **confirmed on-chain data model** (the real schemas).
4. `adr/` — binding decisions (Tailwind, ECharts+uPlot, polling, Prism, Sui-read).
5. `demo-gen/` — how to generate demos.

## Hard rules (apply to every model)
- **Immutable versions:** never edit `fe_design_vN.md` to fix it — supersede with
  `v(N+1)`. Same for questions: keep the `*_qa.md` clean, put answers in
  `*_qa_AUDIT.md`.
- **English only** in any UI; the Mowa wire keys are Polish and are mapped in the
  data adapter — Polish must never reach the UI.
- **IPFS-friendly** builds: `base:'./'`, hash routing, no SSR.
- Procedures (`demo-gen/*/PROMPT.md`) are **run verbatim** — make reasoned
  decisions, don't stop to ask; record deviations in the generated artifact, not
  here.
- **Git:** work on `experimental-aw-fe-v3` (current); older `…-v2`/`…-fe` are history.
  The canonical app is **tracked** at `delivery/delivery-v2/app` (per L-C2) — *not* under
  `.ignored/` anymore.
  Demos are generated under `.ignored/` (gitignored) — don't commit build output.

## Ground-truth facts
- Sui **testnet** package `0x0cc3f972285b0486b2590b5edc9321813ec32a253a26cffa687da5a1131491af`
  (modules `edr_registry`, `talus_xdr_detector`, `polonium_policy`).
- Agent HTTP contract + Sui/Walrus mock are specified in
  `demo-gen/gen-v1/openapi/thorium-xdr.openapi.yaml`.
