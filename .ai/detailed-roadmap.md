# Thorium / SentrySui — Detailed Roadmap

> Companion to `.ai/context.md`. That file is the *what and why*. This file is the *when, who, and in what order*.
> If anything here conflicts with `context.md`, `context.md` wins — update both.

---

## 0. Ground truth and assumptions

**Team (2 people):**
- **Dev A** — full-stack + Solidity background. Owns Move package, Thorium Web UI (admin + fleet dashboard), verifier SDK.
- **Dev B** — security / DevOps + Sui background. Owns Rust sentinel agent, eBPF, TPM/fallback fingerprinting, Walrus uploads, demo gateway, CI/release.

**Demo hardware:**
- **Physical laptop(s)** with TPM 2.0 — runs the agent in TPM-attestation mode, reports `Healthy` continuously.
- **Linux VM** without TPM — runs the agent in fallback-fingerprint mode, **gets attacked live** during the demo, flips to `Compromised`.
- Both devices appear in the fleet view; both write status transitions to Sui. The point of two devices is to show *the mesh* working, not to compromise the presenter's laptop.

**OS scope:** Linux-only through Phase 3. macOS / Windows are Phase 4+ stretch.

**Network:** Sui **testnet** for everything. No mainnet, no real funds.

**Phase shape:** 4 phases, ~2.5 weeks each, ending at hackathon submission.

```
Week:    1  2  3  4  5  6  7  8
Phase:  ├──── 1 ────┤├── 2 ──┤├── 3 ──┤├─ 4 ─┤
                                              ↑ submission
```

**Demo scene** (north star, repeated from `context.md` §7):
Healthy fleet → live attack on VM → eBPF event fires → agent submits PTB → on-chain `status: Compromised` + Walrus blob ID attached → demo VPN gateway rejects within 2s. Physical laptop stays `Healthy` throughout.

---

## Phase 1 — Endpoint Agent & On-Chain Verdict (Weeks 1–3)

**Goal:** the 3-minute demo runs end-to-end with two devices (1 physical, 1 VM). One eBPF signal, one attack vector, one on-chain status type, one Walrus blob.

**Exit criterion:** record a clean run of the demo scene from §7 of `context.md`. If the recording is not credible by end of Week 3, freeze scope and debug rather than starting Phase 2.

### Week 1 — Foundations

**Dev A (Move + scaffolding):**
- [ ] Initialize Move package `move/sentrysui/` with modules: `device.move`, `policy.move`, `capability.move`, `attestation.move`, `events.move`. (See `context.md` §5 for struct sketches.)
- [ ] Implement `Device` struct (`has key`, no `store` → on-chain "SBT" semantics; non-transferable by construction).
- [ ] Implement `SentinelCap`, `AdminCap`, `IncidentResponderCap` (no `copy`, no `drop`).
- [ ] Implement `Policy` struct with allowlist of process hashes + attestation TTL.
- [ ] `init` function publishes a default `Policy` shared object and transfers `AdminCap` to publisher.
- [ ] `Move.toml` targeting testnet. `sui move build` passes.
- [ ] Unit tests for capability gating (negative test: PTB without `SentinelCap` fails).

**Dev B (agent skeleton + fingerprinting):**
- [ ] Initialize Rust workspace at repo root: `sentinel/` (binary), `sentinel-core/` (lib), `sentinel-fingerprint/` (lib).
- [ ] `tokio` async runtime, `anyhow` for binary errors, `thiserror` for library errors, `tracing` for logs.
- [ ] **Fingerprint module** with two modes selected at runtime:
  - `tpm` mode: query TPM 2.0 EK public key via `tpm2-tss` bindings (`tss-esapi` crate). Use EK pub hash as device-stable ID.
  - `fallback` mode: `/etc/machine-id` + first non-loopback NIC MAC + first disk UUID (`/sys/block/*/dev`) → SHA-256.
  - CLI flag `--fingerprint-mode {auto,tpm,fallback}`; `auto` probes `/dev/tpm0` and picks `tpm` if accessible.
