# Questions: v3 → v4 (concise)

> Deliberately short (~30% of the v2→v3 round). Only the **genuinely-open** items
> after vX+1 (answers-driven build). Each: **Assumption** · **Answer:** (fill inline,
> then save as `questions_v3_to_v4_qa_AUDIT.md` and run the
> [`delivery/ITERATION-RUNBOOK.md`](./delivery/ITERATION-RUNBOOK.md) for v4).
> Legend: 🔴 blocks · 🟡 shapes · 🟢 polish.

## Critical 🔴
- **V1 — Live endpoints (flip mock→live).** You said you'd provide the Sui RPC URL
  later (I1) and that WebSocket already exists (I2). **Provide:** `suiRpcUrl`,
  `wsUrl`, agent host, `walrusGateway`. (Config keys + `TODO(live)` markers are
  already in place.) **Answer:** _<!-- … -->_
- **V2 — Durable public URL.** ngrok is ephemeral; trycloudflare is blocked by your
  DNS. For a permanent link, pick: (a) make the repo **public** → GitHub Pages auto-
  deploys, or (b) give **Unstoppable Domains + IPFS** access (your stated target,
  I9/I10). **Answer:** _<!-- … -->_
- **V3 — Which mock surfaces become REAL in v4?** vX+1 ships Compliance, Governance,
  Integrations, Audit, MSSP, Personas, Threat-Intel, Modules as **mock**. Rank the
  top 2–3 to implement for real next. **Answer:** _<!-- … -->_

## Important 🟡
- **V4 — Tailwind + ECharts pass?** vX+1 uses ported theme CSS + SVG (ADR-0002/0003
  deferred for build reliability). Do the real charting/Tailwind pass now? *Assumption:
  yes, in v4.* **Answer:** _<!-- … -->_
- **V5 — Incident tree:** you wanted "my version" (I3) — is the correlation-tree shape
  right, or change grouping (by kill-chain stage / by pod / by tactic)? **Answer:** _<!-- … -->_
- **V6 — CC\* UX-excellence pass** (Part-4 separate thread): run it now to push the
  alert to best-in-class? *Assumption: separate thread, on request.* **Answer:** _<!-- … -->_
- **V7 — Onboarding/invite (I12):** keep the mock invite token until the invite
  contract ships, or wire a real `register_agent` PTB via wallet now? *Assumption:
  mock until contract.* **Answer:** _<!-- … -->_
- **V8 — Incident status storage (I14):** Walrus vs on-chain for real (demo uses
  client-side). When do we move it? **Answer:** _<!-- … -->_

## Polish 🟢
- **V9 — K8s example UI depth (C2):** current is a non-functional namespace/cluster
  preview — add a container-escape kill-chain detail, or leave as preview? **Answer:** _<!-- … -->_
- **V10 — Personas/RBAC:** still single-role (C1). Trigger the role switcher when Beta
  starts? **Answer:** _<!-- … -->_

## ▶ Prompt for the next agent (copy-paste)
> Read `input/answers_v4.md` (when present), `input/DEMO.md`, `fe_design_v3.md`, the
> ADRs, and **follow `delivery/ITERATION-RUNBOOK.md` step by step** to ship v4:
> archive vX+1 → ingest answers → ADRs → build (interactive vs mock tiers; live =
> config+markers) → deploy local+ngrok (verify via the user's resolver `192.168.0.1`,
> never trycloudflare) → sync tracked copy → update design/deployments/README →
> write `questions_v4_to_v5_qa.md` (≤50% length) → archive prompts → push with the
> remote URL prominent in the last commit. English-only, IPFS-safe, token-cautious
> (≤1–2 improve rounds). Don't ask — decide and document.
