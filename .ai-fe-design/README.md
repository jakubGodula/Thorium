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
├── fe_design_v1.md                ← (A) the precise v1 FE spec to implement
├── questions_v1_to_v2_qa.md       ← (B) open questions; answer them INLINE to unlock v2
├── assumptions_v1.md              ← (C) assumptions behind v1 + CONFIRMED on-chain data model
├── prompt_verbatim.md             ← the original prompt that generated v1 (verbatim)
└── input/                         ← raw context used for the analysis
    ├── prompt.txt                 ← original short prompt
    ├── conversation.txt           ← requirements (Defender / Sentinel / SUI / Stripe…)
    ├── WhatsApp Image …21.47.04.jpeg  ← Thorium XDR roadmap reference
    └── WhatsApp Image …22.17.11.jpeg  ← Microsoft 365 Defender UI reference
```

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
2. `fe_design_v1.md` — the current design you're improving.
3. `assumptions_v1.md` — the assumptions v1 rests on + the **confirmed on-chain
   data model** (Sui testnet package, event schemas). Each assumption maps to a
   question below.
4. `input/` — the raw source material (requirements + reference screenshots).
5. `prompt_verbatim.md` — the exact instruction that produced v1.

### B3. Drive the loop with an AI agent (or by hand)

Give your agent (Claude Code / Antigravity / Codex / Cursor) this instruction:

> Read `.ai-fe-design/fe_design_v1.md` and `.ai-fe-design/questions_v1_to_v2_qa.md`.
> (a) Summarize the v1 design. (b) For every open question, propose a recommended
> answer and write it inline under the question. (c) Once questions are answered,
> produce `.ai-fe-design/fe_design_v2.md` that folds the answers into a revised,
> more precise spec, and `.ai-fe-design/questions_v2_to_v3_qa.md` with the next
> round of open questions. Do not ask me clarifying questions — make and record
> reasoned decisions.

Concretely the agent must:

- **a) List the v1 design** — enumerate screens, components, the design system,
  and the JSON/RPC contract from `fe_design_v1.md`.
- **b) Answer the v1→v2 questions** — edit `questions_v1_to_v2_qa.md` in place,
  filling each `**Answer:**` line. (The analysis and recommended defaults are
  already provided for each question — accept, override, or refine them.)
- **c) Compute v2** — write `fe_design_v2.md` = v1 + all the answered decisions,
  plus a fresh `questions_v2_to_v3_qa.md`.

### B4. Commit the v2

```bash
git add .ai-fe-design/
git commit -m "fe-design: v2 (answers v1→v2 questions)"
git push origin HEAD:experimental-aw-fe-v2
# (do NOT push to experimental-aw-fe — it is frozen at v1)
```

---

## Suggested next prompts (copy/paste)

These are good follow-ups once v1 is reviewed:

- **Implement v1 in code**
  > Implement `fe_design_v1.md` in `ui/` (Svelte 5 + TS + Vite). Refactor the
  > monolithic `ui/src/App.svelte` into the component tree the spec defines.
  > Keep the existing Sui wallet + `/api/*` contract working. Build must stay
  > IPFS-deployable (relative asset paths, hash routing, no SSR).

- **Design system pass (Claude design / v0 / Figma Make)**
  > From `fe_design_v1.md`'s "Design System" section, generate a token file
  > (`ui/src/lib/theme.css`) and 6 base components: Card, StatTile, Badge,
  > DataTable, SeverityPill, Drawer. Match Datadog/Stripe density + the dark
  > "Defender-style" palette.

- **Single-screen deep dives**
  > Produce a pixel-level spec + Svelte component for the **Overview** screen
  > only, using the JSON shapes in `fe_design_v1.md` §"Data contract".

---

## Conventions

- Versions are immutable: never edit `fe_design_v1.md` to "fix" it — supersede it
  with `fe_design_v2.md`. The `_v1`, `_v2`… suffix is the history.
- Questions files are **edited in place** (you write answers inline), then the
  answered file is carried forward as the rationale record for the next version.
- Keep everything dependency-light and IPFS-friendly (see the spec's deploy notes).
