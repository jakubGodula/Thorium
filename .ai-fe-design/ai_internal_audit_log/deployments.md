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
