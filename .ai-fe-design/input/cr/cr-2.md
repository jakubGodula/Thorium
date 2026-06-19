# Code Review — CR-2
**Scope:** vYY (CR-1 fixes) + vYY+1 (⌘K experiment) vs `input/answers.md` (A), `input/DEMO.md` CC* (B), and prior CR-1  
**Date:** 2026-06-20  
**Reviewer:** Claude Sonnet 4.6  
**Priority:** A (answers.md) → B (CC* DEMO.md) → CR-1 follow-up → new findings

---

## Executive summary

The vYY build correctly addressed the majority of CR-1's mechanical fixes (adapter seam, per-row decrypt, WS markers, timer cleanup, MSSP cycling, invite token, grey sparkline, logs panel, Claude Code modal). The ⌘K palette (vYY+1) is a clean addition. However, several implementations are surface-deep: the Walrus fetch URL is malformed and will always fall back, the WS path is a chain of no-ops, and there are new interaction gaps introduced in vYY that did not exist before. This review also surfaces missed intentions from `answers.md` that neither vX+1 nor vYY addressed.

---

## PART 1 — CR-1 items: quality assessment of what was implemented

### R1-1 ✅ → 🟡 Adapter seam (`src/lib/adapter.ts`) — shape is right, wiring is incomplete

**What was done:** `adapter.ts` exists with `connectLive`, `querySuiEvents`, `fetchWalrusBlob`. CR-1 A-1/Q-1 is satisfied structurally.

**New finding — `querySuiEvents` is never called from `App.svelte`:** The function is defined and has a correct `TODO(live)` comment, but no caller exists in the app. There is no polling loop. When `mock:false` is set and `suiRpcUrl` is provided, nothing would change — the chain data on the screen is still the client-side fixture. The polling loop (ADR-0001: Sui at 10s intervals) needs a home even as a stub: a `setInterval(async () => { const evs = await querySuiEvents(cfg); applyEvents(evs) }, 10_000)` in `onMount`, gated by `!cfg.mock`. Without it, flipping `mock:false` is silent.

**New finding — `connectLive` is called but dead by design:** `connectLive(cfg, applyLiveEvent)` is called in `onMount`. But `cfg.mock = true` always (config.json ships with `mock:true`) and `cfg.wsUrl = ""` (empty string). Inside `connectLive`: `if (cfg.mock || !cfg.wsUrl) return () => {}`. So the WS path is never attempted. This is correct behavior, but `applyLiveEvent` receives `_e: LiveEvent` (underscore prefix = intentionally unused), meaning even if the WS connected, the app state would not change. The stub needs at minimum a comment mapping which state variables each event type drives:
```
// AgentRegistered   → push to fleet store, show "new agent" KPI flash (CR L-B2)
// TelemetryReported → update pod cpu/ram/disk + sparkline
// IncidentReport    → set phase = 'isolated', open drawer, CC* banner
// ClassificationReported → update Talus score card
```
Without this map, the next agent who fills in `applyLiveEvent` has no contract to follow.

---

### R1-2 ✅ → 🔴 Walrus fetch URL is structurally wrong

**What was done:** `fetchWalrusBlob` attempts `fetch(${gw}/${blobId})` where `gw = "https://aggregator.walrus-testnet.walrus.space/v1"` and `blobId = "walrus:blob:7f3a"`.

**Bug:** The constructed URL is `https://aggregator.walrus-testnet.walrus.space/v1/walrus:blob:7f3a`.
- The Walrus aggregator API path is `/v1/blobs/{digest}`, not `/${blobId}` verbatim.
- The `walrus:blob:` prefix is a display/reference format. The actual digest/ID would be a base58 or base64url string (~43 chars), not `7f3a`.
- The colon in `walrus:blob:7f3a` is not URL-safe without encoding; `fetch()` may reject or produce a malformed URL.

**Consequence:** The "real fetch" will always 404 (or error) and fall through to the demo blob. The "`real fetch + graceful fallback`" narrative in ADR-0009 is technically inaccurate — there is no real-fetch path that can succeed with the current data.

