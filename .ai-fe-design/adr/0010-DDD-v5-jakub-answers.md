# ADR-0010: Deployment DDD (v5) — built from Jakub's answers

**Status:** Accepted · **Date:** 2026-06-20 · **Branch:** `experimental-aw-fe-v3`
**Source of truth:** `questions_v4_to_v5_qa_LONG.md` (Jakub's answers, commit `18a1f17`).
**Priority:** A `answers` → B CC* → C docs/contract/code.

## Implemented (per the answered Parts A–E)
- **L-A5 multi-endpoint** — the scenario now defends/targets **>1 endpoint**: ws-07 gets
  a BLOCKED lateral-movement attempt (defended) alongside alma9-edge-01 (NOT WORTHY).
  Talus: first 2 cards static, the rest react live across endpoints. Alerts shows a
  DEFENDED/auto-resolved ws-07 row.
- **L-B3** — Fleet Telemetry "Trend" → **"Threat level"** (badges) + a new **ECharts**
  CPU-over-time chart (L-E1).
- **L-B5** — Claude-Code response is a **toast** (modal retired/dormant).
- **L-B2** — KPI **flash** on the healthy phase.
- **L-B4** — **responsive** banner + rail for <1100px / <760px.
- **L-E2** — **Threat Intel** is the most "real" surface (live feed, reacts to scenario).
- **L-E5 / I-M3-1 / J-F4-2** — incident **status lifecycle** (Open→Acked→Resolved) +
  **Acknowledge/Resolve** on the banner & Alerts; **Audit Trail** now builds as the
  analyst acts (I-M3-3). Status target = Walrus (client-side now).
- **L-E1** — ECharts adopted (lazy-loaded); Tailwind **deferred** (kept theme CSS for
  build reliability — noted in doubts).
- **L-E4** — ⌘K kept + improved: mock labels (H-N2-6), "View incident"/"Acknowledge"
  commands when compromised (J-F4-8), overflow hint (H-N2-2).
- **CR-2 cheap fixes** also done: tree row → drawer (G-R1-4/J-F4-1), **Mute ≠ reset**
  (G-R1-6), **Copy actually copies** (G-R1-7), **Connect Wallet → toast** (J-F4-3),
  nav **badge** on active alert (H-N2-4), denser `.cards` (H-N2-1), demo dwell 8s (H-N2-3).
- **L-A7** invite token kept + flagged "to improve". **L-C2** tracked path is canonical.
- **L-C1 IPFS hash** — built dist → CID `bafybeici77d4xq7mdwo7xgwyl4dfxolog3uereebcwfwuxnnaw4jiidczq`
  (CIDv1, only-hash; needs pinning to resolve publicly).

## Deliberately NOT done (out of scope / needs more)
- **Live backend (L-A1/A2/A4/E5 "Mowa")** — wiring the real backend requires the Mowa
  repo + sui-cli + cargo (Jakub's note). Out of scope for a FE iteration → kept mock;
  the adapter seam + `TODO(live)` markers remain the home. (Doubt logged.)
- **Full Tailwind migration** — partial (ECharts only); theme CSS retained.
- Parts G–O answers were blank → CR-2 cheap fixes applied on judgment; the rest → doubts.

## Consequences
- + The demo now shows multi-endpoint defense, a real chart, an analyst action loop,
  and responsive layout — closer to "real tool" than slideshow.
- − Bundle grew (ECharts ~1MB lazy chunk; loads only on Fleet Telemetry).
- − Live data still mock; durable URL still ngrok+CID (not pinned).
