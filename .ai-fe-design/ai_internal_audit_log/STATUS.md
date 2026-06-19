# Deployment STATUS (live record) — 2026-06-19

## Local — ✅ VERIFIED
- `cd /Users/macbook/work/Thorium/.ignored/fe-demo/demo_designV2_genV2/app && npm run demo`
- Build ✓ (~50 kB JS / 19 kB gzip); served HTTP 200; CC* renders Stripe-grade.
- Visual proof: `.ai-fe-design/demo-gen/gen-v2/mockup/app-cc-alert.png` (from the
  running app).

## Remote (durable, GitHub Pages) — ⛔ BLOCKED (private repo) — READY to enable
- **Root cause:** the repo `jakubGodula/Thorium` is **private** (unauthenticated
  GitHub API → 404). GitHub Pages does not serve a **free private** repo, and there
  is **no `gh` auth / token** in this environment to enable Pages or read Actions.
- **Not done deliberately:** I did **not** make the repo public — it's a security
  product; that exposure is the owner's decision, not the agent's.
- **What IS in place (one step from live):**
  - **delivery-v1:** `gh-pages` branch pushed → enable in Settings → Pages → Branch
    `gh-pages`/root.
  - **delivery-v2:** `.github/workflows/deploy-pages.yml` with
    `actions/configure-pages enablement:true` → auto-enables + deploys on push (will
    publish automatically once the repo is on a plan that allows Pages, or made
    public).
  - Target URL (once enabled): **https://jakubgodula.github.io/Thorium/** (`?cc=1`).
- **Polled** `https://jakubgodula.github.io/Thorium/` repeatedly → 404 (expected
  while private/Pages-off).

## Remote (ephemeral, verification only) — ✅ VERIFIED the build serves publicly
- Brought the production build up over a real public URL via **localtunnel**
  (`https://*.loca.lt`). `curl` over the public URL → **HTTP 200**, correct hashed
  `assets/index-*.js|css`, and `config.json` (`scope:alfa`) — i.e. the deployable
  artifact serves correctly over the public internet.
- Browser screenshot over the tunnel was blocked by loca.lt's **anti-abuse
  interstitial** (their page, not our app — bypassable only for non-browser
  requests). So the **CC* visual proof remains the local-app screenshot**.
- The tunnel is **ephemeral** (dies with the session) → intentionally **not**
  documented as a durable URL.
- Side fix: added `server/preview.allowedHosts:true` to `vite.config.ts` so tunnels
  reach the dev/preview server (synced to the tracked delivery-v2 copy).

## Remote (unrestricted public, Cloudflare Quick Tunnel) — ✅ VERIFIED LIVE
- **delivery-v3** (`delivery/delivery-v3/serve-public.sh`): downloaded `cloudflared`
  (brew was broken by an untrusted mongodb tap; used the direct arm64 binary),
  served the Alfa build on :5173, opened a **Cloudflare Quick Tunnel**.
- **Live URL (verified):** `https://roller-flag-smtp-landscape.trycloudflare.com`
  (`/?cc=1` for the alert). **HTTP 200** over the public internet, **no
  interstitial**, and the **CC* alert rendered in a real browser through the public
  URL** → `demo-gen/gen-v2/mockup/public-cc-alert.png`.
- Note: local system resolver (192.168.0.1) negatively cached the new host; verified
  via `1.1.1.1` + Chrome `--host-resolver-rules`. Public DNS resolves fine.
- **Ephemeral:** random hostname, live only while the process runs. Prominent record
  in `/LIVE-DEMO.md`; regenerate with the delivery-v3 script.

## Bottom line
Local demo: working & verified. Remote **unrestricted public access: ✅ achieved**
(Cloudflare Quick Tunnel, delivery-v3) — CC* clickable over a real public URL. A
**durable** Pages URL (`jakubgodula.github.io/Thorium/`) is one setting away (make
the private repo public or enable Pages-for-private); pipeline already in place.