**Fix needed:** Either:  
(a) Use a real Walrus blob digest (e.g., a pinned test blob from the Walrus testnet) and construct `${gw}/blobs/${digest}` properly, or  
(b) Be honest: remove `gw && !cfg.mock` guard and always use the fallback until real blob IDs are provided. The spinner + "decrypted (Seal, demo)" label is more honest than a fetch that silently 404s.

---

### R1-3 ✅ → 🟡 `recentLogs` panel satisfies B-3 only on the Telemetry tab

**What was done:** A "Recent logs" panel appears at the bottom of the Fleet Telemetry tab, turns red and shows eBPF/FIM events when `compromised`.

**Missed intention from DEMO.md §5:** "The NOT-OK log + telemetry is clearly visible in the frontend" — a judge watching the CC* stepper from the default **Overview/Endpoints** tab will never see the logs panel unless they actively navigate to Fleet Telemetry. The primary CC* view is Overview/Endpoints (where the banner and drawer are). The log evidence should be surfaced there as well, even as a small collapsed "Recent activity" strip below the endpoint table or inside the Incident Command drawer (the drawer currently shows `eBPF execve: curl…` only in the timeline, which is good, but adding a raw log stream would reinforce the "logs visible" criterion).

---

### R1-4 ✅ → 🟢 Incident tree highlights INC-991 correctly

**What was done:** `class:t-active={live}` with a pulsing dot and child-count. This works.

**Minor gap:** Clicking on `INC-991` row does nothing (`t-root` is a `div`, not a button). In the demo, the natural expectation is that clicking the incident opens the Incident Command drawer (which is only accessible from the Overview/Endpoints tab). Add `onclick={() => { tab = 'overview'; drawerOpen = true }}` on `t-root` when `live` to close the loop between the incident tree and the drawer. This is a one-line fix with high UX payoff.

---

### R1-5 ✅ → 🟡 Claude Code modal is good but disconnected from the narrative

**What was done:** Response action "Execute skill / connect Claude Code" opens a modal with a CLI preview (`thorium respond INC-991 --skill quarantine-and-rca --agent claude-code --context sui://0x9aBc…01`).

**Missed intention:** The `sui://0x9aBc…01` reference should match the **actual INC-991 tx digest** shown in the drawer (`tx 0x9aBcDeF…01`). Currently the modal hardcodes `0x9aBc…01` and the drawer hardcodes `0x9aBcDeF…01` — slightly different truncation patterns, which a sharp observer would notice. These should use the same constant.

**Improvement:** The modal says "Mock — no agent is invoked in this demo." at the bottom. This undercuts the energy. Consider instead: "Coming in v2 — the agent loop is defined: the CLI will open a PR with an RCA by the time the on-call acks." This is more aspirational and story-forward.

---

### R1-6 ✅ → 🟢 Mute button is semantically wrong

**What was done:** The banner has `<button … onclick={reset}>Mute</button>`.

**Problem:** "Mute" calls `reset()` which: clears the timer, sets `autoplay = false`, sets `phase = 'idle'`, closes the drawer. This is not muting — it is ending the entire CC* scenario. If a demo presenter clicks "Mute" to dismiss the audio/visual noise without stopping the scenario, they will accidentally wipe the incident state.

**Fix:** Rename to "Dismiss" or "Reset demo". Or: implement a real `muteAlert` that hides the banner but keeps `phase = 'isolated'` and the drawer data intact. `bannerVisible = false` toggled by Mute, `reset()` moved to a dedicated "Reset" button. This matters because in an unattended booth, a passerby could hit Mute thinking it stops beeping.

---

### R1-7 ✅ → 🟢 "Copy command" button doesn't copy

**`App.svelte:247`:** `onclick={() => note('Copied connect command')}` — the toast says "Copied" but `navigator.clipboard.writeText` is never called.

This is a trivial fix that meaningfully helps the demo: an actual visitor who wants to try connecting a pod would copy the command and paste it into their terminal. The current behavior will confuse them. Change to:
```ts
onclick={() => { navigator.clipboard.writeText(connectCmd).catch(() => {}); note('Copied connect command') }}
```

---

## PART 2 — New code quality findings in vYY

### N2-1 🔴 CSS dual-definition creates hidden dead weight

