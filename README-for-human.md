# Thorium XDR — Frontend Demo (for humans)

A plain-language guide to **what the demo is**, the **two scopes (Alfa / Beta)**, and
**how to run & deploy it**. For the agent/spec entry points see
[`README.md`](./README.md), [`AGENTS.md`](./AGENTS.md), and
[`.ai-fe-design/`](./.ai-fe-design/).

---

## The two scopes — Alfa vs Beta

The same design produces **two very different products** depending on whether the big
roadmap/business files are in scope. This is now a **parameter** of the demo generator
(`--scope=alfa|beta`, **alfa is the default**).

### 🅰️ Version **Alfa** *(default)* — the focused SOC console
> "Only the critical part of the application — like **Microsoft Defender** in
> structure, the **look & feel of Walrus/SUI**, the capabilities of **ELK / Datadog**,
> but in the **blockchain domain**." Centered on the **CC\*** critical demo path.

In scope: **Overview · Endpoints · Incidents · Alerts · Fleet Telemetry · Chain
Activity · VMs** (+ Talus / Vulnerabilities / Polonium as light tabs), with the
**CC\*** critical path (observed pod → healthy → attack → NOT WORTHY → prominent
alert) front and center.

Out of scope (that's Beta): personas/RBAC, business models, $THOR/DAO, compliance,
MSSP multi-tenant, the full module catalog.

### 🅱️ Version **Beta** — Alfa **plus** the two big files
> Alfa **plus** everything implied by
> [`.ai-fe-design/input/roadmap_en.html`](./.ai-fe-design/input/roadmap_en.html) and
> [`.ai-fe-design/input/presentation_en.html`](./.ai-fe-design/input/presentation_en.html).

Adds the **5 personas** (Internal Admin · SOC Freelancer · MSSP Agency · NIS2 Auditor
· Insurance Adjuster) + role-scoped views, the **4 business models**, **$THOR token /
DAO governance**, **Compliance-as-a-Service (NIS2)**, **MSSP multi-tenant**, and the
broader **module catalog** (Lithium/K8s, Neon, Xenon, Silicon, Titanium, …).

> **Why it matters:** adding those two files "changes everything" — it turns a SOC
> tool into a multi-persona Web3 security *platform*. The full gap is catalogued as
> **Part 3 (Diff)** in
> [`.ai-fe-design/questions_v2_to_v3_qa.md`](./.ai-fe-design/questions_v2_to_v3_qa.md).
> **The demo defaults to Alfa**; Beta is opt-in.

---

## Run the demo locally
The generated demo lives under `.ignored/fe-demo/demo_designV2_genV2/` (gitignored —
it's a build artifact). It is **Version Alfa by default**. **Use the absolute path**
(the `app/` is one level deeper):

```bash
cd /Users/macbook/work/Thorium/.ignored/fe-demo/demo_designV2_genV2/app
npm install
npm run demo          # app on http://localhost:5173  (+ Prism mock on :4010)
# open http://localhost:5173  →  click "▶ Run CC* scenario"   (or /?cc=1)
```

- **Clickable** SOC console; **CC\*** is a guided, manual walk-through (the
  "Run CC\* scenario" button steps connect → healthy → attack → NOT WORTHY → alert).
- **Living mocks:** the Prism mock serves the agent + Sui-event contract; the CC\*
  scenario also runs deterministically client-side.

## Deploy (remote)
- **Remote (GitHub Pages, auto-deploy):** **https://jakubgodula.github.io/Thorium/**
  (CC* deep-link: `…/Thorium/?cc=1`), published by GitHub Actions (FE
  **delivery-v2**). ⚠️ **Not live yet:** the repo is **private**, so Pages must be
  enabled once (GitHub Pro, or publish from a public repo). The workflow +
  `gh-pages` branch are ready and the build is verified to serve over a public URL —
  it'll go live the moment Pages is allowed. One click, no code change.
- **IPFS / any static host:** `npm run build` → host `dist/` (IPFS-safe: `base:'./'`,
  hash routing) or `ipfs add -r dist`.

> Honest live-status + how to flip it on:
> [`.ai-fe-design/ai_internal_audit_log/STATUS.md`](./.ai-fe-design/ai_internal_audit_log/STATUS.md).

---

## Where everything is
- Design: [`.ai-fe-design/`](./.ai-fe-design/) (v1 → v2; questions; ADRs; brand).
- Demo generators: [`.ai-fe-design/demo-gen/`](./.ai-fe-design/demo-gen/)
  (`gen-v2` recommended; `--scope=alfa|beta`).
- ⭐ Critical demo case: [`.ai-fe-design/input/DEMO.md`](./.ai-fe-design/input/DEMO.md).
