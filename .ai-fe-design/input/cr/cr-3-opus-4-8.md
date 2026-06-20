# Code Review — CR-3
**Scope:** DDD (v5) build on `experimental-aw-fe-v3` vs **Jakub's answers** in
`questions_v4_to_v5_qa_LONG.md` (commit `18a1f17`, not mutated since `bed8cf5`), the
binding CC\* in `input/DEMO.md`/`input/answers.md`, and the repo as a whole (`/init` lens).
**Date:** 2026-06-20
**Reviewer:** Claude **Opus 4.8 (1M context)**
**Method:** read every shipped source file (`App.svelte`, `scenario.ts`, `adapter.ts`,
`config.json`, `Chart.svelte`, `app.css` deltas) line-by-line against the inline answers,
not just the commit message / design doc. Findings are verified in code, with file:line.
**Priority (assumed — see Q0):** A `answers.md` ⇒ B CC\* `DEMO.md` ⇒ C prior docs / Sui contract.
**Legend:** 🔴 blocks the demo / a literal answer · 🟡 shapes it · 🟢 polish.

---

## Executive summary

DDD (v5) is a genuine step up: multi-endpoint defense, a real ECharts chart, the
Open→Acked→Resolved lifecycle, a dynamic audit trail, and the CR-2 cheap wins
(tree→drawer, Mute≠reset, real clipboard copy, nav badges, 8 s dwell) are all present and
correct in the code. The build is demo-fit for tomorrow.

But there are **three classes of gap** that this round must close so no misunderstanding
survives:

1. **Answers that were stated but not landed in the build** — most importantly the domain
   `thorium.her` (config still ships `thorium.crypto`), the *"do Walrus now"* instruction
   (shipped client-side only), and the IPFS hash (delivered but **unpinned** → likely won't
   resolve for you). These are priority-A items where the *answer exists* and the *build
   diverges*.
2. **Decisions made on your behalf because Parts G–O were blank.** The whole basis of the
   build (the priority order in N1, the brand in Part O, ~25 CR-2 items) was **never
   answered** — the agent decided by judgment. Most calls are reasonable; a few priority-A
   intentions from `answers.md` were silently dropped and should be confirmed, not assumed.
3. **`/init` mismatches — the repo misdescribes itself.** `AGENTS.md` (the first file any
   colleague/AI is told to read) still points to **v2 / `experimental-aw-fe-v2` /
   `questions_v2_to_v3`** — it would send a new agent three versions backwards. This
   directly contradicts the N8/N10 self-assessment of "discoverable: yes."

The single most important thing for *this* iteration: **N1 was never confirmed and Parts
G–O are still blank.** Every "the agent decided" below traces back to that. One pass of
answers on G–O (or an explicit "use your judgment, I trust the defaults") removes the
ambiguity permanently.

---

## Part 1 — Stated answers that did NOT land in the build (priority A)

These are the highest-signal findings: you gave an answer, the code does something else.

### 1.1 🔴 `thorium.her` was answered but the build still ships `thorium.crypto`
- **Answer (L-A8):** "thorium.her".
- **Code:** `delivery-v2/app/public/config.json` → `"unstoppableDomain": "thorium.crypto"`.
  `App.svelte:123` (`connectCmd`) and `:353` (footer) read that value, so the onboarding
  `curl https://thorium.crypto/agent…` command and the footer both still say
  **thorium.crypto**. The answer never reached the UI.
- **Why it matters:** it's a one-line config change, and it's a priority-A answer. It was
  parked as a *doubt* (W5) instead of *applied*. Parking is right only because **`.her`
  is not a known Unstoppable Domain TLD** (UD issues `.crypto/.x/.nft/.wallet/.hi/…`, not
  `.her`) — so I suspect a **typo**. **→ Q1.** Until you confirm, the build can't show the
  real domain anywhere.

### 1.2 🔴 "Do Walrus **now**" (L-E5) shipped as client-side only
- **Answer (L-E5):** "Let's do Walrus **now**. Try to ensure to do it properly with Mowa
  language from the context I provided above."
- **Code:** incident status lives in a Svelte `$state` (`incStatus`, `App.svelte:23`);
  `ackIncident()`/Resolve mutate it client-side and toast "→ Walrus audit" — but
  `adapter.ts` never writes to Walrus, and `fetchWalrusBlob` only *reads* (with a malformed
  URL — see 1.5). Nothing is persisted on Walrus.
- **Assessment:** the deferral is **defensible** — "properly with Mowa" inherently needs
  the Mowa repo + `sui-cli` + `cargo`, which a frontend iteration genuinely cannot build.
  But it is still a divergence from a literal **"now."** This is the **single biggest
  expectation gap** of the round and it's currently buried as W1/W12 rather than stated
  plainly. **→ Q2:** do you want the next iteration to actually stand up the Mowa/Sui build
  env (one-off, slow) and wire real Walrus persistence, or is the client-side mock +
  adapter seam acceptable for the demo and Walrus is a post-demo task?