- [ ] **Key module:**
  - In `tpm` mode: generate Ed25519 device key sealed to TPM via `tpm2-tss`; key cannot leave the chip.
  - In `fallback` mode: generate Ed25519 in-memory, persist to `/etc/thorium/device.key` with `0600` perms.
  - Both modes expose the same `Signer` trait so the rest of the agent doesn't care.
- [ ] Smoke test: agent prints fingerprint + pubkey on both modes (run on host + VM).

**Joint:**
- [ ] CI: GitHub Actions running `sui move build`, `cargo fmt --check`, `cargo clippy -- -D warnings`, `cargo test`.
- [ ] `.nvmrc` already present; add `rust-toolchain.toml` pinning stable Rust.

### Week 2 — eBPF signal + first PTB

**Dev A (PTB plumbing on the Move side):**
- [ ] Entry function `device::register(policy: &Policy, pubkey: vector<u8>, fingerprint: vector<u8>, sentinel_cap: &SentinelCap)` — for now manual registration (Phase 2 adds `EnrollmentTicket`).
- [ ] Entry function `device::heartbeat(device: &mut Device, attestation: AttestationReport, sig: vector<u8>, cap: &SentinelCap)` — verifies Ed25519 signature against `device.public_key`, updates `last_attestation_epoch` and `last_attestation_root`. Stays `Healthy` if attestation valid.
- [ ] Entry function `device::flag_compromised(device: &mut Device, blob_id: vector<u8>, severity: u8, cap: &SentinelCap)` — flips `status` to `Compromised`, attaches Walrus blob ID, emits `StatusChanged` event.
- [ ] Move unit tests for all three entry functions, including the negative path (wrong cap, expired attestation, invalid signature).
- [ ] Publish package to testnet. Record `PackageID` and shared `Policy` object ID in `.ai/deployments.md`.

**Dev B (eBPF probe + PTB submission):**
- [ ] Add `aya` and `aya-ebpf` to workspace. Single eBPF program: tracepoint on `sched_process_exec`.
- [ ] Userspace consumer reads ring buffer, computes SHA-256 of the executed binary path (read the file in userspace, not in eBPF), compares against in-memory allowlist loaded from `Policy` on chain.
- [ ] **Allowlist hydration:** on startup and every N seconds, agent reads the `Policy` shared object via `sui-sdk` and refreshes the local allowlist.
- [ ] **Heartbeat loop:** every 30s, build window hash of recent (allowed) execs, sign with device key, submit `device::heartbeat` PTB.
- [ ] **Anomaly path:** on a disallowed exec, build a forensic snapshot (process tree, hash, ringbuf window), sign, hand off to the blob uploader (stub for now — uploads to local `/tmp/`).
- [ ] Manual end-to-end test: `cp /bin/ls /tmp/evil && /tmp/evil` triggers the anomaly path, agent logs it, no PTB yet.

### Week 3 — Walrus, demo gateway, dashboard MVP, demo recording

**Dev A (Web UI + verifier SDK + demo gateway co-owned):**
- [ ] Web UI lives at the **repo root SvelteKit app** (`src/routes/`, `src/lib/`). Wire `@mysten/dapp-kit` wallet connection on testnet. (Do not create `dashboard/`; references to it elsewhere in this doc are conceptual.)
- [ ] **Fleet view (`src/routes/fleet/+page.svelte` or similar under `src/routes/`):** table of all `Device` objects under a known `Policy`, with status badge (Healthy / Degraded / Compromised / Unknown), last-attestation epoch, and a link to Sui Explorer.
  - Implementation: query `getOwnedObjects` for `Device` type, or maintain an indexer that subscribes to `StatusChanged` events. Sui client lives in `src/lib/sui/`.
