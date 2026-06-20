# 🔴 LIVE DEMO — Thorium XDR (Alfa) — REACHABLE URLs

> **Fix:** the earlier `*.trycloudflare.com` URL failed for you with
> `ERR_NAME_NOT_RESOLVED` — your router's DNS (192.168.0.1) **does not reliably
> resolve Cloudflare-tunnel hostnames** (intermittent NXDOMAIN). Below are URLs that
> need **no flaky DNS**. Serving the **DDD (v5)** build (branch `experimental-aw-fe-v3`).

## 🌐 DDD (v5, latest) — public/remote, share with your friend
### https://7021-213-134-178-35.ngrok-free.app   ·   CC*: …/?cc=1   ·   press ⌘K
*(v5: multi-endpoint defense · ECharts CPU chart · Threat-level column · incident
Open→Acked→Resolved + dynamic audit · live Threat-Intel · responsive. Branch
`experimental-aw-fe-v3` · LAN :5176 · IPFS CID `bafybeici77d4xq7mdwo7xgwyl4dfxolog3uereebcwfwuxnnaw4jiidczq` (unpinned).)*

<details><summary>older URLs (likely dead — ngrok is ephemeral)</summary>

vYY+1 `https://6b3e-213-134-178-35.ngrok-free.app` · vX+1 `https://4ae4-213-134-178-35.ngrok-free.app`
</details>
- **ngrok** (resolves on your router 192.168.0.1 → 18.158.249.75; HTTP 200 verified).
- One-time **"You are about to visit…" page → click "Visit Site"**, then it loads.
- New left-rail SOC console: Monitor / Detect / Respond / Platform — incidents tree,
  Talus, vulns (Walrus decrypt), threat-intel, onboarding, compliance, governance,
  personas, integrations, audit, modules, "other" — CC* still the hero.

## ✅ Local / LAN — guaranteed, no DNS, no interstitial (DDD / v5)
### http://localhost:5176   ·   CC*: http://localhost:5176/?cc=1   (this Mac)
### http://192.168.0.251:5176   ·   CC*: …/?cc=1   (LAN — any device, no DNS)
> Proof of DDD render: [`.ai-fe-design/demo-gen/gen-v2/mockup/DDD-cc.png`](./.ai-fe-design/demo-gen/gen-v2/mockup/DDD-cc.png).
> Older builds used :5173–:5175 (likely stopped).

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