### 1.3 🔴 The IPFS hash exists but is **unpinned** → likely non-resolving
- **Answer (L-C1):** "Give me a hash to the site IPFS."
- **Reality:** CID `bafybeici77…czq` was produced via a local `kubo` node **add-only, no
  pin/no publish** (per `DDD-decisions-STAGED-ONLY.md`). It is in the README and design
  doc, so the *literal* request ("a hash") is met — but it will **not resolve on a public
  gateway** (`ipfs.io/ipfs/bafy…`) unless your machine's kubo daemon is online and
  reachable, or it's pinned (Pinata / web3.storage / your node). The deliverable you can
  actually *open* is the ephemeral ngrok URL, which dies with the process.
- **→ Q3:** want me to pin it (need a Pinata/web3.storage token, or your IPFS node), or is
  the hash-only artifact enough and the live URL stays ngrok/LAN?

### 1.4 🟡 L-A5 multi-endpoint: built, but "first 2 cards static" was not honored + the caption contradicts the cards
- **Answer (L-A5):** "make first **2** cards static and then the rest dynamic, so the demo
  can include more than one endpoint being defended/targeted."
- **Code (`App.svelte:268-274`, Talus tab):** card **1** *does* react (`Baseline — nominal`
  ↔ `Credential dumping / kernel exploit`, `card-bad` toggled on `compromised`); card 2 is
  static; cards 3–4 react. So **card 1 is dynamic**, violating "first 2 static." Worse, the
  caption on `:274` literally reads *"First two cards are fixed model status; the rest react
  live"* — which is **false for card 1** and a sharp judge will notice.
- The *spirit* (multi-endpoint: alma9 NOT WORTHY + ws-07 BLOCKED across two cards) is
  achieved well. This is a small letter-of-the-answer + self-contradicting-caption fix:
  either make card 1 static, or reword the caption. **→ Q4** (or just fix to match the
  caption).

### 1.5 🟡 Walrus fetch URL is still malformed (G-R1-2 decision was never taken)
- CR-2 asked you to choose (a) real digest + `${gw}/blobs/${digest}`, or (b) be honest and
  drop the fetch guard. **Neither was answered** (G-R1-2 blank), and the code still has the
  original bug: `adapter.ts:46` builds `${gw}/${blobId}` → `…/v1/walrus:blob:7f3a` (wrong
  path, colon not URL-safe, `7f3a` is not a ~43-char digest). It's **inert today** because
  `cfg.mock=true` gates it, so the fallback "decrypted (Seal, demo)" always shows — fine for
  the demo. But the moment anyone flips `mock:false` (your "live profile tomorrow"), every
  decrypt 404s silently. **→ Q5:** option (a) with a real testnet blob digest, or (b) drop
  the guard and own the mock honestly?

---

## Part 2 — Priority-A intentions still open (Parts G–O blank → decided by judgment)

The deploy honestly claims only: *tree→drawer, Mute≠reset, copy, wallet toast, nav badges,
denser cards, 8 s dwell* — and all of those are **correctly done** (verified in code). It
does **not** claim the items below, so these are not regressions — but they are open
intentions from `answers.md` (priority A) that were left because G–O carried no answer.
Each is small and high-narrative. Confirm "do these" or "skip for demo":

| # | Item (source) | Status in code | Note |
|---|---|---|---|
| 2.1 🟡 | **SIEM differentiation** (I-M3-4 / G8) | **Not done** — `scenario.ts:142` all `'mock'`; `App.svelte:327` all `b-pending` | Splunk "Connected (mock)" + "1 alert forwarded" flash on isolate would sell the integration. |
| 2.2 🟡 | **Governance conditional vote** (I-M3-5 / G2) | **Not done** — `App.svelte:308-313` static | Add post-`isolated` card "emergency threshold 0.85→0.75, auto-triggered by INC-991". |
| 2.3 🟡 | **Offline state on panels** (I-M3-6 / J-F4-6 / G11) | **Not done** — `offline` only toggles the lockbar (`App.svelte:175`); Chain/Telemetry unchanged | Chain Activity should show "⚠ Disconnected from Sui RPC". |
| 2.4 🟢 | **On-chain evidence accumulates** (F4-7) | **Not done** — drawer evidence is one static line `App.svelte:218` | Should grow per phase like the kill-chain timeline does. |
| 2.5 🟢 | **Onboarding "Simulate registration"** (F4-4) | **Not done** — onboarding ends at Copy (`App.svelte:295`) | A button → `phase='connected'` ties onboarding to CC\* step 1. |
| 2.6 🟢 | **Booth "live demo running — click to take over" overlay** (I-M3-7 / U2) | **Not done** | Only the small progress bar signals autoplay. |

