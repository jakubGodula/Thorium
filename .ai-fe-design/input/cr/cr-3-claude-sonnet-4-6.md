# Code Review — CR-3
**Scope:** DDD (v5, commit `39ab140`) vs `questions_v4_to_v5_qa_LONG.md` Parts A–E (Jakub's answers)
**Date:** 2026-06-20
**Reviewer:** Claude Sonnet 4.6
**Priority:** A (answers.md) → B (CC* DEMO.md) → CR-2 follow-up → new findings
**Method:** Full read of `App.svelte`, `app.css`, `scenario.ts`, `adapter.ts`, all Q&A and CR files.

---

## Executive summary

DDD (v5) correctly ships the A–E answers (multi-endpoint, Threat Level column, ECharts,
incident lifecycle, Threat Intel, nav badges, toast, 8s dwell). However, five
answer-driven items are silently wrong or unimplemented (kpiFlash never renders, Walrus
URL still malformed, card-1 reacts when Jakub said "first 2 static", claudeModal is dead
HTML, L-E5 Walrus/Mowa is only a client-side toggle). Beyond that: Parts G–O of the LONG
Q&A are entirely unanswered, key docs are stale, and 9 items from CR-2 were explicitly
NOT carried into v5 (marked as carried forward in `fe_design_v5.md` but absent from the
code). This CR documents all of them so the next agent has a complete, unambiguous backlog.

---

## PART 1 — Answer-vs-implementation mismatches (the most important section)

These items have an explicit Jakub answer in Parts A–E but the implementation does not
match it. They are the highest priority: the user said one thing; the agent shipped
another.

---

### M1-1 🔴 L-A5 answer: "first 2 static, rest dynamic" — card 1 is reactive

**Jakub's answer (L-A5):** "Let's make first 2 cards static and then the rest dynamic,
so that the demo can include more than one endpoint that is being defended/targeted."

**What shipped:** In `App.svelte:269–274`, Talus AI tab cards:
- Card 1 (`alma9-edge-01` detection) — **reactive** (`{compromised ? 'Credential dumping / kernel exploit' : 'Baseline — nominal'}`)
- Card 2 (Correlation) — **static** ✓
- Card 3 (`alma9-edge-01` defended pod) — **reactive** ✓
- Card 4 (`ws-07` second targeted pod) — **reactive** ✓

Card 1 reacts to `compromised` despite the answer saying "first 2 static." The code
comment at the bottom of the Talus panel says "First two cards are fixed model status; the
rest react live" — but card 1 does NOT match that description.

**The ambiguity:** "First 2 static" could mean (a) the top 2 cards are always the same
Talus model status cards (baseline, correlation model), with endpoint cards 3+4 reacting,
or (b) a different card ordering was intended. The design intends to show *multiple
endpoints being defended* — which maps naturally to cards 3 and 4 reacting (ws-07 and
alma9), with cards 1 and 2 being fixed "how Talus works" model cards. The current card 1
conflates the detection result (an endpoint outcome) with the AI model card (a capability
description).

**Resolution needed:** Confirm whether card 1 should be a static AI capability card
("Talus AI — anomaly detection model · threshold 0.85") and the detection result should be
card 3/4 only, or whether "first 2 static" was approximate and the current reactive card 1
is acceptable.

---

### M1-2 🔴 L-B2 kpiFlash state never applied to the template

**Jakub's answer (L-B2):** "You can, thank you." (add a KPI flash at `healthy`).

**What shipped:** `App.svelte:99`: `kpiFlash = true; setTimeout(() => (kpiFlash = false), 900)` sets and clears the state correctly on the `healthy` transition. But **no element in the template uses `kpiFlash`**. There is no `class:flash={kpiFlash}`, no `class:kpi-flash`, and no CSS for a flash animation. The state is managed but has zero visual output.

This is a silent implementation gap: L-B2 appears done in the script block but is entirely absent in the template. The "KPI flash" item was listed as completed in `fe_design_v5.md`.

**Fix:** Add `class:flash={kpiFlash}` to `.kpi` elements + a short CSS animation (`@keyframes flash { 0%,100%{background:var(--bg-1)} 50%{background:rgba(56,189,248,.18)} }`). One-line fix with real visual payoff.

---

### M1-3 🟡 L-B5 answer: "toast" — dead modal HTML still present

**Jakub's answer (L-B5):** "Toast."

**What shipped:** The response action "Execute skill / connect Claude Code" fires `note(a.l)` which IS a toast — correct. But `claudeModal = $state(false)` is declared with a comment "// dormant (L-B5: Claude action is a toast now)" and the full modal HTML (lines 356–376, ~20 lines) is still rendered inside `{#if claudeModal}`. Since `claudeModal` is never set to `true` anywhere in the app, this is dead HTML.

**Contradiction with CR-2 Part 7:** CR-2 says "Claude-Code modal — strong hackathon narrative; build on it, don't simplify back to toast." Jakub's explicit answer overrides the reviewer's preference. The code followed Jakub (toast), but left the old modal HTML as dead weight.

**Resolution:** The dead `{#if claudeModal}` block should be removed. If the modal is ever revived, it should be a deliberate decision in the next Q&A. The current state — a declared state variable that's never set, guarding 20 lines of HTML — is confusing to every future agent.

---

### M1-4 🟡 L-E5 "Walrus now, properly with Mowa" = client-side toggle only

**Jakub's answer (L-E5):** "Let's do Walrus now. Try to ensure to do it properly with
Mowa language from the context that I provided above."

**What shipped:** `incStatus = $state<IncStatus>('Open')` — a simple client-side Svelte
rune. The `ackIncident()` function sets `incStatus = 'Acked'`. The `note()` message says
"Acknowledged INC-991 (→ Walrus audit)" with "(→ Walrus audit)" implying future
persistence. The `auditAt()` function appends entries to a reactive array based on
`incStatus`. Zero Walrus API calls, zero Mowa context.

**The ambiguity:** "Properly with Mowa language from the context I provided above" could
mean (a) make a real write call to the Walrus API via the Mowa backend (impossible without
the backend running), (b) use the Walrus JS client library (`@mysten/walrus`) for
browser-side writes, or (c) the user accepted a stub but phrased it aspirationally.
The v5 design correctly notes this is "client-side now; Walrus later" — but the Q&A
answer sounds like it should be real NOW.

**Critical question for CR-3:** Does "do Walrus now properly" mean implement a *real*
Walrus write from the browser, or is the client-side stub with a Walrus-labelled toast
sufficient for the demo? Without the Mowa backend (W1–W4 open), only browser-direct
Walrus writes are possible. If that's the intent, it requires `@mysten/walrus` SDK and a
real blob ID.

---

### M1-5 🟡 W5 domain "thorium.her" — not a valid Unstoppable Domain TLD

**Jakub's answer (L-A8):** "thorium.her"

**What shipped:** `connectCmd` uses `cfg.unstoppableDomain ?? 'thorium.crypto'`. If
`config.json` sets `unstoppableDomain: "thorium.her"`, the footer and onboarding command
will show `thorium.her`.

**Problem:** `.her` is not a registered Unstoppable Domains TLD. Valid UNS TLDs include
`.crypto`, `.nft`, `.x`, `.wallet`, `.blockchain`, `.bitcoin`, `.dao`, `.888`,
`.zil`, `.polygon`. `.hero` would be a .crypto subdomain pattern (e.g., `thorium.hero`).
This is almost certainly a typo.

**Pending since:** `questions_v5_to_v6_qa.md` W5 asks the same thing but has no answer.

**Ask Jakub:** Is it `thorium.crypto`, `thorium.x`, `thorium.nft`, or a different string?
Until answered, the footer should show the fallback `thorium.crypto` (the original config
value), not `thorium.her`.

---

## PART 2 — CR-2 findings NOT carried into DDD (v5)

`fe_design_v5.md` lists "CR-2 cheap wins" as done, but 9 CR-2 items were NOT fixed.
These are listed as open in the LONG Q&A Parts G–J but have `_<!-- … -->_` answers.
The DDD build picked some cheap wins (tree→drawer, Mute≠reset, copy, wallet→toast, badges,
denser cards, 8s dwell) but skipped others without documenting the skip.

---

### C2-1 🔴 G-R1-2: Walrus fetch URL still malformed (not fixed in v5)

`adapter.ts:46`: `fetch(\`${gw}/${blobId}\`)` where `gw = "…/v1"` and `blobId = "walrus:blob:7f3a"`.
The constructed URL is `…/v1/walrus:blob:7f3a` — wrong path (should be `/v1/blobs/{digest}`)
and `7f3a` is not a real digest (should be ~43 char base58 string). This always 404s.

Documented in CR-2 R1-2 🔴. NOT addressed in v5. Still in adapter.ts unchanged.

**Decision needed:** (a) Provide real Walrus blob digest + fix URL to `/blobs/${digest}`, or
(b) remove the fetch guard and always use the demo fallback with honest labelling.
This was also listed as C2-Q1 in Part L2 of the LONG Q&A — unanswered.

---

### C2-2 🔴 G-R1-1: `querySuiEvents` polling loop absent (not fixed in v5)

`adapter.ts:33–38` defines `querySuiEvents()` but it is never called from `App.svelte`.
No `setInterval` stub in `onMount`. Flipping `mock:false` + setting `suiRpcUrl` changes
nothing visible. Documented in CR-2 R1-1. NOT addressed in v5.

This is the #1 technical risk for backend integration: there is no live data path,
only the location where one would be wired.

---

### C2-3 🟡 I-M3-4: Integrations tab still shows all "mock" with no differentiation

`scenario.ts:142–145`: all 4 integration rows have status `'mock'`.
CR-2 M3-4 suggested: Splunk = "Connected (mock)", others = "Configure", Splunk flashes
"1 alert forwarded" on `isolated`. Not implemented in v5.

---

### C2-4 🟡 I-M3-5: Governance DAO vote still static, no INC-991 reactive card

`App.svelte:307–313`: governance cards are always the same 3 static cards.
CR-2 M3-5 (and the Jakub answer "You can add it") suggested a conditional card after
`isolated`: "New vote: emergency threshold 0.85 → 0.75 (auto-triggered by INC-991)".
Not implemented in v5.

---

### C2-5 🟡 J-F4-6: Offline lockdown doesn't affect data panels

When `offline = true`, the lockbar appears but Chain Activity still shows live event data,
Fleet Telemetry shows live metrics, and the rail foot still shows "mock · Sui testnet".
CR-2 F4-6. Not addressed in v5.

---

### C2-6 🟡 J-F4-7: On-chain evidence is one static line

`App.svelte:218`: `<div class="evid">tx 0x9aBcDeF…01 · IncidentReport{severity:"CRITICAL"}</div>`
Always the same. The kill-chain timeline accumulates per-phase but the evidence section
never does. CR-2 F4-7. Not addressed in v5.

---

### C2-7 🟡 I-M3-6: Empty/loading states still missing most tabs

Chain Activity, Fleet Telemetry, Incidents, Vulnerabilities all show empty table bodies
during `phase === 'idle'` with no stub state, CTA, or skeleton. Only the Alerts tab has
a proper empty state. CR-2 M3-6. Not addressed in v5.

---

### C2-8 🟡 H-N2-1: `.cards` triple-defined, Talus tab shows ~4 cols not 2

`app.css` has THREE `.cards` definitions:
1. Line 135: `grid-template-columns:1fr 1fr` (2-col — the original Talus mockup intent)
2. Line 181: `repeat(auto-fill,minmax(220px,1fr))` (responsive auto)
3. Line 220 (v5 DDD): `repeat(auto-fill,minmax(248px,1fr))` (denser but still auto-fill)

The third definition wins globally. On a 1280px viewport with 232px rail, content is ~1048px
→ `auto-fill` at 248px gives ~4 columns. The Talus AI tab was designed for 2 columns.
The "sparse look on wide screens" from CR-2 H-N2-1 is still present.

The legacy `.nav` / `.tab` CSS rules (lines 40–45) still exist but no `.tab` or `.nav`
elements are in the DOM. Dead CSS.

---

### C2-9 🟡 G-R1-5: claudeModal address inconsistency (dormant but ships)

The dead modal at `App.svelte:363` hardcodes `sui://0x9aBc…01`; the drawer at line 218
uses `0x9aBcDeF…01`. Different truncation patterns. If the modal is ever re-enabled, this
inconsistency will show immediately. Even as dead code, it documents a wrong constant.

---

## PART 3 — Stale documentation (misleads future agents)

---

### D1 🔴 `AGENTS.md` is fully stale — references v2 as current

`AGENTS.md` currently says:
- "Current design: fe_design_v2.md" (we're on v5)
- "Read order: fe_design_v2.md — current design"
- "Output → `.ignored/fe-demo/demo_designV2_genV1/`"
- "Git: work on `experimental-aw-fe-v2`; `experimental-aw-fe` is frozen at v1."
- "Current: v2 done; `questions_v2_to_v3_qa.md` open."

Every bullet is wrong. The current design is v5, branch is `experimental-aw-fe-v3`,
and `questions_v5_to_v6_qa.md` is open. Any new agent reading `AGENTS.md` as their
first stop will work on the wrong branch with the wrong design file and produce output
to a path that may conflict with v5.

**Must be updated before the next agent arrives.** The colleague hand-off depends on it.

---

### D2 🔴 `ITERATION-RUNBOOK.md` Step 9 pushes to wrong branch

`delivery/ITERATION-RUNBOOK.md:87`: `git push origin HEAD:experimental-aw-fe-v2`

The current branch is `experimental-aw-fe-v3`. A future agent following the RUNBOOK
verbatim will push to the wrong branch (and potentially clobber v2 history).

---

### D3 🟡 `fe_design_v5.md` credits CR-2 items as done that are not done

`fe_design_v5.md` lists: "CR-2 cheap wins (tree→drawer, Mute≠reset, copy works,
wallet→toast, denser cards, 8s dwell)." This is partially accurate. But it also implies
the rest of CR-2 is handled, which Part 2 of this review disproves. The "Out of scope"
section only mentions the live backend and Tailwind — it does not enumerate the 9 CR-2
items that were silently skipped.

---

### D4 🟡 `AGENTS.md` "Hard rules" references the wrong canonical app path

`AGENTS.md:51`: "Git: work on `experimental-aw-fe-v2`"
`ITERATION-RUNBOOK.md:9`: "Canonical paths: demo app = `.ignored/fe-demo/demo_designV2_genV2/app`
(gitignored; tracked CI copy = `.ai-fe-design/delivery/delivery-v2/app`)"

The tracked CI copy path is correct, but AGENTS.md's branch reference is wrong. A new
agent using AGENTS.md as the primary entrypoint will work from wrong branch context.

---

## PART 4 — Unanswered blockers (Parts G–O are blank — highest risk for next agent)

The LONG Q&A Parts G–O were appended by the previous agent and have `_<!-- … -->_`
as answers. They are NOT future-backlog items — many of them are **decisions that block
the next iteration's implementation**. The most critical:

---

### U1 🔴 N1: Priority order never confirmed by Jakub

**Question (N1):** "Confirm the priority order is permanent: A) answers.md → B) CC* → C) prior docs."

This is the governing rule for EVERY future agent. The RUNBOOK implements it, but Jakub
never explicitly said "yes, this is correct and permanent." If his intent is different
(e.g., CC* DEMO.md should override answers in some cases), every agent since has been
making decisions on an unconfirmed contract.

---

### U2 🔴 N4: Demo-fitness decisions are open

**Question (N4):** "My take: must-fix before demo: J-F4-1 tree→drawer, J-F4-2 Alerts Ack,
G-R1-6 Mute=reset footgun, H-N2-3 dwell too fast, G-R1-7 copy-doesn't-copy, J-F4-3 dead
Wallet button, H-N2-1 .cards sparse layout. Confirm priority / add/remove."

Of these 7 must-fixes:
- J-F4-1 (tree→drawer): ✅ fixed in v5
- J-F4-2 (Alerts Ack): ✅ fixed in v5
- G-R1-6 (Mute=reset): ✅ fixed in v5 (Mute now calls `muteBanner()`)
- H-N2-3 (dwell 8s): ✅ fixed in v5
- G-R1-7 (copy doesn't copy): ✅ fixed in v5 (uses `navigator.clipboard.writeText`)
- J-F4-3 (dead Wallet): ✅ fixed in v5 (fires `note()` toast)
- H-N2-1 (.cards sparse): 🔴 still present in v5

Jakub never confirmed this list. Items were implemented based on the previous agent's
judgment, without confirmation. If Jakub had a different priority (e.g., Wallet button
not important, but Governance reactive card IS important), v5 spent effort on the wrong
fixes.

---

### U3 🔴 N7: Backend integration (10 questions) — all unanswered

W1–W4 in `questions_v5_to_v6_qa.md` (build/run commands, WS schema, Sui RPC, Walrus
blobs) are the technical blockers for any live backend integration. The 10 questions in
Part N7 cover auth, CORS, config knobs, graceful degrade, and ownership. All blank.

**Impact on v6:** Without W1–W4, the adapter seam in `adapter.ts` cannot be filled.
Without N7.10 (who owns the backend tomorrow), there is no integration plan.

---

### U4 🟡 N2: CC* consistency — 10 sub-questions unanswered

10 specific CC* scenario alignment questions (K8s vs generic pod, DDoS vs kernel-only,
Sui write-tx animation, NOT WORTHY field, 2s SLA, second pod ws-07 scope, etc.) have no
Jakub answers. The current implementation made judgment calls for each of these.

The most consequential unconfirmed calls:
- **N2.1:** Is K8s framing (Lithium, namespace columns) correct, or revert to generic host?
  The build shows K8s (`prod-eu1/prod/edge`). Jakub never confirmed this.
- **N2.4:** Is `NOT WORTHY` = `is_active=false` or a distinct `worthiness` field on
  `AgentIdentity`? The build uses `is_active=false`. If the on-chain schema has a different
  field, the displayed value is wrong.
- **N2.8:** Who triggers the demo — presenter clicks "Run CC*" OR autoplay/booth OR both?
  Both exist in the build. If booth-only is intended, the "▶ Run CC* scenario" button
  may be inappropriate.

---

### U5 🟡 N3: Alfa vs Beta scope never confirmed for the final demo

**Question (N3):** "Is the demo scope: Alfa-with-mock-Beta-tabs (current) / pure Alfa /
fully-implemented Beta?"

The build is Alfa + mock Beta surfaces (Compliance, Governance, Integrations, Audit,
Roadmap, Other all as mock panels). Jakub never confirmed this is the right scope. If
"pure Alfa" was intended, half the left-rail nav items are clutter for the demo.

---

### U6 🟢 O1–O3: Brand / theme / look-and-feel entirely unanswered

Parts O cover the preference matrix (Keep/Tweak/Regenerate for brand identity, color
theme, typography, layout, CC* alert styling, motion). All checkboxes are blank. The
overall question O2 (satisfactory / generate alternatives / apply specific brand) is
blank. O3's 7 sub-questions (blockchain idiom, ELK alikeness, Defender comparison,
Stripe-grade UX self-assessment) are all blank.

These are subjective but actionable: if Jakub would say "Regenerate" to the color theme,
the next agent should run the gen-v2 improve loop as a brand pass before building more
features.

---

## PART 5 — Code-level findings new to CR-3

---

### N3-1 🟡 `auditTrail` static export is now dead code

`scenario.ts:137–141` exports a static `auditTrail` array (hardcoded 3 rows). It was the
old Audit Trail implementation. `auditAt()` (lines 190–198) is now the correct reactive
implementation used in the app. The static `auditTrail` export is imported nowhere and
is dead code. Remove to avoid future agents re-importing the stale one.

---

### N3-2 🟡 `paletteCmds` includes `⌘K` commands only when `compromised`

`App.svelte:48–50`: "View active incident (open drawer)" and "Acknowledge alert INC-991"
commands are only added when `compromised`. This is correct behavior. But the `paletteCmds`
array is recalculated on every `paletteQ` change (it's a `$derived`). Since `compromised`
is also `$derived`, this works correctly — the ⌘K palette dynamically shows/hides
incident-specific commands based on scenario state. This is fine; noting for clarity.

---

### N3-3 🟢 `fleet()` function in scenario.ts is never called

`scenario.ts:22–27` defines `fleet(): Pod[]` returning ws-07 and db-02. It is not called
anywhere in `App.svelte` — the multi-endpoint pods are sourced from `fleetAt()` instead.
`fleet()` is dead code.

---

### N3-4 🟢 `topbar` has two CSS definitions; `position:sticky` is redundant but harmless

`app.css:21–23` (first def): `.topbar { ...; position:sticky; top:0; z-index:50 }`
`app.css:171` (second def): `.topbar { position:sticky }` — no `top`, just re-states sticky.

The second definition doesn't override `top:0` since it doesn't set `top`. The topbar
IS sticky. But the double definition is confusing. The old top-tab `.nav`/`.tab` rules
(lines 40–45) are also confirmed dead — no `.tab` or `.nav` elements exist in the DOM.

---

### N3-5 🟢 `defended` variable is derived but never rendered

`App.svelte:66`: `const defended = $derived(defendedEvent(phase))` computes ws-07's
blocked lateral event. This is used in... nowhere in the template. `defendedEvent()` data
(pod, action, t) should appear somewhere — the ws-07 defended status in the Alerts or
Overview table — but it's only displayed via the static `scenario.ts` row in the Alerts
tab (hardcoded as `'ws-07 · lateral movement (nmap)'`). The derived `defended` object
exists but is unused. Either use it to drive the Alerts row dynamically, or remove the
derive.

---

## PART 6 — Questions for Jakub (priority ordered)

The following require answers from Jakub before the next agent can proceed safely.

| # | Priority | Question | Blocks |
|---|---|---|---|
| Q1 | 🔴 | **N1:** Is `A(answers) → B(CC*) → C(prior docs)` the confirmed permanent priority order? | Every future agent |
| Q2 | 🔴 | **L-A5:** Should card 1 on Talus tab be static (AI model info only) or reactive like today? | Demo story clarity |
| Q3 | 🔴 | **W5:** Is the Unstoppable Domain `thorium.her`, `thorium.crypto`, or something else? | Footer, onboarding cmd |
| Q4 | 🔴 | **W1–W4:** Backend build/run commands, WS schema, Sui RPC URL, real Walrus blob digests | Any live integration |
| Q5 | 🔴 | **G-R1-2:** Real Walrus blob ID + correct path, OR drop the fetch and always use demo blob? | Vulns decrypt row |
| Q6 | 🟡 | **L-B2:** kpiFlash is wired in state but not rendered — confirm the visual flash is wanted | L-B2 "done" is wrong |
| Q7 | 🟡 | **L-E5:** "Do Walrus now properly with Mowa" — is a browser-direct Walrus SDK write intended, or is client-side state + "→ Walrus audit" toast sufficient for the demo? | Incident status |
| Q8 | 🟡 | **N2:** K8s framing (namespace cols) — correct for demo or revert to generic host? | Endpoints table |
| Q9 | 🟡 | **N3:** Is "Alfa + mock Beta surfaces" the final scope for the demo, or pure Alfa? | Rail nav items |
| Q10 | 🟡 | **O1–O3:** Brand matrix — Keep / Tweak / Regenerate for colors, mark, typography, CC* alert? | Gen-v2 brand pass |
| Q11 | 🟡 | **N4 confirmation:** H-N2-1 (.cards 4-col on wide screens) still open after v5 — is a 2-col Talus layout wanted? | Talus tab visual |
| Q12 | 🟢 | **N7.10:** Who owns the backend for the demo? You / teammate / the AI agent? What's the repo? | Integration plan |
| Q13 | 🟢 | Should `AGENTS.md` + `ITERATION-RUNBOOK.md` be updated to reflect v5/branch v3, or kept as-is for historical context? | Colleague hand-off |

---

## PART 7 — What DDD (v5) got right — preserve in v6

- **Incident lifecycle** (`Open→Acked→Resolved`) — correctly implemented, dynamic `auditAt()`, banner color changes on ack. Keep exactly.
- **Tree→drawer click** — `t-root` click navigates to overview and opens drawer. One-line, high payoff. Keep.
- **Mute≠Reset** — `muteBanner()` correctly hides banner without resetting `phase`. Keep.
- **Copy command** — `navigator.clipboard?.writeText(connectCmd)` is present and correct. Keep.
- **8s dwell** — `setTimeout(runScenario, 8000)` in autoplay. Keep.
- **Nav badges** — conditional `<span class="nav-badge">1</span>` on Incidents/Alerts when `compromised && incStatus==='Open'`. Keep.
- **Wallet button** — `note('Wallet connect — coming soon...')` toast. Keep.
- **adapter.ts structure** — correct live/mock boundary. Do not restructure.
- **ECharts CPU chart** — correct lazy-load pattern via `Chart.svelte`. Keep.
- **Threat Intel reacts** — `threatIntelRows(phase)` adds CRITICAL/HIGH rows on attack. Keep.
- **`$derived` everywhere** — `pod`, `spark`, `others`, `defended`, `auditRows`, `intel`, `telemetryOption` all reactive. Keep.
- **IncStatus state in derived auditRows** — `auditAt(phase, drawerOpen, incStatus)` correctly ties analyst actions to audit entries. Keep and build on.
- **Grey sparkline for connecting phase** — subtle, correct. Keep.
- **`onDestroy` cleanup** — timer + WS + keydown. Keep.

---

## Summary: what must change before the next iteration ships

### Must-fix (silent wrong implementations):
1. **M1-2** `kpiFlash` state — apply to template (`class:flash={kpiFlash}`) + CSS keyframe
2. **M1-1** Talus card 1 static/reactive clarification (needs Q2 answered first)
3. **M1-3** Remove dead `{#if claudeModal}` block (20 lines of unreachable HTML)
4. **C2-1** Walrus URL: fix path or always use demo fallback (needs Q5 answered first)

### Must-fix (stale docs that mislead agents):
5. **D1** Update `AGENTS.md` to reference v5 design and `experimental-aw-fe-v3` branch
6. **D2** Update `ITERATION-RUNBOOK.md` Step 9 branch to `experimental-aw-fe-v3`

### Should-fix (open CR-2 items with confirmed answers in LONG Q&A but not implemented):
7. **C2-3** Integrations tab differentiation (Splunk connected, others configure)
8. **C2-4** Governance reactive DAO card after `isolated`
9. **C2-9** On-chain evidence accumulates per-phase (not single static line)

### Dead code to remove:
10. `auditTrail` static export in `scenario.ts:137–141`
11. `fleet()` function in `scenario.ts:22–27`
12. `defended` derived variable (used nowhere in template)
13. Legacy `.nav`/`.tab` CSS rules (lines 40–45 in `app.css`)
14. First `.cards` definition (line 135, `1fr 1fr`) — superseded by line 220

### Needs Jakub answers before proceeding (LONG Q&A Parts N, O):
- Q1 priority order, Q2 Talus card ordering, Q3 domain, Q4–Q5 Walrus, Q7 L-E5 intent, Q8 K8s framing, Q9 scope, Q10 brand
