# Questions: v5 → v6 — **LONG** (the longest appended Q&A) · driven by CR-3

> **Most important input this round:** the two CR-3 reviews of DDD (v5) —
> [`input/cr/cr-3-opus-4-8.md`](./input/cr/cr-3-opus-4-8.md) (Opus 4.8) and
> [`input/cr/cr-3-claude-sonnet-4-6.md`](./input/cr/cr-3-claude-sonnet-4-6.md) (Sonnet 4.6).
> This document's job: **make every doubt those two reviews raised explicit and
> decidable.** Each item ends with **Answer:** — fill inline.
>
> **The vision RFI (contemplatory, not acted on this round):**
> [`questions_v4_to_v5_qa_LONG.md`](./questions_v4_to_v5_qa_LONG.md) is the **ultimate,
> precise RFI for the frontend vision**. It is *not* re-derived here — it is the
> backdrop. Parts **G–O** of it remain the master backlog; the items below are the
> *gating* subset CR-3 surfaced.
>
> **Priority rule (still unconfirmed — see V0):** A `answers.md` → B CC* `DEMO.md`
> → C prior docs / Sui contract.  🔴 blocks · 🟡 shapes · 🟢 polish.
> *(O = Opus finding, S = Sonnet finding, B = both converge.)*

---

## Part 1 — Stated answers that did NOT land in the build (highest signal · priority A)
> Both reviewers agree these are the top class: Jakub answered, the code diverges.

- **V1 🔴 (B) Domain `thorium.her` not applied + likely a typo.** Answer L-A8 = "thorium.her",
  but `config.json` still ships `unstoppableDomain:"thorium.crypto"`, so the footer +
  onboarding `curl https://thorium.crypto/agent…` show the old value. **And `.her` is not a
  valid Unstoppable TLD** (UD issues `.crypto/.x/.nft/.wallet/.hi/…`). → **What is the real
  domain** (`thorium.crypto`? `thorium.hero`? other)? I'll apply it in one line. **Answer:** _<!-- -->_
- **V2 🔴 (B) "Do Walrus **now**, properly with Mowa" (L-E5) shipped client-side only.**
  `incStatus` is Svelte `$state`; Ack/Resolve toast "→ Walrus audit" but **nothing is
  written to Walrus** and no Mowa is invoked. Deferral is defensible (Mowa needs
  sui-cli+cargo), but it diverges from a literal "now". → **Stand up the Mowa/Sui build env
  and wire real Walrus persistence in v6, OR accept client-side mock + adapter for the demo
  (Walrus post-demo)?** **Answer:** _<!-- -->_
- **V3 🔴 (B) IPFS hash is **unpinned** → won't resolve on a public gateway.** CID
  `bafybeici77…czq` was `kubo add --only-hash` (no pin/publish), so `ipfs.io/ipfs/bafy…`
  won't open unless pinned. The only openable URL is the ephemeral ngrok. → **Pin it
  (give a Pinata/web3.storage token or your IPFS node) so the demo has a durable URL, or is
  hash-only enough?** **Answer:** _<!-- -->_
- **V4 🔴 (B) Talus "first 2 cards static" not honored + self-contradicting caption.** Card 1
  *reacts* to `compromised` (Baseline ↔ Credential-dumping), yet the panel caption says
  "First two cards are fixed model status." A sharp judge will catch the contradiction.
  → **Make card 1 a static AI-model card (and keep the endpoint reactions on cards 3–4), or
  was "first 2 static" approximate (then I just fix the caption)?** **Answer:** _<!-- -->_
