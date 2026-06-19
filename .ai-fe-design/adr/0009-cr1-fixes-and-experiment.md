# ADR-0009: CR-1 fixes (vYY) + ⌘K experiment (vYY+1)

**Status:** Accepted · **Date:** 2026-06-20 · **Driver:** `input/cr/cr-1.md`
**Priority:** A `answers.md` → B `DEMO.md` (CC*) → C prior docs/code.

## Context
CR-1 (Sonnet 4.6) reviewed vX+1. It confirms the core is good (CC* stepper, two-tier
mock honesty, left rail, kill-chain) and lists gaps. We split them: **decided →
implement now**; **ambiguous → transition Q&A** (`questions_vYY_to_vZZ_*`).

## Decisions implemented (vYY, CR-fix build)
- **A-1/Q-1 adapter boundary** → created `src/lib/adapter.ts` (the single live/mock
  seam ADR-0006 called for). `connectLive` (WS), `querySuiEvents`, `fetchWalrusBlob`
  with concrete `TODO(live)` homes.
- **A-2 WebSocket markers** → `Fleet Telemetry` + `Chain Activity` carry `WS/polling`
  badges; `applyLiveEvent` receiver stub documents where live events drive state.
- **A-3 incident tree** → active CC* incident (INC-991) pulses/stands out when
  compromised; child-count shown.
- **A-4/Q-3 Walrus decrypt** → **per-row** state (was a single global flag) + a real
  `fetch(walrusGateway/blobId)` attempt with a demo fallback + a "decrypting…" spinner.
- **A-7/P5 invite token** → realistic `inv_8Qm4Zr2Tn9Kx7Wb3Yc6Hf1Ld` + `demo` tag
  (was `…-MOCK`, which broke immersion).
- **B-1 connect phase** → grey/pending sparkline (was misleading green).
- **B-3 NOT-OK logs** → a "Recent logs" panel (eBPF/FIM/syslog) on Fleet Telemetry,
  visible without opening the drawer (the CC* "NOT-OK log visible" criterion).
- **B-5 Claude Code response** → opens a richer **AI-agent modal** (not just a toast)
  — leans into the Sui/AI hackathon narrative.
- **Q-2** `connectCmd` → `$derived` (reads config reactively). **Q-4** `onDestroy`
  clears timer + WS + keydown. **Q-5** MSSP switcher actually cycles tenants + `mock` tag.

## Decision: experiment (vYY+1)
- **⌘K command palette** (answer I17) — fuzzy nav + Run CC* / Demo mode. A clean,
  demoable upgrade layered on the CR-fix build, shipped as the 2nd deployment.

## Deliberately NOT decided → transition Q&A (ambiguous)
P1 real UD domain · P2 WS message schema · P3 live-profile scope/timing · P4 where
the "partly implemented" tree lives · P6 durable URL (repo public vs IPFS) · A-6
personas top-level vs subtab · A-8 hash-router not configured · Q-6 English-keyed
contract. (See `questions_vYY_to_vZZ_qa_LONG.md`.)

## Consequences
- + Demo is more honest *and* more real (adapter seam, real Walrus fetch attempt,
  NOT-OK logs, live markers) without breaking the working core (CR Part 6).
- + Two deployments this round (CR-fix + experiment), both verified.
- − Live data still not wired (correct — answer C5 says "tomorrow"); the seam now
  exists so it's a fill-in, not a refactor. ECharts/Tailwind still deferred.
