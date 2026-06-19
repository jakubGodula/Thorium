# Mock backend (gen-v1) — Prism, contract-driven

The mock is **just the OpenAPI spec + Stoplight Prism** — no hand-written server.
[`../openapi/thorium-xdr.openapi.yaml`](../openapi/thorium-xdr.openapi.yaml) is the
single source of truth for both the mock and the FE data adapter.

## Run
```bash
cd .ai-fe-design/demo-gen/gen-v1/mock
docker compose -f docker-compose.prism.yml up
# mock now serving on http://localhost:4010
```

Or without Docker:
```bash
npx @stoplight/prism-cli mock ../openapi/thorium-xdr.openapi.yaml -p 4010
```

## What it serves
- **Agent API** (`/api/status`, `/api/rpc`, `/api/logi`, `/api/izoluj`,
  `/api/przywroc`, `/api/vm/*`) — Mowa contract with real (Polish) wire keys.
- **Sui mock** (`/sui/queryEvents`, `/sui/multiGetObjects`) — synthetic on-chain
  events/objects for package `0x0cc3…91af`.
- **Walrus mock** (`/walrus/{blobId}`) — sealed/placeholder blobs.

Prism returns the `example` baked into each operation → deterministic, realistic
data for a clickable demo. Add `--dynamic` to the Prism command for varied data.

## Smoke test
```bash
curl localhost:4010/api/status
curl -X POST localhost:4010/sui/queryEvents -H 'content-type: application/json' \
  -d '{"module":"edr_registry","eventType":"IncidentReport","limit":50}'
```

## ⭐ CC* scenario data
The OpenAPI `queryEvents` example already includes the attacked-pod events
(`IncidentReport` CRITICAL + `ClassificationReported` → `TRIGGER_ISOLATION`) plus a
healthy `TelemetryReported`, so the contract-true data for the CC* path
([`../../../input/DEMO.md`](../../../input/DEMO.md)) is present. Because Prism is
stateless, the demo app drives the connect→healthy→attack→NOT-WORTHY sequence with
a client-side **"Run CC\* scenario"** stepper over these fixtures.

## Notes / limitations (demo assumptions)
- Prism is **stateless**: `vm_create` / `izoluj` return success but don't mutate
  later `lista`/`status` responses. For stateful demo behavior, the generator may
  optionally swap Prism for the Fastify variant (see v2→v3 R15) — out of scope for
  gen-v1.
- Keep the spec the source of truth: when the contract changes, edit the YAML, not
  a server.
