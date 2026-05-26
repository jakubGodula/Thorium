# LEGACY — `agent/src-tauri/`

> **You are reading a legacy marker.** This directory is preserved for reference but is **not part of the active Thorium design**.

## What this is

A Tauri 2.0 scaffold (vanilla TS frontend + Rust backend) that was created during early planning for an endpoint agent with a desktop GUI. The scaffold contains:

- `Cargo.toml`, `Cargo.lock`, `build.rs` — Rust crate setup for the Tauri backend
- `tauri.conf.json`, `capabilities/` — Tauri config and OS-capability declarations
- `src/`, `icons/` — Rust source stubs and app icons

The parent directory (`agent/`) holds the vanilla-TS frontend that was meant to pair with this Tauri backend.

## Why it's marked legacy

The active design in `.ai/context.md` explicitly rejects Tauri for the agent:

- **§7 (Sentinel agent):** *"Pure headless daemon. No Tauri (legacy outline artifact; explicitly removed)."*
- **§9 (Anti-goals):** *"Tauri / desktop GUI on the agent — agent is headless."*

The real agent will be a pure Rust + `tokio` binary, with eBPF telemetry via `aya`, TPM key sealing via `tss-esapi`, and Sui PTB submission via `sui-sdk`. It has no GUI. It lives in a future `sentinel/` workspace (see `.ai/detailed-roadmap.md` Phase 1 Week 1 — Dev B tasks).

## Why it isn't deleted

Two reasons:

1. **A future AI agent may want to look at this scaffold** for examples of Tauri capability declarations, icon assets, or Cargo dependency choices — even if the overall framework choice is wrong.
2. **Removing it requires a destructive `rm -rf`** that should be done deliberately, not as a side effect of a documentation pass.

If/when this directory is removed, do it in a dedicated commit (`chore: remove legacy Tauri scaffold`) and reference this file in the message.

## Do not

- Do not add code to this scaffold expecting it to be part of the production agent.
- Do not import from `agent/src-tauri/` into the real `sentinel/` workspace when it lands.
- Do not let `cargo build` in this directory be a signal of project health — it builds a thing we are not shipping.

## See also

- `.ai/context.md` §7, §9
- `.ai/detailed-roadmap.md` Phase 1 Week 1, Dev B tasks
- `.ai/reconciliation-log.md` 2026-05-26 entry (T11 closure)
