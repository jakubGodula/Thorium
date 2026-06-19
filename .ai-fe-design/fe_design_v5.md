# Thorium XDR — Frontend Design Spec **v5** (DDD)

> Supersedes v3/v4. Built from Jakub's answers in `questions_v4_to_v5_qa_LONG.md`
> (commit `18a1f17`). Decisions: [`adr/0010-DDD-v5-jakub-answers.md`](./adr/0010-DDD-v5-jakub-answers.md).
> Realized by deployment **DDD** on branch `experimental-aw-fe-v3`.

## What v5 adds (answers-driven)
- **Multi-endpoint defense** (L-A5): ws-07 BLOCKED lateral + alma9-edge-01 NOT WORTHY;
  Talus 2-static + rest live; Alerts DEFENDED row.
- **Fleet Telemetry**: "Threat level" column + **ECharts** CPU chart (L-B3/L-E1).
- **Incident lifecycle** Open→Acked→Resolved + Acknowledge/Resolve + dynamic Audit Trail
  (L-E5/I-M3-1/I-M3-3); target storage = Walrus.
- **Threat Intel** = most "real" surface (L-E2). KPI flash (L-B2). Responsive <1100px (L-B4).
  Claude→toast (L-B5). ⌘K kept+improved (L-E4). CR-2 cheap fixes (tree→drawer, Mute≠reset,
  copy, wallet toast, nav badges, denser cards, 8s dwell).
- **IPFS**: dist CID `bafybeici77d4xq7mdwo7xgwyl4dfxolog3uereebcwfwuxnnaw4jiidczq` (L-C1).

## Out of scope (→ `questions_v5_to_v6_qa.md`)
Live Mowa backend (needs Mowa repo + sui-cli + cargo) → kept mock + adapter seam.
Full Tailwind (only ECharts adopted). Parts G–O of the LONG Q&A still unanswered.

## Carried forward
v3 §0–§5 + CC* (ADR-0007) + the RUNBOOK iteration loop. v5 states deltas only.
