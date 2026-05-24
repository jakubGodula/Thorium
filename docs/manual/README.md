# Run Manuals

This directory holds per-component run scripts and the end-to-end demo walkthrough. One file lands here as each component becomes runnable.

## Expected files (created on demand)

- `run-move-publish.md` — publish the Move package to testnet
- `run-agent.md` — start the sentinel agent in tpm or fallback mode
- `run-web.md` — start the SvelteKit Web UI in dev (`bun run dev`)
- `run-verifier-sdk.md` — local linking and tests
- `run-demo-gateway.md` — start the mock VPN/gateway service
- `demo-scenario.md` — the full 3-minute demo walkthrough (see `.ai/context.md` §8)

Each file should be a runnable checklist: prerequisites, commands, expected output, troubleshooting.

All TypeScript/JavaScript commands use `bun` — never `npm` or `npx`.