- [ ] **Live event stream:** subscribe to `StatusChanged` events via `SuiClient.subscribeEvent`, render newest-first. Reactive store in `src/lib/stores/`.
- [ ] `verifier-sdk/` TypeScript package exporting `isDeviceTrusted(deviceId: string): Promise<boolean>` — reads the `Device` object, returns `status === Healthy`.
- [ ] `demo-gateway/` minimal Node service:
  - `/connect` endpoint that takes a `deviceId`, calls `isDeviceTrusted`, responds 200 or 403.
  - A small browser panel that polls `/connect` for each device every 1s, shows green/red.

**Dev B (Walrus + wire it all up):**
- [ ] Walrus uploader in Rust: HTTP `PUT` to the testnet Upload Relay, Quilt-batched if more than one blob queued.
- [ ] Wire anomaly path: detect → upload blob to Walrus → receive `blob_id` → submit `device::flag_compromised` PTB with `blob_id`.
- [ ] Run agent on physical laptop in TPM mode and on Linux VM in fallback mode. Both register, both heartbeat.
- [ ] **Live demo dry-run** with both devices visible in the dashboard. Trigger the attack on VM (`/tmp/evil`). Watch on-chain flip, watch gateway flip red.
- [ ] Measure: time from attack to gateway-red. Target < 5s; investigate if > 10s.

**Joint (end of Week 3):**
- [ ] Record a 3-minute video of the demo scene. This is the **Phase 1 exit gate**.
- [ ] If the recording is shaky, **stop and stabilize before starting Phase 2**.
- [ ] Tag the repo `phase-1-complete`.

**Phase 1 risks:**
- TPM integration via `tss-esapi` is finicky on different hardware. Fallback: if TPM mode is fighting us by mid-Week 1, ship fallback-only for the physical host too and downgrade the "tamper-evident" claim in README.
- eBPF kernel-version compatibility. Pin a known-good kernel for the VM image.
- Walrus testnet endpoint availability. If it's down during a dry-run, have a local mock that returns a fake blob ID so the demo isn't blocked.

---

## Phase 2 — Web3 Identity & Provisioning (Weeks 4–5)

**Goal:** replace the manual `device::register` flow with a real bulk-enrollment pipeline. zkLogin for admin sign-in. Kill-switch for compromised agents. Polished fleet dashboard.

**Exit criterion:** admin signs into Thorium UI with Google (zkLogin), pastes "I want 5 devices", signs one PTB, gets 5 `EnrollmentTicket` objects. A fresh VM with no prior registration consumes one ticket on first run and shows up in the fleet view automatically.

### Week 4 — EnrollmentTicket + zkLogin + Web UI

**Dev A:**
- [ ] **New Move module `enrollment.move`:**
  - Struct `EnrollmentTicket has key { id, policy_id, nonce: vector<u8>, expires_at_epoch, issued_by: address }` — non-transferable by lack of `store`. (If we *do* want admin-to-admin handoff, add `store` and remove from this constraint.)
  - Entry `enrollment::mint_batch(policy: &Policy, count: u64, ttl_epochs: u64, cap: &AdminCap, ctx)` — mints `count` tickets and transfers them to the admin's address.
  - Entry `enrollment::consume(ticket: EnrollmentTicket, policy: &Policy, pubkey, fingerprint, ctx)` — consumes (deletes) the ticket, mints a `Device` object owned by `tx_context::sender`. Same function emits `DeviceEnrolled` event.
  - Replace the manual `device::register` from Phase 1 with `enrollment::consume`.
  - Unit tests covering: expired ticket → fail, double-consume → fail (object gone), wrong policy → fail.
- [ ] **Admin Web UI** in the root SvelteKit app (e.g., `src/routes/admin/enroll/+page.svelte`):
  - "Enroll devices" screen: input `count`, picks `Policy`, signs the `mint_batch` PTB, displays the list of ticket IDs.
  - "Download enrollment bundle" button that produces a small JSON `{ticket_id, policy_id, pkg_id, rpc_url}` per ticket — this is the file the agent reads on first run (see `context.md` §6 for the bundle path convention).
