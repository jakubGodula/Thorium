# Questions: v2 → v3 (organized: Critical · Important · Diff · UX)

> Round to take [`fe_design_v2.md`](./fe_design_v2.md) → **v3** (first implemented
> demo). Each item: **Assumption (v2)** (what we proceed under so nothing blocks) ·
> **Question** (confirm/override) · **Answer:** (fill inline).
>
> Flow: answer inline → save answered copy as `questions_v2_to_v3_qa_AUDIT.md` →
> generate `fe_design_v3.md`. Grounding: confirmed on-chain model
> [`assumptions_v1.md`](./assumptions_v1.md); v1→v2 decisions
> [`questions_v1_to_v2_qa_AUDIT.md`](./questions_v1_to_v2_qa_AUDIT.md); ADRs
> [`adr/`](./adr/); ⭐ critical demo [`input/DEMO.md`](./input/DEMO.md); **source
> material** [`input/roadmap_en.html`](./input/roadmap_en.html) (full roadmap) +
> [`input/presentation_en.html`](./input/presentation_en.html) (business models +
> personas + tech advantages).
>
> **Structure:** Part 1 Critical (≤5) · Part 2 Important (~20) · Part 3 Diff vs
> roadmap/presentation (as questions) · Part 4 Optional UX track (+ agent prompt).
> Legend: 🔴 blocks v3 · 🟡 shapes scope · 🟢 polish.

---

# PART 1 — CRITICAL (answer these first) 🔴

### C1 🔴 Personas / RBAC — does v3 model the 5 roles?
**Why:** `presentation_en.html` defines five roles — **Internal Admin · SOC
Freelancer · MSSP Agency (multi-tenant) · NIS2 Auditor (read-only) · Insurance
Adjuster (read-only)** — each implying a different surface (capabilities, tenancy,
read-only). This is the single biggest IA decision.
**Assumption (v2):** single "analyst/admin" surface gated by wallet-connect; no role
switching.
**Question:** For v3, do we add a **role switcher + role-scoped views** (at least
Admin vs Auditor read-only vs MSSP multi-tenant), or stay single-role for the demo?
**Answer:** _<!-- fill in -->_

### C2 🔴 CC* observed pod = a Kubernetes pod (ties to "Lithium / Cloud-Native K8s")?
**Why:** the roadmap lists **Lithium — Native K8s protection (Admission Controller)
+ container-escape detection**. CC* says "connect a new **pod**." If the observed
pod is a K8s pod, CC* should show namespace/cluster context and a container-escape
attack, not just a generic host.
**Assumption (v2):** observed pod = generic monitored endpoint (`AgentIdentity`
SBT); attack = kernel exploit/DDoS.
**Question:** Confirm pod = K8s pod (show cluster/namespace + container-escape), or
keep it a generic host for v3?
**Answer:** _<!-- fill in -->_

### C3 🔴 CC* alert presentation — final pick (see Part 4 playbook)
**Assumption (v2):** #1 **top banner → Incident Command drawer** + pulsing
"NOT WORTHY" badge (rendered mockup in `demo-gen/gen-v2/mockup/`).
**Question:** Keep #1, or combine (e.g. #1 + #5 fleet-map beacon; or #2 War-Room
takeover for the live demo)? Record motion/sound choices. (Full catalog: Part 4.)
**Answer:** _<!-- fill in -->_

### C4 🔴 v3 implemented scope
**Assumption (v2):** Milestone 1 = Overview · Endpoints · Incidents · VMs · **Alerts**
+ the CC* path + Chain Activity + Fleet Telemetry, in a Datadog-style shell;
everything else (the long roadmap tail) = "coming soon" tiles.
**Question:** Confirm the v3 build scope and what is explicitly out (Part 3 lists the
candidates).
**Answer:** _<!-- fill in -->_

### C5 🔴 Demo data source for v3
**Assumption (v2):** mock-by-default (Prism on :4010); `config.json` flag switches to
a live agent + Sui testnet RPC.
**Question:** Confirm mock-by-default; if you want a live profile too, give the
testnet RPC URL + a reachable agent host.
**Answer:** _<!-- fill in -->_

---

# PART 2 — IMPORTANT 🟡

### I1 🟡 Sui read endpoint
**Assumption:** fullnode JSON-RPC `queryEvents` + `multiGetObjects`; no indexer.
**Question:** RPC URL (default `https://fullnode.testnet.sui.io`)? GraphQL? limits?
**Answer:** _<!-- fill in -->_