- **V5 🔴 (S) `kpiFlash` is wired in state but never rendered.** `App.svelte` sets/clears
  `kpiFlash` on the healthy phase, but **no element uses it** (no `class:flash`, no CSS).
  L-B2 ("you can, thank you") is effectively un-shipped though `fe_design_v5.md` lists it
  done. → **Confirm you want the visual KPI flash** (I'll add `class:flash` + a keyframe). **Answer:** _<!-- -->_
- **V6 🔴 (B) Walrus fetch URL still malformed** (`${gw}/${blobId}` → `…/v1/walrus:blob:7f3a`;
  wrong path, colon unsafe, `7f3a` not a real digest). Inert today (`mock:true`), but every
  decrypt 404s the moment `mock:false`. → **(a) real testnet blob digest + `/blobs/{digest}`,
  or (b) drop the fetch guard and own the demo blob honestly?** **Answer:** _<!-- -->_

## Part 2 — `/init`: the repo misdescribes itself (the "misunderstanding" risk)
> Both reviewers flag this as the highest-value **non-code** fix. I have applied the safe
> doc fixes this round (noted); please confirm the approach.

- **V7 🔴 (B) `AGENTS.md` was three versions stale** — it said "current = v2", read
  `fe_design_v2.md`, work on `experimental-aw-fe-v2`, demos under `.ignored/` (contradicts
  your L-C2 "tracked path"). A fresh agent would go 3 versions backwards. **→ I refreshed it
  to v5 / `experimental-aw-fe-v3` + a self-updating "Current state" header.** Confirm that's
  the right move (vs pinning it historical). **Answer:** _<!-- -->_
- **V8 🔴 (S) `ITERATION-RUNBOOK.md` Step 9 pushed to `experimental-aw-fe-v2`** (wrong
  branch). **→ I fixed it to `experimental-aw-fe-v3`.** Confirm. **Answer:** _<!-- -->_
- **V9 🟡 (O) Root clutter — "which app is real?"** Untracked `my-app/` (a full SvelteKit
  scaffold), `.svelte-kit/`, `.idea/`, `Thorium.iml`, `node_modules/` at root; the real app
  is at `.ai-fe-design/delivery/delivery-v2/app`. A colleague who `npm install`s at root or
  opens `my-app/` builds the wrong thing. → **Is `my-app/` dead (deletable/ignorable)? Add a
  root pointer / `make demo`?** **Answer:** _<!-- -->_
- **V10 🟡 (B) No router though the hard rule + ADR-0008 require hash routing.** Only `?cc=1`
  deep-links; tabs are `tab` state. → **Add hash routing now (deep links to tabs/incidents),
  or formally drop the rule for the demo?** **Answer:** _<!-- -->_
- **V11 🟢 (O) Version-vocabulary drift.** The vision file is titled "v3→v4" but is the v4→v5
  source of truth; design is "v5"; filenames vs titles vs deployment tags diverge. → **Want
  me to normalize one table (design vN ⊗ q-file ⊗ deployment tag) in `AGENTS.md`?** **Answer:** _<!-- -->_

## Part 3 — CR-2 items NOT carried into v5 (answered-in-spirit but absent in code)
> Sonnet verified these are still missing; Opus lists 2.1–2.6. Tick which land in v6.

- **V12 🟡 (B) SIEM differentiation** (I-M3-4) — all rows say "mock". Want Splunk "Connected
  (mock)" + "1 alert forwarded" flash on isolate? **Answer:** _<!-- -->_
- **V13 🟡 (B) Governance reactive DAO card** (I-M3-5, your G2 "you can add it") — add post-
  isolate "emergency threshold 0.85→0.75, auto-triggered by INC-991"? **Answer:** _<!-- -->_
- **V14 🟡 (B) Offline state on panels** (J-F4-6, your G11 "correct") — `offline` only toggles
  the lockbar; Chain/Telemetry unchanged. Make Chain show "⚠ Disconnected from Sui RPC"? **Answer:** _<!-- -->_
- **V15 🟢 (B) On-chain evidence accumulates per phase** (F4-7) — drawer evidence is one
  static line; should grow like the timeline. **Answer:** _<!-- -->_
- **V16 🟢 (B) Empty/loading states** (I-M3-6) — only Alerts has a real empty state; others
  show empty tables when idle. Add stubs/skeletons? **Answer:** _<!-- -->_
- **V17 🟢 (O) Onboarding "Simulate registration"** (F4-4) — a button → `phase='connected'`
  ties onboarding to CC* step 1. **Answer:** _<!-- -->_
- **V18 🟢 (O) Booth "live demo running — click to take over" overlay** (U2). **Answer:** _<!-- -->_
- **V19 🟢 (S) `.cards` triple-defined → ~4 sparse cols** (H-N2-1 still open). Want 2-col
  Talus? (I'll dedupe + remove legacy `.nav`/`.tab` CSS.) **Answer:** _<!-- -->_

## Part 4 — Dead code to remove (Sonnet PART 5 + N3-x) — confirm cleanup
- **V20 🟢** Remove dead: static `auditTrail` export, `fleet()` (superseded by `fleetAt`),
  the unused `defended` derived (or wire it into the Alerts row), legacy `.nav`/`.tab` CSS,
  the first `.cards{1fr 1fr}`, and the dead `{#if claudeModal}` 20-line block (L-B5=toast;
  the modal also has a tx-truncation mismatch `0x9aBc…01` vs `0x9aBcDeF…01`). **OK to delete
  all of this in v6?** **Answer:** _<!-- -->_

## Part 5 — Live backend (the real integration track — all blank)
- **V21 🔴 (B) `querySuiEvents` polling loop is absent** — defined in `adapter.ts`, never
  called; flipping `mock:false` changes nothing. Need: **W-a** Mowa backend build/run cmds
  (or a running endpoint); **W-b** WS endpoint + **message schema** (event types→fields);
  **W-c** Sui RPC URL + which `queryEvents` (module/type); **W-d** real Walrus gateway +
  digests; **W-e** auth model (wallet-signed / API key / open); **W-f** who owns the backend
  repo tomorrow. **Answer:** _<!-- -->_
- **V22 🟡 Mock-backend posture for a *public* demo** — must it be auth'd / CORS / rate-
  limited, or local-only/throwaway? **Answer:** _<!-- -->_

## Part 6 — CC* consistency, scope & brand (Parts N2/N3/O — still blank)
- **V23 🔴 (B) N1 priority order never confirmed** — A→B→C. Is it permanent, or does CC*
  ever override answers? Every agent since assumes A→B→C. **Answer:** _<!-- -->_
- **V24 🟡 (B) CC* semantics (N2):** (a) K8s framing (namespace cols / Lithium) correct or
  revert to generic host? (b) `NOT WORTHY` = `is_active=false` or a distinct on-chain
  `worthiness` field on `AgentIdentity`? (c) who triggers — presenter "Run CC*" / autoplay-
  booth / both? (d) kernel-only or also DDoS? **Answer:** _<!-- -->_
- **V25 🟡 (B) Scope (N3)** — final demo = **Alfa + mock-Beta tabs** (current), **pure Alfa**,
  or **fully-implemented Beta**? If pure Alfa, ~half the rail is clutter. **Answer:** _<!-- -->_
- **V26 🟡 (B) Brand (Part O)** — Keep / Tweak / **Regenerate** the color theme, mark,
  typography, CC* alert styling, motion? The build assumes "Keep". If "Regenerate", a
  gen-v2 brand pass runs before more features. **Answer:** _<!-- -->_

---

## Part 7 — ⭐ NEW: Analysis of improvements between the important deployments
> Unique to this phase (requested). How the live demo evolved across the 4 milestone
> deployments. Links/states are in `ai_internal_audit_log/deployments.md`.

| # | Deployment (build) | Headline change vs previous | Net effect |
|---|---|---|---|
| 1 | **v1 / v2** (Alfa MVP → improved) | v1: the CC* path (connect→healthy→attack→NOT WORTHY→Stripe banner) on client fixtures. v2: **Demo-mode autoplay**, scenario progress, un-stubbed Talus/Vulns, drawer callouts, trust footer. | Established the *story* and the Stripe-grade alert; from "wireframe" to "watchable demo". |
| 2 | **vX+1** (answers-driven, `4ae4…`) | Reorg to a **grouped left-rail** (Monitor/Detect/Respond/Platform); added **~12 Beta-as-mock surfaces** (personas, governance, compliance, MSSP, integrations, audit, threat-intel, modules, "other"), **incident tree**, **onboarding cmd**, **Walrus decrypt**, **K8s preview**, **WS markers**. | From "one screen" to a *platform* IA; honest mock/interactive tiers. |
| 3 | **vYY / vYY+1** (CR-1 fixes + ⌘K, `6b3e…`) | **adapter seam** (live/mock boundary), **NOT-OK logs**, **per-row Walrus decrypt + spinner**, reactive `connectCmd`, `onDestroy` cleanup, MSSP cycling, **⌘K command palette**. | Hardened correctness + a power-user accelerator; demo-fit for a guided walk. |
| 4 | **DDD / v5** (`7021…`, branch v3) | **Multi-endpoint defense** (ws-07 BLOCKED + alma9 NOT WORTHY), **ECharts** CPU chart, **Threat-level** column, **incident lifecycle** Open→Acked→Resolved + dynamic audit, **live Threat-Intel**, nav badges, responsive <1100px, **tree→drawer / Mute≠reset / real copy / 8s dwell**. | From "looks like a tool" to "**acts** like a tool" — an analyst action loop + a real chart. |

**Trajectory in one line:** *story (v1/v2) → platform IA (vX+1) → correctness & power-use
(vYY) → interactivity & realism (DDD).* **The consistent gap across all four:** ephemeral
hosting (no durable URL) and **no live data path** (mock only) — exactly the V2/V3/V21
items. Closing those is the step-change v6 should target, not more surfaces.

---

## Part 8 — Consolidated decision list (merge of both reviewers' question sets)
> Opus Q0–Q12 + Sonnet Q1–Q13, de-duplicated. Answer these and the ambiguity is gone.

| # | 🔴/🟡 | Decision | Maps to |
|---|---|---|---|
| D0 | 🔴 | Confirm priority **A→B→C** (permanent)? | V23 / N1 |
| D1 | 🔴 | Real domain (`thorium.her` typo → ?) | V1 |
| D2 | 🔴 | Stand up Mowa/Sui env for **real Walrus now**, or client-side mock for demo? | V2 |
| D3 | 🔴 | **Pin** the IPFS CID (token/node), or hash-only? | V3 |
| D4 | 🔴 | Talus card-1 static vs reactive (+ caption) | V4 |
| D5 | 🔴 | Render `kpiFlash`? | V5 |
| D6 | 🔴 | Walrus URL: real digest vs drop-guard | V6 |
| D7 | 🔴 | Refresh `AGENTS.md`/RUNBOOK to v5/v3 — confirm (done) | V7/V8 |
| D8 | 🟡 | Live-backend specifics (build, WS schema, Sui RPC, Walrus, auth, owner) | V21 |
| D9 | 🟡 | Which of V12–V19 land in v6? | Part 3 |
| D10 | 🟡 | CC* semantics (K8s, NOT-WORTHY field, trigger, DDoS) | V24 |
| D11 | 🟡 | Scope: Alfa+mockBeta / pure Alfa / full Beta | V25 |
| D12 | 🟡 | Brand: Keep/Tweak/Regenerate | V26 |
| D13 | 🟡 | Delete the dead code (V20) — OK? | V20 |
| D14 | 🟡 | `my-app/` deletable + root pointer? | V9 |
| D15 | 🟢 | Hash routing now or drop the rule? | V10 |

---

## Closing
- **The vision RFI** is [`questions_v4_to_v5_qa_LONG.md`](./questions_v4_to_v5_qa_LONG.md) —
  precise and ultimate; this file does not override it, it *operationalizes* the CR-3 doubts
  against it. Its Parts **G–O** remain the master backlog.
- After you answer: save `questions_v5_to_v6_qa_LONG_AUDIT.md`, then a new agent runs
  [`delivery/ITERATION-RUNBOOK.md`](./delivery/ITERATION-RUNBOOK.md) for v6 — **5-minute
  correctness first** (D1, D4, D5, V7/V8 done), then the **IPFS pin** (D3), then the
  **live-backend** track (D2/D8).
