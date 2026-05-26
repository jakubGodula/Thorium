# `agent/` — Legacy Tauri Scaffold

> **If you just landed here:** this directory is **not the active agent codebase.** Read this file, then move on.

## What is here

This directory is the remnant of an early design that paired a vanilla-TS Vite frontend (`src/`, `index.html`, `vite.config.ts`) with a Tauri 2.0 Rust backend (`src-tauri/`). It was created during initial project scaffolding and has not been developed further.

- `src-tauri/` — Tauri Cargo project. See `src-tauri/LEGACY.md` for full context on why it is kept.
- `src/`, `index.html`, `vite.config.ts`, `tsconfig.json` — vanilla-TS frontend that was meant to pair with the Tauri backend.
- `package-lock.json` — npm lockfile from initial scaffold. Project convention is `bun` / `bun.lock(b)` (see `.ai/context.md` §12); this file is a scaffold artifact, not the source of truth. Slated for `git rm --cached` in a future cleanup commit.

## What is NOT here

The **real Thorium sentinel agent** is a pure Rust + `tokio` headless binary. It has no GUI, no Tauri, no frontend. It will live at:

```
sentinel/          (binary crate)
sentinel-core/     (lib: eBPF, telemetry, PTB submission)
sentinel-fingerprint/  (lib: TPM + fallback fingerprinting)
```

These directories do not exist yet — they are created in **Phase 1 Week 1** (Dev B tasks). See `.ai/detailed-roadmap.md`.

## Why `agent/` is not deleted

The Tauri scaffold may contain useful reference material (capability declarations, icon assets, Cargo dependency choices) that a future AI agent or developer might want to inspect. See `src-tauri/LEGACY.md` for the full reasoning.

Do not build on, import from, or run `cargo build` in this directory expecting production behavior.

## See also

- `agent/src-tauri/LEGACY.md` — why the Tauri scaffold is kept
- `.ai/context.md` §7, §9 — headless agent design and Tauri as an anti-goal
- `.ai/detailed-roadmap.md` Phase 1 Week 1 — where the real agent scaffolding lands

---

*Last updated: 2026-05-26 (precision pass).*
