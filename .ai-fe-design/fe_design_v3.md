# Thorium XDR — Frontend Design Spec **v3**

> Status: **v3** · Supersedes [`fe_design_v2.md`](./fe_design_v2.md) (v2 stays as
> history). · Branch: `experimental-aw-fe-v2`.
>
> **How v3 was derived — UPDATED:** the user then provided **real answers**
> ([`input/answers.md`](./input/answers.md), saved as
> [`questions_v2_to_v3_qa_AUDIT.md`](./questions_v2_to_v3_qa_AUDIT.md)). These
> **supersede** the earlier "adopted assumptions" draft and **expand scope**: keep a
> single role (C1) and CC* #1 (C3), but **surface most Beta concepts as labeled
> mock/non-functional tabs** (personas/roles, governance+$THOR, compliance/NIS2
> auditor view, MSSP tenant switcher, module catalog, web terminal, audit trail,
> SIEM integrations, privacy badges, offline-lockdown, threat-intel/deception,
> "other"), **plus real** additions: incident **correlation tree** (I3), **onboarding
> command generator** with mock invite (I12), **browser Walrus/Seal decrypt** (I4),
> **Talus correlation demo** (I5), **K8s example UI** (C2, non-functional), and
> **WebSocket integration markers** (I2). Live data = config + code markers, mock by
> default (C5); deploy target = **Unstoppable Domains + IPFS** (I9/I10). This is
> realized in the shipped **vX+1** build and recorded in
> [`adr/0008-vX1-answers-scope-leftrail.md`](./adr/0008-vX1-answers-scope-leftrail.md).
> Build/iteration procedure: [`delivery/ITERATION-RUNBOOK.md`](./delivery/ITERATION-RUNBOOK.md).

---

## 0. What v3 locks in (decisions from the adopted assumptions)

### Scope — **Alfa is the product; Beta is deferred**
- v3 = **Version Alfa**: a focused SOC console + the **CC\*** critical path (Defender
  IA · Walrus look · ELK/Datadog capability · blockchain domain).
- **Beta** (personas/RBAC, business models, $THOR/DAO, compliance/NIS2, MSSP
  multi-tenant, full module catalog — Part-3 diff) is **out of v3 scope**; surfaced
  only as "coming soon". (C1, C4, G1–G13.)

### Critical decisions (Part 1)
- **C1 Auth:** single SOC surface, wallet-connect gates writes; **no persona/RBAC** in
  v3 (→ Beta).
- **C2 Observed pod = a Kubernetes pod** (ties to roadmap **Lithium / Cloud-Native
  K8s**): the UI shows **namespace/cluster** context (the demo already labels
  `prod/edge`), and the CC\* attack is a kernel-exploit / container-escape vector.
- **C3 CC\* alert = the v2 choice:** persistent top **Critical Incident banner →
  Incident Command drawer** + pulsing **"NOT WORTHY"** badge. (Alternatives stay a
  Part-4 / separate-UX-thread exploration.)
- **C4 Milestone:** Overview · Endpoints · Incidents · **Alerts** · **Fleet
  Telemetry** · **Chain Activity** · VMs, plus **Talus AI** + **Vulnerabilities**;
  CC\* prominent. (Largely realized in the shipped demo.)
- **C5 Data:** **mock-by-default** (client-side contract-true fixtures / Prism);
  `config.json` switches to a live agent + Sui RPC.

### Important decisions (Part 2, adopted)
- Sui reads via **fullnode JSON-RPC `queryEvents` + `multiGetObjects`**; no indexer
  (I1, I6).
- **Polling** now; WebSocket later (I2 / ADR-0001).
- **Incidents** may become a **correlation tree** in a later pass; v3 ships a list +
  the CC\* kill-chain timeline (I3).
- **Walrus/Seal** rows shown **locked** ("🔒 Sealed"); decrypt on demand; no browser
  Seal SDK (I4).
- **Talus** read-only (threshold + classifications) (I5).
- **Multi-sig** = placeholder (I7).
- **IPFS**: boot-time `config.json` (`agentApiBase, suiRpcUrl, packageId, network,
  walrusGateway, mock`); base `'./'`, hash routing (I9).
