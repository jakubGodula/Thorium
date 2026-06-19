# ADR-0006: Mock/agent wire keys stay Polish (English at the adapter) — **TODO**

**Status:** Accepted (v2)
**Date:** 2026-06-19

## Context
The real Mowa agent (`thorium_agent.mowa`) emits **Polish JSON keys** (`kod`, `typ`,
`tresc`, `klucz_pub`, `izoluj`, …). The OpenAPI mock
(`demo-gen/gen-v1/openapi/thorium-xdr.openapi.yaml`) intentionally mirrors these so
the mock contract == the real agent contract. The UI, however, is **English only**
(ADR/§ design v2 Q13).

## Decision
The mock and agent keep **Polish wire keys**; all mapping to English view-models
happens in the FE **data adapter** (`src/lib/data/adapter.ts`). **No Polish reaches
the UI.**

## Consequences
- + Mock fidelity: swapping mock → live agent needs no contract change.
- + Single mapping boundary; UI stays clean and English.
- − Contributors see Polish keys in fixtures/spec (documented here + in the spec).

## ⚠️ TODO (revisit)
- [ ] **TODO:** Decide whether to also expose an **English-keyed** variant of the
  contract (e.g. an adapter/proxy or a `?lang=en` mock profile) so external
  integrators never see Polish. Tracked as a follow-up; for now Polish-on-the-wire
  stands. (Mirrored as a TODO note in `README.md`.)