`app.css` defines several classes twice:
- `.layout` at line 70 (grid columns) and line 174 (padding reset)  
- `.cards` at line 135 (2-column) and line 181 (auto-fill)  
- `.banner` at line 48 (slide-in, border) and line 175 (margin reset)  
- `.panel` at line 72 (background) and line 176 (margin-bottom)  

The second definitions cascade-override the first for left-rail layout. But there is now dead CSS from the old top-tab `.nav`, `.tab` rules (lines 40–45) that never render — there is no `.tab` element in the DOM. These accumulate silently. The ADR-0002 (Tailwind) migration would fix this; until then, a comment block marking "legacy top-tab CSS — no longer rendered" would prevent future confusion.

**More critical:** `.cards` at line 135 sets `grid-template-columns:1fr 1fr` (2-column). `.cards` at line 181 sets `repeat(auto-fill,minmax(220px,1fr))` (responsive). The second wins for all `.cards` elements globally. The Talus AI cards (`tab === 'talus'`, line 221) and Trust badges (`tab === 'privacy'`) and all Platform tabs all use `.cards`. On a 1280px viewport with a 232px rail, the content area is 1048px — `auto-fill` at 220px gives ~4 columns. The Talus cards look designed for 2 columns (per the mockup). On wider screens the Talus tab will look sparse. This is a regression from the old 2-column design.

---

### N2-2 🟡 `palette` list cap of 8 with no overflow hint

`paletteCmds.slice(0, 8)` silently truncates. With 20 total commands (2 fixed + 18 nav), an empty query shows 8 and hides 12 without any "N more…" indication. A judge typing ⌘K and not seeing their target command may assume it doesn't exist.

---

### N2-3 🟡 Demo mode restart is abrupt at the peak moment

When `autoplay = true` and the scenario completes the `isolated` phase, the stepper waits 4500ms and calls `runScenario()` again, which immediately calls `reset()` (closes drawer, sets `phase = 'idle'`) before restarting. This means the CRITICAL alert banner + drawer vanish abruptly. For an unattended booth the ideal loop would:
1. Hold at `isolated` for a longer dwell (e.g., 8s) so passersby can read the alert  
2. Fade/collapse the banner with a CSS transition before resetting  
3. Then restart the sequence  

Currently the peak moment lasts only 4500ms before vanishing, which is shorter than it takes a person to read the banner text (~7s for a first-time reader).

---

### N2-4 🟡 No navigation badge/count on active alert

When `phase === 'isolated'`, the left-rail nav items "Incidents (tree)" and "Alerts" give no visual cue that there is an active CRITICAL item. A `1` badge on these nav items (standard in Datadog/Defender) would guide a cold audience to the relevant screens without requiring them to notice the banner. This is a missed interaction design detail — the Stripe-grade bar is as much about discoverability as visual polish.

---

### N2-5 🟢 `topbar` CSS position is dangerously loose

`app.css` line 171: `.topbar{position:sticky}` — no `top` value. This is valid CSS (defaults to `auto`) but `position:sticky` without `top` behaves like `position:relative`. The topbar is not actually sticky in the left-rail layout. The old definition at line 21 sets `top:0` but in the left-rail layout context (where `main` is a flex column) the sticky behavior may not work as expected. Visual check needed: does the topbar stick on scroll on the vYY+1 build?

---

### N2-6 🟢 The `⌘K` palette shows mock tab commands without labeling them mock

`paletteCmds` includes `"Go: Platform › Governance · $THOR"`, `"Go: Platform › Compliance (NIS2)"`, etc. These navigate to mock panels. For a demo audience, if someone uses the palette to jump to "Governance · $THOR" they see a mock panel with a `mock` tag — fine. But the palette itself does not warn that some destinations are mock/soon. Adding `(mock)` or `(soon)` to those labels in `paletteCmds` would maintain the two-fidelity honesty standard in the palette:
```ts
{ label: `Go: ${g.group} › ${it.label}${it.tag ? ` (${it.tag})` : ''}`, run: () => (tab = it.id) }
```

---

## PART 3 — Missed intentions from `answers.md` (not in CR-1 or not in vYY)

### M3-1 🔴 I14 — Incident status lifecycle is completely absent

