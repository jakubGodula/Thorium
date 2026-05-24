# Thorium — Progress Tracker

> Living checklist derived from `.ai/detailed-roadmap.md`. Tick boxes as items complete. Update the `← CURRENT` marker each Monday.

## Phase 1 — Endpoint Agent & On-chain Verdict (Weeks 1–3)

### Week 1 — Foundations ← CURRENT

Dev A (Move + scaffolding):
- [ ] Initialize Move package `move/<package>/` with modules: `device.move`, `policy.move`, `capability.move`, `attestation.move`, `events.move`
- [ ] Implement `Device` struct (`has key`, no `store` → SBT semantics)
- [ ] Implement `SentinelCap`, `AdminCap`, `IncidentResponderCap` (no `copy`, no `drop`)
- [ ] Implement `Policy` struct with allowlist of process hashes + attestation TTL
- [ ] `init` function publishes default `Policy` shared object and transfers `AdminCap` to publisher
- [ ] `Move.toml` targeting testnet; `sui move build` passes
- [ ] Unit tests for capability gating (negative test: PTB without `SentinelCap` fails)

Dev B (agent skeleton + fingerprinting):
- [ ] Initialize Rust workspace: `sentinel/` (binary), `sentinel-core/` (lib), `sentinel-fingerprint/` (lib)
- [ ] `tokio` async runtime, `anyhow` (binary), `thiserror` (libs), `tracing`
- [ ] Fingerprint module — `tpm` mode (`tss-esapi` against TPM 2.0 EK pub)
- [ ] Fingerprint module — `fallback` mode (`/etc/machine-id` + NIC MAC + disk UUID → SHA-256)
- [ ] CLI flag `--fingerprint-mode {auto,tpm,fallback}`; `auto` probes `/dev/tpm0`
- [ ] Key module — TPM-sealed Ed25519 (key never leaves chip)
- [ ] Key module — file-sealed Ed25519 at `/etc/thorium/device.key` (`0600`)
- [ ] Shared `Signer` trait across both modes
- [ ] Smoke test: agent prints fingerprint + pubkey on both modes (host + VM)

Joint:
- [ ] GitHub Actions CI: `sui move build`, `cargo fmt --check`, `cargo clippy -- -D warnings`, `cargo test`
- [ ] `rust-toolchain.toml` pinning stable Rust

### Week 2 — eBPF signal + first PTB

Dev A (Move PTB plumbing):
- [ ] Entry `device::register(policy, pubkey, fingerprint, &SentinelCap)` (manual; replaced by `enrollment::consume` in Phase 2)
- [ ] Entry `device::heartbeat(&mut Device, AttestationReport, sig, &SentinelCap)` — verifies Ed25519, updates `last_attestation_*`
- [ ] Entry `device::flag_compromised(&mut Device, blob_id, severity, &SentinelCap)` — flips status, emits `StatusChanged`
- [ ] Move unit tests for all three (positive + negative paths: wrong cap, expired attestation, invalid sig)
- [ ] Publish package to testnet; record `PackageID` + default `Policy` ID in `.ai/deployments.md`

Dev B (eBPF + PTB submission):
- [ ] Add `aya` + `aya-ebpf` to workspace; tracepoint on `sched_process_exec`
- [ ] Userspace consumer: ring-buffer read, SHA-256 of binary in userspace, compare to allowlist
- [ ] Allowlist hydration: on startup + every 30 s, read `Policy` shared object via `sui-sdk`
- [ ] Heartbeat loop: every 30 s, window hash of allowed execs, sign, submit `device::heartbeat`
- [ ] Anomaly path: forensic snapshot, sign, stub blob upload to `/tmp/`
- [ ] Manual e2e: `cp /bin/ls /tmp/evil && /tmp/evil` triggers anomaly log (no PTB yet)

### Week 3 — Walrus, demo gateway, dashboard MVP, demo recording

Dev A (Web UI + verifier SDK + demo gateway co-owned):
- [ ] Root SvelteKit app: `@mysten/dapp-kit` wallet connection on testnet (Sui client in `src/lib/sui/`)
- [ ] Fleet view route in `src/routes/`: device table with status badge + last-attestation epoch + Explorer link
- [ ] Live event stream: subscribe to `StatusChanged`, reactive store in `src/lib/stores/`
- [ ] `verifier-sdk/` TypeScript package: `isDeviceTrusted(deviceId): Promise<boolean>`
- [ ] `demo-gateway/` Node/Bun service: `/connect` endpoint + browser panel polling every 1 s

Dev B (Walrus + wire it all up):
- [ ] Walrus uploader (Rust HTTP `PUT` to testnet Upload Relay; Quilt-batched when > 1 blob)
- [ ] Wire anomaly path: detect → Walrus blob → `device::flag_compromised` PTB with `blob_id`
- [ ] Run agent on physical laptop (TPM mode) + Linux VM (fallback). Both register + heartbeat
- [ ] Live demo dry-run with both devices visible in fleet; trigger VM attack; observe flip + gateway red
- [ ] Measure attack → gateway-red time; target < 5 s, investigate if > 10 s

Joint (end of Week 3):
- [ ] Record 3-min demo video (Phase 1 exit gate)
- [ ] If recording is shaky, stop and stabilize before starting Phase 2
- [ ] Tag repo `phase-1-complete`

## Phase 2 — Web3 Identity & Provisioning (Weeks 4–5)

### Week 4 — EnrollmentTicket + zkLogin + Web UI

