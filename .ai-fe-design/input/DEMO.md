# ⭐ CRITICAL DEMO CASE — "CC*" (must be prominent & flawless)

> **This is the most important attachment in the workspace.** Every design version
> (v1, v2, v3) and every generated demo MUST make this path **prominent, very well
> visible, elegant and modern** on the frontend — Stripe-grade. If a screen doesn't
> serve this story, it is secondary.
>
> Added 2026-06-19 during the design discussion. Canonical source; referenced by
> `README.md` (top), `fe_design_v1.md`, `fe_design_v2.md`,
> `questions_v2_to_v3_qa.md`, and `prompts/init/`.

## The story (happy → compromised → response)

**Actors:** the **Thorium UI** (our frontend), the **Sui contract** (package
`0x0cc3…91af`), and an **observed pod** (a monitored endpoint = an `AgentIdentity`
SBT; think a Kubernetes pod connected to Thorium for blockchain-attested
observation).

1. **Connect.** A user connects a **new observed pod** into Thorium to be observed
   via blockchain. → on-chain `register_agent` ⇒ `AgentRegistered` event. The pod
   appears in the UI (Endpoints / Chain Activity).
2. **Healthy.** The observed pod is healthy and the **Sui contract interacts with
   it**. The frontend **confirms the on-chain interaction** AND an **OK status** in
   the pod's telemetry. → `TelemetryReported{cpu/ram/disk = OK}`, `is_active=true`;
   green/healthy everywhere.
3. **Attack.** We **simulate a kernel attack or DDoS** against the observed pod.
4. **Marked not worthy.** Thorium marks the observed pod as **NOT WORTHY**
   (untrusted/unhealthy). → eBPF/Talus detection ⇒ `ClassificationReported`
   (`anomaly_score ≥ threshold` → `TRIGGER_ISOLATION`) + `IncidentReport`
   (CRITICAL); `is_active=false` / status **Isolated/Quarantined**.
5. **Visible degradation.** Sui tries to interact with it (or another agent), and
   the **NOT-OK log + telemetry is clearly visible in the frontend**.
6. **The alert (the money shot).** A **prominent, beautiful alert** surfaces in the
   frontend — *as good as Stripe would do it*. The compromised pod is shown as
   **"Not Worthy"** both in the UI and (conceptually) on Sui.
7. **Response hints (placeholders OK).** Offer next actions as hints / "Coming
   soon" mockups / dummy buttons + alert:
   - Notify on-call
   - Slack integration: "observed pod compromised"
   - Freeze ports · Isolate pod · Kill it in cloud
   - Execute skill / connect to Claude Code or a developer

## v2 decision — how the alert is presented (CC*e)
For v2 we **commit to one** primary presentation (alternatives are a v3 question):

> **A persistent top "Critical Incident" banner (Stripe-style) that opens an
> "Incident Command" slide-over drawer**, while the affected pod is flagged
> everywhere with a pulsing red **"NOT WORTHY"** badge.
> - Banner: fixed top, red accent, severity + pod + "View incident" CTA; collapses
>   to a beacon, never silently disappears.
> - Drawer: live **kill-chain timeline** (connect → healthy telemetry → attack →
>   classification → isolation), on-chain evidence (tx digests, event JSON), and the
>   response-hint buttons (§7, placeholders).
> - Cross-screen: the pod row in Endpoints/Fleet Telemetry/Chain Activity shows the
>   NOT-WORTHY badge + a red pulse; telemetry sparkline turns red and breaches.

This is the v2 working assumption (**CC***). The 3–5 alternative presentations are
left open in `questions_v2_to_v3_qa.md` (R18).

## Driving it in the demo (mock is stateless)
Prism is stateless, so the demo app provides a **"Run CC\* scenario"** control that
steps the UI through states 1→7 client-side using the contract-true fixtures in the
OpenAPI spec (a healthy pod, then the attacked-pod incident/classification/isolation
events). The narrative is deterministic and repeatable for live demos.

## Visual target (rendered)
A standalone, rendered mockup of the v2 alert presentation lives at
[`../demo-gen/gen-v2/mockup/cc-alert.html`](../demo-gen/gen-v2/mockup/cc-alert.html)
(screenshot: `cc-alert.png`). It was refined by the gen-v2 auto-improvement loop and
is the visual North Star for the generated demo. The full catalog of alternative
presentations is the **"Final Chapter"** in
[`../questions_v2_to_v3_qa.md`](../questions_v2_to_v3_qa.md).

## Acceptance (CC* is demo-ready when…)
- [ ] A viewer can watch connect → healthy → attack → NOT WORTHY → alert in <60s.
- [ ] The alert is unmissable and looks production-grade (Stripe bar).
- [ ] On-chain interaction + OK telemetry are visible in the healthy phase.
- [ ] NOT-OK telemetry/logs + the "Not Worthy" status are visible after the attack.
- [ ] Response-hint actions are present (placeholders clearly labeled).