**Answer I14:** "The status should be stored on Walrus, but it can be stored on chain for the demo."

**What exists:** The Alerts table shows `Status: Open` (hardcoded badge). There is no action to change status. The Audit Trail mock shows "Acknowledged CRITICAL" as if it happened, but the alert badge in the Alerts tab still shows "Open" — inconsistency. The Incident Command drawer also has no status field.

**Missing interaction:** An analyst's primary action in any SOC tool is to acknowledge, escalate, or close an alert. This is missing entirely. Even a mock "Acknowledge" button on the alert row (that changes the badge to "Acked" client-side + appends to the Audit Trail) would complete the story. The current state makes it look like the alert exists with no recourse except "Coming soon" response actions.

---

### M3-2 🔴 I3 answer context — "you'd like to see my version" implies a comparison

**Answer I3:** "Yes, that has already been partly implemented, but I'd like to see your version."

**Missed intent:** This answer implies the user wants to compare the AI-generated incident tree to something existing. Neither vX+1 nor vYY ever surfaced what the "partly implemented" version is, nor did any agent ask where it lives. The transition Q&A (L-A3) asks the question. But if there is existing code with a different tree structure, the vYY tree may diverge silently. This is an information gap that could mean throwing away working code.

---

### M3-3 🟡 G7 — Audit Trail is static, doesn't react to the CC* scenario

**Answer G7:** "Correct. But we do not need it to be fully functional, just a mock of what's coming for the demo."

**What exists:** `auditTrail` in `scenario.ts` is a static array of 3 rows (hardcoded timestamps 14:41:07–14:42:03). The Audit Trail tab always shows these 3 rows regardless of whether the scenario has run.

**Missed intent:** For demo coherence, the audit trail should populate *as the analyst interacts* — i.e., when the user opens the drawer during `isolated` phase, the entry "Opened INC-991 · 14:41:07" should appear. This ties the analyst's own action to an on-chain audit event, making the "every analyst action as an immutable tx" claim viscerally real. The data is already there; it just needs to be conditional on `compromised` and/or keyed to `drawerOpen` state.

---

### M3-4 🟡 G8 — SIEM Integrations tab shows mock status "mock" for all rows

**What exists:** All 4 integration rows show `<span class="badge b-pending">mock</span>`.

**Better mock:** The "mock" badge in a yellow/pending color implies these integrations are pending configuration, not that they are future features. It would be clearer to show:
- Splunk: `<span class="badge b-ok">Connected (mock)</span>` — to demo that the integration exists in principle  
- Others: `<span class="badge b-pending">Configure</span>` — implying they can be wired  
- On CC* `isolated` phase: Splunk row should briefly flash a "1 alert forwarded" indicator to show the integration firing  

The current all-"mock" presentation looks like a placeholder table with no differentiation.

---

### M3-5 🟡 G2 — Governance tab: DAO vote is static

**Answer G2:** "You can add it."

**What exists:** Three static cards: $THOR rewards, DAO policy vote #42 (64% yes), P2P heuristic pool.

**Improvement:** The DAO vote card could react to the CC* scenario: after `isolated`, show "New vote proposed: Emergency threshold reduction 0.85 → 0.75 (auto-triggered by INC-991)". This ties the governance mock to the live CC* story and shows the autonomous nature of on-chain governance reacting to an incident. One additional conditional card — trivial to add, high narrative payoff.

---

### M3-6 🟡 I13 — Empty/loading/error states are still missing

**Answer I13:** "Correct." (empty states with primary action + chain/agent-unreachable banner)

**What exists:** The Alerts tab has a stub state: `<div class="stub"><h2>No active alerts.</h2><p>Run the CC* scenario to generate one.</p></div>`. This is a good empty state. But every other tab (Chain Activity, Fleet Telemetry, Incidents when `phase === 'idle'`, Vulnerabilities) shows either nothing or a header with an empty table body. There is no loading skeleton, no "Connect your first pod" CTA, no offline-comms banner when `offline = true` beyond the lockbar at the top.

The Offline Lockdown button exists and fires a lockbar, but no panel changes to show "offline" state data. When `offline = true`, the Chain Activity should show "⚠ Disconnected from Sui RPC" instead of the event feed.

---