- [ ] **zkLogin via Enoki:** wire `@mysten/enoki` + `@mysten/dapp-kit` for Google OIDC sign-in on the admin UI. Capture admin's Sui address, ensure it owns `AdminCap`.
  - Stretch (only if Week 4 ends early): begin custom OIDC → JWT → zk-SNARK pipeline as a separate package. Don't block Phase 3 on this. Carries into Phase 4 if not done.

**Dev B:**
- [ ] **Agent first-run flow:**
  - If no `device.key` and `bundle.json` present in config dir: generate keypair, build `enrollment::consume` PTB referencing the ticket from the bundle, submit.
  - On success: persist the resulting `Device` object ID locally; switch into normal heartbeat loop.
  - On failure (ticket already consumed, expired, etc.): exit with clear error.
- [ ] **Provisioning CLI (`thorium-provision`):** small Rust binary the admin runs to install the agent + bundle on a target machine. Takes `--bundle ./ticket-3.json --target user@host`, copies binary, drops bundle, sets up systemd unit, starts service.
- [ ] Test: bulk-enroll 5 tickets via UI, provision 5 fresh VMs, confirm 5 devices appear in fleet view.

### Week 5 — Kill-switch + dashboard polish + fleet operations

**Dev A:**
- [ ] **Kill-switch / admin revoke:** entry `device::admin_flag_compromised(device: &mut Device, reason: vector<u8>, cap: &AdminCap)` — same status transition as the sentinel-triggered one, but `AdminCap`-gated. Emits `StatusChanged` with `triggered_by: Admin`. (This is the same on-chain *outcome* as the sentinel path — one verdict, two callers.)
- [ ] **Dashboard polish:**
  - Drill-in page per device: full attestation history, current allowlist, last forensic blob link (gated behind future Seal flow — for Phase 2, render the Walrus blob URL directly).
  - "Revoke" button on the drill-in page, signs the admin PTB.
  - Fleet view sortable + filterable by status.
- [ ] **Recovery path:** entry `device::recover(device: &mut Device, cap: &AdminCap)` for `Compromised → Healthy` after manual incident response. UI button on drill-in page.

**Dev B:**
- [ ] **Multi-device demo prep:** add a third device to the test fleet (a second VM). Demonstrate that the kill-switch on device 2 doesn't affect device 1 or device 3.
- [ ] **Allowlist refresh visibility:** agent logs every allowlist refresh with the policy version. Surface "last policy refresh" in the dashboard.
- [ ] **Resilience:** agent reconnects to Sui RPC after transient failures; backoff loop; no panics on PTB errors.
- [ ] Tag the repo `phase-2-complete`.

**Phase 2 risks:**
- Enoki zkLogin can be finicky around OAuth redirect URIs in dev vs prod. Test early in Week 4.
- Object ownership model: tickets minted to admin's address must then be referenced by the agent's first PTB. The agent doesn't own the ticket — it consumes it in a PTB the *agent* signs, after the admin sends the bundle out-of-band. Make sure the Move code permits this (ticket is a shared object? or admin transfers it to a known "enrollment escrow"?). **Decision:** mint tickets as shared objects so any caller can consume them, but include the nonce check + expiry to prevent abuse. Revisit if this opens an attack surface.

---

## Phase 3 — Forensics, Narration, Hardening (Weeks 6–7)

**Goal:** strengthen the "genuine Sui stack usage" judging criterion by wiring Seal, broaden the eBPF signal set beyond `execve`, and add the AI narrator that makes the demo legible to non-security judges. Lock in a pre-recorded backup video.

**Exit criterion:** pre-recorded 3-min demo video exists. Seal gates the forensic blobs. At least two additional eBPF signals are live. Security review passes.

