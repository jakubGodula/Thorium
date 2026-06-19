#!/usr/bin/env bash
# Thorium XDR demo — FE delivery v1 (remote deploy to GitHub Pages).
# Versioned separately from design (v1/v2) and the demo generator (gen-v1/gen-v2).
# Builds the Alfa demo and force-pushes the static dist/ to the `gh-pages` branch.
#
# Usage:  bash .ai-fe-design/delivery/delivery-v1/deploy.sh
# Prereq: SSH push access to the repo (we have it). Pages must be enabled once in
#         repo Settings → Pages → Branch: gh-pages / root (one-time, UI/gh only).
set -euo pipefail

REPO="git@github.com-personal:jakubGodula/Thorium.git"
APP="/Users/macbook/work/Thorium/.ignored/fe-demo/demo_designV2_genV2/app"
PAGES_URL="https://jakubgodula.github.io/Thorium/"

echo "▶ build (Alfa) …"
cd "$APP"
npm install --no-audit --no-fund --loglevel=error
npm run build                      # base:'./' → works under the /Thorium/ subpath

echo "▶ publish dist → gh-pages …"
cd dist
touch .nojekyll                    # serve assets/ as-is (no Jekyll)
rm -rf .git
git init -q
git config user.email "aleksander.w1992@gmail.com"
git config user.name  "Aleksander Wojcik"
git add -A
git commit -q -m "deploy: thorium-xdr demo (alfa) — FE delivery v1

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>"
git branch -M gh-pages
git push -f "$REPO" gh-pages

echo "✓ pushed. Live (once Pages is enabled): ${PAGES_URL}"
echo "  CC* deep-link:  ${PAGES_URL}?cc=1"