- Error reporting: **none** (I11). Onboarding: guided "connect pod" = CC\* step 1
  (I12). Empty/loading/error states + offline-lockdown banner (I13). Time: relative +
  absolute, UTC, range picker (I15). Dark-only, compact later (I16). ⌘K nice-to-have
  (I17). Desktop-first (I18). Response actions stay **placeholders** in v3 (I19).

### Diff items (Part 3) → **Beta**
All of G1–G13 (personas, $THOR/DAO, compliance, MSSP, module catalog, live web
terminal, audit trails, SIEM export, privacy badges, spatial 3D, offline-lockdown
viz, deception/threat-intel, PAM) are **deferred to Beta**; v3 keeps them as
roadmap/"coming soon" affordances.

### UX excellence (Part 4) → separate thread
The CC\* presentation playbook + UX pass run in a dedicated thread (Part 4d prompt).

---

## 1. v3 = the realized Alfa demo

Unlike v1/v2 (spec-only), **v3 is realized**: a building, clickable, deployed Svelte
5 + TS + Vite app (gen-v2 ⊗ design v2, `--scope=alfa`) under
`.ignored/fe-demo/demo_designV2_genV2/`. v3 is the spec that demo conforms to + the
next increments.

**Implemented in the shipped demo:** shell + nav; Overview/Endpoints with the
observed-pod table; **Fleet Telemetry**; **Chain Activity** event feed; **Incidents**
+ **Alerts** (status); **Talus AI** detections; **Vulnerabilities** (Seal-sealed);
the **CC\* "Run scenario"** stepper + **Demo mode** auto-loop; the **Critical Incident
banner → Incident Command drawer** (kill-chain timeline, on-chain evidence, response
placeholders); scenario-progress indicator; trust footer. English-only.

**Deviations (tracked):** styling uses a hand-tuned theme CSS (ported from the proven
mockup) instead of Tailwind, and charts are lightweight SVG (ECharts/uPlot deferred)
— for build/deploy reliability. ADR-0002/0003 remain the target; revisit in v3→v4.

---

## 2. v3 increments (what to build next, on top of the demo)
Priority order, all within Alfa:
1. **Tailwind + ECharts/uPlot** pass (honor ADR-0002/0003): port the theme to Tailwind
   tokens; replace SVG sparklines with real charts on Fleet Telemetry + Overview KPIs.
2. **Incident correlation tree** (I3) for the Incidents view.
3. **Live data path**: wire `@mysten/sui.js` `queryEvents`/`multiGetObjects` behind
   the adapter; flip `config.json mock:false` to read Sui testnet `0x0cc3…91af`.
4. **Wallet-connect** real flow (gates the response actions; actions stay placeholder).
5. **K8s context** depth (C2): cluster/namespace facets, container-escape detail in the
   kill-chain.
6. **Empty/loading/error + offline-lockdown** states (I13).

---

## 3. Deployment (delivery) — v3 reality
- Local/LAN serving verified (`http://localhost:5173`, `http://192.168.0.251:5173`);
  public via **ngrok** (durable github.io Pages blocked by the **private** repo).
- Delivery is versioned (`delivery-v1` gh-pages · `delivery-v2` Actions · `delivery-v3`
  tunnel). See [`/README-deployment.md`](../README-deployment.md),
  [`/LIVE-DEMO.md`](../LIVE-DEMO.md), and
  [`ai_internal_audit_log/deployments.md`](./ai_internal_audit_log/deployments.md).
- **Lesson folded in:** verify reachable URLs against the *user's* DNS resolver, and
  prefer IP/LAN URLs when tunnel domains are filtered.

---

## 4. Carried forward unchanged
v2 §1–§8 (product context, design system, IA, data contract, architecture, IPFS,
a11y) and the **CC\*** binding (ADR-0007) still apply. v3 only states deltas.

## 5. Open items → v3→v4 / Beta
- Tailwind/ECharts adoption, incident tree, live Sui path (the §2 increments).
- Everything in Part 3 (Beta): personas, compliance, $THOR/DAO, MSSP, module catalog.
- A durable public deployment (needs repo public / Pages-for-private).
- The CC\* UX-excellence pass (separate thread, Part 4d).