None block tomorrow. I list them so the decision is *yours*, not silently the agent's. **→ Q6:** tick which to land in v6 vs drop.

**Also note (architecture, not a demo blocker):** `App.svelte` is now ~390 lines with all
18 tabs inline (K-S5-1, still open). Each round compounds. One extraction pass into
`lib/tabs/*.svelte` + a scenario store before v6 would pay for itself — but only if you're
continuing to iterate on this codebase rather than swapping to the real backend repo.

---

## Part 3 — `/init`: the repo misdescribes itself (the "misunderstanding" risk)

This is the part the prompt specifically asked for: where would a fresh agent/colleague
form a **wrong mental model** from the repo as-is?

### 3.1 🔴 `AGENTS.md` is three versions stale — it sends a new reader backwards
`AGENTS.md` is explicitly "read this first" for any model. It still says (lines 28-51):
- *"Current: v2 done; `questions_v2_to_v3_qa.md` open"* — reality: **v5**, `questions_v5_to_v6` open.
- Read order #2: *"`fe_design_v2.md` — current design"* — reality: **`fe_design_v5.md`**.
- *"work on `experimental-aw-fe-v2`"* — reality: **`experimental-aw-fe-v3`**.
- *"Demos generated under `.ignored/` … don't commit build output"* — contradicts the
  **L-C2 decision you made** ("tracked path pls"); the canonical app now lives at
  `delivery/delivery-v2/app` and **is** committed.

A colleague following `AGENTS.md` literally would edit the wrong design file on the wrong
branch and look for the app in the wrong place. This **directly contradicts** the N8/N10
self-assessment ("discoverable: yes / find in <1 min"). **This is the highest-value
non-code fix of the round.** **→ Q7:** I'll refresh `AGENTS.md` to v5 (+ a "current state"
header that future rounds bump) unless you'd rather keep it pinned and add a pointer.

### 3.2 🟡 No router, but the hard rule + ADR-0008 require hash routing
`AGENTS.md` hard rule: *"IPFS-friendly: `base:'./'`, **hash routing**, no SSR"*; ADR-0008
mentions hash routing. The app has **no router** — `App.svelte:58` even comments *"safe once
a router is added."* Navigation is `tab` state only; the only deep link is `?cc=1`. So
deep-linking to any screen is impossible, and the documented rule is unmet. For a single-
screen demo this is fine, but it's an undeclared contradiction between the rules and the
code. **→ Q8:** add hash routing now (deep links to tabs/incidents), or formally drop the
rule for the demo and note it?

### 3.3 🟡 "Which app is real?" — the working tree has confusing clutter
At repo root (untracked): **`my-app/`** (a full SvelteKit scaffold from May 19),
`.svelte-kit/`, `Thorium.iml`, `.idea/`, `node_modules/`. The **real** app is buried at
`.ai-fe-design/delivery/delivery-v2/app`. A colleague who clones and runs `npm install` at
root, or opens `my-app/`, will build the wrong (empty) thing. None of this is in
`.gitignore` visibly enough. **→ Q9:** is `my-app/` dead scaffolding I can delete/ignore,
or yours? And should the canonical app path be surfaced (a root `make demo` / a one-line
"the app is HERE" pointer) per N9?

### 3.4 🟢 Naming drift in the vision file itself
The file you pointed me at, `questions_v4_to_v5_qa_LONG.md`, is internally titled
*"Questions: v3 → v4 — LONG"* (line 1) and was committed by **Aleksander**, not Jakub
(`bed8cf5` was Jakub's, on the *v3_to_v4* file; `18a1f17` is the v4_to_v5 rename/append by
you). Your *answers* are inline and authentic — but the v3/v4/v5 numbering is now drifting
across filename vs title vs design version (design is "v5", file says "v3→v4"). Harmless to
the build, but it's exactly the kind of thing that makes "which doc is current?" hard. **→
Q10:** want me to normalize the version vocabulary (one table: design vN ⊗ q-file ⊗
deployment tag) in `AGENTS.md`?

---

## Part 4 — Clarifying questions (consolidated — answer inline, these supersede the blanks)

The blanks in Parts G–O + W1–W13 are the backlog; these are the ones that actually **gate
v6 / remove ambiguity**. New ones are marked ✦.

