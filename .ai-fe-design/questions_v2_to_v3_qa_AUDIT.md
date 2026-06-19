# Questions: v2 → v3 — **AUDIT (answers)**

> **No explicit answers were provided** by the user for the v2→v3 round (the request
> "make the v3 design from v2→v3 answers" arrived with a deployment-error screenshot,
> not answers). Per the pattern the user established across v1→v2 ("the recommendation
> is a reasonable assumption"), **v3 adopts each question's documented `Assumption
> (v2)` as the decision.** This file records that mapping; the clean questions stay in
> [`questions_v2_to_v3_qa.md`](./questions_v2_to_v3_qa.md); the result is
> [`fe_design_v3.md`](./fe_design_v3.md).

## Decisions = adopted assumptions

**Part 1 (Critical)**
- **C1** → single SOC surface, wallet-connect gates writes; **no persona/RBAC** in v3
  (personas → Beta).
- **C2** → observed pod = **Kubernetes pod** (Lithium / Cloud-Native K8s); show
  namespace/cluster; attack = kernel-exploit / container-escape.
- **C3** → CC\* alert = **top banner → Incident Command drawer** + "NOT WORTHY" badge
  (the v2 choice).
- **C4** → Alfa milestone (Overview · Endpoints · Incidents · Alerts · Fleet Telemetry
  · Chain Activity · VMs · Talus · Vulnerabilities); CC\* prominent.
- **C5** → mock-by-default; `config.json` switches to live.

**Part 2 (Important)** — all adopted as written:
- I1 fullnode `queryEvents`/`multiGetObjects`, no indexer · I2 polling now, WS later ·
  I3 incident tree = later increment (v3 ships list + kill-chain) · I4 Walrus/Seal rows
  locked, decrypt on demand · I5 Talus read-only · I6 event-sourced telemetry · I7
  multi-sig placeholder · I8 wallet-connect, no app RBAC · I9 boot-time `config.json` ·
  I10 licensed pin provider + DNSLink (TBD) · I11 no error reporting · I12 guided
  connect-pod onboarding (= CC\* step 1) · I13 empty/loading/error + offline-lockdown ·
  I14 incident status client-side in demo · I15 relative+absolute UTC + range picker ·
  I16 dark-only, compact later · I17 ⌘K nice-to-have · I18 desktop-first · I19 response
  actions stay placeholders · I20 no perf budget yet · **I21 Alfa/Beta split confirmed**.

**Part 3 (Diff = Beta)** — G1–G13 **all deferred to Beta**; v3 keeps "coming soon"
affordances only.

**Part 4 (UX)** — CC\* presentation playbook + UX-excellence pass → **separate thread**
(Part 4d prompt). v3 keeps the v2 banner+drawer.

## If you disagree
Answer the matching item inline in `questions_v2_to_v3_qa.md`, then regenerate
`fe_design_v3.md` (or open a v3→v4 round) — the adopted assumptions are defaults, not
locks.
