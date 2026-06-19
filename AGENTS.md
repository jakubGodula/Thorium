# AGENTS.md — Thorium XDR (repo root)

Entrypoint for any AI coding agent landing in this repo.

## 🚀 Capability #1 — generate the frontend demo
When asked to build / run / scaffold / deploy the **frontend demo** or its **mock**:
- **Claude Code:** run the `/fe-demo-gen` skill.
- **Any agent / human:** follow `.ai-fe-design/demo-gen/gen-v1/PROMPT.md` verbatim.
- **Read first:** `.ai-fe-design/input/DEMO.md` (the ⭐ CC* critical demo path).
- **Output:** `.ignored/fe-demo/demo_designV2_genV1/` — app `:5173` + Prism mock
  `:4010` via `npm run demo`; its README lists missing/mocked integrations.

## Where things are
- `.ai-fe-design/` — versioned FE design, ADRs, brand, demo generators, prompts
  archive. Detailed agent guide: **`.ai-fe-design/AGENTS.md`** (read it).
- `ui/` — the Svelte frontend app.
- `move/thorium_edr/` — Sui Move contracts (the on-chain data model).
- `thorium_agent.mowa`, `silicon.mowa` — Mowa agent + signing service.

## Hard rules
- Design work on branch `experimental-aw-fe-v2` (`experimental-aw-fe` is frozen).
- FE is **English only**; **IPFS-friendly** builds; demos go under `.ignored/`
  (gitignored — never commit build output).
- Design/version docs are immutable — supersede, don't rewrite (see
  `.ai-fe-design/AGENTS.md`).
