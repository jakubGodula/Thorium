# Questions: v3 → v4 — **LONG** (exhaustive transition Q&A)

> The detailed companion to [`questions_v3_to_v4_qa.md`](./questions_v3_to_v4_qa.md)
> (short). Built from **CR-1** (`input/cr/cr-1.md`) after shipping **vYY** (CR-fix)
> and **vYY+1** (⌘K experiment). Every item = what CR found · what vYY did · **open
> question** · **Answer:** (inline). Answer → `…_AUDIT.md` → run the RUNBOOK.
> Legend: 🔴 blocks · 🟡 shapes · 🟢 polish.

---

## Part A — vs `answers.md` (Priority A)

### L-A1 🔴 Live profile (C5 / CR A-1, Q-1)
vYY added `src/lib/adapter.ts` (the live/mock seam) with `connectLive`,
`querySuiEvents`, `fetchWalrusBlob` + `TODO(live)` markers. Still no `@mysten/sui.js`
dependency or call. **Q:** Is the live profile in scope for v4? If yes: confirm we add
`@mysten/sui.js`, wire `querySuiEvents` to `cfg.suiRpcUrl`/`packageId`, and flip
`mock:false` as a profile. **Answer:** _<!-- … -->_

### L-A2 🔴 WebSocket schema + source (CR A-2, P2)
vYY marks receivers (Fleet Telemetry, Chain Activity badges; `applyLiveEvent` stub).
You said the WS "is already implemented." **Q:** Where (agent/backend)? **Provide the
WS URL + message schema** (event types → fields) so `applyLiveEvent` maps to
phase/telemetry/incident state precisely. **Answer:** _<!-- … -->_

### L-A3 🟡 Incident tree — existing vs vYY (CR A-3, P4)
vYY highlights the active CC* incident (INC-991 pulses when compromised) + shows
correlated-count. **Q:** You said a tree is "partly implemented" — point to that code;
should vYY align/supersede? Do you want expand/collapse + drill-down, or is the
2-level kill-chain grouping enough for the demo? **Answer:** _<!-- … -->_

### L-A4 🟡 Walrus/Seal decrypt fidelity (CR A-4)
vYY now does a **real `fetch(walrusGateway/blobId)`** per row (with spinner +
graceful demo fallback). No `@mysten/walrus` SDK yet. **Q:** For the demo, is the
real-fetch-with-fallback enough, or wire the actual Seal SDK + a real test blob?
**Answer:** _<!-- … -->_

### L-A5 🟢 Talus correlation liveliness (CR A-5)
Card 1 reacts to the scenario; cards 2–3 are static. **Q:** Make cards 2–3 react to
the CC* phase (glow when kill-chain active), or leave static? **Answer:** _<!-- … -->_

### L-A6 🟡 Personas placement (CR A-6)
"Roles & Models" sits under the **Platform** rail group. **Q:** Keep it there, or
promote to a top-level nav item for the demo flow? **Answer:** _<!-- … -->_

### L-A7 🟢 Invite token format (CR A-7, P5)
vYY uses `inv_8Qm4Zr2Tn9Kx7Wb3Yc6Hf1Ld` + a `demo` tag (replaced `…-MOCK`). **Q:**
Is this format fine, or match a specific real token format/length? **Answer:** _<!-- … -->_

### L-A8 🟡 UD domain + routing (CR A-8, P1)
`config.json` `unstoppableDomain: "thorium.crypto"`; footer/onboarding use it.
`vite.config` `base:'./'` is IPFS-safe; the app is single-page (no router) — ADR-0008
mentioned hash routing but none is configured. **Q1:** Is `thorium.crypto` the real
registered domain? **Q2:** Single-page (no router) OK for the demo, or add hash
routing now (deep-links beyond `?cc=1`)? **Answer:** _<!-- … -->_

---

## Part B — vs CC* `DEMO.md` (Priority B)

### L-B1 🟡 "Connect" phase clarity (CR B-1)
vYY: connect phase now shows a **grey/pending sparkline** (was misleading green). The
drawer doesn't auto-open until `isolated`. **Q:** Auto-open the drawer briefly at
`connected` to show "attested", or keep it closed until the alert? **Answer:** _<!-- … -->_

### L-B2 🟢 Healthy-phase "Sui interacts" moment (CR B-2)
Chain Activity shows `AgentRegistered`/`TelemetryReported` in healthy phase, but the
Overview KPIs don't change. **Q:** Add a subtle "new agent connected" flash/KPI tick
at `healthy` to make the on-chain interaction pop? **Answer:** _<!-- … -->_

### L-B3 🟡 NOT-OK logs (CR B-3) — DONE, confirm
vYY added a **Recent logs** panel (eBPF/FIM/syslog, red when compromised) on Fleet
Telemetry, satisfying "NOT-OK log visible". **Q:** Good placement, or also surface a
log strip on Overview/Alerts? **Answer:** _<!-- … -->_

