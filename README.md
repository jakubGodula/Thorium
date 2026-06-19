# Thorium XDR

A **Web3-native Extended Detection & Response (XDR)** platform: eBPF endpoint
agents (written in the **Mowa** language) whose registry, incidents, telemetry, and
policies live **on the Sui blockchain** (package
`0x0cc3f972285b0486b2590b5edc9321813ec32a253a26cffa687da5a1131491af`, testnet),
with forensic artifacts on **Walrus**. The frontend is a Svelte SOC console
deployed static to **IPFS**.

Repo layout: `ui/` (Svelte FE) · `move/thorium_edr/` (Sui Move contracts) ·
`thorium_agent.mowa` / `silicon.mowa` (Mowa agent + signing) · `vm/` (provisioning)
· **`.ai-fe-design/`** (the versioned frontend design workspace).

---

## 🚀 Capability #1 — generate the frontend demo (for any AI agent)

**Any coding agent (Claude Code, Codex, Antigravity) or human can generate a
runnable, deployable Thorium XDR frontend demo — with living mocks — from the specs
in [`.ai-fe-design/`](./.ai-fe-design/), with no extra context.**

- **Claude Code:** run the skill **`/fe-demo-gen`**.
- **Any agent / human:** follow
  [`.ai-fe-design/demo-gen/gen-v1/PROMPT.md`](./.ai-fe-design/demo-gen/gen-v1/PROMPT.md)
  verbatim (self-contained, model-agnostic). Read
  [`.ai-fe-design/input/DEMO.md`](./.ai-fe-design/input/DEMO.md) **first**.
- **Result:** clickable + **living** demo (app `http://localhost:5173` + Prism mock
  `http://localhost:4010`, one `npm run demo`) + an IPFS-deployable build, under
  `.ignored/fe-demo/demo_designV2_genV1/`. The generated README documents the live
  link, deploy steps, and every **missing/mocked integration** (live Sui, Walrus,
  Slack, cloud-kill, …).

### Scope: Alfa (default) vs Beta
The demo is parameterized `--scope=alfa|beta` (**alfa default**): **Alfa** = focused
SOC console + CC\* (Defender IA · Walrus look · ELK/Datadog capability · blockchain
domain); **Beta** = Alfa + the roadmap/presentation breadth (personas, business
models, $THOR/DAO, compliance, MSSP, module catalog). Human guide:
[`README-for-human.md`](./README-for-human.md).

## Capability #2 — deploy the demo (remote / IPFS)
The build is static and IPFS-safe (`base:'./'`, hash routing). Deployment is
**versioned** (`delivery-v1`, `delivery-v2`, …) — see
[`README-deployment.md`](./README-deployment.md).
- **Remote (auto, delivery-v2):** GitHub Actions publishes to **GitHub Pages** →
  **https://jakubgodula.github.io/Thorium/** (`?cc=1` for the CC* alert).
- **IPFS / any static host:** `npm run build` → host `dist/` or `ipfs add -r dist`.

### ⭐ The Critical Demo Case (CC*) — must be flawless
The demo's spine: connect an **observed pod** (blockchain-attested) → it runs
**healthy** (Sui interaction + OK telemetry visible) → **simulate a kernel attack /
DDoS** → Thorium marks it **NOT WORTHY** → NOT-OK telemetry/logs are clearly visible
→ a **prominent, Stripe-grade alert** drives response. Full spec:
[`.ai-fe-design/input/DEMO.md`](./.ai-fe-design/input/DEMO.md).

---

## Frontend design workspace

[`.ai-fe-design/`](./.ai-fe-design/) holds the versioned FE design (v1 → v2 → …),
the open questions, the ADRs, the brand assets, and the demo generators. Start at
[`.ai-fe-design/README.md`](./.ai-fe-design/README.md) (or
[`.ai-fe-design/AGENTS.md`](./.ai-fe-design/AGENTS.md) if you're an agent).

> Branches: design work lives on `experimental-aw-fe-v2`; `experimental-aw-fe` is
> frozen at v1.
