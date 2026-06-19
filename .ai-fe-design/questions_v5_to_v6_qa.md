# Questions: v5 → v6 — doubts & unknowns (concise)

> ≤50% of the LONG round. Only what DDD (v5) left genuinely open. Answer inline →
> `…_AUDIT.md` → run [`delivery/ITERATION-RUNBOOK.md`](./delivery/ITERATION-RUNBOOK.md).
> 🔴 blocks · 🟡 shapes · 🟢 polish.

## 🔴 Live backend (the big one — L-A1/A2/A4/E5)
You said connect the real backend from **github.com/jakubGodula/Mowa** + Thorium
`experimental` branch, compiled with Mowa (needs **sui-cli + cargo**). I could **not**
do that in a FE iteration (no backend build env). To wire it in v6 I need:
- **W1** The exact build/run commands for the Mowa backend (or a running endpoint URL). **A:** _<!-- -->_
- **W2** The **WS endpoint + message schema** (event types → fields) for `applyLiveEvent`. **A:** _<!-- -->_
- **W3** The **Sui RPC URL** + which `queryEvents` (module/type) the FE should poll. **A:** _<!-- -->_
- **W4** Real **Walrus** gateway + blob digests (the demo CID/fetch is mock; G-R1-2). **A:** _<!-- -->_

## 🔴 Domain & IPFS (L-A8/L-C1)
- **W5** `thorium.her` (your L-A8 answer) — is that the real Unstoppable Domain, or
  `thorium.crypto`/other? (It's in the footer + onboarding cmd.) **A:** _<!-- -->_
- **W6** The DDD build CID is `bafybeici77…czq` (only-hash). **Pin it** where (your
  IPFS node / Pinata / web3.storage) so it resolves publicly, or shall I attempt a pin? **A:** _<!-- -->_

## 🟡 Incident tree & Tailwind
- **W7** You said the incident tree is "partly implemented" in `experimental` — should
  v6's tree **align with / replace** that code? Point me to the file. **A:** _<!-- -->_
- **W8** Full **Tailwind** migration (L-E1) — DDD adopted ECharts only; do the Tailwind
  pass in v6, or keep theme CSS? **A:** _<!-- -->_

## 🟡 Carried-over (still blank in the LONG Q&A)
Parts **G–O** of `questions_v4_to_v5_qa_LONG.md` were unanswered — most relevant now:
- **W9** **Brand/theme** (Part O) — Keep / Tweak / Regenerate? (Biggest subjective call.) **A:** _<!-- -->_
- **W10** Backend security/config for tomorrow (Part N7) — is the mock/real backend
  expected to be auth'd/CORS/rate-limited, or local-only? **A:** _<!-- -->_

## 🟢 Confirm DDD choices
- **W11** Multi-endpoint demo (ws-07 defended + alma9 NOT WORTHY) — right shape? **A:** _<!-- -->_
- **W12** Incident status Open→Acked→Resolved client-side now, Walrus later — OK? **A:** _<!-- -->_
- **W13** ECharts CPU chart on Fleet Telemetry — keep/extend (ram/disk, more pods)? **A:** _<!-- -->_

> Everything not asked here is either decided (ADR-0010) or already parked in the
> LONG Q&A Parts G–O (still the master backlog).
