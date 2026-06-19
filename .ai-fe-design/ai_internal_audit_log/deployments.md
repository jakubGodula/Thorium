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

---

## ❗ CORRECTION (2026-06-19, later) — trycloudflare unreachable for the user

**Problem:** the user got `ERR_NAME_NOT_RESOLVED` on the trycloudflare URL. Root
cause: the user's router DNS (`192.168.0.1`) does **not reliably resolve
`*.trycloudflare.com`** (intermittent NXDOMAIN — likely tunnel-domain filtering /
negative caching). My earlier verification used `1.1.1.1`, masking this. My mistake.

**Fix — URLs the user can actually open (serving the v2 build):**
| Type | URL | Notes |
|---|---|---|
| Local | http://localhost:5173 (`/?cc=1`) | same machine, no DNS |
| **LAN IP** | **http://192.168.0.251:5173** (`/?cc=1`) | no DNS at all (it's an IP), no interstitial — **most reliable** |
| Public | https://c0e2-213-134-178-35.ngrok-free.app (`/?cc=1`) | **ngrok** (updated 3.39.8, authtoken present). Resolves on the user's router (192.168.0.1 → 18.158.249.75), HTTP 200. One-time ngrok "Visit Site" warning. |

Verified the LAN-IP URL renders the full v2 CC* demo in a browser
(`demo-gen/gen-v2/mockup/public-reachable-cc.png`). Lesson logged: **verify reachable
URLs against the *user's* resolver, not a public one.**

---

## vX (v2) — ARCHIVED · vX+1 — ✅ deployed (answers-driven)

**vX (v2)** is archived (frozen build `dist-vX`) and kept reachable on LAN so its
link persists: **http://192.168.0.251:5173** (`/?cc=1`).

**vX+1** (driven by `input/answers.md`; left-rail shell + Beta-as-mock surfaces +
incident tree + onboarding + Walrus decrypt + K8s preview + WS markers; ADR-0008):

deployment success : url https://4ae4-213-134-178-35.ngrok-free.app

- CC* deep-link: https://4ae4-213-134-178-35.ngrok-free.app/?cc=1
- **ngrok** (not trycloudflare — that's blocked by the user's router DNS). Resolves on
  192.168.0.1 → 18.158.249.75; HTTP 200 verified; one-time ngrok "Visit Site" warning.
- LAN (no DNS): http://192.168.0.251:5174 · local: http://localhost:5174.
- Proof: `demo-gen/gen-v2/mockup/vX1-cc-alert.png`. Deploy/iterate procedure:
  `delivery/ITERATION-RUNBOOK.md`.

### Links per deployment (persist)
| Ver | URL | State |
|---|---|---|
| vX (v2) | http://192.168.0.251:5173 (LAN) · ngrok history `…c0e2…`/`…survival…`/`…roller…` | archived |
| **vX+1** | **https://4ae4-213-134-178-35.ngrok-free.app** | **live (latest)** |
