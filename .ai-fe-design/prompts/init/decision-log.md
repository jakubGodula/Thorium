# Decision & assumption log — founding session

Chronological record of every decision, clarifying-question answer, and assumption.
Pairs with [`conversation.md`](./conversation.md).

## Turn 1–1b — v1 design + commit/push discipline
- Created `.ai-fe-design/` with `fe_design_v1.md`, `questions_v1_to_v2_qa.md`,
  `README.md`, `prompt_verbatim.md`; committed `8573834` and pushed to
  `experimental-aw-fe`.
- Analyzed the repo: **Thorium XDR**, Svelte 5 UI, Mowa agent `/api/*` contract,
  Sui Move contracts, reference images.
- Rule established: commit + push at the end; no rebasing pushed commits; don't
  commit unversioned files; leave questions in the Q&A file.

## Turn 2 — branch model + assumptions
- **`experimental-aw-fe` frozen** at v1 (do not push there again).
- Created **`experimental-aw-fe-v2`** (derivative); all later work pushes there.
- Deep analysis of the **Sui Move contracts** → confirmed on-chain model recorded
  in `assumptions_v1.md` (package `0x0cc3…91af`; modules `edr_registry`,
  `talus_xdr_detector`, `polonium_policy`; event/struct schemas). Key inference
  **A1**: the FE is primarily a Sui on-chain reader; agent HTTP is the live/local
  complement. Committed `e9174ee`.

## Turn 3 — v1→v2 answers → v2 design
User's decisions (verbatim in `questions_v1_to_v2_qa_AUDIT.md`):
- **Q1** Svelte 5 + Vite — confirmed.
- **Q2** Charting libraries **allowed** (may be heavy early); Stripe/Bolt/ELK/Walrus bar.
- **Q3** **Tailwind** (overrides v1 plain-CSS).
- **Q4** Keep existing tabs **+ add on-chain telemetry tabs**; mock data; allow a
  separate dockerized mock backend.
- **Q13** **English only — strictly no Polish**.
- **Q14** Thorium branding; add assets + suggest icon.
- **Q12** Multi-sig = placeholder.
- Q5,Q6,Q7,Q8,Q9,Q9b,Q10,Q10b,Q10c,Q11,Q15,Q16,Q17,Q18 → "ask in v2→v3, output
  assumptions; recommendation reasonable" → adopted as working assumptions.
- Outputs: `fe_design_v2.md`, ADR-0001…0005, `brand/`, `questions_v2_to_v3_qa.md`
  (incl. Datadog vs ELK vs Walrus comparison). Split answers into
  `questions_v1_to_v2_qa_AUDIT.md`; kept original questions clean. Committed `ad83dc8`.
- File convention: `*_qa.md` = clean questions; `*_qa_AUDIT.md` = answers.

## Turn 4 — versioned demo+mock generator (clarifying answers)
- **Scope:** author the generator (prompt/skill) only this turn; end with direction
  for "scaffold demo" + "full demo" (next, after sign-off).
- **Form:** Skill + procedure folder → `.claude/skills/fe-demo-gen/` +
  `.ai-fe-design/demo-gen/gen-v1/`.
- **Versioning:** **pinned matrix** — generator (gen-vN) × design (vM) →
  `demo_designV2_genV1`.
- **Mock:** **OpenAPI 3.1 + Stoplight Prism** (Docker).
- Outputs: `demo-gen/` (README, gen-v1 PROMPT, OpenAPI spec, Prism mock),
  `.claude/skills/fe-demo-gen/SKILL.md`, `AGENTS.md`. Committed `8fb8d6a`.

## Turn 5 — wire-keys TODO, archive, ⭐ CC* (clarifying answers)
- **Wire keys:** mock/agent stay **Polish**, English at the adapter → **ADR-0006**
  (with TODO) + README TODO tag.
- **Capability docs:** **Both, maximal** — repo-root `README.md` + `AGENTS.md`,
  `.ai-fe-design/README.md`, `.ai-fe-design/AGENTS.md` all lead with "generate the
  FE demo" as capability #1.
- **v3 handling:** **No v3 file** — CC* added to v1 + v2; v3 items as questions
  (`questions_v2_to_v3_qa.md` R18/R19).
- **Archive fidelity:** verbatim prompts + decision log (this file).
- **⭐ CC\* critical demo case** authored as `input/DEMO.md` (canonical) + **ADR-0007**
  (binding). On-chain mapping: observed pod = `AgentIdentity` SBT; not worthy =
  `is_active=false`/Isolated.
  - **v2 alert decision:** persistent top **Critical Incident banner** → **Incident
    Command drawer** (kill-chain timeline + on-chain evidence) + pulsing "NOT WORTHY"
    badge. 3–5 alternatives left as **R18** (v3 question); CC* confirmation as **R19**.
  - Response actions = labeled placeholders (notify on-call, Slack, freeze/isolate/
    kill, connect to Claude Code/dev).
  - Generator updated: CC* is a **hard acceptance criterion**; generated demo README
    must document the live link (app :5173, mock :4010) + missing/mocked integrations.
- **Not done this turn (by instruction):** generating/running the demo — deferred to
  after sign-off ("go — scaffold the demo").
