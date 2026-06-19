# 🔴 LIVE DEMO — Thorium XDR (Alfa)

Two verified public deployments (both live, unrestricted):

## ▶ v2 (latest, recommended): https://survival-montana-duration-rachel.trycloudflare.com
CC\* alert: **https://survival-montana-duration-rachel.trycloudflare.com/?cc=1**
*(adds Demo-mode auto-loop, Talus AI + Vulnerabilities tabs, scenario progress, trust footer)*

## ▶ v1 (MVP / mockup): https://roller-flag-smtp-landscape.trycloudflare.com
CC\* alert: **https://roller-flag-smtp-landscape.trycloudflare.com/?cc=1**

- **Verified:** both return HTTP 200 over the public internet + the CC\* alert
  rendered in a real browser through each public URL (screenshots:
  [`public-v2-cc-alert.png`](./.ai-fe-design/demo-gen/gen-v2/mockup/public-v2-cc-alert.png) /
  [`public-cc-alert.png`](./.ai-fe-design/demo-gen/gen-v2/mockup/public-cc-alert.png)).
- **Unrestricted:** Cloudflare Quick Tunnel — no login, no interstitial, fully public
  and clickable. Click **“▶ Run CC* scenario”** (or open the `?cc=1` link).
- **Scope:** Version **Alfa** (focused SOC console + CC\*); CC\* runs on client-side
  mock fixtures, so it works with no backend.

> ⚠️ **Ephemeral URL.** This is a Cloudflare Quick Tunnel (FE **delivery-v3**) — it
> stays live only while the serving process runs, and the hostname is random per run.
> If it's down, regenerate a fresh public URL in ~30s:
> ```bash
> bash .ai-fe-design/delivery/delivery-v3/serve-public.sh
> ```
> Then update this file with the new URL.

## Why not a permanent github.io URL?
The repo `jakubGodula/Thorium` is **private**, so GitHub Pages can't serve it
(the Actions deploy run failed; `…github.io/Thorium/` returns 404). The Pages
pipeline (`delivery-v1` gh-pages branch + `delivery-v2` Actions) is in place and will
publish to **https://jakubgodula.github.io/Thorium/** the moment the repo is made
public or put on a plan with Pages for private repos — one setting, no code change.
Full detail: [`.ai-fe-design/ai_internal_audit_log/STATUS.md`](./.ai-fe-design/ai_internal_audit_log/STATUS.md).

## Run locally instead
```bash
cd /Users/macbook/work/Thorium/.ignored/fe-demo/demo_designV2_genV2/app
npm run demo     # http://localhost:5173  (+ Prism mock :4010)
```
