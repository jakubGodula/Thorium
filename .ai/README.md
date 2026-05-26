# `.ai/` — Project documentation for AI agents and humans

> **You just landed here. Read this whole file before anything else.** It's short. It tells you what every other file in this directory is for and in what order to read them.

> If you landed in a different file first (e.g., someone pointed you at `context.md` directly), that's fine — each file in `.ai/` has a self-orienting header that points back here. You won't be lost.

---

## What this project is, in two sentences

**Thorium** is a decentralized endpoint-attestation mesh on Sui. Devices are non-transferable Move objects; a Rust sentinel agent on each device reports software-attestation telemetry; status flips to `Compromised` are on-chain events that downstream services (a demo VPN gateway) read before granting access. Forensic blobs go to Walrus, eventually gated by Seal.

For the elevator pitch, hackathon framing, and demo scenario, open `context.md` §1, §3, §8.

---

## How to read this directory

You can land in any file and still recover, but if you have free choice, read in this order:

| # | File | What it is | Read when |
|---|---|---|---|
| 1 | **`README.md`** *(this file)* | Map of `.ai/` + read order | First, always |
| 2 | **`context.md`** | Architectural ground truth: what we build, identity model, Move design, demo scene, anti-goals, conventions | Once per session, for orientation |
| 3 | **`detailed-roadmap.md`** | Per-phase, per-week task lists, exit criteria, owners (Dev A / Dev B) | When picking up active work |
| 4 | **`progress.md`** | Living checklist derived from the roadmap; tick boxes as items complete | When marking work done or reviewing where things stand |
| 5 | **`deployments.md`** | On-chain artifact registry (`PackageID`, `Policy` object ID, capability IDs) on Sui testnet | When the Move package is published, or when reading state from chain |
| 6 | **`reconciliation-log.md`** | Append-only audit trail of doc/repo reconciliation passes — what changed, why, on what date | When you suspect drift, or want history on a decision |
| 7 | *(future)* `decisions.md` | Architecture Decision Records | When created |
| 7 | *(future)* `deadlines.md` | Submission and milestone dates | When created |

**Outside `.ai/` but referenced everywhere:**

- **`docs/manual/`** — Per-component run scripts (`run-move-publish.md`, `run-agent.md`, `run-web.md`, …) and the demo-scenario walkthrough. One file per component lands here as that component becomes runnable. See `docs/manual/README.md` for the expected filenames.
- **`agent/src-tauri/LEGACY.md`** — Marker explaining a legacy Tauri scaffold preserved for reference but not part of the active design. See it before touching `agent/`.
- **`README.md`** at repo root — currently carries legacy "Thorium XDR" pitch from an older outline. Scheduled for full rewrite at Phase 3 Week 7 (see roadmap). Do not treat it as authoritative.
- **`CLAUDE.md`** at repo root — re-exports `.claude/instructions.md` and `.claude/instructions-local.md` (style/conventions for Claude Code, not project docs).

---

## Authoritative-source rules (memorize these)

Each topic has exactly one source of truth. When you find drift between docs, **fix it in the same pass** and add a `reconciliation-log.md` entry.

| Topic | Authoritative source |
|---|---|
| What to do this week, exit criteria, owners | `detailed-roadmap.md` |
| Why the system is shaped this way, identity model, Move design, demo scene, anti-goals, conventions | `context.md` |
| Whether a task is done | `progress.md` |
| On-chain object IDs on testnet | `deployments.md` |
| History of decisions / resolved ambiguities | `reconciliation-log.md` |

**Conflict resolution rule:** roadmap wins for *what / when*; `context.md` wins for *why / how*. Both must be updated together when drift is found.

---

## Project facts you should hold in your head

These are stated authoritatively in `context.md` but are common reasons to get confused, so they're surfaced here too:

- **Name:** the project is **Thorium**. Any reference to `SentrySui` / `sentrysui` in commit history, branches, external notes, or older AI sessions is **legacy** — treat as `thorium`. The Move package is `move/thorium/`.
- **OS scope:** **Linux only** through Phase 3. macOS / Windows are Phase 4+ stretch.
- **Network:** Sui **testnet** for everything. Never mainnet. No real funds.
- **Package manager:** **`bun`** for all TypeScript/JavaScript. Never `npm`, `npx`, `pnpm`, or `yarn`. `npx <x>` → `bunx <x>`.
- **Web UI lives at the repo root** (root `package.json` is `name: "thorium"` with `@mysten/sui` + `@sveltejs/kit`). `my-app/` exists locally but is **gitignored** — it's scratch.
- **The agent is headless Rust + tokio.** Not Tauri. The `agent/src-tauri/` directory is legacy — see `agent/src-tauri/LEGACY.md`.
- **Two devices in the demo:** physical laptop with real TPM (stays Healthy) + Linux VM with fallback fingerprint (gets attacked). Both upload status to Sui.
- **Phase 1 Walrus is in scope** (the demo needs the forensic blob attached on Compromised). Seal arrives in Phase 3.
- **AI narrator is metadata, never gating.** Move owns every security verdict.
- **8-week hackathon window**, 4 phases of ~2 weeks each, ending at Sui Overflow 2026 submission. Phase 4 = Week 8 = inside the window, not after.

---

## When you change something

1. Make the change in the authoritative file (see the rules table above).
2. Update any companion file that summarizes or duplicates it.
3. Add a dated entry to `reconciliation-log.md` describing what changed and why.
4. Update the file's own "Last updated:" footer.

---

## Why this file exists

A fresh AI agent (or new human) needs to be productive without reading the whole `.ai/` directory front-to-back. This file gives a 3-minute orientation, after which `context.md` and `detailed-roadmap.md` are enough for any task.

If you ever feel lost, come back here.
