# `demo-gen` — versioned demo + mock generators

This folder holds **reusable procedures** that turn a Thorium XDR *frontend design
version* into a runnable artifact: a **clickable demo**, a **living (running)
demo**, a **deployable (IPFS) build**, and a **contract-driven mock + OpenAPI spec**.

It is deliberately separate from the design docs because there are **two
independent version axes**:

```
        design version  →  v1   v2   v3   …     (what the product should be)
   generator version    →  gen-v1  gen-v2  …    (how we turn a design into a demo)

   a RUN pins one of each:   gen-v1 ⊗ design-v2  →  demo_designV2_genV1
```

The generator is versioned so we can improve *how* we build demos without
rewriting the design, and so a later generator can target a future design that
doesn't exist yet.

## Contents
```
demo-gen/
├── README.md                 ← this file (concept + matrix + how to invoke)
└── gen-v1/                    ← generator v1 (pinned to design v2)
    ├── PROMPT.md              ← the procedure (model-agnostic; run verbatim)
    ├── ASSUMPTIONS.md         ← pre-authorized demo-scope assumptions
    ├── openapi/               ← OpenAPI 3.1 contract (mock + FE adapter source of truth)
    └── mock/                  ← Prism mock (docker-compose) + run guide
```

## How to invoke
- **Claude Code:** run the skill — `/fe-demo-gen` (see
  `.claude/skills/fe-demo-gen/`). It reads the latest design + the chosen
  generator and executes `PROMPT.md`.
- **Any other agent (Antigravity / Codex / Cursor) or a human:** open
  `gen-v1/PROMPT.md` and follow it verbatim. It is self-contained.

## Output
Generated demos land in **`.ignored/fe-demo/demo_designV<M>_genV<N>/`** (gitignored
— demos are build artifacts, not design history). Each demo carries its own README
with run + deploy steps and any deviations.

## The iteration plan (design ⊗ generator matrix)

| Step | Generator | Design | Output | Status |
|---|---|---|---|---|
| 1 | **gen-v1** | **v2** | `demo_designV2_genV1` | generator authored ✅ — build pending sign-off |
| 2 | gen-v2 (improved) | v2 | `demo_designV2_genV2` | after we learn from step 1 |
| 3 | gen-v2 | **v3** (in progress by another team) | `demo_designV3_genV2` | once v3 design exists |

**Rule:** when a new design needs capabilities the current generator lacks
(stateful mock, WebSocket, multi-sig, etc.), **fork the generator** (`gen-vN+1/`)
rather than mutating an existing one — keep the matrix provenance honest.

## Authoring rules (keep generators model-agnostic)
- A `PROMPT.md` is a *procedure*, not a chat: ordered steps, explicit acceptance
  criteria, "make reasoned decisions — don't stop to ask."
- No tool-specific assumptions; reference files by repo-relative path.
- Pin the design version in the header; list binding ADRs.
- Demos may rely on `ASSUMPTIONS.md`; they must never edit design docs (record
  deviations in the generated demo's README).
