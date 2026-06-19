# FE delivery **v2** — autonomous GitHub Pages deploy

> Delivery versions are independent of design (v1/v2) and the demo generator
> (gen-v1/gen-v2). **v1** = push prebuilt `dist/` to a `gh-pages` branch (needs a
> one-time Pages enablement in repo Settings). **v2** (this) = a GitHub **Actions**
> workflow that **auto-enables** Pages (`actions/configure-pages@v5` with
> `enablement: true`) and deploys — **no manual toggle**.

## How it works
- `app/` here is the **tracked** copy of the Alfa demo (source of truth for CI; the
  local dev copy lives in `.ignored/fe-demo/demo_designV2_genV2/app/`).
- Workflow: [`.github/workflows/deploy-pages.yml`](../../../.github/workflows/deploy-pages.yml).
- On push to `experimental-aw-fe-v2` touching `app/**`, it builds (`base:'./'`,
  IPFS/subpath-safe) and publishes to Pages.

## Live URL
**https://jakubgodula.github.io/Thorium/**  ·  CC* deep-link:
**https://jakubgodula.github.io/Thorium/?cc=1**

## Run / re-deploy
- Automatic on push (path filter above), or **Actions → "Deploy … to GitHub Pages"
  → Run workflow** (workflow_dispatch).
- The CC* demo runs **client-side** (deterministic scenario), so the remote site is
  fully clickable with no backend/mock.

## Notes & limits
- First run enables Pages via the workflow token; needs repo Actions enabled
  (default on personal repos).
- Remote = standalone demo (no live agent/Sui/Walrus; `config.json` mock fields are
  inert because the CC* path is client-side).
- To keep the tracked copy in sync with the local demo, re-run
  `rsync` from `.ignored/fe-demo/demo_designV2_genV2/app/` (see the audit log).
