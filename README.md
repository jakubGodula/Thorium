# Thorium

> **Status note (2026-05-26):** this README still carries two legacy sections — the SvelteKit `sv` scaffolding preamble below, and a "Thorium XDR" pitch from line ~46 onward. **Both are stale relative to the current project design.** The current design lives in `.ai/context.md` (architecture) and `.ai/detailed-roadmap.md` (plan). A full README rewrite is scheduled for **Phase 3, Week 7** (see roadmap). Keep this note until then.

---

# sv

Everything you need to build a Svelte project, powered by [`sv`](https://github.com/sveltejs/cli).

## Creating a project

If you're seeing this, you've probably already done this step. Congrats!

```sh
# create a new project
bunx sv create my-app
```

To recreate this project with the same configuration:

```sh
# recreate this project
bunx sv@0.15.3 create --template minimal --types ts --add prettier eslint --install npm ./
```

## Developing

Once you've created a project and installed dependencies with `bun install`, start a development server:

```sh
bun run dev

# or start the server and open the app in a new browser tab
bun run dev -- --open
```

## Building

To create a production version of your app:

```sh
bun run build
```

You can preview the production build with `bun run preview`.

> To deploy your app, you may need to install an [adapter](https://svelte.dev/docs/kit/adapters) for your target environment.

---

# 🛸 Project Target State: Thorium XDR

Thorium is a premium, high-performance **Extended Detection and Response (XDR)** platform designed to eliminate data silos and provide autonomous security operations across endpoints, networks, identities, and cloud environments.

## 🎯 Core Vision
The target state of Thorium is a **Decentralized, Agentic SOC**. Instead of a passive monitoring tool, Thorium acts as a proactive AI agent that "thinks" recursively to validate threats and "acts" autonomously to disrupt attacks at machine-speed.

## 🧱 Architectural Components

### 1. Thorium Command Center (Frontend)
- **Tech Stack**: SvelteKit, Vanilla CSS (Glassmorphism), D3.js.
- **Goal**: A high-fidelity, real-time visualization layer for security analysts.
- **Key Views**:
    - **Storyline Reconstruction**: Dynamic, graph-based timeline of attack progression (Initial Access → Lateral Movement → Exfiltration).
    - **Autonomous Triage Log**: A transparent "thought log" showing the Recursive AI's decision-making loops.
    - **ITDR Dashboard**: Real-time management of identity threats and active deception objects (Honeytokens).

### 2. Thorium Agent (Headless Daemon)
- **Tech Stack**: Rust, Tauri 2.0 (Headless Mode).
- **Goal**: A lightweight, high-privileged service deployed on every managed endpoint.
- **Capabilities**:
    - **Deep Telemetry**: Monitoring process trees, file I/O entropy (Ransomware detection), and LSASS memory protection.
    - **Autonomous Disruption**: Programmatic host isolation, process killing, and cloud session revocation.
    - **Ransomware Rollback**: Automated recovery of encrypted files using protected VSS shadow copies.

### 3. Intelligence Core (Recursive AI)
- **Concept**: Moves beyond static alerts to dynamic context harvesting.
- **Logic**: When an alert fires, the AI automatically spins up workers to check O365 calendars, ISP risk scores, and MDM compliance to yield a high-confidence verdict without human input.

### 4. Blockchain Integration (Web3 Security)
- **zkLogin (Sui)**: Enables decentralized, verifiable identity for analysts. Actions like "Host Isolation" are authorized via ZK Proofs, ensuring no single point of failure in command authority.
- **Immutable Audit Trails**: Every critical event (e.g., process termination or isolation) is hashed and anchored to the Sui blockchain, creating a non-repudiable log of security actions.

## 🛡️ Telemetry Summary
To reach its full potential, Thorium ingests and normalizes:
- **Endpoint**: Parent-child process trees, network socket bindings, file modification events.
- **Identity**: MFA push logs, geo-velocity alerts, credential rotations.
- **Network**: DNS query patterns, SSL/TLS handshake metadata, NetFlow.
- **Cloud**: AWS CloudTrail, Azure Activity logs, K8s API server audits.

---
*Thorium: Breaking Silos. Disrupting Threats. Automating the SOC.*