### Week 6 — Seal + additional signals + narrator

**Dev A:**
- [ ] **Seal integration (`@mysten/seal`):**
  - Define Move-side access policy: only holders of `IncidentResponderCap` may decrypt forensic blobs.
  - Mint `IncidentResponderCap` to the admin address at package publish time.
  - Dashboard: "Reveal forensic log" button on a `Compromised` device drill-in. Calls Seal decrypt; renders blob inline.
- [ ] **Verifier SDK polish:** add `getDeviceHistory(id)` returning the last N `StatusChanged` events. Used by drill-in page.

**Dev B:**
- [ ] **eBPF signal #2: kernel module load.** Attach to `module_load` tracepoint. Outside-of-boot-window loads → high severity, triggers `Compromised` directly.
- [ ] **eBPF signal #3: `sys_bpf` BPF_PROG_LOAD** from non-allowlisted loaders. Direct counter to eBPF-rootkit families.
- [ ] **Anomaly classifier:** rule-based scoring across signals. `severity = max(per-signal severity)`. LLM does *not* score — it narrates after the fact.
- [ ] **Narrator:** small Rust task (or Node service) that takes a forensic snapshot, calls Claude API (`claude-sonnet-4-6`), produces a one-paragraph English summary, attaches to the Walrus blob (or stores alongside).
  - **Honest-scope:** Move policy still owns the verdict. Narrator output is metadata, never gating.
- [ ] **Encrypt forensic blob with Seal** before uploading to Walrus.

### Week 7 — Security review, polish, backup recording

**Joint:**
- [ ] Internal security review of the Move package (run `/security-review` against the diff). Focus areas:
  - Capability flow — can `SentinelCap` be smuggled into a wrong-scope call?
  - Signature verification — is the Ed25519 verify in `device::heartbeat` correct and constant-time?
  - Ticket replay — can a consumed ticket be replayed?
  - PTB ordering — is there a TOCTOU between allowlist refresh and exec event?
- [ ] **Pre-recorded backup demo video.** 3 minutes. Same scene. Stored at `demos/backup.mp4`.
- [ ] **README rewrite** for the submission. Lead with the elevator pitch from `context.md` §1. Honest scope claims (tamper-evident, not tamper-proof). Link to live testnet objects on Sui Explorer.
- [ ] Tag the repo `phase-3-complete`.

**Dev A:**
- [ ] Dashboard polish: empty states, loading states, error toasts, mobile-responsive (judges may watch on phones).
- [ ] Demo gateway polish: visible decision log ("rejecting device X because status=Compromised at epoch Y").

**Dev B:**
- [ ] Performance check: agent CPU/memory under sustained load (1000 execs/sec). If it can't keep up, drop sampling rate before the demo.
- [ ] Systemd unit hardening: `NoNewPrivileges=yes`, `ProtectSystem=strict`, `CapabilityBoundingSet=CAP_BPF CAP_SYS_ADMIN` (only what eBPF needs).

**Phase 3 risks:**
- Seal SDK is newer; integration may have rough edges. If Seal blocks us by mid-Week 6, gate forensic-blob *visibility* with a simple AdminCap check in the dashboard instead of true encryption. Flag honestly in README.
- Multiple eBPF probes can interact. Keep them in separate programs attached to separate hooks; share the ring buffer.

---

## Phase 4 — Submission, Buffer, Stretch (Week 8)

**Goal:** ship.

**Exit criterion:** Sui Overflow 2026 submission is in, with live demo URL, GitHub link, video link, and a working testnet deployment.

**Joint:**
- [ ] Final live-demo dry-run on the actual presentation hardware + network.
- [ ] Submission form: pitch, repo, video, deployed package ID, judging-criterion mapping (DePIN primary, Agentic Web secondary, Walrus bounty).
- [ ] Buffer for the inevitable last-minute breakages.

