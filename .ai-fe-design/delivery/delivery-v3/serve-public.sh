#!/usr/bin/env bash
# Thorium XDR demo — FE delivery v3: UNRESTRICTED public URL via Cloudflare Quick
# Tunnel (no login, no interstitial — unlike localtunnel/delivery-v1/v2).
#
# Why v3: delivery-v1 (gh-pages) and v2 (Actions Pages) both need GitHub Pages,
# which is blocked on this PRIVATE repo (Actions run failed; Pages 404). This gives
# a real public, clickable URL immediately. The URL is EPHEMERAL (random; lives only
# while this script runs) — re-run to get a fresh one.
#
# Usage:  bash .ai-fe-design/delivery/delivery-v3/serve-public.sh
set -euo pipefail

APP="/Users/macbook/work/Thorium/.ignored/fe-demo/demo_designV2_genV2/app"
BIN="/tmp/cloudflared"

# 1) cloudflared (no brew needed)
if ! command -v cloudflared >/dev/null && [ ! -x "$BIN" ]; then
  echo "▶ downloading cloudflared (arm64)…"
  curl -fsSL -o /tmp/cloudflared.tgz \
    https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-darwin-arm64.tgz
  tar -xzf /tmp/cloudflared.tgz -C /tmp && chmod +x "$BIN"
fi
CF="$(command -v cloudflared || echo "$BIN")"

# 2) build + serve the Alfa demo on :5173 (vite preview allows tunnel hosts)
cd "$APP"
npm install --no-audit --no-fund --loglevel=error
npm run build
pkill -f "vite preview" 2>/dev/null || true; sleep 1
nohup npx vite preview --port 5173 --host >/tmp/thorium_preview.log 2>&1 &
sleep 4

# 3) open the public tunnel
pkill -f "cloudflared tunnel" 2>/dev/null || true; sleep 1
nohup "$CF" tunnel --url http://localhost:5173 --no-autoupdate >/tmp/cf.log 2>&1 &
echo "▶ waiting for public URL…"
for i in $(seq 1 20); do
  sleep 3
  URL=$(grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' /tmp/cf.log | head -1)
  [ -n "${URL:-}" ] && break
done
echo ""
echo "============================================================"
echo "  LIVE (public, unrestricted):  ${URL:-FAILED}"
echo "  CC* alert deep-link:          ${URL:-}/?cc=1"
echo "  (keep this process running to keep the URL live)"
echo "============================================================"