### I2 🟡 Realtime upgrade (roadmap explicitly says "WebSockets" for the SOC Dashboard)
**Assumption:** polling now (agent 5s / Sui 10s); WS later.
**Question:** The roadmap item "SOC Dashboard (Svelte): live state sync via
WebSockets, incident tree" — does a WS endpoint exist to target in v3?
**Answer:** _<!-- fill in -->_

### I3 🟡 Incidents as a **tree** (roadmap: "Incident tree implementation")?
**Assumption:** flat incident list/table.
**Question:** Should Incidents be a **correlation tree** (kill-chain / cross-device
grouping) rather than a flat list?
**Answer:** _<!-- fill in -->_

### I4 🟡 Walrus / Seal (SEAL homomorphic) access
**Assumption:** sealed rows locked; decrypt via agent/wallet on demand; no browser SDK.
**Question:** Direct browser fetch+decrypt, or proxy via agent? (Presentation stresses
SEAL/MPC privacy — surface it as a trust signal?)
**Answer:** _<!-- fill in -->_

### I5 🟡 Talus admin controls
**Assumption:** read-only `anomaly_threshold` + recent classifications.
**Question:** Expose admin `update_threshold` / `authorize_ai_agent` in v3?
**Answer:** _<!-- fill in -->_

### I6 🟢 Telemetry depth (Datadog vs ELK vs Walrus → "Datadog UX, event-sourced")
**Assumption:** gauges + sparkline from recent events; no TSDB/indexer.
**Question:** Accept event-sourced (no long history) for v3?
**Answer:** _<!-- fill in -->_

### I7 🟡 Multi-Sig (roadmap: 2-of-3 hardware/WebAuthn)
**Assumption:** placeholder only.
**Question:** Confirm placeholder for v3.
**Answer:** _<!-- fill in -->_

### I8 🟡 Auth model
**Assumption:** wallet-connect gates writes; on-chain `admin` enforced; no app RBAC.
**Question:** (See C1.) If roles are needed, where is the role source of truth?
**Answer:** _<!-- fill in -->_

### I9 🔴 IPFS runtime config
**Assumption:** boot-time `config.json` (`agentApiBase`, `suiRpcUrl`, `packageId`,
`network`, `walrusGateway`, `mock`).
**Question:** Confirm keys/approach.
**Answer:** _<!-- fill in -->_

### I10 🟡 IPFS provider / ENS / DNSLink
**Assumption:** licensed pinning provider + DNSLink/ENS; CID in footer.
**Question:** Which provider? ENS/DNSLink name?
**Answer:** _<!-- fill in -->_

### I11 🟢 Error/telemetry reporting
**Assumption:** none (privacy + decentralization).
**Question:** Keep none?
**Answer:** _<!-- fill in -->_

### I12 🟡 Onboarding — "connect a new observed pod" flow
**Assumption:** guided flow (wallet-signed `register_agent`) + agent install snippet;
in the demo it's CC* step 1.
**Question:** Confirm the onboarding UX.
**Answer:** _<!-- fill in -->_

### I13 🟡 Empty / loading / error states (per screen)
**Assumption:** skeletons, empty states with a primary action, chain/agent-unreachable
banner (ties to "Offline Lockdown / Dark Mode").
**Question:** Confirm; define per screen.
**Answer:** _<!-- fill in -->_

### I14 🟡 Incident lifecycle / status (open/ack/resolved/false-positive) + assignee
**Assumption:** status+assignee overlay on on-chain `IncidentReport`; client-only in demo.
**Question:** Where is status stored (client/agent/chain)?
**Answer:** _<!-- fill in -->_

### I15 🟢 Time handling (tz, relative vs absolute, range picker)
**Assumption:** relative + absolute on hover; UTC default; Datadog-style range picker.
**Answer:** _<!-- fill in -->_

### I16 🟢 Density / theming (compact, light, prefs)
**Assumption:** dark only; compact later.
**Answer:** _<!-- fill in -->_

### I17 🟢 Command palette (⌘K)
**Assumption:** ⌘K navigate + jump to incident/pod; nice-to-have.
**Answer:** _<!-- fill in -->_

### I18 🟡 Responsive / mobile
**Assumption:** desktop-first 1280px+, graceful to 1024; no mobile.
**Answer:** _<!-- fill in -->_

### I19 🟡 Real response actions vs placeholder
**Assumption:** all CC* response actions stay placeholders in v3.
**Question:** Any made real (which backend)?
**Answer:** _<!-- fill in -->_

