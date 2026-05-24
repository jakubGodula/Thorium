# Reconciliation Log

> Audit trail for reconciliation passes between `.ai/context.md`, `.ai/detailed-roadmap.md`, and the actual repository state. Most recent entry first.

## 2026-05-24 — Reconciliation pass

### Resolved

- **Q2 (Web UI directory):** SvelteKit Web UI lives at the **repo root** (`package.json` is `name: "thorium"`, has `@mysten/sui` + `@mysten/wallet-standard` + `@sveltejs/kit`). A second SvelteKit scaffold exists at `my-app/` but has no Sui deps and is unused. Updated `context.md` §4 Components table.
- **Q3 (.claude/ vs .ai/):** Both exist with **no overlapping content**. `.claude/instructions.md` + `.claude/instructions-local.md` hold conventions for Claude Code. `.ai/context.md` + `.ai/detailed-roadmap.md` hold project documentation. `CLAUDE.md` at repo root only re-exports the two `.claude/` files via `@` import. No action needed beyond noting the split.
- **Q4 (CI status):** Confirmed `.github/workflows/` **does not exist**. Phase 1 Week 1 Joint task remains pending; no delta to record.
- **Q5 (TPM accessibility):** Dev machine is **macOS** (`darwin`). `/dev/tpm*` does not exist on this OS by design. TPM development must happen on Linux (a TPM laptop, a Linux VM with vTPM, or CI). Phase 1 Dev B TPM work is unaffected on the demo hardware but cannot be exercised on this dev box.
- **Q6 (bundle path):** No `bundle.json` references in source (only in docs). Locked: agent searches `/etc/thorium/bundle.json` then `./bundle.json`, override with `--bundle <path>`. Added to `context.md` §6.
- **Q7 (narrator/):** Confirmed `narrator/` **does not exist**. Correct for Phase 1. No action.
- **Q8 (deployments.md):** Did not exist. Created `.ai/deployments.md` with placeholder template.
- **T2 (SvelteKit vs Next.js):** SvelteKit confirmed. Updated `detailed-roadmap.md` Week 3 Dev A task — replaced "`dashboard/` Next.js app" with "root SvelteKit app at `src/routes/`/`src/lib/`". Updated Phase 2 Week 4 Admin Web UI task to point at `src/routes/admin/enroll/`. Updated the file-inventory block at the bottom of the roadmap. Removed T2 from `context.md` §17.
- **T3 (Phase 4 framing):** Consistency confirmed (both docs already agree Phase 4 = Week 8 inside hackathon). Removed T3 from `context.md` §17.
- **T5 (allowlist refresh interval):** Defaulted to **30 s**, configurable via `--policy-refresh-interval`. Updated `context.md` §7. Removed T5 from §17.
- **T6 (EnrollmentTicket transferability):** Locked to **shared object** (matches roadmap's Phase 2 risks decision). Added explanatory paragraph to `context.md` §6. Removed T6 from §17.

### Updated docs

- `.ai/context.md`:
  - §4 Components table — Web UI path resolved to `/` (root SvelteKit app).
  - §6 — added bundle-path convention and EnrollmentTicket shared-object decision.
  - §7 — set 30 s default for policy refresh interval; removed §17 T5 reference.
  - §15 — closing line updated to point to this reconciliation log.
  - §16 — Q2–Q8 removed; Q1 retained, annotated with verification findings.
  - §17 — T2/T3/T5/T6 removed; T1 and T4 retained, annotated.
  - Closing footer dated 2026-05-24.
- `.ai/detailed-roadmap.md`:
  - Week 3 Dev A — Next.js → root SvelteKit, paths adjusted to `src/routes/` + `src/lib/`.
  - Week 4 Dev A — Admin Web UI now scoped to `src/routes/admin/enroll/` rather than `dashboard/`.
  - File-level inventory — replaced `dashboard/` row with the `src/` SvelteKit layout.
- `README.md`: converted `npx sv create`, `npx sv@0.15.3 create`, `npm install`, `npm run dev|build|preview` to their `bun`/`bunx` equivalents. **Legacy "Thorium XDR" content from line 46 onward (Tauri 2.0, recursive AI, etc.) left untouched — flagged below.**
- `.claude/instructions.md`: converted `npm install`, `npm run *` to `bun install`, `bun run *`. Added a footer line noting bun-only policy.

### New files

- `.ai/progress.md` — living checklist derived from the roadmap; Week 1 marked `← CURRENT`.
- `.ai/deployments.md` — placeholder template (no testnet publish yet).
- `.ai/reconciliation-log.md` — this file.
- `docs/manual/.gitkeep` — empty, establishes the directory in git.
- `docs/manual/README.md` — index of expected run-manuals (none created yet).

### Flagged for human decision

- **T1 / Q1 (Move package name):** No `move/` directory and no `Move.toml` anywhere in the repo. Recommendation per §17 T1 is to name the package `thorium`. The roadmap still says `move/sentrysui/`. Per the reconciliation-pass rules, the path was **not** renamed automatically. Confirm `thorium` (and I'll update the roadmap and any cross-references), or keep `sentrysui` as a legacy internal name with the human-facing project being Thorium.
- **`agent/src-tauri/` directory exists.** This is a Tauri 2.0 scaffold (vanilla TS + Tauri Cargo project), which directly contradicts `context.md` §7 (no Tauri) and §9 (anti-goal: Tauri / desktop GUI on agent). This appears to be legacy from the original outline. Options: (a) delete `agent/` entirely once Phase 1 Dev B begins, (b) keep as a stash branch reference, (c) repurpose into something. **Not deleted in this pass.**
- **`my-app/` SvelteKit scaffold exists** with its own `package-lock.json` and no Sui dependencies. Unused. Delete, keep as a sandbox, or repurpose? Not removed in this pass.
- **Three `package-lock.json` files exist** (root, `my-app/`, `agent/`). Project convention is `bun` (see `context.md` §12 — lockfile is `bun.lockb` / `bun.lock`). Per the reconciliation-pass rules, lockfiles were **not** deleted. Recommended: delete all three after a successful `bun install` produces `bun.lock`, then `git rm` them in a follow-up.
- **`README.md` legacy content (line 46 onward):** "Thorium XDR" pitch references Tauri 2.0, Vanilla CSS / D3.js, "Ransomware Rollback via VSS", LSASS memory protection, O365/AWS CloudTrail telemetry, etc. None of this matches the current Thorium/SentrySui design in `.ai/context.md`. This README needs a full rewrite at Phase 3 Week 7 (already on the roadmap). Flagging now so the human knows the divergence is intentional-but-stale.
- **`.npmrc` exists at repo root** (19 bytes). Did not inspect or modify — flag for human to confirm contents are compatible with `bun` (typically `bun` honors most `.npmrc` settings, but registry overrides may need a `bunfig.toml` equivalent).

### Open (still in §16/§17)

- **§16 Q1** — Move package directory name. Awaits package initialization in Phase 1 Week 1.
- **§17 T1** — Move package name (`sentrysui` legacy vs `thorium` recommended). Pending human confirmation.
- **§17 T4** — `thorium-provision` CLI naming alongside legacy `sentrysui` Move package. Auto-resolves when T1 is decided.
- **§17 T7–T10** — Intentional duplications between `context.md` and `detailed-roadmap.md`. No drift detected; no action needed.
