# Thorium XDR — Demo Generator **gen-v2**

> **Targets design version:** `fe_design_v2.md` (pinned; forward-runnable on v3).
> **Inherits everything in [`../gen-v1/PROMPT.md`](../gen-v1/PROMPT.md)** — same
> stack, same OpenAPI + Prism mock, same output convention. gen-v2 = gen-v1 **plus
> a quality engine**: an auto-improvement loop, visual capture (screenshots), and an
> executable "expected demo path" (Playwright). Run gen-v1's steps, then layer these.
>
> Why gen-v2 exists: the demo's value is almost entirely in the **CC\*** critical
> path being *flawless*. gen-v1 builds it; gen-v2 **iterates it to Stripe-grade**
> and proves it with screenshots + an E2E script.

---

## What gen-v2 adds on top of gen-v1

### 1. Auto-improvement loop (cheap models in a loop / spawned agents)
Continuously improve the demo — above all **CC\*** — using **cheaper models**
(Haiku / Sonnet 4.6) as reviewers, with the orchestrator (this agent) synthesizing.
Full design in [`./improve-loop.md`](./improve-loop.md). In short:

```
render artifact → screenshot → fan out N cheap-model critics (distinct lenses)
   → synthesize top changes → apply → re-render → repeat until stop criteria
```
- **Lenses** (one critic each, parallel): visual/Stripe-grade · demo-narrative
  clarity · accessibility/contrast · on-chain-trust legibility · motion.
- **Stop** when: no critic raises a P1, or 3 rounds elapse, or diffs go cosmetic.
- Use `Agent(model:"haiku" | "sonnet")` for critics; keep the orchestrator on the
  session model. Log each round's verdict + applied changes.

### 2. Visual capture (screenshots, no full app needed)
- For fast iteration, render **standalone HTML mockups** of key states (esp. the
  CC\* alert) and screenshot headless:
  `"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless
   --force-device-scale-factor=2 --window-size=1440,900 --screenshot=out.png file://…`
  (or Playwright `page.screenshot`). See [`./mockup/`](./mockup/) for a worked
  example (`cc-alert.html` → `cc-alert.png`).
- For the real app: add a `screenshots` npm script (Playwright) capturing each
  route + the CC\* states into `screenshots/` for review/regression.

### 3. Executable expected demo path (Playwright/Selenium)
- Ship [`./e2e/cc-star.spec.ts`](./e2e/cc-star.spec.ts): a Playwright spec that
  drives the **"Run CC\* scenario"** and asserts each beat (connect → healthy →
  attack → NOT WORTHY → alert → response hints), screenshotting each. This is both
  the **acceptance test** and the **demo script** (a presenter can follow it).

---

## Procedure (gen-v2)
1. Run [`../gen-v1/PROMPT.md`](../gen-v1/PROMPT.md) §0–§3 to build the app + mock
   (read CC\* `../../input/DEMO.md` first).
2. Wire the `screenshots` script and `e2e/cc-star.spec.ts`.
3. Run the **improve-loop** (`./improve-loop.md`) focused on CC\* until stop criteria.
4. Regenerate screenshots; verify the E2E passes.
5. Write the generated demo README (gen-v1 §3h) **plus** an `improvement-log.md`
   (each loop round: critics' P1s → changes → before/after screenshot).
6. Verify gen-v1 §4 acceptance **+** gen-v2 acceptance below.

## gen-v2 acceptance (in addition to gen-v1 §4)
- [ ] `e2e/cc-star.spec.ts` passes end-to-end and emits per-beat screenshots.
- [ ] An `improvement-log.md` shows ≥1 loop round with before/after screenshots.
- [ ] The CC\* alert is demonstrably Stripe-grade (no critic P1 outstanding).
- [ ] Screenshots of every route exist under `screenshots/`.

## Re-targeting design v3
Same as gen-v1: read `fe_design_v3.md` instead of v2, output to
`demo_designV3_genV2`. If v3 reshapes CC\* (see the v2→v3 "Final Chapter"), update
the loop's CC\* target and the E2E beats; fork to `gen-v3/` only if the *method*
changes.
