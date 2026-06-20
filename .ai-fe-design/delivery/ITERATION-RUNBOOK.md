# Iteration & Deployment RUNBOOK (repeatable for vN → vN+1)

> **For any future agent (Claude / Codex / Antigravity) or human.** This is the
> exact, ordered procedure used to take the Thorium XDR demo from one version to the
> next **driven by a new answers file** (e.g. `input/answers.md` for v3, a future
> `input/answers_v4.md` for v5→v6, etc.). Follow it step by step. Do not ask the user
> to clarify — make decisions, write ADRs, document, deploy, push.
>
> Canonical paths: demo app = `.ignored/fe-demo/demo_designV2_genV2/app` (gitignored;
> tracked CI copy = `.ai-fe-design/delivery/delivery-v2/app`). Design = `.ai-fe-design/`.

## Inputs (priority order — ALWAYS this order)
- **A) `input/answers_<round>.md`** — the answers for this iteration. **First
  principle; follow regardless.** Go through every answer one by one.
- **B) `input/DEMO.md`** — the **CC\*** critical demo path. Must stay prominent.
- **C)** previous design docs, the Sui Move contracts (`move/thorium_edr`), existing
  code. **Advisory only**, always in the context of A then B. Make decisions.

## Steps

### 1. Archive the current deployment (vX)
```bash
cd .ignored/fe-demo/demo_designV2_genV2/app
cp -r dist dist-vX-<ver>                     # freeze the current build
npx vite preview --port 5173 --outDir dist-vX-<ver> --host 0.0.0.0 &   # keep vX on LAN
```
- Append a vX entry to `ai_internal_audit_log/deployments.md` so **its URL persists**.
- Commit **with only that archive note**, then push.

### 2. Ingest the answers
- Save the answers file verbatim as `questions_<round>_qa_AUDIT.md`.
- Read A one-by-one; map each answer → a concrete UI/code decision. Note ambiguities.

### 3. Decide + record (one ADR per significant/ambiguous call)
- Write `adr/00NN-….md`: **Context · Decision · Alternatives · Consequences**.
- Resolve every ambiguity yourself (do not block).

### 4. Build vX+1 (in the app)
- Edit `src/lib/scenario.ts` (config keys + mock data) and `src/App.svelte` (UI).
- **Two fidelity tiers:** interactive (CC*, the things A says are real) vs **mock
  panels** — every mock surface gets a visible `mock`/`soon` tag.
- **Live-data = config + markers, not implemented:** add keys to `public/config.json`
  (`suiRpcUrl`, `wsUrl`, `walrusGateway`, …) and `// TODO(live, answer Ix):` markers
  where real data will plug in. `mock:true` default.
- Keep it **English-only, IPFS-safe** (`base:'./'`, hash routing).
```bash
npm run build        # must succeed; note bundle size
```

### 5. Deploy vX+1 (local + remote) — verify against the USER's resolver
```bash
npx vite preview --port 5174 --outDir dist --host 0.0.0.0 &     # local + LAN
pkill -f "ngrok http"; ngrok http 5174 --log=stdout >/tmp/ngrok.log 2>&1 &
# get URL:
curl -s http://localhost:4040/api/tunnels | grep -oE 'https://[a-z0-9-]+\.ngrok-free\.app' | head -1
```
- **Reachability rules (lessons learned):**
  - **Do NOT use `*.trycloudflare.com`** — the user's router DNS doesn't resolve it.
  - Use **ngrok** (`ngrok-free.app` resolves on the user's router; update with
    `ngrok update` if ERR_NGROK_121; authtoken already in config). One-time "Visit
    Site" warning.
  - Always also give an **IP/LAN URL** (`http://192.168.0.251:5174`) — no DNS at all.
  - **Verify resolution via the user's resolver:** `nslookup <host> 192.168.0.1`
    (NOT `1.1.1.1`), then `curl` for HTTP 200.
- Screenshot the CC* state (`…/?cc=1`) from **localhost** (ngrok interstitial blocks
  headless capture) → `demo-gen/gen-v2/mockup/`.

### 6. Improve (optional, token-cautious: max 1–2 rounds)
- Optionally one gen-v2 loop round (1 cheap-model critic → apply). Stop early.

### 7. Sync + design docs
- `rsync` the app `src/` + config to the **tracked** `delivery-v2/app/` (CI copy).
- Update `fe_design_v<n>.md` to the **real** decisions (supersede any assumptions
  draft). Update `README.md` banner + `LIVE-DEMO.md` + `deployments.md` with the new
  URL (and keep vX's URL listed).

### 8. Audit + next-round questions + prompts
- Append the ADR decisions to `ai_internal_audit_log/` (a dated entry).
- Write `questions_v<n>_to_v<n+1>_qa.md` — **25–50% of the previous round's length**;
  only the genuinely-open items + a copy-paste agent prompt. Concise.
- Append this session's prompts **verbatim** to `prompts/init/conversation.md`.

### 9. Ship
```bash
git add .ai-fe-design/ README.md LIVE-DEMO.md
git commit -m "deploy vX+1 (answers-driven): <ngrok url>"   # URL prominent in the last commit
git push origin HEAD:experimental-aw-fe-v3   # current branch (was -v2; bump per round)
```
- The **last commit must show the verified remote URL** prominently.

### 10. Summarize (≤1 min read)
- Working URLs (remote first), what changed, how to refresh, honest caveats.

## Rules carried forward
- Max **3 deployments per round** (vX, vX+1, vX+2); **2 preferred**.
- A durable public URL needs the repo **public** (or Pages-for-private), or the
  **Unstoppable Domains + IPFS** path (user's account) — ngrok is the ephemeral
  stand-in. Always document this.
- Verify everything against the **user's** environment, not a convenient one.
