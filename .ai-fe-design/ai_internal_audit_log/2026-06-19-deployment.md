# AI internal audit log — 2026-06-19 — deployment session

Decisions & ambiguities resolved autonomously (user instruction: "do not ask
questions; resolve and document here"). Pairs with the commit that adds the
deployment delivery.

## Task
Fix the local run path; document local+remote deployment; deploy remotely; verify
CC* on remote; version the FE delivery; document the URL; push.

## Decisions
1. **Local path bug** — the failing `cd .ignored/...` was a relative path from the
   wrong cwd. Resolved: docs now use the **absolute** path
   `/Users/macbook/work/Thorium/.ignored/fe-demo/demo_designV2_genV2/app` (or
   `cd "$(git rev-parse --show-toplevel)"/.ignored/...`).
2. **Remote target = GitHub Pages.** No `gh` auth and no `GITHUB_TOKEN`/`GH_TOKEN`
   in env → cannot use third-party hosts (Netlify/Vercel/Surge need auth) or enable
   Pages via REST. Pages via our existing **SSH push access** is the only autonomous
   remote. Documented as authorized (user explicitly asked to deploy + push).
3. **Delivery versioning** (FE delivery, separate from design & generator):
   - **delivery-v1** = push prebuilt `dist/` to `gh-pages` branch (`deploy.sh`).
     Pushed successfully, **but Pages 404s** because enabling it needs a one-time
     repo Settings toggle (web UI / authed gh) — not available to the agent.
   - **delivery-v2** = GitHub **Actions** workflow with
     `actions/configure-pages@v5 enablement:true` → **auto-enables** Pages with the
     workflow's GITHUB_TOKEN. Chosen as the "better deployment script" the user asked
     for when v1 was unsatisfactory.
4. **Tracked app copy.** delivery-v2 needs in-repo source for CI to build, but the
   demo lives in gitignored `.ignored/`. Resolved: committed a **tracked copy** at
   `.ai-fe-design/delivery/delivery-v2/app/` (node_modules/dist gitignored). The
   `.ignored/` copy remains the local dev one; keep in sync via rsync.
5. **Remote = standalone/client-side.** The CC* scenario runs client-side, so the
   remote site needs no agent/mock/Sui; `config.json` mock fields are inert there.
6. **base:'./'** kept (relative assets) so the project-page subpath `/Thorium/`
   works without a `base:'/Thorium/'` rebuild.

## Verification
- Local build: `npm run build` ✓ (~50 kB JS / 19 kB gzip). Live app screenshotted
  (idle + `?cc=1` alert) — CC* renders Stripe-grade (see
  `demo-gen/gen-v2/mockup/app-cc-alert.png`).
- delivery-v1 push: `gh-pages` branch created on origin ✓.
- Pages URL `https://jakubgodula.github.io/Thorium/` polled: **404** before
  delivery-v2 (Pages not enabled).
- delivery-v2: workflow committed + pushed → triggers Actions build/deploy.
  Liveness recorded in `STATUS.md` (updated after polling).

## Open / manual items
- If delivery-v2's `configure-pages enablement` is blocked by repo Actions settings,
  the one manual step is **Settings → Pages → Source: GitHub Actions** (or enable
  the `gh-pages` branch for delivery-v1). Documented in `README-deployment.md`.
- Cannot read Actions logs (no `gh`/web) — liveness verified only by polling the URL.
