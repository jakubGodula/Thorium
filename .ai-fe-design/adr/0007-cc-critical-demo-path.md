# ADR-0007: CC* — the critical demo path is a binding, first-class requirement

**Status:** Accepted (v2) — binding on every design version and generated demo
**Date:** 2026-06-19

## Context
The product's headline demo is a single narrative: an **observed pod** is connected
and blockchain-attested, runs healthy, is **attacked (kernel/DDoS)**, gets marked
**NOT WORTHY**, and a **prominent, Stripe-grade alert** drives response. Full
narrative in [`../input/DEMO.md`](../input/DEMO.md) ("CC*").

## Decision
CC* is a **binding requirement**, not a nice-to-have:
- The frontend MUST make CC* **prominent, very well visible, elegant and modern**.
- Map CC* to the real on-chain model: observed pod = `AgentIdentity` SBT; connect =
  `register_agent`/`AgentRegistered`; healthy = `TelemetryReported` OK +
  `is_active=true`; attack/detection = `ClassificationReported`
  (`anomaly_score ≥ threshold` → `TRIGGER_ISOLATION`) + `IncidentReport` CRITICAL;
  not worthy = `is_active=false` / Isolated.
- **v2 alert presentation (decided):** persistent top **Critical Incident banner**
  → **Incident Command drawer** with a live kill-chain timeline + on-chain evidence;
  affected pod flagged everywhere with a pulsing **"NOT WORTHY"** badge.
- **Response hints** may be placeholders ("Coming soon"/dummy buttons): notify
  on-call, Slack, freeze ports / isolate / kill-in-cloud, execute skill / connect
  to Claude Code or a developer.
- The demo drives CC* via a client-side **"Run CC\* scenario"** stepper (Prism is
  stateless), using contract-true fixtures from the OpenAPI spec.

## Consequences
- + One unforgettable demo; every screen earns its place by serving CC*.
- + Concrete acceptance criteria (see `input/DEMO.md`).
- − Alert presentation is opinionated for v2; the 3–5 alternatives are a v3 question
  (`questions_v2_to_v3_qa.md` R18). v3 may revise; until then v2's choice is binding.
