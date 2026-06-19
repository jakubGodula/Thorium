# Deployments log — Thorium XDR demo (Alfa)

Prominent record of verifiable remote deployments. Latest URL also mirrored in the
repo-root [`/LIVE-DEMO.md`](../../../LIVE-DEMO.md) and `README.md` banner.

---

## v1 — 2026-06-19 — ✅ MVP / mockup (Version Alfa)

deployment success : url https://roller-flag-smtp-landscape.trycloudflare.com

- CC* alert deep-link: https://roller-flag-smtp-landscape.trycloudflare.com/?cc=1
- Scope: **Alfa** (focused SOC console + CC*), client-side mock fixtures.
- Delivery: **delivery-v3** (Cloudflare Quick Tunnel) — public, unrestricted, no
  interstitial. Ephemeral (lives while the local serve process runs).
- **Verified:** HTTP 200 over the public internet + the **CC* critical alert
  rendered in a real browser through the public URL** (proof:
  `../demo-gen/gen-v2/mockup/public-cc-alert.png`).
- Fit vs internal CC* requirements: **more-or-less OK** for an MVP/mockup — the
  connect→healthy→attack→NOT WORTHY→Stripe-grade-alert path is present and prominent.

---

## v2 — 2026-06-19 — ✅ improved (closer to CC*/hackathon requirements)

deployment success : url https://survival-montana-duration-rachel.trycloudflare.com

- CC* alert deep-link: https://survival-montana-duration-rachel.trycloudflare.com/?cc=1
- **Both remote deployments are live concurrently** (v1 frozen on :5173, v2 on :5174,
  each its own Cloudflare Quick Tunnel).
- **What improved vs v1** (driven by a gen-v2 loop round — 1 Haiku critic, applied):
  - **Demo mode** (auto-loop the CC* scenario for an unattended booth; `?demo=1`).
  - **Scenario progress** indicator (Step N/4 + phase).
  - Un-stubbed **Talus AI** (detection cards) and **Vulnerabilities** (Seal-sealed
    rows) tabs; richer **Chain Activity** (always-on event feed) + **Alerts** with
    status.
  - Incident drawer **callouts** (isolation method · blast radius).
  - **Trust footer** (Sui network · scope · demo-mode · CC*).
- **Verified:** HTTP 200 over the public URL + CC* (with the new chrome) rendered in
  a browser through the public URL (proof:
  `../demo-gen/gen-v2/mockup/public-v2-cc-alert.png`).

### Both remote URLs (this session — only v1 + v2 allowed)
| Ver | URL | Build |
|---|---|---|
| **v1** | https://roller-flag-smtp-landscape.trycloudflare.com | MVP / mockup (frozen) |
| **v2** | https://survival-montana-duration-rachel.trycloudflare.com | improved (latest) |
