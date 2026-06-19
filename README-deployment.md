# Thorium XDR demo — Deployment (local & remote)

Covers running the **Alfa** demo locally and deploying it remotely. Delivery is
**versioned** (`delivery-v1`, `delivery-v2`, …) separately from design (v1/v2) and
the demo generator (gen-v1/gen-v2).

---

## Local

> Use the **absolute** path (the demo lives under the gitignored `.ignored/`):

```bash
cd /Users/macbook/work/Thorium/.ignored/fe-demo/demo_designV2_genV2/app
npm install
npm run demo        # app → http://localhost:5173   (+ Prism mock → :4010)
# open http://localhost:5173  →  click "▶ Run CC* scenario"   (or /?cc=1)
```
- App only (no mock): `npm run dev`.
- Production preview: `npm run build && npm run preview` → http://localhost:5173.

*(The earlier `cd .ignored/...` failed because it was a relative path from the wrong
cwd — always cd to the absolute path above, or `cd "$(git rev-parse --show-toplevel)"/.ignored/fe-demo/demo_designV2_genV2/app`.)*

---

## Remote

### delivery-v2 (recommended) — GitHub Pages via Actions (auto-enable)
A workflow ([`.github/workflows/deploy-pages.yml`](./.github/workflows/deploy-pages.yml))
builds the tracked app copy (`.ai-fe-design/delivery/delivery-v2/app/`) and deploys
to Pages, **auto-enabling** Pages with `actions/configure-pages` — no manual toggle.

- Trigger: push to `experimental-aw-fe-v2` touching the app, or **Actions → Run
  workflow**.
- **Live URL:** **https://jakubgodula.github.io/Thorium/**
  · CC* deep-link: **https://jakubgodula.github.io/Thorium/?cc=1**
- The CC* demo is **client-side**, so the remote site is fully clickable with no
  backend.

### delivery-v1 (fallback) — gh-pages branch
```bash
bash .ai-fe-design/delivery/delivery-v1/deploy.sh
```
Publishes `dist/` to `gh-pages`. Requires a **one-time** Settings → Pages enablement
(needs web UI / authenticated `gh`). See
[`delivery-v1/README.md`](./.ai-fe-design/delivery/delivery-v1/README.md).

### IPFS (the project's eventual target)
```bash
cd /Users/macbook/work/Thorium/.ignored/fe-demo/demo_designV2_genV2/app
npm run build           # static dist/, base:'./', hash routing → IPFS-safe
ipfs add -r dist        # pin via the licensed provider; put the CID in the footer
```

---

## Build characteristics (why it deploys cleanly anywhere)
- `base: './'` → relative assets (works at a domain root, a `/Thorium/` subpath, or
  an `ipfs://CID/` path).
- **Hash routing** → no server rewrites needed.
- No SSR, no remote fonts/CDNs. ~50 kB JS / 19 kB gzip.

## Verification status
See [`/.ai-fe-design/ai_internal_audit_log/`](./.ai-fe-design/ai_internal_audit_log/)
for the live record of what was deployed/verified and any open manual step.
