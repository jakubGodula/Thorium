# Thorium — Project Context (`.ai/context.md`)

> **You are reading the project's architectural ground truth.** It answers *why* the system is shaped this way and *how the pieces fit*. It does **not** tell you what to work on this week — for that, open `.ai/detailed-roadmap.md` after this file.

> **If you just arrived in this repo:** the canonical landing page is **`.ai/README.md`**. It maps every file in `.ai/`, gives the recommended read order, and tells you what to do if you landed in a different file first. You can navigate from there.

> **Conflict resolution rule:** when this file and the roadmap disagree, the **roadmap wins for *what* and *when*** (it is closer to today's work); **this file wins for *why* and *how***. Update both when you find drift, and add an entry to `.ai/reconciliation-log.md`.

> **Open items live at the bottom:** §16 (Open Questions awaiting repo inspection) and §17 (TBD — known ambiguities). Both are kept short — items move to `reconciliation-log.md` once resolved. As of 2026-05-26, §16 is empty and §17 holds only the conscious duplications T7–T10.

---

## 1. What we are building

**Thorium** is a decentralized endpoint-attestation mesh on Sui. Each enrolled device is a non-transferable Sui Move object with a security status; a per-device sentinel agent (pure Rust, headless) continuously reports software-attestation telemetry; status transitions to `Compromised` are on-chain events that downstream services consult before granting access. Forensic blobs go to Walrus.

**Positioning:** "trust ledger as DePIN, with on-chain circuit breakers for endpoint compromise." Not an XDR-vendor replacement. The novelty is the **public, multi-verifier verdict layer**, not better detection.

**Elevator pitch:** *"Agents narrate. Sui decides. The mesh enforces."*

---

## 2. Status

- **Active phase:** Phase 1 — Endpoint Agent & On-chain Verdict (Weeks 1–3). Update marker in `detailed-roadmap.md`, not here.
- **Phase shape:** 4 phases over 8 working weeks. Per-week tasks live in `detailed-roadmap.md`.
- **Team:** 2 devs (Dev A: fullstack + Solidity; Dev B: security/DevOps + Sui). Detailed allocation in `detailed-roadmap.md` §0.
- **Network:** Sui **testnet** for everything. No mainnet, no real funds.

Assume nothing is built unless the relevant file exists in the repo. See §16 for items Claude Code should verify against the repo on startup.

---

## 3. Hackathon constraints (this drives every choice)

**Event:** Sui Overflow 2026, May–August 2026, global online. Deadline locked in `.ai/deadlines.md` (file may not yet exist — see §16).

**Tracks targeted:**
- **Primary:** Explorations (DePIN/RWA/multichain). Endpoint attestation mesh is textbook DePIN.
- **Secondary narrative:** Agentic Web (AI sentinel agents — Phase 3 narrator).
- **Specialized bounty:** Walrus ($70K pool) — forensic blob archive is genuine Walrus usage. Walrus integration is in Phase 1 specifically to claim this.
- **Possible:** Infra & DevX (framed as trust infrastructure for builders).
- **Possible award:** OpenZeppelin / OtterSec audit credits.

**Judging criteria that shape every decision:**

1. **Demo-first.** Working live demo with real wallet interaction is the minimum bar.
2. **Genuine Sui Stack usage.** Move + SDK + Walrus + real on-chain transactions verifiable on Sui Explorer. Hollow imports penalized.
3. **AI-assisted code held to a higher bar.** Ship substantive work, not LLM wrappers.
4. **Originality + execution** across product/UX/technical design.

Per-phase mapping to judging criteria is in `detailed-roadmap.md` (Phase-to-judging-criterion table).

---

## 4. Architecture

```
┌───────────────────────────────────────────────────────────────────┐
│                         Sui (testnet)                              │
│  ┌──────────────────┐  ┌──────────────┐  ┌──────────────────────┐ │
│  │ Device objects   │  │ Policy obj.  │  │ AdminCap /           │ │
│  │ (non-transfer.,  │◄►│ (shared)     │◄►│ SentinelCap /        │ │
│  │  one per host)   │  │ allowlists,  │  │ EnrollmentTicket     │ │
│  │ status, version, │  │ thresholds   │  │ (Move capabilities)  │ │
│  │ hw_fingerprint   │  └──────────────┘  └──────────────────────┘ │
│  └────────▲─────────┘                                              │
└───────────┼────────────────────────────────────────────────────────┘
            │ PTBs                          ▲
   ┌────────┴───────────┐         ┌─────────┴──────────┐
   │ Sentinel agent     │ ──────► Walrus (forensic blobs, Quilt)
   │ (Rust + tokio)     │         │
   │ eBPF (execve+IMA)  │         └────────────────────┘
   │ TPM (physical) /   │
   │ fallback (VM)      │
   └─────────┬──────────┘
             │
             │ Sui state read via verifier SDK
             ▼
   ┌────────────────────┐        ┌─────────────────────┐
   │ Demo VPN / gateway │        │ Thorium Web UI      │
   │ rejects on         │        │ (SvelteKit)         │
   │ Compromised        │        │ - zkLogin admin     │
   └────────────────────┘        │ - bulk enrollment   │
                                 │ - fleet dashboard   │
                                 └─────────────────────┘
```

### Components (target layout — verify against repo, see §16)

| Component | Path (target) | Lang | Owner |
|---|---|---|---|
| Move package | `move/<package_name>/` — see §16 Q1 | Move | A |
| Sentinel agent — binary | `sentinel/` | Rust | B |
| Sentinel core — lib (eBPF, telemetry, PTB submission) | `sentinel-core/` | Rust | B |
| Sentinel fingerprint — lib (TPM + fallback) | `sentinel-fingerprint/` | Rust | B |
| Provisioning CLI (Phase 2) | `thorium-provision/` | Rust | B |
| Verifier SDK | `verifier-sdk/` | TypeScript | A |
| Demo gateway | `demo-gateway/` | Node/TS (Bun) | B |
| Web UI | `/` (repo root SvelteKit app; `src/routes/` hosts pages) | SvelteKit + dApp Kit + Enoki | A |
| Narrator (Phase 3) | `narrator/` | Rust or Node | A |
| Demo assets | `demos/` (videos, attack scripts) | — | Joint |

### OS scope

**Linux-only through Phase 3.** macOS, Windows = Phase 4+ stretch. The §8 demo (LD_PRELOAD, `insmod`) is Linux-native; effort is not split across kernels.

---

## 5. Identity model (local + on-chain)

Two artifacts, one logical identity:

**Local artifact — sealed keypair + hardware fingerprint**
- Ed25519 keypair generated on-device.
- **Sealed by TPM 2.0** on physical devices (real PCR-bound storage via `tpm2-tss` / `tss-esapi` crate).
- **Fallback** on VMs: file at `/etc/thorium/device.key` (`0600` perms), plus hardware fingerprint composed from `/etc/machine-id` + primary disk UUID. Both physical and VM devices upload status on-chain — the demo proves the mesh works across attestation tiers.
- Hardware fingerprint = motherboard serial + primary MAC on physical; `machine-id` + disk UUID on VM.
- Mode selected at runtime: `--fingerprint-mode {auto,tpm,fallback}`. `auto` probes `/dev/tpm0`.

**On-chain artifact — non-transferable Device Move object**
- `Device` struct has `key` ability and **no `store`** → cannot be wrapped, transferred, or moved into other objects. This is functionally a Soulbound Token in Sui's object model.
- We do **not** introduce a separate SBT standard or token layer on top. Sui's object semantics give us SBT behavior natively. Early outlines mentioned "SBT" — that means this Device object.

The local keypair signs sentinel reports; the on-chain Device object's `public_key` field anchors which key is authoritative for which device.

---

## 6. Move contract design

### Module layout

```
move/<package>/
├── sources/
│   ├── device.move           // Device object + status transitions
│   ├── policy.move           // Policy object + threshold rules
│   ├── capability.move       // AdminCap, SentinelCap, IncidentResponderCap
│   ├── enrollment.move       // EnrollmentTicket + consume → mint Device (Phase 2)
│   ├── attestation.move      // AttestationReport struct + signature verification
│   └── events.move           // Sui events for status / enrollment
├── tests/
└── Move.toml
```

> Package directory: `move/thorium/`. The Move package name is **`thorium`** (resolved 2026-05-26). Any older reference to `sentrysui` is legacy — treat as `thorium`.

### Key types (sketch — finalize in Phase 1)

```move
public struct Device has key {
    id: UID,
    operator: address,                    // who controls the device's reports
    public_key: vector<u8>,               // Ed25519 device-bound key
    hardware_fingerprint: vector<u8>,     // hash of mb-serial+MAC or machine-id+disk
    policy_id: ID,                        // ref to Policy object
    status: u8,                           // 0=Healthy, 1=Degraded, 2=Compromised, 3=Unknown
    last_attestation_epoch: u64,
    last_attestation_root: vector<u8>,
    forensic_blob_id: Option<vector<u8>>, // Walrus blob ID when Compromised
}
// NO `store` ability → Device is non-transferable → SBT-equivalent

public struct EnrollmentTicket has key {
    id: UID,
    policy_id: ID,
    nonce: vector<u8>,
    expires_at_epoch: u64,
    issued_by: address,
}
// Phase 2. Burned by enrollment::consume on agent first run, atomically mints Device.

public struct SentinelCap has key, store {
    id: UID,
    operator: address,
    scope: vector<ID>,                    // devices this cap may report on
}
// NO `copy`, NO `drop` — mintable, transferable, non-duplicable.

public struct AdminCap has key, store { id: UID }
// Held by Thorium admin(s); used for kill-switch (= status flip with admin authority).
```

### Status transitions

| From | To | Required cap | Notes |
|---|---|---|---|
| Healthy / Degraded → Compromised | `SentinelCap` | within scope, severity ≥ threshold (sentinel-initiated) |
| Healthy / Degraded → Compromised | `AdminCap` | **kill-switch** — admin-initiated revocation |
| Healthy ↔ Degraded | `SentinelCap` | within scope, within attestation TTL |
| any → Unknown | none (anyone) | system function; only fires if TTL exceeded |
| Compromised → Healthy | `AdminCap` | manual incident-response recovery |

> **"Kill-switch" is not a separate function.** It is the same status-flip-to-Compromised entry, callable with `AdminCap` instead of `SentinelCap`. One Move function (or two functions sharing the same internal state-transition logic), two authorized capabilities.

### Enrollment flow (Phase 2)

1. Admin (via Web UI, signed-in with zkLogin/Enoki) calls `enrollment::mint_batch(policy, count, ttl, &AdminCap)` → one PTB mints N `EnrollmentTicket` objects.
2. Admin downloads a bundle (`{ticket_id, policy_id, pkg_id, rpc_url}`) per ticket; distributes out-of-band.
3. Agent first-run reads bundle, generates keypair, builds `enrollment::consume(ticket, policy, pubkey, fingerprint)` PTB → atomically burns ticket and mints Device.

**Bundle file convention:** agent searches for the enrollment bundle at `/etc/thorium/bundle.json` (production / packaged install) and `./bundle.json` (development / first-run from CWD), in that order. First match wins. Override with `--bundle <path>`.

**EnrollmentTicket transferability:** tickets are created as **shared objects** so the agent (which doesn't own them) can consume them in a PTB it signs. Replay/abuse is prevented by the on-ticket `nonce` + `expires_at_epoch` and by the fact that `consume` deletes the ticket atomically with the `Device` mint.

Visible on Sui Explorer as a tx that consumed an `EnrollmentTicket` and created a `Device`.

### Conventions

- Entry functions validate caps via `&SentinelCap` / `&AdminCap` references.
- Status enum as `u8` with named constants in the module.
- Emit a Sui event on every status change (`StatusChanged { device_id, from, to, epoch, blob_id, triggered_by }`) and every enrollment (`DeviceEnrolled`).
- Routine heartbeats mutate only the Device object → **fast path** (no consensus contention).
- Policy / EnrollmentTicket mints → shared-object path, full consensus.

---

## 7. Sentinel agent

### Stack
- **Language:** Rust
- **Runtime:** `tokio` async. Pure headless daemon. **No Tauri** (legacy outline artifact; explicitly removed).
- **Error handling:** `anyhow` in binaries, `thiserror` in libs.
- **Logging:** `tracing`.
- **eBPF library:** `aya` + `aya-ebpf`. Study Tetragon's TracingPolicy model as architectural reference; do not reimplement it.
- **Sui interaction:** `sui-sdk` (Rust)
- **TPM interaction:** `tss-esapi` crate (bindings over `tpm2-tss`).
- **Walrus interaction:** HTTP against the Mysten-operated Upload Relay (testnet endpoint).

### Phase 1 signal — execve + hash allowlist

The single signal that ships first, end-to-end:

- Hook: `sched_process_exec` tracepoint.
- Capture: binary path. Compute SHA-256 in userspace — not in eBPF.
- Compare: against allowlist hash set loaded from the on-chain `Policy` object; refreshed every **30 s** by default, override with `--policy-refresh-interval <secs>`.
- Deterministic trigger: `LD_PRELOAD=/tmp/evil.so <victim>` or `cp /bin/ls /tmp/evil && /tmp/evil` — both produce a non-allowlisted exec.

### Later signals (Phase 3+)

In priority order, added incrementally:
1. Kernel module loads via `module_load` (catches `insmod /tmp/evil.ko`).
2. `sys_bpf` `BPF_PROG_LOAD` from non-allowlisted loaders (counter to eBPF-rootkit families).
3. IMA measurement-list anomalies (`/sys/kernel/security/ima/ascii_runtime_measurements`).
4. Unexpected outbound connections via `tcp_connect`.
5. Capability transitions via `cap_capable` LSM hook.

A small high-S/N set is more credible than a firehose. Axelsson's base-rate fallacy applies: false positives drown response capacity. Rules-first; AI as triage (Phase 3 narrator).

### Autonomous disruption

For the hackathon demo: **post-verdict only.** The on-chain `Compromised` event is the trigger; the demo gateway acts on it. Move owns the decision.

For the eventual product (post-hackathon): mixed model — pre-verdict local actions for high-severity-high-confidence signals, post-verdict actions for everything else. Out of scope for Sui Overflow.

### Reporting flow

```
kernel event → eBPF ring buffer → Rust consumer → batched report
                                                      ↓
                                              window hash + Ed25519 signature
                                                      ↓
                                       routine heartbeat OR anomaly
                                          ↓                ↓
                                  Sui PTB (status        Walrus blob (forensic
                                    update, fast path)    snapshot, Quilt-batched)
                                                              ↓
                                                          blob_id in next PTB
                                                              ↓
                                                          Sui PTB (status=
                                                          Compromised, attach blob)
```

---

## 8. Demo scenario (north star — every choice rolls up to this)

A live 3-minute scene with **two devices** running side-by-side:

- **Device 1:** physical laptop with TPM 2.0, real PCR-bound key sealing.
- **Device 2:** Linux VM with fallback fingerprint (`machine-id` + disk UUID) and file-sealed key.

Both enroll, both heartbeat, both can flip to `Compromised`. The mesh demonstrates that the attestation tier varies but the verdict layer is uniform.

### The 3-minute scene

1. **Healthy state.** Web UI fleet view shows both devices `Healthy`. Sui Explorer shows the two Device objects. Demo VPN dashboard is green: "VPN access granted to both."
2. **Attack injection on the VM** (so we don't compromise the presenter's laptop): live `LD_PRELOAD=/tmp/evil.so /usr/local/bin/api-server`.
3. **Telemetry trace.** Agent log panel shows the eBPF event firing with non-allowlisted hash. Phase 3: narrator emits a one-paragraph English summary.
4. **On-chain flip.** PTB submits; VM's Device object `status: Compromised` + Walrus blob ID attached. Visible on Sui Explorer within ~1s (single-owner fast path).
5. **Downstream rejection.** VPN dashboard flips the VM to red within 2s of polling. New connection attempt from the VM is rejected. Physical device remains `Healthy`, still connects.
6. **(Bonus) Kill-switch.** Admin clicks "Quarantine" in the Web UI on the physical device. PTB submits with `AdminCap` instead of `SentinelCap`. Same `StatusChanged` event; downstream rejects within 2s.

**Pre-recorded backup video of the same scene is mandatory by end of Phase 3.** Stored at `demos/backup.mp4`.

---

## 9. Out of scope / anti-goals

These will be *rejected* in PRs and design discussions for the hackathon scope:

- ❌ **Custodial vault model** — no Move contracts holding real user funds.
- ❌ **Fake TPM attestation** — on physical devices we use real `tpm2-tss`; on VMs we use the documented fallback and say so.
- ❌ **AI as security backstop** — the LLM narrates and proposes; Move policy decides.
- ❌ **Untargeted "ML on syscalls"** — base-rate fallacy. Rules-first, AI as triage.
- ❌ **Mainnet with real funds** — testnet for the demo. If mainnet, trivial sums only.
- ❌ **Multi-OS support in Phase 1–3** — Linux only. macOS / Windows ETW = Phase 4+.
- ❌ **Tauri / desktop GUI on the agent** — agent is headless.
- ❌ **Separate SBT token standard** — Sui's `key`-without-`store` gives SBT semantics natively.
- ❌ **Nautilus enclave-signed reports in Phase 1–3** — Phase 4 stretch only.
- ❌ **Pre-verdict autonomous disruption** — post-verdict only for the demo.
- ❌ **Bitcoin/Ethereum/Solana primers in docs/comments** — assume reader knows them.
- ❌ **npm / npx in scripts and docs** — package manager is `bun`. See §12.

---

## 10. Honest-scope policy

**Software attestation is the baseline.** Sentinel hashes processes, monitors eBPF events, signs reports with a device-bound Ed25519 key. Buys "tamper-evident, not tamper-proof." A compromised host can lie, but staleness, forensic trail, and on-chain verdict layer remain.

**TPM is in scope for physical devices in Phase 1.** Real PCR-bound key sealing via `tpm2-tss`. Code path exercised in CI and in the live demo on the physical laptop. Device public key registered in the Device object at enrollment.

**Fallback path is in scope and named as such.** VMs and TPM-less hardware use `machine-id` + disk UUID as fingerprint and file-sealed key with restricted perms. Demo shows both tiers uploading status — we are explicit that the VM is the weaker tier.

**Nautilus / TEE-signed reports stays out of scope through Phase 3.** Phase 4 stretch only.

The README / pitch slide must name these tiers honestly. If we cannot do real TPM, we say "software attestation only" and don't pretend.

---

## 11. External dependencies and resources

### SDKs / Frameworks
- **Sui SDK (TypeScript):** `@mysten/sui` — Web UI + verifier SDK
- **Sui SDK (Rust):** `sui-sdk` — sentinel agent
- **Walrus SDK:** `@mysten/walrus` for TS; HTTP against Upload Relay for Rust
- **Seal SDK** (Phase 3): `@mysten/seal`
- **dApp Kit:** `@mysten/dapp-kit` — Web UI wallet connection
- **Enoki SDK:** `@mysten/enoki` — zkLogin admin onboarding for the Web UI
- **SvelteKit:** Web UI framework. Minimal template, TypeScript.
- **aya** (Rust eBPF): https://github.com/aya-rs/aya
- **tpm2-tss** + **tss-esapi** crate: physical-device key sealing
- **Bun:** package manager and JS/TS runtime for everything Node-flavored. **Do not use npm/npx.**

### Key documentation
- Sui Overflow 2026: https://overflow.sui.io/
- Sui Move: https://docs.sui.io/concepts/sui-move-concepts
- Walrus: https://docs.wal.app/
- Seal: https://seal-docs.wal.app/
- Tetragon (architectural reference): https://tetragon.io/docs/
- Linux IMA: https://sourceforge.net/p/linux-ima/wiki/Home/

### Verification endpoints
- Sui Explorer: https://suiscan.xyz/ or https://suivision.xyz/
- Sui Testnet faucet: https://faucet.sui.io/
- Walrus Upload Relay (testnet): per Walrus docs

---

## 12. Conventions

### Package manager
- **bun** for everything TypeScript/JavaScript. `bun install`, `bun run dev`, `bun run build`, `bunx <tool>`.
- **Never** `npm`, `npx`, `pnpm`, or `yarn` in scripts, READMEs, or CI.
- Lockfile: `bun.lockb` (or `bun.lock`) committed; do not commit `package-lock.json` or `yarn.lock`.

### Code style
- **Move:** snake_case modules and functions; PascalCase structs. One module per logical concept. Comment every entry function with its capability requirement.
- **Rust:** `rustfmt` defaults. `clippy::pedantic` warnings allowed, no errors. `anyhow::Result` in binaries, `thiserror` in libs. Async with `tokio`. `tracing` for logs.
- **TypeScript:** `biome` or `prettier`. Strict mode. No `any` without justifying comment.
- **Svelte:** SvelteKit conventions. Stores in `src/lib/stores/`; Sui-related logic in `src/lib/sui/`; components in `src/lib/components/`. No global side-effects in module scope.

### Commit style
- Conventional commits: `feat(move): add EnrollmentTicket`, `fix(sentinel): handle ringbuf overflow`.

### When proposing changes
1. State the goal in one line.
2. List affected files.
3. Identify which judging-criterion / phase exit-criterion is advanced.
4. If touching Move: confirm capability-pattern is preserved (caps have no `copy`/`drop`).
5. If adding a new external dependency: justify against the "thin dependency" preference.

### When in doubt
- Optimize for the 3-minute demo, not for production polish.
- Prefer testnet over mainnet for anything funds-related.
- Honest README beats overclaimed README.
- If a feature requires AI to be the authoritative decision-maker for security, it is wrong. Refactor so Move owns the decision.

---

## 13. Phase boundaries (summary — granular plan in `detailed-roadmap.md`)

```
Phase 1 — Endpoint Agent & On-chain Verdict           (weeks 1–3)
  Exit: §8 demo runs end-to-end on the VM device.
        Move package on testnet, agent runs end-to-end,
        Walrus blob attached on Compromised, verifier SDK + demo
        gateway minimal but working. Tag: phase-1-complete.

Phase 2 — Web3 Identity & Provisioning                (weeks 4–5)
  Exit: EnrollmentTicket mint+consume flow on testnet,
        Thorium Web UI with zkLogin admin sign-in (via Enoki),
        bulk-mint UI, kill-switch (AdminCap path),
        fleet dashboard showing multiple devices.
        Tag: phase-2-complete.

Phase 3 — Forensics & Narration                       (weeks 6–7)
  Exit: Seal-encrypted forensic blobs with Move-defined access,
        AI narrator (Claude API), anomaly classifier,
        module_load + BPF_PROG_LOAD signals,
        dashboard polish, pre-recorded demo video.
        Tag: phase-3-complete.

Phase 4 — Submission, Buffer, Stretch                 (week 8)
  Exit: Sui Overflow 2026 submission filed.
  Stretch (ranked): custom OIDC→zkLogin, Nautilus, multi-OS
        scaffolding, second attack scenario.
```

> **Phase 4 is *inside* the hackathon window**, not post-hackathon. Truly post-deadline work is not tracked in this document.

---

## 14. Glossary

- **PTB** — Programmable Transaction Block. A composable batch of Move calls executed atomically on Sui.
- **Capability (Move)** — A struct without `copy` or `drop` abilities, gating access to entry functions via type-system enforcement.
- **Fast path** — Sui's single-owner-object transaction path, finalizing via reliable broadcast without global consensus.
- **Walrus Quilt** — Walrus's batching primitive for small files; bundles up to ~660 small blobs into one storage unit.
- **Seal** — Sui's threshold-encryption layer with Move-defined access policies. Phase 3.
- **Nautilus** — Sui's TEE-coprocessor framework (currently AWS Nitro Enclaves). Phase 4 stretch.
- **zkLogin** — Sui's native OAuth-based authentication using Groth16 zk-SNARKs. Used here for Web UI admin sign-in via Enoki.
- **EnrollmentTicket** — Move object minted in bulk by admin; burned by agent on first run to atomically create its Device object.
- **Kill-switch** — Admin-initiated status flip to `Compromised`. Same Move state transition as sentinel-initiated; different capability (`AdminCap` vs `SentinelCap`).
- **IMA** — Linux Integrity Measurement Architecture. Hashes files on load, extends PCR 10 if TPM present.
- **PCR** — TPM Platform Configuration Register; extend-only register holding cumulative measurements.
- **LSM-BPF (KRSI)** — Kernel Runtime Security Instrumentation; eBPF programs attached to Linux Security Module mediation hooks. TOCTOU-resistant.
- **Hardware fingerprint** — Motherboard serial + primary MAC on physical devices; `/etc/machine-id` + primary disk UUID on VMs.
- **SBT (in our project)** — Not a separate token standard. Refers to the Device Move object, which is non-transferable by virtue of having `key` without `store`.

---

## 15. Companion documents in `.ai/` and `docs/`

> **New agent / fresh-session entry point:** start at **`.ai/README.md`** — it's the file-by-file map of this directory and tells you in what order to read what. If you landed in any other file first, you can still recover by opening that one. Everything else here is authoritative for its own scope and cross-references the rest.

- **`.ai/README.md`** — Landing page / map. Tells you what each file is for and the recommended read order.
- **`.ai/context.md`** *(this file)* — Stable architectural ground truth: what we are building, identity model, Move design, demo scene, anti-goals, conventions. The *why* and *how the pieces fit*.
- **`.ai/detailed-roadmap.md`** — Authoritative per-phase, per-week task lists, exit criteria, decision gates. Source of truth for *what to do this week*.
- **`.ai/progress.md`** — Living checklist derived from the roadmap. Tick boxes as items complete.
- **`.ai/deadlines.md`** — Hackathon submission deadline, internal milestone deadlines. *(File may not yet exist; if absent, create when the deadline calendar is finalized.)*
- **`.ai/deployments.md`** — Testnet object IDs (Move package, default Policy object, etc.) recorded as they're published.
- **`.ai/reconciliation-log.md`** — Audit trail for resolved §16/§17 items. Append-only, dated entries.
- *(Possible future)* **`.ai/decisions.md`** — Architecture Decision Records as we lock in choices.
- **`docs/manual/`** — Per-component run scripts and the demo-scenario walkthrough. One file per component as that component lands. `docs/manual/README.md` lists expected filenames.
- **`agent/src-tauri/LEGACY.md`** — Notes on the legacy Tauri scaffold that is kept in place for reference but not used by the current plan (see §9, §17 T11 history).

---

## 16. Open Questions for local resolution

> *Empty as of 2026-05-26.* All Q1–Q8 raised in earlier reconciliation passes are resolved. New questions should be added here as `Qn` entries when discovered, then removed when answered. See `.ai/reconciliation-log.md` for history.

---

## 17. TBD — known ambiguities & duplications

These are inconsistencies between `context.md` and `detailed-roadmap.md`, or between either doc and external user statements, that need a single source of truth. Resolved items move to `.ai/reconciliation-log.md`.

> **As of 2026-05-26: all naming / repo-state items (T1, T4, T11, T12, T13, T14) are resolved.** Only T7–T10 remain, and those are conscious duplications that need ongoing vigilance — not open work.

**T7 — Team allocation duplication.**
- `context.md` §2 and `detailed-roadmap.md` §0 both state the team split.
- Intentional duplication for orientation. The authoritative copy is `detailed-roadmap.md`; this file references it.
- No action; flagged so the duplication is conscious.

**T8 — Demo scenario duplication.**
- `context.md` §8 (detailed) and `detailed-roadmap.md` (abbreviated reference) both describe the demo scene.
- Authoritative copy is this file (`context.md` §8 — it's the architectural north star). Roadmap correctly summarizes-and-points.
- No action.

**T9 — Phase boundaries duplication.**
- `context.md` §13 (summary) and `detailed-roadmap.md` (granular) both have phase descriptions.
- Authoritative copy of *exit criteria* is roadmap. This file should summarize, not duplicate. Current §13 is on the boundary — keep slim.
- No action unless drift emerges.

**T10 — File-level inventory duplication.**
- `detailed-roadmap.md` "File-level inventory" lists `move/thorium/`, `sentinel/`, etc.
- `context.md` §4 Components table lists the same.
- Authoritative copy: this file (§4). Roadmap can keep its inventory as long as it matches.

---

*Last updated: 2026-05-26. **All §16 questions and §17 T1/T4/T11/T12/T13/T14 items closed.** Move package name locked to `thorium`. `agent/src-tauri/` is marked legacy in place (see `agent/src-tauri/LEGACY.md`). `my-app/` confirmed gitignored — local-only sandbox. `package-lock.json` files left in place; standing recommendation is `bun install` then `git rm --cached` when convenient. README front-matter labels the legacy "Thorium XDR" pitch as deferred to Phase 3 Week 7. New AI agents: start at `.ai/README.md` for the file map. Full audit trail in `.ai/reconciliation-log.md`.*
