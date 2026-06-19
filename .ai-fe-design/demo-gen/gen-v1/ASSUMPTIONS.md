# Demo-scope assumptions (gen-v1)

Pre-authorized assumptions for the demo (the user allowed demos to "output
assumptions"). These let the generator run without stopping for answers. They are
**demo-local** — they do not change the design; they record how the *demo* fills
gaps. Anything load-bearing is also tracked in `questions_v2_to_v3_qa.md`.

| # | Assumption | Basis |
|---|---|---|
| D1 | Demo runs **mock-by-default** (Prism on `:4010`); live profile via `config.json`. | v2→v3 R5; ADR-0004 |
| D2 | Data is **synthetic but contract-true** — shapes come from the OpenAPI spec, which mirrors the Move schemas (`assumptions_v1.md` §1). | ADR-0005 |
| D3 | Mock is **stateless** (Prism) for gen-v1; write actions return success without persisting. Stateful mock = gen-v2 candidate. | mock/README |
| D4 | **Polling**, not WebSocket (agent 5s / Sui 10s). | ADR-0001 |
| D5 | **No wallet signing** in the demo — wallet-connect is visual; on-chain "writes" are simulated against the mock. | v2 Q11/Q12 (placeholder) |
| D6 | **English only**; Mowa Polish wire keys mapped in the adapter. | v2 Q13 |
| D7 | Branding = suggested `brand/` mark + cyan `#38bdf8` / mint `#5eead4`. | v2 Q14 |
| D8 | **Helium** tab hidden behind a feature flag (undefined scope). | v2 Q5 |
| D9 | Telemetry = gauges + sparkline/series from recent events; **no long-range history / indexer**. | v2→v3 R3/R4 |
| D10 | Multi-sig shown as a **read-only placeholder**. | v2 Q12 |
| D11 | Sample fleet = ~24 agents, a handful of incidents across CRITICAL/HIGH/WARNING, 1–2 isolated hosts — enough to populate every screen. | demo realism |
| D12 | Network label = **Sui testnet**, package `0x0cc3…91af`. | Published.toml |

If a future design version invalidates one of these, fork the generator
(`gen-v2/`) rather than editing gen-v1.
