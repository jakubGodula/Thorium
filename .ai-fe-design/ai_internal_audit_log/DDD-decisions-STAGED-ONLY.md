# DDD (v5) decisions — LOCAL STAGING ONLY (not committed, per instruction)

Branch experimental-aw-fe-v3. Source of truth: questions_v4_to_v5_qa_LONG.md (18a1f17).

## Decisions taken (answers Parts A–E)
- Multi-endpoint defense (L-A5): ws-07 BLOCKED lateral alongside alma9 NOT WORTHY;
  Talus 2 static + rest dynamic across endpoints.
- Threat-level column + ECharts CPU chart (L-B3/L-E1, lazy-loaded).
- Incident status Open→Acked→Resolved + Acknowledge/Resolve + dynamic Audit Trail
  (L-E5/I-M3-1/I-M3-3) — client-side now, Walrus target.
- Threat Intel live (L-E2). KPI flash (L-B2). Responsive <1100px (L-B4).
  Claude→toast (L-B5). ⌘K kept+improved (L-E4).
- CR-2 cheap fixes (judgment, Parts G–O unanswered): tree→drawer, Mute≠reset, copy
  works, wallet→toast, nav badges, denser cards, 8s dwell, ⌘K mock labels.
- IPFS CID via kubo only-hash: bafybeici77d4xq7mdwo7xgwyl4dfxolog3uereebcwfwuxnnaw4jiidczq.

## Deferred (decisions to NOT do now)
- Live Mowa backend (L-A1/A2/A4/E5): needs Mowa repo + sui-cli + cargo → out of FE
  scope; adapter seam kept. → questions_v5_to_v6_qa.md W1–W4.
- Full Tailwind (L-E1): ECharts only; theme CSS retained. → W8.
- UD domain "thorium.her" ambiguous → W5.

## Verification vs answers (main object this iteration)
Built + deployed DDD; rendered & screenshotted (demo-gen/gen-v2/mockup/DDD-cc.png):
banner Acknowledge, nav "1" badges, multi-endpoint rows present, build clean. Live
backend NOT verifiable (deferred). Quality: improved interactivity + a real chart;
remaining gaps logged as doubts.

## Why staged-only
Per the prompt: "decisions log into a new audit file but this time only in local
staging git area (once DDD is deployed)." DDD is pushed; this file is `git add`ed but
intentionally NOT committed/pushed.
