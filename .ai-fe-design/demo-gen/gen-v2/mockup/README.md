# CC* alert — standalone mockup (gen-v2)

A **self-contained HTML mockup** of the CC\* critical alert (no build, no server).
Open it in any browser to see the target look the generated demo must hit:

```bash
open .ai-fe-design/demo-gen/gen-v2/mockup/cc-alert.html      # macOS
```

- [`cc-alert.html`](./cc-alert.html) — the mockup (top Critical Incident banner +
  NOT-WORTHY pod row + Incident Command drawer with kill-chain timeline, on-chain
  evidence, and placeholder response actions).
- `cc-alert.png` — headless-Chrome screenshot of the mockup (regenerate below).
- `app-cc-alert.png` — **proof:** the same state rendered by the **real generated
  Svelte app** (gen-v2 ⊗ design v2, scope=alfa) under
  `.ignored/fe-demo/demo_designV2_genV2/`. The app reproduces this target 1:1.

## Regenerate the screenshot
```bash
cd .ai-fe-design/demo-gen/gen-v2/mockup
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless \
  --force-device-scale-factor=2 --window-size=1440,900 \
  --screenshot="cc-alert.png" "file://$PWD/cc-alert.html"
```

## How it was made (the loop)
This mockup was refined by the gen-v2 **auto-improvement loop**
([`../improve-loop.md`](../improve-loop.md)): rendered → screenshotted → critiqued by
2 cheap-model (Haiku) reviewers (visual + demo-narrative lenses) → top converged
changes applied → re-rendered. Round-1 changes: sharper banner copy
(kernel-exploit + 0.91 + pod), "✓ Healthy 40s ago" → "⚡ Auto-isolated in 2s"
before/after arc, highlighted climax timeline event, KPI glow, stronger NOT-WORTHY
badge, sticky drawer header.

> This is a **design target**, not the app. The real demo implements the same look
> in Svelte+Tailwind and drives it via the "Run CC\* scenario" stepper. Use this as
> the visual North Star and the screenshot as a regression reference.