| # | Question | Blocks |
|---|---|---|
| **Q0** ✦ | Confirm the priority order **A `answers.md` ⇒ B CC\* ⇒ C docs/contract** (Part N1 — never answered). Everything below assumes it. | the entire decision basis |
| **Q1** | `thorium.her` — typo? what's the real registered UD (or `thorium.crypto`)? (1.1 / W5) | domain in UI + onboarding |
| **Q2** | Stand up the Mowa/Sui build env for **real Walrus persistence** now, or keep client-side mock + adapter for the demo? (1.2 / L-E5 / W1) | the "do Walrus now" gap |
| **Q3** | **Pin** the IPFS CID (give Pinata/web3.storage token or node), or hash-only is enough? (1.3 / W6) | a durable, openable demo URL |
| **Q4** | Talus card 1 — make it static (honor "first 2 static") or fix the caption? (1.4) | answer fidelity |
| **Q5** | Walrus URL — real testnet digest (`/blobs/{digest}`) or drop the guard? (1.5 / G-R1-2 / W4) | live profile correctness |
| **Q6** ✦ | Of 2.1–2.6 (SIEM / governance / offline / evidence / onboarding / booth), which land in v6? | priority-A intentions |
| **Q7** ✦ | OK to refresh `AGENTS.md` to v5 + add a self-updating "current state" header? (3.1) | onboarding correctness |
| **Q8** | Add hash routing now or drop the rule for the demo? (3.2) | deep-linking + rule consistency |
| **Q9** ✦ | Is `my-app/` + root clutter deletable/ignorable? (3.3) | "which app is real" |
| **Q10** | Live backend specifics — still need **WS schema (W2)**, **Sui `queryEvents` module/type (W3)**, **real Walrus gateway+digests (W4)**, and **who owns the backend repo tomorrow (N7.10)**. | any real integration |
| **Q11** | **Part O brand** — Keep / Tweak / Regenerate (W9, still blank)? The biggest subjective call; the build assumes "Keep." | look-and-feel direction |
| **Q12** | Mock backend posture (N7.7 / W10) — must it be auth'd / CORS / rate-limited for a **public** demo, or local-only/throwaway? | public-demo safety |

---

## Part 5 — Correct and must be preserved (verified in code, do not regress)

- **Lifecycle**: `Open→Acked→Resolved` with banner state (`acked` class), Ack/Resolve
  buttons on the Alerts row, and the **dynamic** audit trail (`auditAt(phase, opened,
  status)`, `scenario.ts:190`) that grows as the analyst acts (I-M3-3) — well done.
- **Multi-endpoint** (`fleetAt` / `defendedEvent` / ws-07 BLOCKED + alma9 NOT WORTHY) and
  the **ECharts** CPU chart with both pods (`telemetryOption`) — real and lazy-loaded.
- **CR-2 cheap wins all present**: tree→drawer (`App.svelte:252`), `muteBanner()`≠`reset()`
  (`:108`), real `navigator.clipboard.writeText` on copy (`:295`), nav `1` badges gated on
  `compromised && incStatus==='Open'` (`:154`), 8 s peak dwell (`:103`), ⌘K `(mock)`/`(soon)`
  labels + "+N more" overflow hint (`:53`,`:383`).
- **Threat-level column** (L-B3) and **live Threat Intel** (L-E2, `threatIntelRows`) — done.
- **Claude→toast** (L-B5): the rich modal is correctly made dormant (`claudeModal` retained
  but unbound) and the response action toasts — matches your "toast" answer.
- **The adapter seam** (`adapter.ts`) — still the right single boundary; keep it.
- **`onDestroy` cleanup, `$derived connectCmd`, per-row decrypt + spinner, MSSP cycling,
  invite token** — all intact from CR-1/CR-2 "must preserve."

---

## Part 6 — Recommended order before the demo / for v6

1. **5-minute correctness** (do regardless): apply `thorium.her`→config **or** confirm
   typo (Q1); fix Talus card-1/caption contradiction (Q4); these are the only places the
   *shipped* build visibly diverges from a literal answer.
2. **Refresh `AGENTS.md` to v5** (Q7) — biggest findability fix, zero risk.
3. **Decide the IPFS pin** (Q3) — the difference between a demo you can send and one that
   dies with the ngrok process.
4. **Confirm G–O / N1 once** (Q0, Q6, Q11) — converts ~30 silent agent-judgment calls into
   confirmed decisions; this is what permanently removes the "misunderstanding" risk.
5. **Then** the live-backend track (Q2, Q5, Q10) as its own iteration with the Mowa env.

> Net: the build is demo-ready; the *understanding* is not yet pinned. The blockers are not
> in the Svelte — they're the unanswered Parts G–O, the stale `AGENTS.md`, and three
> stated-but-unlanded answers (domain, Walrus-now, IPFS-pin). Close those and CR-4 should
> be all-green.
