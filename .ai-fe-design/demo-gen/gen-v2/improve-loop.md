# gen-v2 auto-improvement loop

A cheap, parallel critic loop that drives the demo — above all the **CC\*** critical
path — to Stripe-grade. The orchestrator (the running agent) renders + synthesizes;
**cheaper models do the critiques** (cost-efficient, diverse perspectives).

## The loop
```
1. RENDER   build/refresh the artifact (standalone HTML mockup early, real app later)
2. CAPTURE  screenshot it headless (Chrome --headless or Playwright)
3. CRITIQUE fan out N critics in PARALLEL, each a different lens, on a CHEAP model
4. SYNTH    orchestrator merges → picks the highest-impact, non-conflicting changes
5. APPLY    edit the artifact
6. REPEAT   from 1 until STOP
```

## Critics (one per lens, parallel, model = haiku or sonnet-4-6)
| Lens | Asks |
|---|---|
| Visual / Stripe-grade | hierarchy, spacing, color, typography, motion — concrete CSS |
| Demo narrative | does a cold viewer get "healthy → attacked → contained fast" in <10s? |
| Accessibility | contrast (WCAG AA), focus, color-not-only severity, reduced-motion |
| On-chain trust | are tx digests / object IDs / event JSON legible and believable? |
| Motion | entrance, pulse urgency, climax emphasis — without being gaudy |

Each critic returns a **numbered list of ≤5 concrete changes** (CSS/markup deltas).

## Synthesis rules
- Prefer changes ≥2 critics converge on; drop conflicting/cosmetic ones.
- Never let polish bury the story: CC\* legibility > decoration.
- Keep it dependency-light and `prefers-reduced-motion`-aware.

## Stop criteria
- No critic raises a **P1** (story-breaking or "looks unfinished"), OR
- max rounds elapsed, OR
- remaining suggestions are cosmetic / subjective.

### Token-cautious default (important)
Default cadence is **autonomous but frugal: 1–2 iterations** per invocation (one
critic batch each), then stop and report — do **not** keep looping. Only lift the cap
when the user explicitly asks for "deep polish" / more rounds. Always log tokens spent
and the stop reason. (Rationale: the loop is valuable but cheap-model rounds still
cost; the user set a low default budget.)

## Cost control
- Critics on **Haiku** by default (escalate one lens to Sonnet 4.6 if it stalls).
- Run critics **in one parallel batch** per round.
- Cap rounds (default 3). Log tokens per round.

## Worked example (this is real — round 1 ran during gen-v2 authoring)
- Artifact: [`./mockup/cc-alert.html`](./mockup/cc-alert.html) → screenshot
  `cc-alert.png`.
- Critics: 2× Haiku (visual + narrative). Converged P1s applied:
  1. Banner: left 4px red accent, solid (not foggy) bg, slide-in entrance.
  2. Sharper banner copy — lead with **Kernel exploit** + **0.91 anomaly** + pod.
  3. **Before/after**: "✓ Healthy 40s ago" struck-through chip.
  4. **Payoff**: "⚡ Auto-isolated in 2s" badge (the 2s detection→isolation delta).
  5. Climax timeline event highlighted; KPI glow; stronger NOT-WORTHY badge; sticky
     drawer header + incident-ID pill.
- Result: visibly more dramatic + legible (before/after PNGs in `./mockup/`).

> When run inside a real generated demo, the loop edits the Svelte components and
> re-screenshots via Playwright, writing an `improvement-log.md` per round.
