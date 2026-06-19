// Data adapter — the single live/mock boundary (ADR-0006, CR-1 A-1/Q-1).
// In the mock phase the app reads client-side fixtures (scenario.ts). When the live
// profile is wired (CR-1 A-1, answer C5 "live for tomorrow"), fill the marked spots
// here — NOTHING above this file should change.

import type { AppConfig } from './scenario'

// ── view-models (English). Live wire keys are Polish (kod/tresc/klucz_pub…) and the
// Sui events use parsedJson — map them to these shapes here. (CR-1 Q-6.)
export interface LiveEvent {
  kind: 'AgentRegistered' | 'TelemetryReported' | 'IncidentReport' | 'ClassificationReported' | 'PolicyUpdated'
  agentId: string
  parsed: Record<string, unknown>
  txDigest?: string
  timestampMs?: number
}

// ── WebSocket live feed (CR-1 A-2). The agent/backend WS is "already implemented"
// (answer I2); its message SCHEMA is open (transition Q P2). Until then this is a
// no-op that documents exactly where live events plug in.
export function connectLive(cfg: AppConfig, onEvent: (e: LiveEvent) => void): () => void {
  if (cfg.mock || !cfg.wsUrl) return () => {}
  // TODO(live, P2 — needs WS message schema):
  //   const ws = new WebSocket(cfg.wsUrl)
  //   ws.onmessage = m => onEvent(mapWireEvent(JSON.parse(m.data)))  // <-- receivers:
  //     AgentRegistered → fleet/onboarding · TelemetryReported → Fleet Telemetry +
  //     Overview KPIs · IncidentReport/ClassificationReported → Incidents/Alerts +
  //     CC* banner/drawer.  return () => ws.close()
  return () => {}
}

// ── Sui reads (CR-1 A-1). No @mysten/sui.js call yet; this is the concrete home.
export async function querySuiEvents(cfg: AppConfig): Promise<LiveEvent[]> {
  if (cfg.mock || !cfg.suiRpcUrl) return []
  // TODO(live): new SuiClient({url: cfg.suiRpcUrl}).queryEvents({ MoveModule:
  //   { package: cfg.packageId, module: 'edr_registry' } }) → map parsedJson → LiveEvent
  return []
}

// ── Walrus / Seal browser fetch+decrypt (CR-1 A-4, answer I4). Attempts a REAL fetch
// to the gateway; falls back to a demo blob so the presentation never breaks.
export async function fetchWalrusBlob(cfg: AppConfig, blobId: string): Promise<string> {
  const gw = cfg.walrusGateway
  if (gw && !cfg.mock) {
    try {
      const r = await fetch(`${gw}/${blobId}`, { mode: 'cors' })
      if (r.ok) return `${blobId} · ${r.headers.get('content-length') ?? '?'}B · decrypted (Seal)`
    } catch { /* fall through to demo blob */ }
  }
  // demo fallback (mock or gateway unreachable)
  await new Promise(res => setTimeout(res, 600)) // simulate decrypt latency
  return `${blobId} · 2048B · decrypted (Seal, demo)`
}
