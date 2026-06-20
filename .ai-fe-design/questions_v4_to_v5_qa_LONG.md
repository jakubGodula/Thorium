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
`mock:false` as a profile. **Answer:** You would have to check the https://github.com/jakubGodula/Mowa for the instructions on the language that the backend is written in and then connect the backend from https://github.com/jakubGodula/Thorium/tree/experimental by compiling it with that language, please keep in mid that this requires sui-cli and cargo.

### L-A2 🔴 WebSocket schema + source (CR A-2, P2)
vYY marks receivers (Fleet Telemetry, Chain Activity badges; `applyLiveEvent` stub).
You said the WS "is already implemented." **Q:** Where (agent/backend)? **Provide the
WS URL + message schema** (event types → fields) so `applyLiveEvent` maps to
phase/telemetry/incident state precisely. Same as above. 

### L-A3 🟡 Incident tree — existing vs vYY (CR A-3, P4)
vYY highlights the active CC* incident (INC-991 pulses when compromised) + shows
correlated-count. **Q:** You said a tree is "partly implemented" — point to that code;
should vYY align/supersede? Do you want expand/collapse + drill-down, or is the
2-level kill-chain grouping enough for the demo? Same as above. you can find it there and most likely make iut much nicer. 

### L-A4 🟡 Walrus/Seal decrypt fidelity (CR A-4)
vYY now does a **real `fetch(walrusGateway/blobId)`** per row (with spinner +
graceful demo fallback). No `@mysten/walrus` SDK yet. **Q:** For the demo, is the
real-fetch-with-fallback enough, or wire the actual Seal SDK + a real test blob? You can include the new context of the backend and use it.

### L-A5 🟢 Talus correlation liveliness (CR A-5)
Card 1 reacts to the scenario; cards 2–3 are static. **Q:** Make cards 2–3 react to
the CC* phase (glow when kill-chain active), or leave static? **Answer:** let's make first 2 cards static and then the rest dynamic, so that the demo can include more than one endpoint that is being defended/targeted.

### L-A6 🟡 Personas placement (CR A-6)
"Roles & Models" sits under the **Platform** rail group. **Q:** Keep it there, or
promote to a top-level nav item for the demo flow? **Answer:** Keep it there.

### L-A7 🟢 Invite token format (CR A-7, P5)
vYY uses `inv_8Qm4Zr2Tn9Kx7Wb3Yc6Hf1Ld` + a `demo` tag (replaced `…-MOCK`). **Q:**
Is this format fine, or match a specific real token format/length? **Answer:** Whaterev will do for now. Just mark it as to be improved or something.

### L-A8 🟡 UD domain + routing (CR A-8, P1)
`config.json` `unstoppableDomain: "thorium.crypto"`; footer/onboarding use it.
`vite.config` `base:'./'` is IPFS-safe; the app is single-page (no router) — ADR-0008
mentioned hash routing but none is configured. **Q1:** Is `thorium.crypto` the real
registered domain? **Q2:** Single-page (no router) OK for the demo, or add hash
routing now (deep-links beyond `?cc=1`)? **Answer:** thorium.her

---

## Part B — vs CC* `DEMO.md` (Priority B)

### L-B1 🟡 "Connect" phase clarity (CR B-1)
vYY: connect phase now shows a **grey/pending sparkline** (was misleading green). The
drawer doesn't auto-open until `isolated`. **Q:** Auto-open the drawer briefly at
`connected` to show "attested", or keep it closed until the alert? **Answer:** I believe that you will find your answer in the experimental brunch.

### L-B2 🟢 Healthy-phase "Sui interacts" moment (CR B-2)
Chain Activity shows `AgentRegistered`/`TelemetryReported` in healthy phase, but the
Overview KPIs don't change. **Q:** Add a subtle "new agent connected" flash/KPI tick
at `healthy` to make the on-chain interaction pop? **Answer:** You can, thank you.

### L-B3 🟡 NOT-OK logs (CR B-3) — DONE, confirm
vYY added a **Recent logs** panel (eBPF/FIM/syslog, red when compromised) on Fleet
Telemetry, satisfying "NOT-OK log visible". **Q:** Good placement, or also surface a
log strip on Overview/Alerts? **Answer:** Change the "TREND" column in this page to "THREAT LEVEL"

