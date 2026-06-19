# gen-v2 assumptions (inherits gen-v1)

Inherits all of [`../gen-v1/ASSUMPTIONS.md`](../gen-v1/ASSUMPTIONS.md) (D1–D15).
gen-v2 adds:

| # | Assumption | Basis |
|---|---|---|
| E1 | Quality is driven by an **auto-improvement loop** with **cheaper models** (Haiku / Sonnet 4.6) as parallel critics; orchestrator synthesizes. | improve-loop.md |
| E2 | Fast iteration uses **standalone HTML mockups** screenshotted headless (Chrome/Playwright) before touching the full app. | improve-loop.md |
| E3 | The **CC\*** path is the loop's primary optimization target; other screens are secondary. | input/DEMO.md, ADR-0007 |
| E4 | The **expected demo path is executable** (`e2e/cc-star.spec.ts`, Playwright) and serves as both acceptance test and presenter script. | e2e/ |
| E5 | Loop **stop criteria**: no P1 from any critic, or 3 rounds, or only-cosmetic deltas. | improve-loop.md |
| E6 | Screenshot baseline 1440×900 @2x; demo "money shot" is the CC\* alert state. | mockup/ |
| E7 | The loop must keep results **accessible** (WCAG AA, reduced-motion) and **dependency-light**; polish never buries the story. | synthesis rules |
