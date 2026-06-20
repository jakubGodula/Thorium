# ▶ Colleague hand-off — answer the RFI + see the demo

> Self-reviewed 2026-06-20 (CR-3 round): every link verified to exist; demo URL verified
> HTTP 200; IDs/attributions corrected. Kept in-repo so it can't drift.

## 1) See the live demo
**https://7021-213-134-178-35.ngrok-free.app/?cc=1** — one-time ngrok "Visit Site"; press
**⌘K** for the command palette. *(DDD / v5, branch `experimental-aw-fe-v3`.)*
- ⚠️ **Ephemeral** (ngrok dies with the process). If down: current URL + refresh command
  are in [`/LIVE-DEMO.md`](../LIVE-DEMO.md) and
  [`ai_internal_audit_log/deployments.md`](./ai_internal_audit_log/deployments.md).
- For a **durable** link, pin the IPFS CID `bafybeici77d4xq7mdwo7xgwyl4dfxolog3uereebcwfwuxnnaw4jiidczq` (see P.1c below).

## 2) ⭐ Fill in THE document — the ultimate RFI (~15–45 min)
**[`questions_v4_to_v5_qa_LONG.md`](./questions_v4_to_v5_qa_LONG.md)** — the precise,
append-only vision RFI. Answer every `**Answer:**`. It ends with **Part P** (the CR-3
refinements). The fast-path **🔴** that unblock v6:
- **P.0** — confirm the priority rule **A `answers.md` → B CC\* → C docs**.
- **P.1a domain** (`thorium.her` isn't a valid UD TLD → what's real?), **P.1d Talus card-1**
  (static vs reactive + caption), **P.1e KPI flash** (render it?) — *5-minute correctness.*
- **P.1c** — **pin the IPFS CID** (a Pinata/web3.storage token or your node) → a durable URL.
- **P.6** — the live **Mowa backend** (build cmds, WS schema, Sui RPC, real Walrus blobs,
  auth, owner) — the #1 technical risk.
- **P.2** answer Parts G–O once · **P.7** scope (Alfa/Beta) + **brand Keep/Tweak/Regenerate**.

## 3) Companion (optional, deeper)
[`questions_v5_to_v6_qa_LONG.md`](./questions_v5_to_v6_qa_LONG.md) — the per-finding ledger
(decisions **D0–D15** map 1:1 to the P-items above) **and its Part 7 = the analysis of how
the demo evolved** (v1/v2 → vX+1 → vYY → DDD). The short version is
[`questions_v5_to_v6_qa.md`](./questions_v5_to_v6_qa.md).

## Orient in <1 min
- All deployments + URLs → [`ai_internal_audit_log/deployments.md`](./ai_internal_audit_log/deployments.md).
- How the demo evolved → **Part 7** of `questions_v5_to_v6_qa_LONG.md`.
- My read on the build → [`prompts/init/cr3-understanding-and-opinion.md`](./prompts/init/cr3-understanding-and-opinion.md).
- Repo/agent orientation → [`AGENTS.md`](./AGENTS.md) (refreshed to v5 / branch v3).

## When done
Save your answers as `questions_v4_to_v5_qa_LONG_AUDIT.md` (and/or drop `input/answers_v6.md`),
then a new agent runs [`delivery/ITERATION-RUNBOOK.md`](./delivery/ITERATION-RUNBOOK.md) to
ship v6 — **5-minute correctness first** (P.1a/P.1d/P.1e), then **pin IPFS** (P.1c), then the
**live-backend** track (P.6).

> Two honest reminders: the ngrok URL dies with the process (pin the IPFS CID for a durable
> link), and the data is **mock** until the live backend (P.6) is wired.