### L-B4 🟢 Banner at 1024px (CR B-4)
Banner may wrap awkwardly at the 1024 lower breakpoint (I18). **Q:** Add a compact
banner variant <1100px, or is 1280px-first acceptable for the demo? **Answer:** It's acceptable, but add it please,other people might want to run it on smaller resolution monitors.

### L-B5 🟢 AI-agent response (CR B-5) — DONE, confirm
vYY: "Execute skill / connect Claude Code" now opens a **richer modal** (preview of
the AI-agent remediation flow) instead of a toast. **Q:** Lean further into this
(the hackathon AI/Sui differentiator), or keep as a preview modal? **Answer:** toast

---

## Part C — Deployment (Priority C / process)

### L-C1 🔴 Durable URL (CR D-1/D-3, P6)
Both deployments are **ephemeral ngrok / LAN**; GitHub Pages is blocked (private
repo). **Q (most impactful for the hackathon):** make the repo **public** (Pages auto-
deploys), pay for private Pages, or deploy to **Unstoppable + IPFS** now? Give access
if (b)/(c). **Answer:** Give me a hash to the site IPFS.

### L-C2 🟢 Tracked-copy sync (CR D-2)
`delivery/delivery-v2/app` is rsynced from `.ignored/…` each round (now = vYY+1).
**Q:** Keep the dual-copy (gitignored dev + tracked CI), or move the canonical app
into a tracked path to remove sync risk? **Answer:** tracked path pls.

### L-C3 🟢 vX archive recoverability (CR D-4)
Archived builds (`dist-vX`, `dist-vYY`) live under gitignored `.ignored/` — lost if
the machine is wiped. **Q:** Acceptable (URLs logged in `deployments.md`), or also
commit a built artifact / tag per version? **Answer:** _<!-- … -->_

---

## Part D — Code quality (CR Part 4) — mostly DONE, confirm
- **L-D1 🟡 Adapter (Q-1)** — `src/lib/adapter.ts` created. Confirm the shape (Polish→
  English mapping home) is what you want. **Answer:** Yes.
- **L-D2 🟢 `connectCmd` (Q-2)** — now `$derived` (reactive). ✅ confirm.
- **L-D3 🟢 Per-row decrypt (Q-3)** — `decryptedText` map + spinner. ✅ confirm.
- **L-D4 🟢 Timer/WS cleanup (Q-4)** — `onDestroy` clears timer + WS + keydown. ✅ confirm.
- **L-D5 🟢 MSSP tenant (Q-5)** — switcher now cycles tenants + `mock` tag. ✅ confirm.
- **L-D6 🟡 Polish wire keys (Q-6 / ADR-0006 TODO)** — adapter is the translation
  home; OpenAPI still Polish. **Q:** expose an English-keyed contract variant, or keep
  the adapter as the only boundary? **Answer:** We don;t need anything else than the English language in the UI for the demo.

---

## Part E — Forward (beyond CR)
- **L-E1 🟡 Charting/Tailwind (ADR-0002/0003)** — adopt ECharts/uPlot + Tailwind in
  v4? *Assumption: yes.* **Answer:** Yes.
- **L-E2 🟡 Which Beta surface becomes REAL first?** rank: Compliance · Governance ·
  Integrations · Audit · Threat-Intel · MSSP. **Answer:** Threat Intel
- **L-E3 🟢 CC\* UX-excellence pass** (separate thread, gen-v2 loop): run it for v4?
  **Answer:** Yes.
- **L-E4 🟢 ⌘K palette (vYY+1 experiment)** — keep/extend (actions, recent, search
  data), or drop? **Answer:** Keep.
- **L-E5 🟢 Incident status storage (I14)** — Walrus vs on-chain for real; when? **Answer:** Let's do Walrus now. Try to ensure to do it properly with Mowa languyage from the context that I provided above.

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

---

# Part N — THE FINAL ITERATION concerns (the prompt's CONTENT 1–10)

