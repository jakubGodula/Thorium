# Questions: v3 → v4 — **SHORT** (transition Q&A)

> Concise transition set (≈30% of the v2→v3 round). The exhaustive companion is
> [`questions_v3_to_v4_qa_LONG.md`](./questions_v3_to_v4_qa_LONG.md). Refreshed after
> **CR-1** (`input/cr/cr-1.md`) + the vYY (CR-fix) / vYY+1 (⌘K) deployments. Answer
> inline → save as `questions_v3_to_v4_qa_AUDIT.md` → run
> [`delivery/ITERATION-RUNBOOK.md`](./delivery/ITERATION-RUNBOOK.md). 🔴 blocks · 🟡 shapes · 🟢 polish.

## Critical 🔴
- **S1 — Durable public URL (CR D-1/D-3/P6).** ngrok is ephemeral; trycloudflare is
  DNS-blocked on your router. Pick: (a) make the repo **public** → GitHub Pages
  auto-deploys, or (b) give **Unstoppable Domains + IPFS** access (`thorium.crypto`?).
  **Answer:** _<!-- … -->_
- **S2 — Live profile in scope for v4? (CR A-1/P3, answer C5).** The adapter seam +
  `TODO(live)` markers now exist. Wire `@mysten/sui.js` + the WS now, or stay mock?
  **Answer:** _<!-- … -->_
- **S3 — WebSocket message schema (CR A-2/P2).** You said the WS "is already
  implemented" — **share the message shape / endpoint** so the receiver stubs become
  real. **Answer:** _<!-- … -->_

## Important 🟡
- **S4 — `thorium.crypto` real? (CR A-8/P1).** Is that the actual registered UD
  domain (used in footer/onboarding)? If not, give the correct one. **Answer:** _<!-- … -->_
- **S5 — Existing incident tree (CR A-3/P4).** You said it's "partly implemented" —
  point to that code, or does vYY's version supersede it? **Answer:** _<!-- … -->_
- **S6 — Invite token format (CR A-7/P5).** vYY uses `inv_8Qm4Zr2Tn9Kx7Wb3Yc6Hf1Ld`
  (`demo` tag). Good, or a specific real format? **Answer:** _<!-- … -->_
- **S7 — Tailwind + ECharts now? (ADR-0002/0003).** Do the real charting/Tailwind
  pass in v4? *Assumption: yes.* **Answer:** _<!-- … -->_

## Polish 🟢
- **S8 — Personas: top-level tab or under Platform? (CR A-6).** Currently under
  Platform. **Answer:** _<!-- … -->_
- **S9 — Which mock surface becomes REAL first?** (Compliance / Governance /
  Integrations / Audit / Threat-Intel). Rank top 2. **Answer:** _<!-- … -->_

## ▶ Next-agent prompt
> Read `input/answers_v4.md` (if present) + the AUDIT of this file, then **follow
> `delivery/ITERATION-RUNBOOK.md`** to ship v4 (archive → ADRs → build → deploy
> ngrok+LAN verified via `192.168.0.1` → sync tracked copy → docs → next Q&A
> short+long → prompts → push with the URL prominent). Don't ask — decide & document.
