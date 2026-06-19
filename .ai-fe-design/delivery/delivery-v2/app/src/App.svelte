<script lang="ts">
  import { onMount } from 'svelte'
  import {
    type Phase, type AppConfig, PHASES, fleet, observedPod, podSpark, timeline,
    responseActions, loadConfig,
  } from './lib/scenario'

  type Tab = 'overview' | 'telemetry' | 'incidents' | 'alerts' | 'chain' | 'endpoints' | 'talus' | 'vulns' | 'more'
  let tab = $state<Tab>('overview')
  let phase = $state<Phase>('idle')
  let drawerOpen = $state(false)
  let autoplay = $state(false)
  let toast = $state('')
  let cfg = $state<AppConfig>({ scope: 'alfa', network: 'testnet', packageId: '0x0cc3…91af', mock: true })

  onMount(async () => {
    cfg = await loadConfig()
    const q = new URLSearchParams(location.search)
    if (q.has('cc')) { phase = 'isolated'; drawerOpen = true }
    if (q.has('demo')) { autoplay = true; runScenario() }
  })

  const pod = $derived(observedPod(phase))
  const spark = $derived(podSpark(phase))
  const events = $derived(timeline(phase))
  const compromised = $derived(phase === 'attacked' || phase === 'isolated')
  const others = fleet()
  const PHASE_LABEL: Record<Phase, string> = { idle: 'Idle', connected: 'Connecting pod', healthy: 'Healthy', attacked: 'Under attack', isolated: 'Isolated' }
  const step = $derived(PHASES.indexOf(phase))

  let timer: ReturnType<typeof setTimeout> | null = null
  function runScenario() {
    if (timer) clearTimeout(timer)
    drawerOpen = false
    const seq: Phase[] = ['connected', 'healthy', 'attacked', 'isolated']
    let k = 0
    phase = 'idle'
    const advance = () => {
      phase = seq[k]
      if (phase === 'isolated') drawerOpen = true
      k++
      if (k < seq.length) timer = setTimeout(advance, k <= 1 ? 1100 : 1600)
      else if (autoplay) timer = setTimeout(runScenario, 4500) // loop for unattended booth
    }
    timer = setTimeout(advance, 400)
  }
  function reset() { if (timer) clearTimeout(timer); autoplay = false; phase = 'idle'; drawerOpen = false }
  function toggleAutoplay() { autoplay = !autoplay; if (autoplay) runScenario(); else reset() }
  function fireAction(l: string) { toast = `${l} — placeholder (coming soon)`; setTimeout(() => (toast = ''), 2600) }

  const tabs: { id: Tab; label: string; soon?: boolean }[] = [
    { id: 'overview', label: 'Overview' },
    { id: 'telemetry', label: 'Fleet Telemetry' },
    { id: 'incidents', label: 'Incidents' },
    { id: 'alerts', label: 'Alerts' },
    { id: 'chain', label: 'Chain Activity' },
    { id: 'endpoints', label: 'Endpoints' },
    { id: 'talus', label: 'Talus AI' },
    { id: 'vulns', label: 'Vulnerabilities' },
    { id: 'more', label: 'VMs · Polonium', soon: true },
  ]

  const chainRows = $derived([
    ...(compromised ? [
      { sev: 'CRITICAL', cls: 'b-bad', ev: 'alma9-edge-01 · IncidentReport (kernel exploit)', act: 'KILLED_AND_ISOLATED', tx: '0x9aBc…01' },
      { sev: 'HIGH', cls: 'b-pending', ev: 'alma9-edge-01 · ClassificationReported 0.91', act: 'TRIGGER_ISOLATION', tx: '0x7xYz…' },
    ] : []),
    ...(step >= 2 ? [{ sev: 'INFO', cls: 'b-ok', ev: 'alma9-edge-01 · TelemetryReported cpu 12%', act: '—', tx: '0x5tuv…' }] : []),
    ...(step >= 1 ? [{ sev: 'INFO', cls: 'b-ok', ev: 'alma9-edge-01 · AgentRegistered', act: '—', tx: '0x12aB…' }] : []),
    { sev: 'INFO', cls: 'b-ok', ev: 'ws-07 · TelemetryReported cpu 13%', act: '—', tx: '0x88cd…' },
  ])