## N1 🔴 Is this the single most important rule, every iteration?
Confirm the priority order is permanent and overrides everything:
> A) `input/answers.md` ⇒ must-have, the **first principle**, always most important in
> the current iteration — **follow regardless.**
> B) **CC\*** Demo requirements — in the context of A).
> C) prior docs / **the Sui hackathon contract** / existing codebase — **optional**;
> decide; always in the context of A) then B).
**Answer:** _<!-- confirm / amend -->_

## N2 🟡 CC* definition consistency — does the demo match the spec & answers?
Cross-check (my analysis in `FINAL-ITERATION-STEPS/03-assessment.md`): the CC* path in
`input/DEMO.md` vs the shipped vYY+1 build vs `input/answers.md` is broadly aligned, but
these need confirmation (≤15):
1. **"Observed pod"** — `DEMO.md` says generic pod; `answers.md C2` says K8s (Lithium,
   non-functional UI). The build shows `prod-eu1/prod/edge` namespace columns. Is the K8s
   framing correct for the demo, or revert to generic host? **A:** _<!-- -->_
2. **Attack vector** — kernel exploit *and/or* DDoS? The build shows kernel exploit
   (`curl|bash`). Keep kernel-only, or also show a DDoS signal? **A:** _<!-- -->_
3. **"Healthy → Sui interacts"** — is showing `AgentRegistered`+`TelemetryReported` in
   Chain Activity sufficient as "Sui contract interacts", or do you want a visible
   write-tx animation? **A:** _<!-- -->_
4. **"NOT WORTHY"** — `is_active=false` + Isolated badge. Is that the exact on-chain
   semantic, or a distinct `worthiness` field on `AgentIdentity`? **A:** _<!-- -->_
5. **Auto-isolation timing** — the "⚡ 2s" claim: is 2s the real target SLA, or
   illustrative? **A:** _<!-- -->_
6. **Alert presentation** — confirmed #1 banner→drawer (answers C3). Final for the demo? **A:** _<!-- -->_
7. **Response actions** — all placeholders (answers I19). Confirm none are live tomorrow. **A:** _<!-- -->_
8. **Who triggers the demo** — presenter clicks "Run CC*", or autoplay/booth, or both? **A:** _<!-- -->_
9. **Second pod (ws-07 lateral)** — keep the background lateral-movement incident, or
   focus solely on alma9-edge-01? **A:** _<!-- -->_
10. **Evidence on Walrus** — should the demo show a real frozen-to-Walrus action, or is
    the sealed-row mock enough (see G-R1-2)? **A:** _<!-- -->_

## N3 🟡 Was the Alfa/Beta scope precisely clarified?
> **Alfa** — only the critical part of the app, Defender-like, Walrus look & feel,
> ELK/Datadog capability, blockchain domain.
> **Beta** — Alfa **+** the two big files (`roadmap_en.html`, `presentation_en.html`).
The shipped build is "Alfa + Beta-as-mock surfaces" (per answers Part 3). Confirm: is the
demo's scope **Alfa-with-mock-Beta-tabs** the intended final scope, or pure Alfa, or
fully-implemented Beta? Which surfaces (if any) cross the line to "real" for tomorrow? **A:** _<!-- -->_

## N4 🔴 Is the last deployment fit for the demo tomorrow? What must improve?
My take is in `FINAL-ITERATION-STEPS/03-assessment.md`. Top must-fix-before-demo (from
CR-2): **J-F4-1 tree→drawer**, **J-F4-2 Alerts Ack**, **G-R1-6 Mute=reset footgun**,
**H-N2-3 demo dwell too fast**, **G-R1-7 copy-doesn't-copy**, **J-F4-3 dead Wallet
button**, **H-N2-1 `.cards` sparse layout**. Confirm priority / add/remove. **A:** _<!-- -->_

## N5 🟡 UX & quality of UI interaction — good enough?
Beyond the CR-2 interaction gaps (Part J): is the overall interaction model
(left-rail + CC* drawer + ⌘K) the right one, or do you want the Part-4 alternative CC*
presentations (war-room takeover / map beacon)? Any specific screen that feels weak? **A:** _<!-- -->_

