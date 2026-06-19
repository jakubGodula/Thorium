# `.ai-fe-design` — Thorium XDR Frontend Design Workspace

This directory is the **single source of truth** for the Thorium XDR frontend (FE)
design. It is intentionally **not** gitignored: it is versioned so the design
evolves in the open, alongside the code, reviewable in PRs.

It is built to be driven by **humans and AI agents** (Claude Code, Antigravity,
Codex, Cursor, etc.) in a simple, repeatable loop:

```
v1 design  ──▶  answer "v1 → v2" questions  ──▶  v2 design  ──▶  (repeat)
```

---

## What's in here

```
.ai-fe-design/
├── README.md                      ← you are here (the guide / flow)
├── AGENTS.md                      ← portable entrypoint for ANY model (read first)
├── fe_design_v1.md                ← v1 FE spec (history; frozen)
├── fe_design_v2.md                ← (A) CURRENT spec = v1 + decisions
├── questions_v1_to_v2_qa.md       ← v1→v2 ORIGINAL questions (clean)
├── questions_v1_to_v2_qa_AUDIT.md ← v1→v2 ANSWERS (user's decisions, verbatim)
├── questions_v2_to_v3_qa.md       ← (B) NEXT round: questions + assumptions; answer INLINE
├── assumptions_v1.md              ← (C) assumptions + CONFIRMED on-chain data model
├── adr/                           ← Architecture Decision Records (Tailwind, charts, realtime…)
├── brand/                         ← suggested Thorium logo / favicon / palette
├── demo-gen/                      ← versioned demo+mock GENERATORS (design ⊗ generator matrix)
│   └── gen-v1/                    ← gen-v1 (pinned to design v2): PROMPT + OpenAPI + Prism mock
├── prompt_verbatim.md             ← the original prompt(s), verbatim
└── input/                         ← raw context used for the analysis
    ├── prompt.txt                 ← original short prompt
    ├── conversation.txt           ← requirements (Defender / Sentinel / SUI / Stripe…)
    ├── WhatsApp Image …21.47.04.jpeg  ← Thorium XDR roadmap reference
    └── WhatsApp Image …22.17.11.jpeg  ← Microsoft 365 Defender UI reference
```
(Claude Code also has a `/fe-demo-gen` skill at `.claude/skills/fe-demo-gen/`.)

`fe_design_v1.md` was produced **from a real analysis of this repository** (the
existing `ui/` Svelte app, the `thorium_agent.mowa` JSON/RPC contract, and the
reference images). It is not generic boilerplate — it maps directly onto the
endpoints and tabs that already exist.

---

## The flow (for the next human or agent)

### Branch model

- `experimental-aw-fe` — holds the **v1** design. **Frozen** — do not push here.
- `experimental-aw-fe-v2` — derivative of the above; holds the v1→v2 questions +
  assumptions (this iteration), and is where the **v2** design will be committed
  once the questions below are answered.
- Each later iteration continues on this v2 branch (or a fresh derivative).

### B1. Open the project on the working branch

```bash
cd /Users/macbook/work/Thorium
git fetch origin
git checkout experimental-aw-fe-v2       # the active design branch
git pull --ff-only
```

### B2. Orient yourself

Open `.ai-fe-design/` and read, in order:

1. `README.md` (this file) — the flow.
2. **`fe_design_v2.md`** — the CURRENT design (v1 + decisions). `fe_design_v1.md`
   is history.
3. `assumptions_v1.md` — assumptions + the **confirmed on-chain data model** (Sui
   testnet package, event schemas).
4. `adr/` — why the big calls were made (Tailwind, charts, realtime, mock backend,
   Sui-primary read).
5. **`questions_v2_to_v3_qa.md`** — the open round you're answering now.
6. `input/` + `prompt_verbatim.md` — raw source material + original prompts.

> Current state: **v2 is done.** The active task is answering
> `questions_v2_to_v3_qa.md` to produce **v3** (the first implemented demo).

### B3. Drive the loop with an AI agent (or by hand)

The loop is the same every round (here: v2 → v3). Give your agent this instruction:

> Read `.ai-fe-design/fe_design_v2.md` and `.ai-fe-design/questions_v2_to_v3_qa.md`.
> (a) Summarize the current design. (b) Answer each open question inline. (c) Once
> answered, save an answered copy as `questions_v2_to_v3_qa_AUDIT.md`, restore the
> original questions file clean, then produce `fe_design_v3.md` that folds the
> decisions in, plus `questions_v3_to_v4_qa.md` for anything still open. Do not ask
> me clarifying questions — make and record reasoned decisions.

Concretely each round:

- **a) List the current design** — screens, components, data contract, ADRs.
- **b) Answer the questions** — fill each `**Answer:**` inline.
- **c) Compute the next version** — `fe_design_vN.md` = previous + decisions, plus
  a fresh `questions_vN_to_v(N+1)_qa.md`.

### B4. Commit

```bash
git add .ai-fe-design/
git commit -m "fe-design: v3 (answers v2→v3 questions)"
git push origin HEAD:experimental-aw-fe-v2
# (do NOT push to experimental-aw-fe — it is frozen at v1)
```

---

## Suggested next prompts (copy/paste)

- **Build the demo (gen-v1 ⊗ design v2)** — now via the versioned generator:
  > Run the `fe-demo-gen` skill (or follow `demo-gen/gen-v1/PROMPT.md` verbatim)
  > to generate `.ignored/fe-demo/demo_designV2_genV1/`: a Svelte 5 + TS + Vite +
  > Tailwind app (ECharts/uPlot) + the Prism mock from
  > `demo-gen/gen-v1/openapi/`. Do it in two passes — **scaffold** (app + mock +
  > a few wired screens) for sign-off, then **full demo** (all screens, polish).

- **Design system pass (Claude design / v0 / Figma Make)**
  > From `fe_design_v2.md` §2 + the v1 §3.1 tokens, generate the Tailwind theme
  > (`tailwind.config`/`@theme`) and base components (Card, StatTile, SeverityPill,
  > DataTable, Drawer, Chart) with shadcn-svelte/bits-ui. Stripe/ELK/Walrus polish.

- **Single-screen deep dives**
  > Produce a pixel-level spec + Svelte component for the **Overview** (or **Fleet
  > Telemetry**) screen, using the event shapes in `assumptions_v1.md` §1.

---

## Conventions

- **Immutable versions:** never edit `fe_design_vN.md` to "fix" it — supersede it
  with `fe_design_v(N+1).md`. The `_v1`, `_v2`… suffix is the history.
- **Questions / AUDIT split:** `questions_vN_to_v(N+1)_qa.md` stays the **clean
  original questions**. The user's inline answers are preserved verbatim in
  `questions_vN_to_v(N+1)_qa_AUDIT.md` (the decision of record). The next version
  is computed from the AUDIT file.
- **ADRs:** significant, hard-to-reverse decisions get a record under `adr/`.
- **No Polish** in any UI string (English only); Mowa wire keys stay Polish but are
  mapped to English view-models in the data adapter.
- IPFS-friendly build (relative paths, hash routing, no SSR); bundle-size
  optimization is a deliberate later pass (heavy is OK in early iterations).