### L-B4 🟢 Banner at 1024px (CR B-4)
Banner may wrap awkwardly at the 1024 lower breakpoint (I18). **Q:** Add a compact
banner variant <1100px, or is 1280px-first acceptable for the demo? **Answer:** _<!-- … -->_

### L-B5 🟢 AI-agent response (CR B-5) — DONE, confirm
vYY: "Execute skill / connect Claude Code" now opens a **richer modal** (preview of
the AI-agent remediation flow) instead of a toast. **Q:** Lean further into this
(the hackathon AI/Sui differentiator), or keep as a preview modal? **Answer:** _<!-- … -->_

---

## Part C — Deployment (Priority C / process)

### L-C1 🔴 Durable URL (CR D-1/D-3, P6)
Both deployments are **ephemeral ngrok / LAN**; GitHub Pages is blocked (private
repo). **Q (most impactful for the hackathon):** make the repo **public** (Pages auto-
deploys), pay for private Pages, or deploy to **Unstoppable + IPFS** now? Give access
if (b)/(c). **Answer:** _<!-- … -->_

### L-C2 🟢 Tracked-copy sync (CR D-2)
`delivery/delivery-v2/app` is rsynced from `.ignored/…` each round (now = vYY+1).
**Q:** Keep the dual-copy (gitignored dev + tracked CI), or move the canonical app
into a tracked path to remove sync risk? **Answer:** _<!-- … -->_

### L-C3 🟢 vX archive recoverability (CR D-4)
Archived builds (`dist-vX`, `dist-vYY`) live under gitignored `.ignored/` — lost if
the machine is wiped. **Q:** Acceptable (URLs logged in `deployments.md`), or also
commit a built artifact / tag per version? **Answer:** _<!-- … -->_

---

## Part D — Code quality (CR Part 4) — mostly DONE, confirm
- **L-D1 🟡 Adapter (Q-1)** — `src/lib/adapter.ts` created. Confirm the shape (Polish→
  English mapping home) is what you want. **Answer:** _<!-- … -->_
- **L-D2 🟢 `connectCmd` (Q-2)** — now `$derived` (reactive). ✅ confirm.
- **L-D3 🟢 Per-row decrypt (Q-3)** — `decryptedText` map + spinner. ✅ confirm.
- **L-D4 🟢 Timer/WS cleanup (Q-4)** — `onDestroy` clears timer + WS + keydown. ✅ confirm.
- **L-D5 🟢 MSSP tenant (Q-5)** — switcher now cycles tenants + `mock` tag. ✅ confirm.
- **L-D6 🟡 Polish wire keys (Q-6 / ADR-0006 TODO)** — adapter is the translation
  home; OpenAPI still Polish. **Q:** expose an English-keyed contract variant, or keep
  the adapter as the only boundary? **Answer:** _<!-- … -->_

---

## Part E — Forward (beyond CR)
- **L-E1 🟡 Charting/Tailwind (ADR-0002/0003)** — adopt ECharts/uPlot + Tailwind in
  v4? *Assumption: yes.* **Answer:** _<!-- … -->_
- **L-E2 🟡 Which Beta surface becomes REAL first?** rank: Compliance · Governance ·
  Integrations · Audit · Threat-Intel · MSSP. **Answer:** _<!-- … -->_
- **L-E3 🟢 CC\* UX-excellence pass** (separate thread, gen-v2 loop): run it for v4?
  **Answer:** _<!-- … -->_
- **L-E4 🟢 ⌘K palette (vYY+1 experiment)** — keep/extend (actions, recent, search
  data), or drop? **Answer:** _<!-- … -->_
- **L-E5 🟢 Incident status storage (I14)** — Walrus vs on-chain for real; when? **Answer:** _<!-- … -->_

---

## Part F — The 6 explicit blockers (CR Part 5) — consolidated
| # | Needed from you |
|---|---|
| P1 | Is `thorium.crypto` the real UD domain? (L-A8) |
| P2 | WS message schema / endpoint (L-A2) |
| P3 | Live profile in scope for v4? (L-A1) |
| P4 | Where is the existing incident tree? (L-A3) |
| P5 | Invite token format (L-A7) |
| P6 | Durable URL: repo public vs IPFS now? (L-C1) |

## ▶ Next-agent prompt
> Read `input/answers_v4.md` (the answers to this file) + `input/DEMO.md` +
> `fe_design_v3.md` + ADRs, then **follow `delivery/ITERATION-RUNBOOK.md`** verbatim
> to ship v4: archive the current build → write ADRs for sure calls → implement
> (interactive vs mock tiers; live = fill the adapter `TODO(live)` spots) → build →
> deploy ngrok + LAN, **verify against the user's resolver `192.168.0.1`** (never
> trycloudflare) → sync the tracked copy → update design/deployments/README/LIVE-DEMO
> → write the next transition Q&A in **short + long** → archive prompts verbatim →
> push with the remote URL **prominent in the last commit**. English-only, IPFS-safe,
> token-cautious (≤1–2 improve rounds, max 3 deployments / 2 preferred). Don't ask the
> user — decide and document; put residual ambiguity in the long Q&A.
