# Step 04 — Colleague hand-off prompt (THE FINAL ITERATION output)

> Copy-paste this to the colleague / next agent. (Also reproduced in the chat summary.)

---

## ▶ For you / a colleague — take a look at:

**a) Demo — last deployment (LIVE):**
- **https://6b3e-213-134-178-35.ngrok-free.app/?cc=1** (click ngrok's one-time
  "Visit Site"; press **⌘K** for the command palette).
- LAN (no DNS, this network): http://192.168.0.251:5175
- ⚠️ Ephemeral (ngrok) — alive while the serving process runs. If down, regenerate:
  `cd /Users/macbook/work/Thorium/.ignored/fe-demo/demo_designV2_genV2/app && ngrok http 5175`.

**b) SHORT Q&A — for a fast next iteration (~5–10 min):**
- [`.ai-fe-design/questions_v3_to_v4_qa.md`](../questions_v3_to_v4_qa.md) (FINAL, not
  changed this round). Answer inline if you just want to move quickly.

**c) ⭐ THE MOST IMPORTANT DOCUMENT — the LONG Q&A with appended content (~15–60 min):**
- [`.ai-fe-design/questions_v3_to_v4_qa_LONG.md`](../questions_v3_to_v4_qa_LONG.md).
- It now contains: the original Parts A–F, **+ CR-2 (Parts G/H/I/J/K/L2/M, every
  finding)**, **+ Part N (Final-Iteration concerns 1–10: priority rule, CC* consistency
  ×10, Alfa/Beta scope, demo-fitness, UX, mobile, mock-backend ×10, README/naming,
  local-gen, findability)**. Fill in every `Answer:` you can — the more precise, the
  better the next build.

### How to use after you answer
1. Save the answered LONG file as `questions_v3_to_v4_qa_AUDIT.md` (and/or drop a new
   `input/answers_v4.md`).
2. A new agent runs [`.ai-fe-design/delivery/ITERATION-RUNBOOK.md`](../delivery/ITERATION-RUNBOOK.md)
   to ship v4 (archive → ADRs → build → deploy ngrok+LAN verified via `192.168.0.1` →
   docs → next short+long Q&A → push with URL prominent).

### Context to orient fast (<1 min each)
- All deployments: `ai_internal_audit_log/deployments.md` + `/LIVE-DEMO.md`.
- What was achieved + my honest assessment: `FINAL-ITERATION-STEPS/03-assessment.md`.
- Generate the FE yourself: `demo-gen/gen-v2/STEPS.md` (or skill `/fe-demo-gen`).
- Decisions/ambiguities: `adr/` + this `FINAL-ITERATION-STEPS/` folder.

**Top things to decide for tomorrow:** durable URL (repo public vs IPFS), the live
backend/WS/Sui/Walrus wiring (the adapter seam is ready), and the ~6 cheap demo-polish
fixes (tree→drawer, Alerts Ack, Mute≠reset, copy, dead Wallet button, demo dwell).
