# SentrySui — Project Context for Claude Code

> Place this file at `.claude/sentrysui.md`, `.ai/context.md`, or `CLAUDE.md` at repo root. Claude Code reads this on session start to ground its suggestions in the project's actual scope, architecture, and constraints. **Read this fully before proposing changes.**

---

## 1. What we are building

**SentrySui** is a decentralized device-attestation mesh on Sui. Each enrolled device is a Sui Move object with a security status; a per-device sentinel agent (Rust) continuously reports software-attestation telemetry; status transitions to `Compromised` are on-chain events that downstream services (a demo VPN/gateway) consult before granting access. Forensic logs are stored on Walrus; sensitive logs are gated by Seal access policies.

**Positioning:** "the trust ledger as DePIN, with on-chain circuit breakers for endpoint compromise." Not an XDR vendor replacement. The novelty is the **public, multi-verifier verdict layer**, not better detection.

**One-line elevator pitch for the demo:** *"AI agents narrate. Sui decides. The mesh enforces."*

---

## 2. Status

- **Phase:** Pre-build, week 0. No production code yet.
- **Team:** 2 fullstack devs. Strong in security, backend, blockchain. AI agents = new skill.
- **Timeline:** Sui Overflow 2026, May–August 2026 (~12 weeks). Hard deadline read from the official handbook; confirm in `.ai/deadlines.md` once locked.

When Claude Code starts on a task, assume nothing is built unless the relevant file exists in the repo.

---

## 3. Hackathon constraints (this drives everything)

- **Primary track:** Explorations (DePIN/RWA/multichain).
- **Secondary narrative:** Agentic Web (AI sentinel agents).
- **Specialized bounty:** Walrus ($70K pool) — forensic log archive is genuine Walrus usage.
- **Possible:** Infra & DevX if framed as "trust infrastructure for builders."
- **Possible award:** OpenZeppelin / OtterSec audit credits.

**Judging criteria that shape every decision:**

1. **Demo-first.** A working live demo with real wallet interaction is the minimum bar. Slide-only submissions lose.
2. **Genuine Sui Stack usage.** Move + SDK + Walrus + (optionally Seal/Nautilus) with real on-chain transactions verifiable on Sui Explorer. Hollow SDK imports are penalized.
3. **AI-assisted code is held to a higher bar.** Be critical, ship substantive work, not LLM wrappers.
4. **Originality + execution** across product/UX/technical design.

---

## 4. Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         Sui Mainnet                              │
│  ┌─────────────────┐    ┌──────────────┐    ┌────────────────┐ │
│  │ Device objects  │    │ Policy obj.  │    │ AdminCap /     │ │
│  │ (one per host)  │◄──►│ (shared)     │◄──►│ SentinelCap    │ │
│  │ status, version │    │ allowlists,  │    │ (Move          │ │
│  │ last_attest_eph │    │ thresholds   │    │ capabilities)  │ │
│  └────────▲────────┘    └──────────────┘    └────────────────┘ │
│           │ PTBs                                                 │
└───────────┼─────────────────────────────────────────────────────┘
            │                              ▲
   ┌────────┴─────────┐          ┌────────┴────────┐
   │ Sentinel agent   │ ───► Walrus (forensic logs, Quilt-batched)
   │ (Rust + eBPF)    │          │  Seal policy: IncidentResponderCap
   │ Tetragon-based   │          │  required to decrypt
   │ telemetry        │          └─────────────────┘
   │ Claude/Atoma     │
   │ narrator         │
   └──────────────────┘
            │
            │ exposes status via verifier SDK
            ▼
   ┌──────────────────┐
   │ Demo VPN / API   │  reads Sui state, rejects on Compromised
   │ gateway          │
   └──────────────────┘
