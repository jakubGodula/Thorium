# 🔴 LIVE DEMO — Thorium XDR (Alfa) — REACHABLE URLs

> **Fix:** the earlier `*.trycloudflare.com` URL failed for you with
> `ERR_NAME_NOT_RESOLVED` — your router's DNS (192.168.0.1) **does not reliably
> resolve Cloudflare-tunnel hostnames** (intermittent NXDOMAIN). Below are URLs that
> need **no flaky DNS**. Serving the **v2** (improved) Alfa build.

## ✅ Open this — guaranteed, no DNS, no interstitial
### http://localhost:5173   ·   CC*: http://localhost:5173/?cc=1
(you're on this Mac — this just works)

### http://192.168.0.251:5173   ·   CC*: http://192.168.0.251:5173/?cc=1
(LAN IP — reachable from any device on your network; it's an IP, so no DNS at all)

> Verified rendering over the LAN IP (proof:
> [`.ai-fe-design/demo-gen/gen-v2/mockup/public-reachable-cc.png`](./.ai-fe-design/demo-gen/gen-v2/mockup/public-reachable-cc.png)).

## 🌐 Public/remote URL (resolves on your router; one-time warning)
### https://c0e2-213-134-178-35.ngrok-free.app   ·   CC*: …/?cc=1
- **ngrok** (resolves via your 192.168.0.1 → 18.158.249.75, HTTP 200 verified).
- ngrok-free shows a **one-time "You are about to visit…" page — click "Visit Site"**,
  then the demo loads. (That interstitial is ngrok's, not the app.)

## What you'll see (CC* — the critical path)
Observed pod **alma9-edge-01**: connect → healthy → **kernel exploit** → anomaly 0.91
→ **NOT WORTHY · auto-isolated** → top **Critical Incident banner** → **Incident
Command** drawer (kill-chain + on-chain evidence + response actions). Click
**▶ Run CC* scenario** or **◷ Demo mode** (auto-loop), or open any `?cc=1` link.

## If a URL is down (processes stopped)
Re-serve + re-tunnel in ~20s:
```bash
cd /Users/macbook/work/Thorium/.ignored/fe-demo/demo_designV2_genV2/app
npx vite preview --port 5173 --outDir dist --host 0.0.0.0 &   # local + LAN
ngrok http 5173                                               # fresh public URL
```

## Why no permanent github.io URL?
The repo is **private**, so GitHub Pages can't serve it (the Actions deploy run
failed). Making it public or enabling Pages-for-private would give a durable
`jakubgodula.github.io/Thorium/` — pipeline is ready (delivery-v1/v2). Detail:
[`.ai-fe-design/ai_internal_audit_log/STATUS.md`](./.ai-fe-design/ai_internal_audit_log/STATUS.md).