**If time remains (stretch, ranked):**
1. **Custom OIDC → JWT → zkLogin pipeline** (the original Phase 2 ambition). Replace Enoki with our own circuit. High effort, high originality score.
2. **Nautilus enclave-signed reports.** Wrap the agent's report-signing in an AWS Nitro Enclave; Move refuses reports not signed by an enclave with expected PCRs. (Honest-scope upgrade from "tamper-evident" toward "tamper-resistant.")
3. **Multi-OS scaffolding.** Stub macOS Endpoint Security framework hooks behind the same `Signer` / `Telemetry` traits. No live impl — just proof the architecture allows it. Useful in the README.
4. **Second attack scenario.** `insmod /tmp/evil.ko` as a second demo path, exercising signal #2.

---

## File-level inventory (target end-state)

```
Thorium/
├── .ai/
│   ├── context.md
│   ├── detailed-roadmap.md          (this file)
│   └── deployments.md               (testnet object IDs)
├── move/sentrysui/
│   ├── sources/
│   │   ├── device.move
│   │   ├── policy.move
│   │   ├── capability.move
│   │   ├── attestation.move
│   │   ├── enrollment.move          (Phase 2)
│   │   └── events.move
│   ├── tests/
│   └── Move.toml
├── sentinel/                        (Rust agent binary)
├── sentinel-core/                   (Rust lib: eBPF, telemetry, PTB submission)
├── sentinel-fingerprint/            (Rust lib: TPM + fallback)
├── thorium-provision/               (Rust CLI, Phase 2)
├── narrator/                        (Phase 3)
├── verifier-sdk/                    (TypeScript)
├── demo-gateway/                    (Node/TS, Bun runtime)
├── src/                             (root SvelteKit app — the Web UI / dashboard / admin)
│   ├── routes/                      (fleet view, drill-in, admin enroll, etc.)
│   └── lib/{components,stores,sui}/
├── demos/
│   ├── backup.mp4                   (Phase 3 deliverable)
│   └── attack-scripts/
└── README.md
```

---

## Phase-to-judging-criterion mapping

| Phase | DePIN | Agentic Web | Walrus bounty | Originality |
|---|---|---|---|---|
| 1 | Core: on-chain verdict + Device mesh | Agent presence only | Forensic blob upload | — |
| 2 | Bulk fleet enrollment as DePIN onboarding | — | — | EnrollmentTicket pattern |
| 3 | — | AI narrator | Seal-gated forensic archive | Multi-signal classifier |
| 4 (stretch) | — | — | — | Custom zkLogin / Nautilus |

---

## Decision log

- **Drop Tauri** — pure Rust + tokio. (Tauri was legacy outline; buys nothing for a headless daemon.)
- **Linux-only through Phase 3.** macOS / Windows = Phase 4+ stretch.
- **One identity concept, two artifacts:** local (TPM-sealed Ed25519 key + fingerprint) ↔ on-chain (`Device` Move object, non-transferable by `has key` without `store`). No separate SBT layer on top.
- **TPM is in scope from Phase 1** for physical hosts; VM uses fallback fingerprint. Both report to chain. Attack happens on VM.
- **Enrollment = on-chain `EnrollmentTicket` Move objects** minted in bulk by admin, consumed by agent on first run.
- **Kill-switch = same status transition as sentinel-triggered**, gated by `AdminCap` instead of `SentinelCap`. One outcome, two callers.
- **zkLogin via Enoki for Phase 2** (low risk); custom OIDC pipeline is Phase 4 stretch.
- **Walrus moves into Phase 1**, not Phase 3 — required for the demo scene.
- **AI narrator stays Phase 3** — not required for demo, helps judging legibility.
- **Demo on 2 devices**: physical (TPM, stays Healthy) + VM (fallback, gets attacked). Fleet view required from Phase 1.

---

*Last updated: 2026-05-23. Update the week marker in `context.md` §12 in lockstep with phase transitions.*