```

### Components

| Component | Lang | Purpose |
|---|---|---|
| Move package `sentrysui` | Move | Device/Policy/Cap objects + entry functions |
| Sentinel agent `sentinel/` | Rust | Telemetry collection, PTB submission, Walrus uploads |
| Verifier SDK `verifier-sdk/` | TypeScript | `isDeviceTrusted(deviceId) -> bool` for downstream services |
| Demo gateway `demo-gateway/` | Node/TS | Mock VPN endpoint that consults the verifier SDK |
| Dashboard `dashboard/` | Next.js + dApp Kit | Fleet view, event stream, drill-in |
| Narrator `narrator/` | Rust or Node | AI narration of telemetry events (Claude API or Atoma) |

---

## 5. Move contract design

### Module structure
```
sentrysui/
├── sources/
│   ├── device.move        // Device object + status transitions
│   ├── policy.move        // Policy object + threshold rules
│   ├── capability.move    // AdminCap, SentinelCap, IncidentResponderCap
│   ├── attestation.move   // AttestationReport struct + validation
│   └── events.move        // Sui events for status changes
├── tests/
└── Move.toml
```

### Key types (sketch)

```move
public struct Device has key {
    id: UID,
    owner: address,
    public_key: vector<u8>,        // Ed25519 device-bound key
    policy_id: ID,                  // ref to Policy object
    status: u8,                     // 0=Healthy, 1=Degraded, 2=Compromised, 3=Unknown
    last_attestation_epoch: u64,
    last_attestation_root: vector<u8>,  // hash of recent telemetry window
    forensic_blob_id: Option<vector<u8>>, // Walrus blob ID when Compromised
}

public struct Policy has key {
    id: UID,
    name: vector<u8>,
    allowed_process_hashes: vector<vector<u8>>,
    expected_kernel_hash: Option<vector<u8>>,
    sentinel_threshold: u64,        // number of sentinel reports required
    attestation_ttl_epochs: u64,    // stale → Unknown
}

public struct SentinelCap has key, store {
    id: UID,
    operator: address,
    scope: vector<ID>,              // devices this cap may report on
}
// NO `copy`, NO `drop` — capability is mintable, transferable, non-duplicable
```

### Status transition rules

| From | To | Required cap | Validation |
|---|---|---|---|
| Healthy | Degraded | SentinelCap | within scope, attestation within TTL |
| Healthy | Compromised | SentinelCap | within scope, severity ≥ threshold |
| Degraded | Compromised | SentinelCap | same as above |
| any → Unknown | (auto) | none | TTL exceeded; system function callable by anyone, gated by epoch check |
| Compromised → Healthy | AdminCap | manual incident-response recovery |

**Move conventions:**
- Entry functions validate caps via `&SentinelCap` references — caps cannot be copied or forged.
- Status enum as `u8` with named constants in the module (avoid magic numbers).
- Emit a Sui event on every status change (`StatusChanged { device_id, from, to, epoch, blob_id }`).
- Routine heartbeats mutate only the Device object → take Sui's **fast path** (single-owner object, no consensus contention).
- Policy updates mutate shared state → full consensus path.

---

## 6. Sentinel agent

### Stack
- **Language:** Rust
- **eBPF:** `aya` (preferred) or `libbpf-rs`
- **Architecture pattern:** Tetragon-style. Study Tetragon's TracingPolicy model. Do not reimplement Tetragon; use it directly if possible and wrap its event stream.
- **Sui interaction:** `sui-sdk` (Rust)
- **Walrus interaction:** HTTP against the public Upload Relay (Mysten-operated testnet/mainnet endpoints)

### Curated signal set (instrument these, in this order)

1. **`execve` events** via `sched_process_exec` tracepoint or LSM `bprm_check_security`. Emit binary path + IMA file hash. Compare to allowlist.
2. **Kernel module loads** via `module_load` tracepoint. Outside-of-boot-window loads = high severity.
3. **`sys_bpf` BPF_PROG_LOAD calls** from non-allowlisted loaders. Direct counter to eBPF-rootkit families.
4. **IMA measurement-list anomalies** by reading `/sys/kernel/security/ima/ascii_runtime_measurements`.
5. **Unexpected outbound connections** via `tcp_connect` kprobe. Limit cardinality.
6. **Capability transitions** via `cap_capable` LSM hook.

**Don't instrument everything.** A small high-S/N signal set is more credible than a firehose. See Axelsson's base-rate analysis — false positives drown response capacity.

### Reporting flow

```
kernel event → eBPF ring buffer → Rust consumer → batched report
                                                      ↓
                                              window hash + signature
                                                      ↓
                                       routine heartbeat OR anomaly
                                          ↓                ↓
                                  Sui PTB (status=        Walrus blob (forensic
                                    Healthy update)        snapshot) → Quilt-batched
                                                              ↓
                                                          blob_id in PTB
                                                              ↓
                                                          Sui PTB (status=
                                                          Compromised, attach blob)