### I20 🟢 Performance / bundle budget
**Assumption:** no hard budget for the demo; optimization pass later.
**Answer:** _<!-- fill in -->_

### I21 🟢 Alfa vs Beta scope boundary (low priority — already decided, confirm)
**Context:** the demo is parameterized `--scope=alfa|beta` (**alfa default**). Alfa =
focused SOC console + CC* (Defender IA / Walrus look / ELK-Datadog capability /
blockchain domain). Beta = Alfa + the roadmap/presentation breadth (all of Part 3:
personas, business models, $THOR/DAO, compliance, MSSP, module catalog). See
[`../README-for-human.md`](../README-for-human.md).
**Assumption (v2):** Alfa is the line above; demo ships Alfa by default.
**Question:** Confirm the Alfa/Beta split (and any item you'd move across the line).
**Answer:** _<!-- fill in -->_

---

# PART 3 — DIFF: roadmap/presentation vs the actual demo (as questions) 🟡

> **These items collectively define Version Beta.** Version **Alfa** (the demo's
> default scope) deliberately excludes them; answering them here decides what a Beta
> build would add. See [`../README-for-human.md`](../README-for-human.md).

> Gap analysis. These concepts appear in `roadmap_en.html` /
> `presentation_en.html` but are **absent from the v2 design/demo**. Each: should v3
> surface it (even as a "coming soon" placeholder)? Default assumption unless noted:
> **roadmap/coming-soon tile only** (keep the demo focused on the SOC loop + CC*).

### G1 🔴 Business-model / persona framing (the presentation's core)
Internal SOC · MSSP/Outsourcing · Compliance-as-a-Service · Web3/Freemium. Surface as
a persona/role lens in the UI, or keep out of the SOC demo? (See C1.)
**Answer:** _<!-- fill in -->_

### G2 🟡 $THOR token economy + DAO policy voting (Web3/Freemium)
Earn $THOR for reporting zero-days; DAO voting on policy rules. Add a
"Network / Governance" screen, or omit?
**Answer:** _<!-- fill in -->_

### G3 🟡 Compliance-as-a-Service (NIS2 / KSC)
Chain-of-custody, immutable Walrus evidence, read-only access for authorities/insurers,
Pay-As-You-Go Walrus. Add a **Compliance** screen + read-only auditor view?
**Answer:** _<!-- fill in -->_

### G4 🟡 MSSP multi-tenant fleet
Shared fleet management across multiple clients; RBAC for external operators. Add a
**tenant switcher** + cross-tenant fleet view?
**Answer:** _<!-- fill in -->_

### G5 🟡 Module breadth as roadmap tiles
Lithium(K8s) · Neon(SSL inspection) · Xenon(Deception/Honeypots) · Silicon(UEBA) ·
Titanium(DLP) · Aluminum(Email) · DNS/USB DLP · YARA(Magnesium). Show as a
roadmap/"coming soon" catalog in-app, or omit?
**Answer:** _<!-- fill in -->_

### G6 🟡 Live Web Terminal (DFIR)
Remote CLI console in the incident view. Add as a placeholder panel in Incident
Command (great CC* response affordance)?
**Answer:** _<!-- fill in -->_

### G7 🟡 Analyst Audit Trails (every analyst action as an immutable on-chain tx)
Surface an **audit log** of analyst actions (insider-threat protection)?
**Answer:** _<!-- fill in -->_

### G8 🟡 SIEM export + Webhooks (Splunk / QRadar / Syslog CEF)
Add an **Integrations** screen (export targets, webhooks, ITSM Jira/ServiceNow)?
**Answer:** _<!-- fill in -->_

### G9 🟢 Privacy/trust messaging (SEAL homomorphic, Magnesium MPC, eBPF zero-overhead)
The presentation leans hard on "we never read your plaintext." Surface these as trust
badges / an explainer in the UI?
**Answer:** _<!-- fill in -->_

### G10 🟢 Spatial SOC (3D Kill-Chain, R&D) → influences CC* alert option #5?
Does the future 3D/topology view change how we design the CC* fleet-map beacon now?
**Answer:** _<!-- fill in -->_

### G11 🟢 Offline Lockdown / Dark Mode (agent loses C2 / Sui RPC)
Visualize a fleet/agent "lockdown" state (lost-comms emergency)?
**Answer:** _<!-- fill in -->_

### G12 🟢 Threat Intel (STIX/TAXII, MISP) + Deception alerts (zero-FP honeytokens)
Surface IoC feeds and honeytoken-trip alerts (the latter are "100% certain" — great
for the Alerts view)?
**Answer:** _<!-- fill in -->_

### G13 🟢 Out-of-FE-scope confirm (Hydrogen PAM/FIDO2, A/B Auto-Updater, Mowa JIT)
Assumed **not** in the frontend. Confirm these stay agent/infra-only.
**Answer:** _<!-- fill in -->_

---

# PART 4 — OPTIONAL: dedicated UX/UI excellence track (separate thread) 🟢

> The demo (esp. **CC\***) must be best-in-class. That deserves its own focused
> thread. This part = (a) the CC* presentation playbook, (b) UX references, (c) a
> ready-to-paste **prompt for another AI agent** to run the excellence pass.
>
> **Scope note:** the UX excellence pass targets **Version Alfa** (the focused SOC
> console + CC*) by default — that is where the demo's quality bar lives. Beta-only
> surfaces (personas, compliance, governance) get their own UX pass once scoped.

## 4a. CC* presentation playbook (catalog of options)
1. **Top banner → Incident Command drawer** *(v2 default; rendered in `demo-gen/gen-v2/mockup/`)* — sticky/floating · drawer right/bottom · auto-open vs click.
2. **Full-screen "War Room" takeover** on CRITICAL — max drama; risk: hijacks app.
3. **Toast / notification stack** — many alerts; risk: miss the big one.
4. **Command-palette / spotlight (⌘K)** — power users; risk: invisible to a cold audience.
5. **Live map / topology beacon** (→ R&D Spatial SOC 3D) — spatial "where"; pairs with #1.

**Cross-cutting levers:** motion (entrance/pulse/climax) · subtle sound vs none ·
the before→after device ("Healthy 40s ago" → "Auto-isolated in 2s") · severity color
+ icon (never color alone) · inline on-chain proof (tx digest, event JSON) · the
automation-speed payoff (Δt detection→isolation) · reduced-motion fallback.

## 4b. UX references / methods
- **Comparators:** Stripe Radar/Dashboard alerts · Linear notifications · Datadog
  monitors/incidents · PagerDuty/Opsgenie timelines · Sentry/Vercel issue alerts ·
  Grafana/Kibana alerting.
- **Methods:** 5-second test · first-click test · banner-vs-takeover A/B ·
  severity-perception study · WCAG-AA contrast audit · reduced-motion check.
- **Sources:** NN/g (alerts & notifications), Refactoring UI (hierarchy), Apple HIG /
  Material on critical alerts, IBM Carbon + Atlassian status/notification patterns.
  *(Add your team's preferred links here.)*

## 4c. Open UX questions
- **U1 🟢** Final CC* presentation (mirror of C3) + motion/sound spec.
- **U2 🟢** A "demo mode" toggle that auto-plays CC* for unattended booths?
- **U3 🟢** Should healthy→compromised use an animated transition (morph) or hard cut?
- **U4 🟢** Sound on CRITICAL — yes/no, and which (subtle vs alarm)?

## 4d. ▶ Prompt for a separate AI-agent thread (copy-paste)
> **Role:** Senior product designer + Svelte/Tailwind engineer. **Goal:** take the
> Thorium XDR demo (gen-v2 ⊗ design v2) and elevate the **CC\*** critical alert to
> best-in-class (Stripe/Linear/Datadog bar).
> **Inputs:** `.ai-fe-design/input/DEMO.md`, `fe_design_v2.md` §8.5,
> `adr/0007`, `demo-gen/gen-v2/mockup/cc-alert.html` (current target),
> `demo-gen/gen-v2/improve-loop.md`, and Part 4 above.
> **Do:** (1) implement 2–3 of the Part-4a presentations as switchable variants;
> (2) run the gen-v2 auto-improvement loop with cheap-model critics across the 5
> UX lenses for ≤3 rounds; (3) produce before/after screenshots + an
> `improvement-log.md`; (4) WCAG-AA + reduced-motion pass; (5) recommend one winner
> with rationale. **Constraints:** English only, dependency-light, IPFS-safe, do not
> break the OpenAPI/mock contract. **Output:** updated components + screenshots +
> a short decision memo. Spend tokens generously here — this thread is *about*
> quality.

---

### After answering
1. Save answers; copy this answered file to `questions_v2_to_v3_qa_AUDIT.md`.
2. Generate `fe_design_v3.md` = v2 + Part 1–3 decisions (Part 4 → separate UX thread).
3. Open `questions_v3_to_v4_qa.md` for anything still open.
4. `git add .ai-fe-design/ && git commit && git push origin HEAD:experimental-aw-fe-v2`.
