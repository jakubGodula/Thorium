# ADR-0008: vX+1 — answers-driven scope expansion + left-rail shell

**Status:** Accepted (vX+1) — driven by `input/answers.md` (the first principle)
**Date:** 2026-06-19

## Context
`input/answers.md` (the authoritative answers to the v2→v3 questions) expanded the
demo well beyond minimal Alfa: it asks to **surface most Part-3 (Beta) concepts as
clearly-labeled mock/non-functional tabs** (personas/roles, governance+$THOR,
compliance/NIS2 auditor view, MSSP tenant switcher, module catalog, web terminal,
audit trail, integrations/SIEM, privacy badges, offline-lockdown, threat-intel/
deception, "other"), plus **real** additions: an **incident correlation tree** (I3),
an **onboarding command generator** with mock invite token (I12), **browser-side
Walrus/Seal decrypt** (I4), a **Talus correlation demo** (I5), **K8s example UI**
(C2, non-functional), and **WebSocket integration markers** (I2). Single role, no
switcher (C1/I8). CC* kept as #1 banner→drawer (C3).

## Decision
1. **Adopt a grouped left-rail navigation** (Monitor · Detect · Respond · Platform)
   — top tabs don't scale to ~18 sections; this matches the Defender-style rail the
   design always anticipated.
2. **Two fidelity tiers:** *interactive* (CC*, incidents-tree, onboarding, telemetry,
   chain, talus, vulns-decrypt) vs *mock panels* — every mock surface carries a
   visible `mock` / `soon` tag and a toast saying "mock / coming soon".
3. **Live-data is wired as config + code markers, not implemented:** `config.json`
   gains `suiRpcUrl`, `wsUrl`, `walrusGateway`, `unstoppableDomain`; `App.svelte`
   has `TODO(live, …)` markers where WS/Sui/Walrus data will plug in. mock=true by
   default; flip for the live profile (C5).
4. **Deploy target = Unstoppable Domains + IPFS** (I9/I10): build stays IPFS-safe
   (`base:'./'`, hash routing); footer shows the domain.

## Alternatives considered
- *Keep minimal Alfa (top tabs, no Beta surfaces).* Rejected — contradicts
  answers.md (the first principle).
- *Fully implement the Beta surfaces.* Rejected — out of scope/time; answers
  explicitly say "mock / for the demo / non-functional" for those.
- *Modal mega-menu instead of a rail.* Rejected — worse discoverability for judges.

## Consequences
- + Demo now tells the whole platform story (SOC loop + CC* + business/compliance/
  governance breadth) while staying honest about what's mock.
- + Single code path; live data is a config flip + filling the marked spots.
- − More surface to maintain; mock content must not be mistaken for real (mitigated
  by tags). ECharts/Tailwind still deferred (ADR-0002/0003) for build reliability.