Dev A:
- [ ] New Move module `enrollment.move` with `EnrollmentTicket` struct (shared object; `nonce` + `expires_at_epoch`)
- [ ] Entry `enrollment::mint_batch(&Policy, count, ttl_epochs, &AdminCap, ctx)` mints N tickets
- [ ] Entry `enrollment::consume(ticket, &Policy, pubkey, fingerprint, ctx)` burns ticket + mints `Device` + emits `DeviceEnrolled`
- [ ] Replace manual `device::register` with `enrollment::consume`
- [ ] Move unit tests: expired ticket fails, double-consume fails, wrong policy fails
- [ ] Admin Web UI route (`src/routes/admin/enroll/`): count input, policy picker, sign `mint_batch`, show ticket IDs
- [ ] "Download enrollment bundle" button → `{ticket_id, policy_id, pkg_id, rpc_url}` JSON per ticket
- [ ] Wire `@mysten/enoki` + `@mysten/dapp-kit` for Google OIDC sign-in; capture admin Sui address; verify it owns `AdminCap`
- [ ] (Stretch) Begin custom OIDC → JWT → zk-SNARK pipeline as separate package (carries to Phase 4 if not done)

Dev B:
- [ ] Agent first-run flow: read bundle (`/etc/thorium/bundle.json` then `./bundle.json`), keygen, submit `enrollment::consume` PTB
- [ ] Persist resulting `Device` object ID locally; transition to normal heartbeat loop
- [ ] Clear-error exit on ticket already-consumed / expired
- [ ] `thorium-provision/` Rust CLI: `--bundle ./ticket-N.json --target user@host` (copy binary, drop bundle, systemd unit)
- [ ] Test: bulk-enroll 5 tickets via UI, provision 5 fresh VMs, confirm 5 devices appear in fleet view

### Week 5 — Kill-switch + dashboard polish + fleet operations

Dev A:
- [ ] Entry `device::admin_flag_compromised(&mut Device, reason, &AdminCap)` (kill-switch; same transition, `AdminCap`-gated; `StatusChanged.triggered_by = Admin`)
- [ ] Drill-in route (`src/routes/devices/[id]/+page.svelte`): attestation history, allowlist, last Walrus blob URL
- [ ] "Revoke" button on drill-in (signs admin PTB)
- [ ] Fleet view sortable + filterable by status
- [ ] Entry `device::recover(&mut Device, &AdminCap)` for `Compromised → Healthy`; UI button on drill-in

Dev B:
- [ ] Multi-device demo prep: add a third device (second VM); confirm kill-switch on dev 2 doesn't touch dev 1 / dev 3
- [ ] Allowlist refresh visibility: agent logs each refresh w/ policy version; surface "last policy refresh" in dashboard
- [ ] Resilience: agent reconnects after transient Sui RPC failures (backoff); no panics on PTB errors
- [ ] Tag repo `phase-2-complete`

## Phase 3 — Forensics & Narration (Weeks 6–7)

### Week 6 — Seal + additional signals + narrator

Dev A:
- [ ] Seal integration (`@mysten/seal`): access policy gated by `IncidentResponderCap`
- [ ] Mint `IncidentResponderCap` to admin address at package publish
- [ ] Dashboard: "Reveal forensic log" button on `Compromised` drill-in calls Seal decrypt + renders inline
- [ ] Verifier SDK: add `getDeviceHistory(id)` returning last N `StatusChanged` events

Dev B:
- [ ] eBPF signal #2: `module_load` tracepoint (out-of-boot-window load → high severity → `Compromised`)
- [ ] eBPF signal #3: `sys_bpf` `BPF_PROG_LOAD` from non-allowlisted loaders
- [ ] Rule-based anomaly classifier (`severity = max(per-signal)`; LLM does NOT score)
- [ ] Narrator: take forensic snapshot, call Claude API (`claude-sonnet-4-6`), one-paragraph summary attached to blob
- [ ] Encrypt forensic blob with Seal before Walrus upload

### Week 7 — Security review, polish, backup recording

Joint:
- [ ] Internal security review (`/security-review`): cap flow, sig verify, ticket replay, allowlist TOCTOU
- [ ] Pre-recorded backup demo video at `demos/backup.mp4` (3 min)
- [ ] README rewrite for submission (elevator pitch, honest scope, testnet Explorer links)
- [ ] Tag repo `phase-3-complete`

Dev A:
- [ ] Dashboard polish: empty states, loading states, error toasts, mobile-responsive
- [ ] Demo gateway polish: visible decision log

Dev B:
- [ ] Performance check at 1000 execs/sec; drop sampling rate if needed
- [ ] Systemd hardening: `NoNewPrivileges=yes`, `ProtectSystem=strict`, `CapabilityBoundingSet=CAP_BPF CAP_SYS_ADMIN`

## Phase 4 — Submission, Buffer, Stretch (Week 8)

Joint:
- [ ] Final live-demo dry-run on actual presentation hardware + network
- [ ] Submission form: pitch, repo, video, deployed package ID, judging-criterion mapping
- [ ] Buffer for last-minute breakages

Stretch (ranked, only if time remains):
- [ ] Custom OIDC → JWT → zkLogin pipeline (replace Enoki with own circuit)
- [ ] Nautilus enclave-signed reports (AWS Nitro Enclave; Move refuses non-enclave reports)
- [ ] Multi-OS scaffolding (macOS ES hooks behind `Signer`/`Telemetry` traits — stubs only)
- [ ] Second attack scenario: `insmod /tmp/evil.ko` exercising signal #2

---

Last updated: 2026-05-24 (initial generation from roadmap by reconciliation pass).
