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

---
---

# ⬇ APPENDED 2026-06-20 — CR-2 + THE FINAL ITERATION (append-only)

> This document is **append-only**. Everything above is preserved. Below: **every**
> remark from `input/cr/cr-2.md` (so none is lost) + the Final-Iteration concerns.
> Each item: the finding · **Decision needed / Answer:** (fill inline).

## Part G — CR-2 Part 1: quality of the CR-1 fixes
- **G-R1-1 🟡 Adapter wired but inert.** `querySuiEvents` is **never called** (no
  polling loop); `connectLive` runs but `cfg.mock=true`/`wsUrl=""` make it a no-op and
  `applyLiveEvent` is empty. Flipping `mock:false` changes nothing silently. *Fix needs
  a `setInterval(querySuiEvents,10s)` stub gated on `!mock`, and an event→state map in
  `applyLiveEvent` (AgentRegistered→fleet/KPI · TelemetryReported→cpu/ram/sparkline ·
  IncidentReport→phase=isolated+drawer+banner · ClassificationReported→Talus).*
  **Answer:** _<!-- … -->_
- **G-R1-2 🔴 Walrus fetch URL is malformed.** `${gw}/${blobId}` with `gw=…/v1` and
  `blobId="walrus:blob:7f3a"` → `…/v1/walrus:blob:7f3a` (wrong path; aggregator is
  `/v1/blobs/{digest}`; `7f3a` isn't a real ~43-char digest; colon not URL-safe). The
  "real fetch" **always 404s** → fallback. **Decision:** (a) provide a real test blob
  digest + build `${gw}/blobs/${digest}`, or (b) be honest — drop the fetch guard and
  always use the labelled demo blob. **Answer:** _<!-- … -->_
- **G-R1-3 🟡 NOT-OK logs only on Telemetry tab.** The CC* primary view is
  Overview/Endpoints; a judge won't see the logs unless they navigate. Surface a log
  strip on Overview or in the drawer too. **Answer:** _<!-- … -->_
- **G-R1-4 🟢 Incident-tree row not clickable.** `t-root` is a `div`; clicking INC-991
  does nothing. Add `onclick → tab='overview'; drawerOpen=true` (1-line, high payoff).
  **Answer:** _<!-- … -->_
- **G-R1-5 🟡 Claude-Code modal disconnected.** Modal hardcodes `0x9aBc…01`; drawer
  shows `0x9aBcDeF…01` (different truncation). Use one constant. Reword "Mock — no
  agent invoked" → more aspirational ("the agent loop is defined…"). **Answer:** _<!-- … -->_
- **G-R1-6 🟢 "Mute" actually resets the whole scenario** (`reset()`): in a booth a
  passerby wipes the incident. Make Mute hide the banner only (`bannerVisible=false`),
  keep `phase=isolated`; move reset to its own button. **Answer:** _<!-- … -->_
- **G-R1-7 🟢 "Copy command" doesn't copy** — toast says "Copied" but no
  `navigator.clipboard.writeText`. **Answer:** _<!-- … -->_

## Part H — CR-2 Part 2: new code-quality findings (vYY)
- **H-N2-1 🔴 CSS dual-definitions / dead legacy CSS.** `.layout`, `.cards`, `.banner`,
  `.panel` defined twice; old top-tab `.nav`/`.tab` rules never render. Critically
  `.cards` resolves to `auto-fill 220px` (~4 cols) overriding the intended 2-col Talus/
  badges layout → sparse look on wide screens. Dedupe + mark/remove legacy. **Answer:** _<!-- … -->_
- **H-N2-2 🟡 ⌘K caps at 8 with no "N more" hint** — 12 commands hidden silently. **Answer:** _<!-- … -->_
- **H-N2-3 🟡 Demo loop too fast at the peak** — banner/drawer vanish after 4.5s; a
  first-time reader needs ~7s. Dwell ~8s + fade before reset. **Answer:** _<!-- … -->_
- **H-N2-4 🟡 No nav badge/count on active alert** — Incidents/Alerts rail items show no
  `1` badge during `isolated` (Datadog/Defender convention; discoverability). **Answer:** _<!-- … -->_
- **H-N2-5 🟢 `.topbar{position:sticky}` has no `top`** → behaves relative; verify it
  actually sticks on scroll in the rail layout. **Answer:** _<!-- … -->_
- **H-N2-6 🟢 ⌘K shows mock destinations unlabelled** — add `(mock)`/`(soon)` to palette
  labels to keep the two-fidelity honesty. **Answer:** _<!-- … -->_

## Part I — CR-2 Part 3: missed intentions from answers.md
- **I-M3-1 🔴 I14 incident status lifecycle absent.** Alerts shows hardcoded "Open"; no
  Ack/Escalate/Resolve; Audit Trail says "Acknowledged" but the badge stays "Open"
  (inconsistent). Add a mock **Acknowledge** (badge→Acked client-side + append audit).
  **Answer:** _<!-- … -->_
- **I-M3-2 🔴 I3 "your version" implies a comparison.** The "partly implemented" tree
  was never surfaced; vYY may diverge from existing code. (Mirrors L-A3.) **Answer:** _<!-- … -->_
- **I-M3-3 🟡 G7 Audit Trail static** — should populate as the analyst acts (e.g., open
  drawer in `isolated` → "Opened INC-991" appears). **Answer:** _<!-- … -->_
- **I-M3-4 🟡 G8 SIEM rows all "mock"** — undifferentiated. Show Splunk "Connected
  (mock)", others "Configure"; on `isolated`, Splunk flashes "1 alert forwarded". **Answer:** _<!-- … -->_
- **I-M3-5 🟡 G2 Governance DAO vote static** — add a conditional card after `isolated`:
  "New vote: emergency threshold 0.85→0.75 (auto-triggered by INC-991)". **Answer:** _<!-- … -->_
- **I-M3-6 🟡 I13 empty/loading/error states still missing** on most tabs; `offline`
  toggles a lockbar but no panel reflects offline (Chain Activity should show
  "⚠ Disconnected from Sui RPC"). **Answer:** _<!-- … -->_
- **I-M3-7 🟢 U2 booth framing** — demo mode lacks a "live demo running — click to take
  over" overlay for cold passersby. **Answer:** _<!-- … -->_

## Part J — CR-2 Part 4: UI interaction gaps
- **J-F4-1 🔴 Incident tree → drawer** (biggest demo gap; mirrors G-R1-4). **Answer:** _<!-- … -->_
- **J-F4-2 🔴 Alerts "Acknowledge" missing** — only tab where the analyst should act has
  no action; add Ack → status Acked + audit append + banner red→amber. **Answer:** _<!-- … -->_
- **J-F4-3 🟡 "Connect Wallet" dead button** — no tag/feedback; mock wallet selector or
  a toast. **Answer:** _<!-- … -->_
- **J-F4-4 🟡 Onboarding has no "Simulate registration"** tie-in to the CC* stepper
  (`phase='connected'`) — would connect onboarding to DEMO.md step 1. **Answer:** _<!-- … -->_
- **J-F4-5 🟡 KPI tiles don't animate on phase change** (CR-1 B-2, still open) — count-up/
  flash on "new agent connected". **Answer:** _<!-- … -->_
- **J-F4-6 🟡 Offline Lockdown doesn't affect data panels** (G11) — Chain/Telemetry/
  rail-foot should reflect offline/stale. **Answer:** _<!-- … -->_
- **J-F4-7 🟢 On-chain evidence is one static line** — should accumulate per phase like
  the timeline. **Answer:** _<!-- … -->_
- **J-F4-8 🟢 ⌘K lacks "View incident"/"Acknowledge" commands** (only when compromised).
  **Answer:** _<!-- … -->_

## Part K — CR-2 Part 5: style/architecture
- **K-S5-1 🟡 `App.svelte` becoming a monolith** (~340 script + ~230 template, all 18
  tabs inline). Extract `lib/tabs/*.svelte` + a scenario store. Not blocking, but each
  round compounds. **Answer:** _<!-- … -->_
- **K-S5-2 🟢 Inline styles in template** → move to utility classes. **Answer:** _<!-- … -->_
- **K-S5-3 🟢 CR-iteration comments in `app.css`** should be removed once stable
  (history belongs in ADRs). **Answer:** _<!-- … -->_

## Part L2 — CR-2 Part 6: explicit decisions needed (Q1–Q7)
| # | Question | Why it blocks | **Answer** |
|---|---|---|---|
| C2-Q1 | Real Walrus blob IDs for fixtures? | else `fetchWalrusBlob` can never succeed | _<!-- … -->_ |
| C2-Q2 | Click INC-991 → open drawer? | high UX, trivial | _<!-- … -->_ |
| C2-Q3 | "Mute" = dismiss banner without reset? | presenter/booth UX | _<!-- … -->_ |
| C2-Q4 | Interactive incident status (Open/Ack/Resolved)? | completes analyst loop | _<!-- … -->_ |
| C2-Q5 | "Connect Wallet" → mock selector or toast? | dead button in primary nav | _<!-- … -->_ |
| C2-Q6 | Demo dwell 8s vs 4.5s at CRITICAL? | loop too fast for booth | _<!-- … -->_ |
| C2-Q7 | ⌘K palette: keep as experiment or promote to main? | ADR-0009 marks it experiment | _<!-- … -->_ |

## Part M — CR-2 Part 7: MUST PRESERVE (do not regress)
adapter.ts structure · per-row `decryptedText`+spinner · `$derived connectCmd` ·
`onDestroy` cleanup · grey connected sparkline · Claude-Code modal (build on it) ·
MSSP tenant cycling · ⌘K palette (autofocus + Escape) · invite token `inv_8Qm4…` ·
NOT-OK logs panel. **(Carry this list into every future ADR's "consequences".)**