</script>

<div class="topbar">
  <div class="logo"><span class="mark"></span>Thorium <span class="x">XDR</span></div>
  <div class="chip"><span class="dot"></span> Sui {cfg.network} · <span class="mono">{cfg.packageId.slice(0, 8)}…</span></div>
  <span class="chip" style="border-color:rgba(94,234,212,.3);color:#5eead4">scope: {cfg.scope}{cfg.mock ? ' · mock' : ''}</span>
  <div class="grow"></div>
  <button class="ghost">⌘K Search</button>
  <button class="ghost">Connect Wallet</button>
  <button class="ghost" class:on={autoplay} onclick={toggleAutoplay} title="Auto-loop the CC* scenario">{autoplay ? '⏸ Demo mode' : '◷ Demo mode'}</button>
  {#if phase === 'idle'}
    <button class="run" onclick={runScenario}>▶ Run CC* scenario</button>
  {:else}
    <button class="ghost" onclick={reset}>↻ Reset</button>
  {/if}
</div>

<nav class="nav">
  {#each tabs as t}
    <button class="tab" class:active={tab === t.id} onclick={() => (tab = t.id)}>
      {t.label}{#if t.soon}<span class="soon">soon</span>{/if}
    </button>
  {/each}
</nav>

{#if compromised}
  <div class="banner" role="alert">
    <span class="pulse"></span>
    <div>
      <div class="sev">CRITICAL · ON-CHAIN INCIDENT <span class="was">✓ Healthy 40s ago</span></div>
      <div class="msg"><b>Kernel exploit</b> on observed pod <b>alma9-edge-01</b> · anomaly <b>0.91</b> · marked <b>NOT WORTHY</b> &amp; auto-isolated on Sui</div>
    </div>
    <div class="cta">
      <span class="speed">⚡ Auto-isolated in 2s</span>
      <button class="btn btn-quiet" onclick={reset}>Mute</button>
      <button class="btn btn-crit" onclick={() => (drawerOpen = true)}>View incident →</button>
    </div>
  </div>
{/if}

{#if tab === 'overview' || tab === 'endpoints'}
  <div class="layout" class:solo={!drawerOpen}>
    <div>
      {#if tab === 'overview'}
        <div class="kpis">
          <div class="kpi"><div class="t">Active Agents</div><div class="v">{compromised ? 23 : 24}</div></div>
          <div class="kpi" class:bad={compromised}><div class="t">Critical Threats</div><div class="v">{compromised ? 1 : 0}</div></div>
          <div class="kpi"><div class="t">Pods Observed</div><div class="v">{phase === 'idle' ? 23 : 24}</div></div>
        </div>
      {/if}
      <div class="panel">
        <h3>Monitored Endpoints (SBT) {#if phase === 'idle'}— click ▶ Run CC* scenario{/if}</h3>
        <table>
          <thead><tr><th>Observed Pod</th><th>Telemetry</th><th>Status</th><th>On-chain</th></tr></thead>
          <tbody>
            {#if pod}
              <tr class:row-bad={compromised}>
                <td><b>{pod.hostname}</b><br><span class="mono" style="color:var(--text-2);font-size:11px">{pod.namespace} · {pod.id}</span></td>
                <td><svg class="spark" viewBox="0 0 120 22" preserveAspectRatio="none"><polyline points={spark.points} fill="none" stroke={spark.color} stroke-width="2"/></svg></td>
                <td>
                  {#if pod.status === 'NOT WORTHY'}<span class="badge b-bad"><span class="pulse"></span>NOT WORTHY</span>
                  {:else if pod.status === 'Connecting'}<span class="badge b-pending">Connecting…</span>
                  {:else}<span class="badge b-ok">Healthy</span>{/if}
                </td>
                <td><span class="mono" style="font-size:11px;color:var(--text-2)">is_active={pod.isActive}</span></td>
              </tr>
            {/if}
            {#each others as o}
              <tr>
                <td>{o.hostname}<br><span class="mono" style="color:var(--text-2);font-size:11px">{o.namespace} · {o.id}</span></td>
                <td><svg class="spark" viewBox="0 0 120 22" preserveAspectRatio="none"><polyline points="0,14 20,13 40,15 60,12 80,13 100,11 120,12" fill="none" stroke="#22c55e" stroke-width="2"/></svg></td>
                <td><span class="badge b-ok">Healthy</span></td>
                <td><span class="mono" style="font-size:11px;color:var(--text-2)">is_active=true</span></td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    </div>

    {#if drawerOpen}
      <div class="drawer" role="dialog" aria-label="Incident Command">
        <div class="head">
          <span class="sev">CRITICAL</span>
          <div><div style="font-weight:700">Incident Command</div>
            <div class="mono" style="font-size:11px;color:var(--text-2)">INC-991 · alma9-edge-01</div></div>
          <button class="ghost" style="margin-left:auto" onclick={() => (drawerOpen = false)}>✕</button>
        </div>
        <div class="body">
          <div class="callouts">
            <div class="callout"><div class="cl-l">Isolation method</div><div class="cl-v">KILLED_AND_ISOLATED</div></div>
            <div class="callout"><div class="cl-l">Blast radius</div><div class="cl-v">1 pod · 0 lateral</div></div>
          </div>
          <div class="section-label">Kill-chain timeline</div>
          <div class="tl">
            {#each events as e}
              <div class="ev {e.kind}" class:climax={e.climax}>
                <div class="h">{e.h}</div><div class="s">{e.s}</div><div class="t">{e.t}</div>
              </div>
            {/each}
          </div>
          <div class="section-label">On-chain evidence</div>
          <div class="evid">tx 0x9aBcDeF…01 · IncidentReport&#123;severity:"CRITICAL", action_taken:"KILLED_AND_ISOLATED"&#125;</div>
          <div class="section-label">Response — recommended actions</div>
          <div class="actions">
            {#each responseActions as a}
              <button class="resp" onclick={() => fireAction(a.l)}><span class="i">{a.i}</span><span class="l">{a.l}</span><span class="soon">Coming soon</span></button>
            {/each}
          </div>
        </div>
      </div>
    {/if}
  </div>

{:else if tab === 'telemetry'}
  <div class="layout solo"><div class="panel"><h3>Fleet Telemetry — cpu / ram / disk</h3>
    <table><thead><tr><th>Pod</th><th>CPU</th><th>RAM</th><th>Disk</th><th>Trend</th></tr></thead><tbody>
      {#if pod}<tr class:row-bad={compromised}><td><b>{pod.hostname}</b></td><td class="mono">{pod.cpu}%</td><td class="mono">{pod.ram}%</td><td class="mono">{pod.disk}%</td>
        <td><svg class="spark" viewBox="0 0 120 22" preserveAspectRatio="none"><polyline points={spark.points} fill="none" stroke={spark.color} stroke-width="2"/></svg></td></tr>{/if}
      {#each others as o}<tr><td>{o.hostname}</td><td class="mono">{o.cpu}%</td><td class="mono">{o.ram}%</td><td class="mono">{o.disk}%</td>
        <td><svg class="spark" viewBox="0 0 120 22" preserveAspectRatio="none"><polyline points="0,14 20,13 40,15 60,12 80,13 100,11 120,12" fill="none" stroke="#22c55e" stroke-width="2"/></svg></td></tr>{/each}
    </tbody></table></div></div>

{:else if tab === 'chain'}
  <div class="layout solo"><div class="panel"><h3>Chain Activity — on-chain events · pkg <span class="mono" style="font-size:12px">{cfg.packageId.slice(0,8)}…</span></h3>
    <table><thead><tr><th>Severity</th><th>Event</th><th>Action</th><th>tx digest</th></tr></thead><tbody>
      {#each chainRows as r}<tr class:row-bad={r.cls==='b-bad'}><td><span class="badge {r.cls}">{r.sev}</span></td><td>{r.ev}</td><td class="mono">{r.act}</td><td class="mono" style="color:var(--accent)">{r.tx}</td></tr>{/each}
    </tbody></table></div></div>

{:else if tab === 'incidents' || tab === 'alerts'}
  <div class="layout solo"><div class="panel"><h3>{tab === 'alerts' ? 'Alerts' : 'Incidents'}</h3>
    {#if compromised}
      <table><thead><tr><th>Severity</th><th>Pod / Detection</th><th>Action</th><th>Status</th><th>tx</th></tr></thead><tbody>
        <tr class="row-bad"><td><span class="badge b-bad">CRITICAL</span></td><td>alma9-edge-01 · kernel exploit (eBPF)</td><td class="mono">KILLED_AND_ISOLATED</td><td><span class="badge b-pending">Open</span></td><td class="mono" style="color:var(--accent)">0x9aBc…01</td></tr>
        <tr><td><span class="badge b-pending">HIGH</span></td><td>alma9-edge-01 · Talus anomaly 0.91</td><td class="mono">TRIGGER_ISOLATION</td><td><span class="badge b-pending">Open</span></td><td class="mono" style="color:var(--accent)">0x7xYz…</td></tr>
      </tbody></table>
    {:else}<div class="stub"><h2>No active {tab}.</h2><p>Click <b>▶ Run CC* scenario</b> (or <b>◷ Demo mode</b>) to generate the critical incident.</p></div>{/if}
  </div></div>

{:else if tab === 'talus'}
  <div class="layout solo"><div class="panel"><h3>🤖 Talus AI — detections (anomaly threshold 0.85)</h3>
    <div class="cards">
      <div class="card {compromised ? 'card-bad' : ''}">
        <div class="card-h">{compromised ? 'Credential dumping / kernel exploit' : 'Baseline — nominal'}</div>
        <div class="card-s">alma9-edge-01 · score <b>{compromised ? '0.91' : '0.06'}</b> {compromised ? '≥ 0.85 → TRIGGER_ISOLATION' : '· within baseline'}</div>
        <div class="card-meta">ClassificationReported · Ed25519-verified AI agent</div>
      </div>
      <div class="card"><div class="card-h">Lateral movement watch</div><div class="card-s">fleet · score 0.04 · no anomalies</div><div class="card-meta">Cross-Device XDR heuristic</div></div>
    </div></div></div>

{:else if tab === 'vulns'}
  <div class="layout solo"><div class="panel"><h3>🦭 Vulnerability Registry — Seal-encrypted (Walrus)</h3>
    <table><thead><tr><th>Pod</th><th>CVE</th><th>Package</th><th>Severity</th><th>Evidence</th></tr></thead><tbody>
      <tr class:row-bad={compromised}><td>alma9-edge-01</td><td class="mono">CVE-2025-{compromised ? '31337' : '0991'}</td><td class="mono">glibc</td><td><span class="badge {compromised ? 'b-bad' : 'b-pending'}">{compromised ? 'CRITICAL' : 'MEDIUM'}</span></td><td><span class="badge b-ok">🔒 Sealed</span></td></tr>
      <tr><td>db-02</td><td class="mono">CVE-2025-2048</td><td class="mono">openssl</td><td><span class="badge b-pending">HIGH</span></td><td><span class="badge b-ok">🔒 Sealed</span></td></tr>
    </tbody></table></div></div>

{:else}
  <div class="layout solo"><div class="panel"><div class="stub">
    <h2>VMs · Polonium — coming soon</h2>
    <p>This Alfa slice focuses on the <b>CC*</b> critical path. VM lifecycle &amp; Polonium policy console are next; full Alfa breadth + Beta surfaces (personas, compliance, $THOR/DAO) follow.</p>
  </div></div></div>
{/if}

{#if phase !== 'idle'}
  <div class="progress">
    <span class="p-step">Step {Math.min(step, 4)}/4</span>
    <div class="p-bar"><div class="p-fill" style="width:{(Math.min(step,4)/4)*100}%"></div></div>
    <span class="p-lbl">{PHASE_LABEL[phase]}{autoplay ? ' · ⟳ looping' : ''}</span>
  </div>
{/if}

<footer class="trust">Powered by <b>Thorium XDR</b> · Sui {cfg.network} · scope {cfg.scope} · demo mode (stateless, contract fixtures) · CC* critical path</footer>

{#if toast}<div class="toast">{toast}</div>{/if}
