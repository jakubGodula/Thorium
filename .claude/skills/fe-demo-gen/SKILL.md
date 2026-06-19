---
name: fe-demo-gen
description: >
  Generate a runnable Thorium XDR frontend demo (clickable + living + deployable)
  with a contract-driven Prism mock and OpenAPI spec, from a pinned frontend
  design version. Use when the user wants to scaffold/build/run the FE demo, the
  mock backend, or a deployable IPFS demo from the .ai-fe-design specs. Versioned
  via the design ⊗ generator matrix in .ai-fe-design/demo-gen/.
---

# fe-demo-gen

Turns a Thorium XDR **frontend design version** into a demo + mock. Generators are
versioned independently of the design (see the matrix in
`.ai-fe-design/demo-gen/README.md`). Default run = **gen-v1 ⊗ design v2**.

## When to use
- "Build / scaffold / run the FE demo", "spin up the mock", "make the deployable
  IPFS demo", "generate the clickable demo from the design".

## How to run
1. Pick the generator (default `gen-v1`) and the design version (default the
   latest `fe_design_v*.md`, currently v2). Confirm the pair with the user only if
   ambiguous; otherwise use the defaults and state them.
2. Read, in order:
   - `.ai-fe-design/demo-gen/<gen>/PROMPT.md` (the procedure — the authority)
   - `.ai-fe-design/demo-gen/<gen>/ASSUMPTIONS.md`
   - the target `.ai-fe-design/fe_design_v<M>.md`
   - `.ai-fe-design/assumptions_v1.md` §1 (on-chain schemas)
   - `.ai-fe-design/adr/` (binding decisions)
   - `.ai-fe-design/demo-gen/<gen>/openapi/` + `mock/`
3. Execute `PROMPT.md` step by step. Make reasoned decisions; rely on
   `ASSUMPTIONS.md`; do not stop to ask. Record deviations in the generated demo's
   README, never in the design docs.
4. Output to `.ignored/fe-demo/demo_designV<M>_genV<N>/` (gitignored).
5. Verify the PROMPT's acceptance criteria (boots app+mock, no Polish, charts
   render, IPFS build loads, config switch works).

## Scope discipline
- Two-step delivery is fine: **scaffold first** (app + mock skeleton, a couple of
  screens wired), get sign-off, then **full demo** (all screens, polish). Say which
  step you're doing.
- Forking: if the target design needs capabilities the generator lacks, propose a
  new `gen-vN+1/` rather than mutating an existing generator.

## Notes
- This skill is a thin wrapper; the portable source of truth is the `PROMPT.md`,
  so non-Claude agents can run the same procedure by hand.
