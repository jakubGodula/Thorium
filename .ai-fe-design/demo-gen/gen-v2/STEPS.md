# Steps — generate the demo from **design v2** using **gen-v2**

The exact, copy-pasteable path to produce the runnable Thorium XDR demo. gen-v2 is
the **recommended** generator (gen-v1 is the simpler, proven fallback — same output,
without the auto-improvement loop / screenshots / E2E).

> Output goes to `.ignored/fe-demo/demo_designV2_genV2/` (gitignored).

## 0. Trigger
- **Claude Code:** run `/fe-demo-gen` and pick generator `gen-v2`, design `v2`.
- **Any agent / human:** open
  [`./PROMPT.md`](./PROMPT.md) and follow it verbatim (it inherits
  [`../gen-v1/PROMPT.md`](../gen-v1/PROMPT.md)). **Read
  [`../../input/DEMO.md`](../../input/DEMO.md) first.**

## 1. Read the inputs (in order)
`input/DEMO.md` (⭐ CC*) → `fe_design_v2.md` (incl. §8.5) → `assumptions_v1.md` §1
(on-chain schemas) → `adr/` (ADR-0007 = CC*, ADR-0006 = wire keys) →
`gen-v1/openapi/thorium-xdr.openapi.yaml` → `gen-v2/{improve-loop,ASSUMPTIONS}.md`.

## 2. Build (gen-v1 body)
Scaffold Svelte 5 + TS + Vite + Tailwind; ECharts/uPlot; data adapter over the
OpenAPI contract; shell + all tabs incl. **Chain Activity / Fleet Telemetry /
Alerts**; the **"Run CC\* scenario"** stepper; copy the Prism mock.

## 3. Quality engine (gen-v2 additions)
- Add `screenshots` (Playwright) + `e2e/cc-star.spec.ts`.
- Run the **auto-improvement loop** ([`./improve-loop.md`](./improve-loop.md)) on the
  CC\* alert until stop criteria; write `improvement-log.md` (before/after shots).

## 4. Run it (living demo)
```bash
cd .ignored/fe-demo/demo_designV2_genV2
docker compose -f mock/docker-compose.prism.yml up -d   # mock on :4010
npm install
npm run demo                                            # app :5173 + mock
# open http://localhost:5173  → click "Run CC* scenario"
npx playwright test e2e/cc-star.spec.ts                 # verify the path
```

## 5. Deploy (IPFS)
```bash
npm run build           # static dist/, base:'./', hash routing
ipfs add -r dist        # pin via the licensed provider; CID in footer
```
Edit `config.json` post-build to point at a live agent + Sui RPC (no rebuild).

## 6. Done when
gen-v1 §4 acceptance **+** gen-v2 acceptance (E2E passes, improvement-log exists,
no CC\* P1, route screenshots present) **+** the generated README documents the live
link, deploy, CC\*, and **missing/mocked integrations** (Sui, Walrus, Slack,
cloud-kill, Claude Code).