### M3-7 🟢 U2 — Demo mode toggle has no visible "booth mode" context

**Answer U2 (in Part 4a):** "A 'demo mode' toggle that auto-plays CC* for unattended booths?"

**What exists:** `Demo mode` button cycles autoplay. When autoplay is on, the button shows `⏸ Demo mode`. The scenario runs and resets on loop.

**Missing:** There's no "you are watching a demo" framing for a cold passerby at a booth. In demo mode, a persistent overlay or footer message like "⟳ Live demo running — click anywhere to take over" would help a stranger understand they're watching an automated presentation, not a broken app. The progress bar at the bottom helps but is small and at the bottom-left.

---

## PART 4 — UI interaction improvements (functional review)

### F4-1 🔴 Incident tree → drawer is the most important missing interaction

When a user is on the "Incidents (tree)" tab and sees INC-991 pulsing with CRITICAL, clicking it should open the Incident Command drawer — the natural next action. Currently clicking the row does nothing. This is the most visible interaction gap for a demo audience who discovers the Incidents tab first.

**Suggested fix:**
```svelte
<div class="t-root" class:t-active={live}
  onclick={live ? () => { tab = 'overview'; drawerOpen = true } : undefined}
  style={live ? 'cursor:pointer' : ''}>
```

---

### F4-2 🔴 Alerts tab: "Acknowledge" action missing

The Alerts tab shows CRITICAL and HIGH alerts with status "Open" and no actions. This is the only tab where the analyst can be expected to act, and there is nothing to do. At minimum:
- An "Ack" button on the CRITICAL row that sets status to "Acked" client-side  
- An entry appended to `auditTrail` (or a reactive version of it)  
- The banner could then change from red to amber ("Acknowledged — monitoring") to show the lifecycle

---

### F4-3 🟡 "Connect Wallet" does nothing and is always visible

The topbar has a `Connect Wallet` button (line 129) that does nothing. Unlike the MSSP switcher (which has a `mock` tag), this button has no tag and no feedback. Clicking it should either open a wallet-connection dialog (even a mock "Select wallet" modal listing Sui Wallet, Ethos, etc.) or show a toast "Wallet connect — coming soon (gates write actions)". Currently it is a dead button in the primary action bar, which looks like a bug.

---

### F4-4 🟡 Onboarding flow ends at "Copy command" with no visual feedback of progress

The "Connect a pod" screen shows a CLI command. The user is supposed to run it and then the pod appears in the fleet. For the demo, there is no "simulate registration" button that would trigger `phase = 'connected'` from the onboarding screen. A "Simulate registration" or "Try it in the demo" button on the onboarding screen would connect the onboarding narrative directly to the CC* stepper — this is the CC* step 1 described in `DEMO.md`.

---

### F4-5 🟡 KPI tiles on Overview don't animate on phase change

**CR-1 B-2 noted this.** It was NOT addressed in vYY. When the scenario transitions to `healthy` (pod connected and attested), the "Active Agents" KPI goes from 24→24 (no change) and "Pods Observed" from 23→24 (increments). The increment happens instantaneously with no animation. For the demo, a brief number-count-up or flash on KPI change would make the "new agent connected" moment tangible. Datadog/Stripe do this with number counters.

---

### F4-6 🟡 "Offline Lockdown" state doesn't affect data panels

When `offline = true`, the lockbar appears but:
- Chain Activity still shows live event data (should show "⚠ Disconnected from Sui RPC · last sync 14:40:02")  
- Fleet Telemetry still shows live metrics (should dim or show "stale" indicators on all rows)  
- The rail-foot still shows `mock · Sui testnet` (should show "offline" status)  

This is a missed intention from answer G11: "Correct" — the offline-lockdown viz was supposed to change the app's presentation of data.

---

### F4-7 🟢 On-chain evidence in drawer is a single static line

**`App.svelte:177`:** `<div class="evid">tx 0x9aBcDeF…01 · IncidentReport{severity:"CRITICAL"}</div>`

This is always the same single line regardless of CC* phase. The Kill-chain timeline accumulates events phase by phase — the on-chain evidence should too. When `phase === 'attacked'`, show `ClassificationReported` tx. When `phase === 'isolated'`, show both `ClassificationReported` + `IncidentReport` txs. This would make the evidence section feel like a live feed rather than a pre-set caption.