## N6 🟡 Mobile / responsive / "advanced enough" / good-looking?
Current build is **desktop-first 1280px+** (answer I18); no mobile/responsive work; the
232px rail + content reflows but isn't tested <1100px (CR L-B4, H-N2-1). For tomorrow:
is desktop-only acceptable, or do you need tablet/mobile? Is the visual bar (dark SOC,
Stripe-grade alert) sufficient, or push further (Tailwind+ECharts, ADR-0002/0003)? **A:** _<!-- -->_

## N7 🟡 Mock backend — is its scope familiar & integration-ready? (≤15)
**Important for tomorrow's real/mock backend integration.** Today the demo reads
**client-side fixtures** (`scenario.ts`); the Prism mock (`demo-gen/gen-v1/openapi`) is
defined but **not run** in the deployed app; the adapter (`lib/adapter.ts`) is the seam.
Please confirm:
1. Tomorrow: integrate **real** backend, the **Prism** OpenAPI mock, or a **new** mock? **A:** _<!-- -->_
2. Is the **OpenAPI contract** (`thorium-xdr.openapi.yaml`) the agreed shape, or will the
   real backend differ? (Polish wire keys — Q-6 still open.) **A:** _<!-- -->_
3. **WS endpoint + message schema** (G-R1-1 / L-A2 / P2) — provide it. **A:** _<!-- -->_
4. **Sui RPC URL** (L-A1) + which events the FE should `queryEvents`. **A:** _<!-- -->_
5. **Walrus** — real gateway + real blob digests (G-R1-2), or keep sealed-mock? **A:** _<!-- -->_
6. **Auth** — does the backend expect a wallet-signed session, an API key, or open
   (public contracts)? **A:** _<!-- -->_
7. Is the mock backend expected to be **secure** (authn/z, CORS, rate-limit) for a public
   demo, or is it throwaway/local-only? **A:** _<!-- -->_
8. Is it **configurable enough** via `config.json` (`agentApiBase/suiRpcUrl/wsUrl/
   walrusGateway/mock`), or are more knobs needed (env, per-tenant)? **A:** _<!-- -->_
9. Should the demo **degrade gracefully** when the backend is down (offline-lockbar +
   stale data — see I-M3-6/J-F4-6), or hard-fail? **A:** _<!-- -->_
10. Who owns the backend contract tomorrow (you / a teammate / me)? Where's its repo? **A:** _<!-- -->_

## N8 🟢 Are the README, audit logs, and namings OK?
My review in `03-assessment.md`. Specifically: are the version names clear (design
v1/v2/v3 · deployments vX/vX+1/vYY/vYY+1 · delivery-v1/v2/v3 · gen-v1/gen-v2)? Is
`.ai-fe-design/` discoverable? Anything to rename before the colleague arrives? **A:** _<!-- -->_