```

---

## 7. Demo scenario (this is what we optimize for)

A live 3-minute scene the judges watch end-to-end:

1. **Healthy state visible.** Device object on Sui Explorer shows `status: Healthy`. Demo VPN dashboard reads via verifier SDK, panel is green: "VPN access granted."
2. **Attack injection.** On the device, attack #1 is triggered live: `LD_PRELOAD=/tmp/evil.so /usr/local/bin/api-server`. **OR** attack #2: `insmod /tmp/evil.ko`.
3. **Telemetry trace.** Sentinel's view panel shows the eBPF event firing with non-allowlisted hash. Narrator emits a one-paragraph English summary.
4. **On-chain flip.** PTB submits; Device object's `status: Compromised` + Walrus blob ID attached. Visible on Sui Explorer within ~1s (single-owner fast path).
5. **Downstream rejection.** VPN dashboard flips red within 2s of polling. New connection attempt is rejected.

**Build everything backwards from this scene.** If a feature does not show up in those 3 minutes, deprioritize.

A pre-recorded backup video of the same scene is mandatory by Week 7.

---

## 8. Out of scope / anti-goals

These will be *rejected* in PRs and design discussions:

- ❌ **Custodial vault model** — no Move contracts holding real user funds. Capability-based, not custody-based.
- ❌ **Fake TPM attestation** — no `sha256(uname -a)` and calling it attestation. If we don't do real TPM, we don't claim TPM. (See §9 for the honest TPM path.)
- ❌ **AI as security backstop** — the LLM narrates and proposes; Move policy decides. Status transitions cannot depend solely on LLM output.
- ❌ **Untargeted "ML on syscalls"** — see base-rate fallacy. Rules-first, AI as triage.
- ❌ **Mainnet with real funds** — testnet for the demo. If mainnet, trivial sums only.
- ❌ **Production claims we can't back up in 8 weeks** — say "tamper-evident, not tamper-proof" honestly.
- ❌ **Scope expansion** — second strategy/feature added only after Week 4 decision gate.
- ❌ **Bitcoin/Ethereum/Solana primers in docs/comments** — assume reader knows them.

---

## 9. Honest-scope policy

**Software attestation is the MVP.** Sentinel hashes processes, reads IMA, monitors eBPF events, signs reports with a device-bound key. This buys "tamper-evident, not tamper-proof." A compromised host can lie, but staleness, forensic trail, and on-chain verdict layer remain.

**TPM as stretch goal only.** If a TPM is actually used:
- Real PCR quotes via `tpm2-tss`, signed by an AIK.
- AIK public key registered in the Device object.
- IMA measurement-list replayed against on-chain golden set.
- Quote signature verified in Move (via Nautilus / Marlin Oyster attestation-verification path, not by reimplementing TPM quote signature verification in Move from scratch).

**Nautilus as the *right* stretch goal.** Run the sentinel's report-signing component inside an AWS Nitro Enclave. Custom PCR verification is now live on Sui mainnet. The Device object holds expected enclave PCRs. Move refuses any report not signed by an enclave with those PCRs.

---

## 10. External dependencies and resources

### SDKs / Frameworks
- **Sui SDK (TypeScript):** `@mysten/sui` — dashboard + verifier SDK
- **Sui SDK (Rust):** `sui-sdk` — sentinel agent
- **Walrus SDK:** `@mysten/walrus` for TS; HTTP against Upload Relay for Rust
- **Seal SDK:** `@mysten/seal` (TS) — forensic-log encryption
- **dApp Kit:** `@mysten/dapp-kit` — dashboard wallet connection
- **Enoki SDK:** `@mysten/enoki` — zkLogin onboarding for the dashboard
- **Tetragon:** https://github.com/cilium/tetragon — sentinel telemetry foundation
- **aya** (Rust eBPF): https://github.com/aya-rs/aya — if implementing custom probes
- **tpm2-tss** (stretch goal): https://github.com/tpm2-software/tpm2-tss

### Key documentation
- Sui Overflow 2026: https://overflow.sui.io/
- Sui Move: https://docs.sui.io/concepts/sui-move-concepts
- Walrus: https://docs.wal.app/
- Seal: https://seal-docs.wal.app/
- Nautilus: https://docs.sui.io/concepts/cryptography/nautilus
- Tetragon docs: https://tetragon.io/docs/
- Linux IMA: https://sourceforge.net/p/linux-ima/wiki/Home/

### Verification endpoints (use these for demos)
- Sui Explorer: https://suiscan.xyz/ or https://suivision.xyz/
- Sui Testnet faucet: https://faucet.sui.io/
- Walrus Upload Relay (testnet): per Walrus docs

---

## 11. Conventions for Claude Code

### Style
- **Move:** snake_case modules and functions; PascalCase structs. One module per logical concept (Device, Policy, Capability). Comment every entry function with its capability requirement.
- **Rust:** `rustfmt` defaults. `clippy::pedantic` allowed warnings, no errors. Prefer `anyhow::Result` in binaries, `thiserror` in libs. Async with `tokio`.
- **TypeScript:** `biome` or `prettier` with project config. Strict mode. No `any` without comment justifying.

### Commit style
- Conventional commits: `feat(move): add SentinelCap`, `fix(sentinel): handle ringbuf overflow`.

### When proposing changes
1. State the goal in one line.
2. List affected files.
3. Identify which judging-criterion / hackathon-track is advanced.
4. If touching Move: confirm capability-pattern is preserved.
5. If adding a new external dependency: justify against the "thin dependency" preference.

### When in doubt
- Optimize for the 3-minute demo, not for production polish.
- Prefer testnet over mainnet for anything funds-related.
- Honest README beats overclaimed README.
- If a feature requires AI to be the authoritative decision-maker for security, it is wrong. Refactor so Move owns the decision.

---

## 12. Weekly cadence (current week marker)

> Update the marker as the project progresses.

```
Week 1: Foundations & learning            [CURRENT]
Week 2: Move contracts v0 + decision gate
Week 3: Sentinel agent v0 (one signal)
Week 4: Walrus forensic-log archive
Week 5: Dashboard v0
Week 6: Anomaly classifier + AI narrator
Week 7: Verifier SDK + demo gateway + security review
Week 8: Submission + buffer
```

**Decision gate at end of Week 2:** if the Move capability surface feels untractable, pivot to the AuditTrail subset (receipts-only, no status enforcement). Update this file's §1 accordingly.

---

## 13. Definition of done (per component)

| Component | Done means |
|---|---|
| Move package | Published to testnet at stable address; capability/policy patterns tested; status transitions covered by unit tests; events emit correctly |
| Sentinel agent | One eBPF signal end-to-end; signed report submitted via PTB; Walrus blob attached on anomaly |
| Verifier SDK | `isDeviceTrusted(id)` returns correct result against current Sui state; integrated into demo gateway |
| Demo gateway | Rejects connection within 2s of on-chain status flip |
| Dashboard | Connect wallet (zkLogin); fleet view; drill-in to one Device; live event stream |
| Demo recording | 3-minute video showing the full scene; pre-recorded backup exists |

---

## 14. Glossary

- **PTB** — Programmable Transaction Block. A composable batch of Move calls executed atomically on Sui.
- **Capability (Move)** — A struct without `copy` or `drop` abilities, gating access to entry functions via type-system enforcement.
- **Fast path** — Sui's single-owner-object transaction path, finalizing via reliable broadcast without global consensus.
- **Walrus Quilt** — Walrus's batching primitive for small files; bundles up to ~660 small blobs into one storage unit.
- **Seal** — Sui's threshold-encryption layer with Move-defined access policies.
- **Nautilus** — Sui's TEE-coprocessor framework (currently AWS Nitro Enclaves; custom PCR verification is now mainnet-live).
- **IMA** — Linux Integrity Measurement Architecture. Hashes files on load, extends PCR 10 if TPM present.
- **PCR** — TPM Platform Configuration Register; extend-only register holding cumulative measurements.
- **LSM-BPF (KRSI)** — Kernel Runtime Security Instrumentation; eBPF programs attached to Linux Security Module mediation hooks. TOCTOU-resistant.
- **DKG** — Distributed Key Generation. MPC protocol producing a public key whose private counterpart never exists in one place.
- **FROST** — Flexible Round-Optimized Schnorr Threshold signature scheme. IETF-standardized.

---

*Last updated: project initialization. Keep this file current as architecture decisions are made.*