---

### F4-8 🟢 ⌘K palette doesn't include "View incident" or "Open drawer" commands

The palette has "Run CC* scenario" and "Toggle Demo mode" + all nav items. Missing:
- "View active incident / Open drawer" (only relevant when `compromised`) — would let a power user jump directly to the drawer from anywhere in the app  
- "Acknowledge alert INC-991" (only when `compromised`) — would surface the incident action from keyboard  

This would make ⌘K a genuine power-user workflow accelerator rather than just a nav shortcut.

---

## PART 5 — Style review: is the vYY code in the right style?

### S5-1 🟡 `App.svelte` is growing into a monolith

`App.svelte` is now ~340 lines of script + ~230 lines of template. The file handles:
- Scenario state machine  
- Config loading  
- WS lifecycle  
- Per-row Walrus decrypt  
- Keyboard shortcuts  
- Modal state (Claude Code, ⌘K)  
- MSSP tenant state  
- All 18 tab views inline  

This violates the single-responsibility principle and will become unmanageable. The next correct step is extracting tab views into `src/lib/tabs/Overview.svelte`, `Telemetry.svelte`, `Incidents.svelte`, etc. The scenario state machine belongs in a Svelte store (`src/lib/stores/scenario.ts`). This is not blocking the hackathon but each iteration that adds to the monolith makes the next iteration harder.

---

### S5-2 🟢 Inline styles in JSX

`App.svelte` has multiple `style="font-weight:700"`, `style="margin-left:auto"`, `style="margin-top:14px"`, `style="font-size:11px"` etc. scattered through the template. These should be utility classes in `app.css`. Mixing inline styles and CSS classes makes theming and WCAG auditing harder.

---

### S5-3 🟢 CR-1 notes in app.css are good but create maintenance noise

`app.css` has block comments like `/* ── CR-1 fixes: logs · active tree node · modal ── */`. These are useful for tracing changes during the review cycle but become confusing once the code stabilizes. The final version should not have CR-iteration markers in source CSS — only ADRs should document the decision history.

---

## PART 6 — New questions for next session

These are items that need a decision before they can be implemented:

| # | Question | Why it blocks |
|---|---|---|
| Q1 | Real Walrus blob IDs for the test fixtures? | Without them `fetchWalrusBlob` can never succeed; the "real fetch" claim is false |
| Q2 | Should clicking INC-991 in the tree open the drawer? | High UX impact, trivially implementable — just needs a yes |
| Q3 | Should "Mute" dismiss the banner without resetting the scenario? | Presenter UX — critical for live demo booth |
| Q4 | Should incident status (Open/Acked/Resolved) be interactive in the demo? | Completes the analyst workflow loop |
| Q5 | Should "Connect Wallet" open a mock wallet selector or just toast? | Dead button in primary nav is jarring |
| Q6 | Should the demo mode dwell longer at the CRITICAL phase (e.g., 8s instead of 4.5s)? | Current loop too fast for unattended booth |
| Q7 | Is the ⌘K palette meant to stay as experiment or promote to the main build? | ADR-0009 marks it "experiment" — needs decision |

---

## PART 7 — What is correct and must be preserved

- **adapter.ts structure** — the live/mock seam is the right architecture; TODO markers are precise. Do not restructure.
- **per-row `decryptedText` + `decrypting` spinner** — correct fix for Q-3. The UX pattern is right even though the URL is wrong.
- **`$derived connectCmd`** — correct reactive fix.
- **`onDestroy` cleanup** — correct; do not remove.
- **Grey sparkline for connected phase** — subtle but correct; keep it.
- **Claude Code modal** — strong hackathon narrative; build on it, don't simplify back to toast.
- **MSSP tenant cycling** — keeps the mock honest (tag visible, cycles real names).
- **⌘K palette** — clean implementation; `autofocus` on input is correct; Escape closes it correctly.
- **Invite token `inv_8Qm4…`** — better immersion than `…-MOCK`; keep format.
- **NOT-OK logs panel on Fleet Telemetry** — adds evidence trail; keep even if also added elsewhere.