## N9 🟢 Can a colleague locally generate the frontend? Similar to deployed history?
The path is `delivery/ITERATION-RUNBOOK.md` + `demo-gen/gen-v2/` (skill `/fe-demo-gen`).
A local `npm run build && npx vite preview` of `delivery-v2/app` (the tracked copy)
reproduces the **vYY+1** build (it's the synced source). Confirm this is acceptable, or
do you want a one-command `make demo`? **A:** _<!-- -->_

## N10 🟢 Can the colleague find things in <1 minute?
Self-assessed in `03-assessment.md` (a) deployments → `deployments.md` + `LIVE-DEMO.md`
(yes) · (b) generate FE from design → RUNBOOK/gen-v2 (yes; reproduces vYY+1) · (c) read
skills/procedures, AI-friendly context → `AGENTS.md`+`ITERATION-RUNBOOK.md`+`demo-gen`
(yes) · (d) audit/logs/quality → `ai_internal_audit_log/`+ADRs (yes) · (e) alignment &
best deployment → my answer in the assessment. **Confirm or correct each. A:** _<!-- -->_

---

# Part O — Brand, theming & look-and-feel (PREFERENCE MATRIX)

> The biggest subjective call left. Today's identity: dark SOC palette, **Thorium cyan
> `#38bdf8` → Walrus mint `#5eead4`** gradient, shield+`Th`-atom mark
> (`brand/thorium-mark.svg`), system font + JetBrains-Mono for hashes, left-rail IA, a
> Stripe-style CC* banner→drawer. **Is that right — or should we regenerate the brand/
> theme?**

## O1 🟡 Preference matrix — rate each aspect
For each row mark one: **Keep** · **Tweak** · **Regenerate** (+ a note).

| # | Aspect | Keep | Tweak | Regenerate | Note |
|---|---|---|---|---|---|
| O-a | **Brand identity** (name mark, shield+Th atom, logo) | ☐ | ☐ | ☐ | |
| O-b | **Color theme** (cyan→mint on deep navy) | ☐ | ☐ | ☐ | |
| O-c | **Typography** (system UI + mono) | ☐ | ☐ | ☐ | |
| O-d | **Overall look & feel / "alikeness"** | ☐ | ☐ | ☐ | |
| O-e | **Density & layout** (left-rail SOC console) | ☐ | ☐ | ☐ | |
| O-f | **CC\* alert styling** (banner→drawer) | ☐ | ☐ | ☐ | |
| O-g | **Motion** (pulse, slide-in, glow) | ☐ | ☐ | ☐ | |

## O2 🔴 Is the brand satisfactory, or generate a different one?
Overall: **(a) satisfactory as-is** · **(b) generate alternative brand/theme options to
choose from** · **(c) I have a specific brand to apply.** If (b): how many variants, and
any direction (more web3-neon / more enterprise-muted / more Walrus-mint / a light
theme)? **A:** _<!-- -->_

## O3 🟡 Precise look-and-feel questions
1. **Blockchain domain & language** — does the UI *feel* on-chain enough (tx digests,
   object IDs, "on-chain", wallet-first)? Should it lean harder into a **wallet /
   Binance / web3-exchange** idiom (wallet-connect front-and-centre, token balances,
   network pills, gas), or stay SOC-tool-first with chain as a layer? **A:** _<!-- -->_
2. **ELK / Kibana alikeness** — is the data-density / dashboard feel close to ELK, and is
   that the right reference? Too dense, too sparse, or right? **A:** _<!-- -->_
3. **Windows / Microsoft Defender alikeness** — is the left-rail + incident console close
   to Defender, and is that good for the audience, or does it feel too "Microsoft"? **A:** _<!-- -->_
4. **In your own words** — free field: what feels off, what feels great, any reference
   product you want us to match. **A:** _<!-- -->_
5. **Stripe-grade UX bar** — does the interaction quality (clarity, hierarchy, motion,
   empty states, micro-interactions) reach Stripe / Linear / high-end SaaS, or a notch
   below? Where specifically? **A:** _<!-- -->_
6. **Different direction entirely?** — would you lean elsewhere (3D Spatial SOC, a
   terminal/hacker aesthetic, glassmorphism web3, a light theme)? **A:** _<!-- -->_
7. **How close is the *look* to demo-ready** (1–10), and what single visual change would
   move it up the most? **A:** _<!-- -->_

> If you pick **Regenerate** anywhere, the next agent runs the gen-v2 loop as a brand/
> theme pass (`demo-gen/gen-v2/improve-loop.md`) → 2–3 themed variants + a recommendation,
> then re-skins the build via the design tokens (`brand/` + `app.css` theme vars).

---
---

# ⬇ APPENDED 2026-06-20 — Part P · CR-3 FINAL RFI REFINEMENTS (append-only)

> **Why this section exists:** this file is the **ultimate, precise RFI for the frontend
> vision**, and it is **append-only** (nothing above is changed). Before the *final*
> vision is locked, two CR-3 reviews of the DDD (v5) build —
> [`input/cr/cr-3-opus-4-8.md`](./input/cr/cr-3-opus-4-8.md) (Opus 4.8) +
> [`input/cr/cr-3-claude-sonnet-4-6.md`](./input/cr/cr-3-claude-sonnet-4-6.md) (Sonnet 4.6)
> — surfaced remarks that must be folded back into the RFI so no ambiguity survives. Each
> item is a **clarification of an existing answer** or a **decision the RFI still lacks**.
> Answer inline. *(O = Opus · S = Sonnet · B = both converged.)*
>
> The operational, per-finding ledger lives in
> [`questions_v5_to_v6_qa_LONG.md`](./questions_v5_to_v6_qa_LONG.md); this is the
> **vision-level** distillation kept inside the RFI itself.

## P.0 🔴 The governing rule (B · CR-3 #U1/Q0) — never explicitly confirmed
The whole build assumes priority **A `answers.md` → B CC\* `DEMO.md` → C prior docs / Sui
contract**. Confirm it is **permanent**, or state where CC\* may override an answer. *Every
agent decision traces back to this.* **Answer:** _<!-- -->_

## P.1 — Clarify YOUR Part A–E answers where the build diverged (highest signal)
> Both reviewers' #1 class: *you answered, the code shipped something else.* These refine
> the RFI's existing answers — please confirm intent.
- **P.1a 🔴 (B) Domain (refines L-A8 "thorium.her").** `.her` is **not a valid Unstoppable
  TLD** (UD = `.crypto/.x/.nft/.wallet/.hi/…`) and the build still ships `thorium.crypto`.
  **What is the real domain** the footer + onboarding `curl https://<domain>/agent` should
  show? **Answer:** _<!-- -->_
- **P.1b 🔴 (B) "Do Walrus **now**" (refines L-E5).** Shipped as **client-side state only**
  (Ack/Resolve toasts "→ Walrus audit"; no Walrus write, no Mowa). Did you mean a **real**
  browser/Mowa Walrus write **now** (needs `@mysten/walrus` or the Mowa backend + sui-cli/
  cargo), or is the client-side mock acceptable for the demo (Walrus post-demo)? **Answer:** _<!-- -->_
- **P.1c 🔴 (B) IPFS hash (refines L-C1).** CID `bafybeici77…czq` is **unpinned** (only-hash)
  → it will **not open** on a public gateway. For a durable, sendable link, **pin it** (a
  Pinata / web3.storage token, or your IPFS node) — or is the hash-only artifact enough and
  the live URL stays ngrok/LAN? **Answer:** _<!-- -->_
- **P.1d 🔴 (B) Talus "first 2 cards static" (refines L-A5).** Card **1 reacts** to the
  attack, yet the panel caption literally says "first two cards are fixed model status" —
  a self-contradiction a judge will catch. Should card 1 be a **static AI-model card** (with
  the endpoint reactions on cards 3–4), or was "first 2 static" approximate (then I just fix
  the caption)? **Answer:** _<!-- -->_
- **P.1e 🔴 (S) KPI flash (refines L-B2 "you can, thank you").** `kpiFlash` is set/cleared in
  state but **never rendered** (no `class:flash`, no CSS) — so L-B2 is effectively un-shipped
  though `fe_design_v5.md` calls it done. **Confirm you want the visual flash** (1-line + a
  keyframe). **Answer:** _<!-- -->_
- **P.1f 🔴 (B) Walrus fetch URL (CR-2 G-R1-2, still unfixed).** `${gw}/${blobId}` →
  `…/v1/walrus:blob:7f3a` is malformed (wrong path, unsafe colon, `7f3a` not a real digest);
  inert today but 404s the moment `mock:false`. **(a)** real testnet digest + `/blobs/{digest}`
  or **(b)** drop the fetch and own the demo blob honestly? **Answer:** _<!-- -->_

## P.2 🔴 Answer Parts G–O **once** (the real root of ambiguity · B)
The build made **~25–30 judgment calls** purely because **Parts G–O above carry no
answers** (CR-2 items, N1 priority, N2 CC\*-consistency, N3 scope, **Part O brand**). One
pass — even a blanket *"use your judgment, I trust the defaults"* — **permanently removes**
the misunderstanding risk. Will you (a) answer G–O, or (b) bless the defaults? **Answer:** _<!-- -->_

## P.3 🔴 `/init` self-description (B · the "repo misdescribes itself" risk)
`AGENTS.md` + `ITERATION-RUNBOOK.md` pointed **three versions back** (v2 / `…-v2`) — a fresh
agent would work on the wrong branch/design. **I refreshed them to v5 / `experimental-aw-fe-v3`
with a self-updating "Current state" header.** Confirm that approach (vs pinning historical).
Also: is `my-app/` (a stray root SvelteKit scaffold) **deletable/ignorable**, and do you want
a root "the app is HERE → `delivery/delivery-v2/app`" pointer? **Answer:** _<!-- -->_

## P.4 🟡 CR-2 items answered-in-spirit but **not in the code** (B) — tick what lands
SIEM differentiation (Splunk "Connected"+"1 forwarded" on isolate) · Governance reactive
DAO card after isolate · Offline state actually changing Chain/Telemetry panels ·
On-chain evidence accumulating per phase · empty/loading states on idle tabs · onboarding
"Simulate registration" → CC\* step 1 · the booth "live demo running" overlay · the `.cards`
2-col Talus layout (still ~4 sparse cols). **Which of these are in the final vision?** **Answer:** _<!-- -->_

## P.5 🟡 Dead code cleanup (S) — confirm
OK to remove: static `auditTrail` export, `fleet()` (superseded by `fleetAt`), the unused
`defended` derive (or wire it into the Alerts row), legacy `.nav`/`.tab` CSS, the duplicate
`.cards{1fr 1fr}`, and the dead `{#if claudeModal}` 20-line block (L-B5 = toast)? **Answer:** _<!-- -->_

## P.6 🔴 The live-backend track (B) — the #1 technical risk for the final vision
`querySuiEvents` is defined but **never called** (no polling loop) and the WS path is a
no-op — there is **no live data path**, only the seam. To make the final vision *real* I
need: **(a)** Mowa backend build/run cmds or a running endpoint; **(b)** WS endpoint +
**message schema** (event type → fields); **(c)** Sui RPC URL + which `queryEvents`
(module/type); **(d)** real **Walrus** gateway + blob digests; **(e)** auth model
(wallet-signed / API key / open); **(f)** **who owns the backend repo** tomorrow; **(g)**
must a public-demo backend be auth'd/CORS/rate-limited, or local-only? **Answer:** _<!-- -->_

## P.7 🟡 CC\* semantics, scope & brand — the vision-defining calls (B)
- **P.7a CC\* (N2):** K8s framing (namespace cols/Lithium) correct, or revert to generic
  host? · `NOT WORTHY` = `is_active=false` or a distinct on-chain `worthiness` field? · who
  triggers (presenter / autoplay-booth / both)? · kernel-only or also DDoS? **Answer:** _<!-- -->_
- **P.7b Scope (N3):** final demo = **Alfa + mock-Beta tabs** (current) / **pure Alfa** /
  **fully-implemented Beta**? (If pure Alfa, ~half the left-rail is clutter.) **Answer:** _<!-- -->_
- **P.7c Brand (Part O):** Keep / Tweak / **Regenerate** the theme, mark, typography, CC\*
  alert styling, motion? The build assumes **Keep**; "Regenerate" triggers a brand pass
  *before* more features. **Answer:** _<!-- -->_

## P.8 🟢 The two questions that actually define "the FINAL vision"
- **P.8a** When you say *final* frontend vision — is it (i) a **polished mock demo** for the
  hackathon (no live backend, durable IPFS URL), or (ii) a **wired product** against the real
  Mowa/Sui backend? The whole v6 plan forks here. **Answer:** _<!-- -->_
- **P.8b** What is the **one** thing that, if wrong, makes the demo fail for you tomorrow?
  (So we protect it above all.) **Answer:** _<!-- -->_

> **Net (both reviewers agree):** the build is demo-ready; the *understanding* is not yet
> pinned. The blockers are **not in the Svelte** — they are the unanswered Parts G–O/P, the
> three stated-but-unlanded answers (domain, Walrus-now, IPFS-pin), and the live-backend
> spec. Answer P.0–P.8 and the next pass yields the **final** frontend vision.