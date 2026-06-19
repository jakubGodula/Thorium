<script lang="ts">
  import { onMount } from 'svelte'
  import {
    type Phase, type AppConfig, PHASES, fleet, observedPod, podSpark, timeline,
    responseActions, loadConfig, incidentTree, personas, modules, trustBadges,
    auditTrail, integrations, threatIntel,
  } from './lib/scenario'

  let tab = $state('overview')
  let phase = $state<Phase>('idle')
  let drawerOpen = $state(false)
  let autoplay = $state(false)
  let offline = $state(false)
  let tenant = $state('Acme Corp')
  let toast = $state('')
  let cfg = $state<AppConfig>({ scope: 'alfa', network: 'testnet', packageId: '0x0cc3…91af', mock: true })

  onMount(async () => {
    cfg = await loadConfig()
    const q = new URLSearchParams(location.search)
    if (q.has('cc')) { phase = 'isolated'; drawerOpen = true }
    if (q.has('demo')) { autoplay = true; runScenario() }
    // TODO(live, answer I2): when cfg.wsUrl is set, open a WebSocket here and feed
    // events into phase/telemetry/incident state instead of the client-side stepper.
    // const ws = new WebSocket(cfg.wsUrl); ws.onmessage = e => applyEvent(JSON.parse(e.data))
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
    let k = 0; phase = 'idle'
    const advance = () => {
      phase = seq[k]; if (phase === 'isolated') drawerOpen = true; k++
      if (k < seq.length) timer = setTimeout(advance, k <= 1 ? 1100 : 1600)
      else if (autoplay) timer = setTimeout(runScenario, 4500)
    }
    timer = setTimeout(advance, 400)
  }
  function reset() { if (timer) clearTimeout(timer); autoplay = false; phase = 'idle'; drawerOpen = false }
  function toggleAutoplay() { autoplay = !autoplay; if (autoplay) runScenario(); else reset() }
  function note(l: string) { toast = `${l} — mock / coming soon`; setTimeout(() => (toast = ''), 2400) }

  let decrypted = $state(false)
  const connectCmd = `curl -fsSL https://${cfg.unstoppableDomain ?? 'thorium.crypto'}/agent | sh -s -- \\
  --register 0x0cc3…91af --invite TH-INVITE-9F2A-MOCK --owner $(whoami)`

  const NAV: { group: string; items: { id: string; label: string; tag?: string }[] }[] = [
    { group: 'Monitor', items: [
      { id: 'overview', label: 'Overview' }, { id: 'telemetry', label: 'Fleet Telemetry' },
      { id: 'endpoints', label: 'Endpoints' }, { id: 'chain', label: 'Chain Activity' } ] },
    { group: 'Detect', items: [
      { id: 'incidents', label: 'Incidents (tree)' }, { id: 'alerts', label: 'Alerts' },
      { id: 'talus', label: 'Talus AI' }, { id: 'vulns', label: 'Vulnerabilities' },
      { id: 'threat', label: 'Threat Intel' } ] },
    { group: 'Respond', items: [
      { id: 'onboarding', label: 'Connect a pod' }, { id: 'integrations', label: 'Integrations', tag: 'mock' },
      { id: 'audit', label: 'Audit Trail', tag: 'mock' } ] },
    { group: 'Platform', items: [
      { id: 'compliance', label: 'Compliance (NIS2)', tag: 'mock' }, { id: 'governance', label: 'Governance · $THOR', tag: 'mock' },
      { id: 'personas', label: 'Roles & Models', tag: 'mock' }, { id: 'privacy', label: 'Privacy & Trust' },
      { id: 'roadmap', label: 'Modules', tag: 'soon' }, { id: 'other', label: 'Other capabilities', tag: 'soon' } ] },
  ]
  const sevCls: Record<string, string> = { CRITICAL: 'b-bad', HIGH: 'b-pending', WARNING: 'b-pending', INFO: 'b-ok' }
</script>

<div class="app">
  <!-- LEFT RAIL -->
  <aside class="rail">
    <div class="brand"><span class="mark"></span><span>Thorium <span class="x">XDR</span></span></div>
    {#each NAV as g}
      <div class="nav-group">{g.group}</div>
      {#each g.items as it}
        <button class="nav-item" class:active={tab === it.id} onclick={() => (tab = it.id)}>
          {it.label}{#if it.tag}<span class="tag">{it.tag}</span>{/if}
        </button>
      {/each}
    {/each}
    <div class="rail-foot">scope <b>{cfg.scope}</b> · {cfg.mock ? 'mock' : 'live'}<br/>Sui {cfg.network}</div>
  </aside>

  <!-- MAIN -->
  <main>
    <div class="topbar">
      <div class="chip"><span class="dot"></span> Sui {cfg.network} · <span class="mono">{cfg.packageId.slice(0,8)}…</span></div>
      <button class="chip btn-chip" onclick={() => note('MSSP tenant switch')} title="MSSP multi-tenant (mock)">🏢 {tenant} ▾</button>
      <div class="grow"></div>
      <button class="ghost" class:on={offline} onclick={() => { offline = !offline; if(offline) note('Offline Lockdown engaged') }}>{offline ? '🔒 Lockdown' : '◍ Online'}</button>
      <button class="ghost">Connect Wallet</button>
      <button class="ghost" class:on={autoplay} onclick={toggleAutoplay}>{autoplay ? '⏸ Demo mode' : '◷ Demo mode'}</button>
      {#if phase === 'idle'}<button class="run" onclick={runScenario}>▶ Run CC* scenario</button>
      {:else}<button class="ghost" onclick={reset}>↻ Reset</button>{/if}
    </div>

    {#if offline}<div class="lockbar">🔒 Offline Lockdown — lost comms with Sui RPC / C2; agents cut network &amp; freeze processes (Dark Mode).</div>{/if}

    {#if compromised}
      <div class="banner" role="alert">
        <span class="pulse"></span>
        <div><div class="sev">CRITICAL · ON-CHAIN INCIDENT <span class="was">✓ Healthy 40s ago</span></div>
          <div class="msg"><b>Kernel exploit</b> on observed pod <b>alma9-edge-01</b> · anomaly <b>0.91</b> · marked <b>NOT WORTHY</b> &amp; auto-isolated on Sui</div></div>
        <div class="cta"><span class="speed">⚡ Auto-isolated in 2s</span>
          <button class="btn btn-quiet" onclick={reset}>Mute</button>
          <button class="btn btn-crit" onclick={() => (drawerOpen = true)}>View incident →</button></div>
      </div>
    {/if}

    <div class="content">
    {#if tab === 'overview' || tab === 'endpoints'}
      <div class="layout" class:solo={!drawerOpen}>
        <div>
          {#if tab === 'overview'}<div class="kpis">
            <div class="kpi"><div class="t">Active Agents</div><div class="v">{compromised ? 23 : 24}</div></div>
            <div class="kpi" class:bad={compromised}><div class="t">Critical Threats</div><div class="v">{compromised ? 1 : 0}</div></div>
            <div class="kpi"><div class="t">Pods Observed</div><div class="v">{phase === 'idle' ? 23 : 24}</div></div>
          </div>{/if}
          <div class="panel"><h3>Monitored Endpoints (SBT) · K8s {#if phase==='idle'}— ▶ Run CC* scenario{/if}</h3>
            <table><thead><tr><th>Observed Pod</th><th>Cluster / NS</th><th>Telemetry</th><th>Status</th><th>On-chain</th></tr></thead><tbody>
              {#if pod}<tr class:row-bad={compromised}>
                <td><b>{pod.hostname}</b><br><span class="mono dim">{pod.id}</span></td>
                <td class="mono dim">prod-eu1 · {pod.namespace}</td>
                <td><svg class="spark" viewBox="0 0 120 22" preserveAspectRatio="none"><polyline points={spark.points} fill="none" stroke={spark.color} stroke-width="2"/></svg></td>
                <td>{#if pod.status==='NOT WORTHY'}<span class="badge b-bad"><span class="pulse"></span>NOT WORTHY</span>{:else if pod.status==='Connecting'}<span class="badge b-pending">Connecting…</span>{:else}<span class="badge b-ok">Healthy</span>{/if}</td>
                <td class="mono dim">is_active={pod.isActive}</td></tr>{/if}
              {#each others as o}<tr><td>{o.hostname}<br><span class="mono dim">{o.id}</span></td><td class="mono dim">prod-eu1 · {o.namespace}</td>
                <td><svg class="spark" viewBox="0 0 120 22" preserveAspectRatio="none"><polyline points="0,14 20,13 40,15 60,12 80,13 100,11 120,12" fill="none" stroke="#22c55e" stroke-width="2"/></svg></td>
                <td><span class="badge b-ok">Healthy</span></td><td class="mono dim">is_active=true</td></tr>{/each}
            </tbody></table></div>
        </div>
        {#if drawerOpen}<div class="drawer" role="dialog" aria-label="Incident Command">
          <div class="head"><span class="sev">CRITICAL</span><div><div style="font-weight:700">Incident Command</div><div class="mono dim" style="font-size:11px">INC-991 · alma9-edge-01</div></div><button class="ghost" style="margin-left:auto" onclick={() => (drawerOpen=false)}>✕</button></div>
          <div class="body">
            <div class="callouts"><div class="callout"><div class="cl-l">Isolation</div><div class="cl-v">KILLED_AND_ISOLATED</div></div><div class="callout"><div class="cl-l">Blast radius</div><div class="cl-v">1 pod · 0 lateral</div></div></div>
            <div class="section-label">Kill-chain timeline</div>
            <div class="tl">{#each events as e}<div class="ev {e.kind}" class:climax={e.climax}><div class="h">{e.h}</div><div class="s">{e.s}</div><div class="t">{e.t}</div></div>{/each}</div>
            <div class="section-label">On-chain evidence</div>
            <div class="evid">tx 0x9aBcDeF…01 · IncidentReport&#123;severity:"CRITICAL"&#125;</div>
            <div class="section-label">Live Web Terminal (DFIR)</div>
            <button class="term" onclick={() => note('Live Web Terminal')}><span class="mono">root@alma9-edge-01:~# _</span><span class="tag">mock</span></button>
            <div class="section-label">Response — recommended actions</div>
            <div class="actions">{#each responseActions as a}<button class="resp" onclick={() => note(a.l)}><span class="i">{a.i}</span><span class="l">{a.l}</span><span class="soon">Coming soon</span></button>{/each}</div>
          </div>
        </div>{/if}
      </div>

    {:else if tab === 'telemetry'}
      <div class="panel"><h3>Fleet Telemetry — cpu / ram / disk (event-sourced)</h3>
        <table><thead><tr><th>Pod</th><th>CPU</th><th>RAM</th><th>Disk</th><th>Trend</th></tr></thead><tbody>
        {#if pod}<tr class:row-bad={compromised}><td><b>{pod.hostname}</b></td><td class="mono">{pod.cpu}%</td><td class="mono">{pod.ram}%</td><td class="mono">{pod.disk}%</td><td><svg class="spark" viewBox="0 0 120 22" preserveAspectRatio="none"><polyline points={spark.points} fill="none" stroke={spark.color} stroke-width="2"/></svg></td></tr>{/if}
        {#each others as o}<tr><td>{o.hostname}</td><td class="mono">{o.cpu}%</td><td class="mono">{o.ram}%</td><td class="mono">{o.disk}%</td><td><svg class="spark" viewBox="0 0 120 22" preserveAspectRatio="none"><polyline points="0,14 20,13 40,15 60,12 80,13 100,11 120,12" fill="none" stroke="#22c55e" stroke-width="2"/></svg></td></tr>{/each}
        </tbody></table></div>

    {:else if tab === 'chain'}
      <div class="panel"><h3>Chain Activity — on-chain events · pkg <span class="mono dim">{cfg.packageId.slice(0,8)}…</span> <span class="tag">{cfg.wsUrl ? 'WS' : 'polling'}</span></h3>
        <table><thead><tr><th>Severity</th><th>Event</th><th>Action</th><th>tx</th></tr></thead><tbody>
        {#if compromised}<tr class="row-bad"><td><span class="badge b-bad">CRITICAL</span></td><td>alma9-edge-01 · IncidentReport (kernel exploit)</td><td class="mono">KILLED_AND_ISOLATED</td><td class="mono acc">0x9aBc…01</td></tr>
        <tr><td><span class="badge b-pending">HIGH</span></td><td>alma9-edge-01 · ClassificationReported 0.91</td><td class="mono">TRIGGER_ISOLATION</td><td class="mono acc">0x7xYz…</td></tr>{/if}
        {#if step>=2}<tr><td><span class="badge b-ok">INFO</span></td><td>alma9-edge-01 · TelemetryReported cpu 12%</td><td class="mono">—</td><td class="mono acc">0x5tuv…</td></tr>{/if}
        {#if step>=1}<tr><td><span class="badge b-ok">INFO</span></td><td>alma9-edge-01 · AgentRegistered</td><td class="mono">—</td><td class="mono acc">0x12aB…</td></tr>{/if}
        <tr><td><span class="badge b-ok">INFO</span></td><td>ws-07 · TelemetryReported cpu 13%</td><td class="mono">—</td><td class="mono acc">0x88cd…</td></tr>
        </tbody></table></div>

    {:else if tab === 'incidents'}
      <div class="panel"><h3>Incidents — correlation tree (kill-chain grouping)</h3>
        <div class="tree">{#each incidentTree as inc}
          <div class="t-root"><span class="badge {sevCls[inc.sev]}">{inc.sev}</span> <b>{inc.id}</b> · {inc.title}</div>
          {#each inc.children as c}<div class="t-child"><span class="badge {sevCls[c.sev]}">{c.sev}</span> {c.title} <span class="mono acc">{c.tx}</span></div>{/each}
        {/each}</div></div>

    {:else if tab === 'alerts'}
      <div class="panel"><h3>Alerts</h3>{#if compromised}
        <table><thead><tr><th>Severity</th><th>Detection</th><th>Action</th><th>Status</th></tr></thead><tbody>
        <tr class="row-bad"><td><span class="badge b-bad">CRITICAL</span></td><td>alma9-edge-01 · kernel exploit (eBPF)</td><td class="mono">KILLED_AND_ISOLATED</td><td><span class="badge b-pending">Open</span></td></tr>
        <tr><td><span class="badge b-pending">HIGH</span></td><td>alma9-edge-01 · Talus anomaly 0.91</td><td class="mono">TRIGGER_ISOLATION</td><td><span class="badge b-pending">Open</span></td></tr>
        </tbody></table>{:else}<div class="stub"><h2>No active alerts.</h2><p>Run the CC* scenario to generate one.</p></div>{/if}</div>

    {:else if tab === 'talus'}
      <div class="panel"><h3>🤖 Talus AI — detections &amp; correlations (threshold 0.85)</h3>
        <div class="cards">
          <div class="card {compromised ? 'card-bad' : ''}"><div class="card-h">{compromised ? 'Credential dumping / kernel exploit' : 'Baseline — nominal'}</div><div class="card-s">alma9-edge-01 · score <b>{compromised ? '0.91' : '0.06'}</b> {compromised ? '≥ 0.85 → isolate' : 'within baseline'}</div><div class="card-meta">ClassificationReported · Ed25519-verified</div></div>
          <div class="card"><div class="card-h">Correlation: exec → FIM → C2</div><div class="card-s">3 events linked into one kill-chain</div><div class="card-meta">how Talus could drive detections (demo)</div></div>
          <div class="card"><div class="card-h">Lateral-movement watch</div><div class="card-s">fleet · 0.04 · nominal</div><div class="card-meta">Cross-Device XDR heuristic</div></div>
        </div></div>

    {:else if tab === 'vulns'}
      <div class="panel"><h3>🦭 Vulnerability Registry — Seal-encrypted (Walrus)</h3>
        <table><thead><tr><th>Pod</th><th>CVE</th><th>Package</th><th>Severity</th><th>Evidence (browser decrypt)</th></tr></thead><tbody>
        <tr class:row-bad={compromised}><td>alma9-edge-01</td><td class="mono">CVE-2025-{compromised ? '31337' : '0991'}</td><td class="mono">glibc</td><td><span class="badge {compromised ? 'b-bad' : 'b-pending'}">{compromised ? 'CRITICAL' : 'MEDIUM'}</span></td>
          <td>{#if decrypted}<span class="mono acc">walrus:blob:7f3a… · decrypted</span>{:else}<button class="mini" onclick={() => { decrypted = true; note('Seal browser decrypt') }}>🔒 Decrypt (Seal)</button>{/if}</td></tr>
        <tr><td>db-02</td><td class="mono">CVE-2025-2048</td><td class="mono">openssl</td><td><span class="badge b-pending">HIGH</span></td><td><span class="badge b-ok">🔒 Sealed</span></td></tr>
        </tbody></table></div>

    {:else if tab === 'threat'}
      <div class="panel"><h3>Threat Intel &amp; Deception (STIX/TAXII · MISP · honeytokens)</h3>
        <table><thead><tr><th>Severity</th><th>Signal</th><th>Source</th><th></th></tr></thead><tbody>
        {#each threatIntel as r}<tr><td><span class="badge {sevCls[r.sev]}">{r.sev}</span></td><td>{r.t}</td><td class="dim">{r.src}</td><td>{#if r.fp}<span class="badge b-ok">{r.fp}</span>{/if}</td></tr>{/each}
        </tbody></table></div>

    {:else if tab === 'onboarding'}
      <div class="panel"><h3>Connect a pod — register an observed agent on-chain</h3>
        <div class="pad"><p class="dim">Run this on the host/pod. It registers the agent to the public contract with a (mock) invitation token, then appears in the fleet as a Soulbound identity.</p>
          <pre class="cmd">{connectCmd}</pre>
          <button class="run" onclick={() => note('Copied connect command')}>Copy command</button>
          <p class="dim" style="margin-top:14px">Public contracts only for now → the invitation token <span class="mono">TH-INVITE-9F2A-MOCK</span> is a mock. K8s example: target a namespace via <span class="mono">--k8s prod-eu1/prod/edge</span> (UI preview; not yet functional).</p>
        </div></div>

    {:else if tab === 'compliance'}
      <div class="panel"><h3>Compliance-as-a-Service — NIS2 / KSC <span class="tag">auditor view (read-only)</span></h3>
        <div class="cards">
          <div class="card"><div class="card-h">Chain of custody</div><div class="card-s">Every incident frozen as immutable Walrus evidence</div><div class="card-meta">read-only for authorities / insurers</div></div>
          <div class="card"><div class="card-h">NIS2 report</div><div class="card-s">Auto-collected · SHA-256 integrity on-chain</div><div class="card-meta">Pay-As-You-Go Walrus storage</div></div>
          <div class="card"><div class="card-h">INC-991 evidence</div><div class="card-s mono acc">walrus:blob:7f3a… · policy_hash sha256:0011…</div><div class="card-meta">export PDF (mock)</div></div>
        </div></div>

    {:else if tab === 'governance'}
      <div class="panel"><h3>Governance — $THOR &amp; DAO <span class="tag">mock</span></h3>
        <div class="cards">
          <div class="card"><div class="card-h">$THOR rewards</div><div class="card-s">Earn for reporting zero-days to the network</div><div class="card-meta">Web3 / Freemium</div></div>
          <div class="card"><div class="card-h">DAO policy vote #42</div><div class="card-s">"Raise Talus threshold 0.85 → 0.88" · 64% yes</div><div class="card-meta">votes on-chain</div></div>
          <div class="card"><div class="card-h">P2P heuristic pool</div><div class="card-s">Cross-Device XDR shared immunity</div><div class="card-meta">community</div></div>
        </div></div>

    {:else if tab === 'personas'}
      <div class="panel"><h3>Roles &amp; Business Models <span class="tag">future · non-functional</span></h3>
        <div class="cards">{#each personas as p}<div class="card"><div class="card-h">{p.i} {p.n}</div><div class="card-s">{p.d}</div></div>{/each}</div>
        <p class="dim pad">Current build runs as a single role (no switcher). MSSP multi-tenant + read-only auditor/insurer views land with Beta.</p></div>

    {:else if tab === 'privacy'}
      <div class="panel"><h3>Privacy &amp; Trust — we never read your plaintext</h3>
        <div class="cards">{#each trustBadges as b}<div class="card"><div class="card-h">{b[0]} {b[1]}</div><div class="card-s">{b[2]}</div></div>{/each}</div></div>

    {:else if tab === 'integrations'}
      <div class="panel"><h3>Integrations — SIEM export &amp; webhooks <span class="tag">mock</span></h3>
        <table><thead><tr><th>Target</th><th>Mode</th><th>Status</th></tr></thead><tbody>
        {#each integrations as r}<tr><td>{r[0]}</td><td class="dim">{r[1]}</td><td><span class="badge b-pending">{r[2]}</span></td></tr>{/each}
        </tbody></table></div>

    {:else if tab === 'audit'}
      <div class="panel"><h3>Analyst Audit Trail — every action as an immutable tx <span class="tag">mock</span></h3>
        <table><thead><tr><th>Time</th><th>Actor</th><th>Action</th><th>tx</th></tr></thead><tbody>
        {#each auditTrail as r}<tr><td class="mono dim">{r[0]}</td><td class="mono">{r[1]}</td><td>{r[2]}</td><td class="mono acc">{r[3]}</td></tr>{/each}
        </tbody></table></div>

    {:else if tab === 'roadmap'}
      <div class="panel"><h3>Modules — coming soon</h3>
        <div class="cards">{#each modules as m}<div class="card"><div class="card-h">{m[0]} <span class="tag">soon</span></div><div class="card-s">{m[1]}</div></div>{/each}</div></div>

    {:else}
      <div class="panel"><h3>Other capabilities — what makes the solution complete <span class="tag">soon</span></h3>
        <div class="cards">
          <div class="card"><div class="card-h">Hydrogen PAM</div><div class="card-s">FIDO2 / Web3 wallet login · zero passwords in memory</div></div>
          <div class="card"><div class="card-h">A/B Auto-Updater</div><div class="card-s">Ed25519-verified agent updates + fallback partition</div></div>
          <div class="card"><div class="card-h">Mowa JIT → eBPF</div><div class="card-s">SOAR scripts compiled to Ring-0 BPF (zero latency)</div></div>
          <div class="card"><div class="card-h">Spatial SOC (3D)</div><div class="card-s">Kill-chain in 3D · later R&D</div></div>
        </div></div>
    {/if}
    </div>

    {#if phase !== 'idle'}<div class="progress"><span class="p-step">Step {Math.min(step,4)}/4</span><div class="p-bar"><div class="p-fill" style="width:{(Math.min(step,4)/4)*100}%"></div></div><span class="p-lbl">{PHASE_LABEL[phase]}{autoplay ? ' · ⟳' : ''}</span></div>{/if}
    <footer class="trust">Powered by <b>Thorium XDR</b> · Sui {cfg.network} · scope {cfg.scope} · demo (mock fixtures) · deploys to {cfg.unstoppableDomain ?? 'Unstoppable Domain'} (IPFS) · CC* critical path</footer>
  </main>
</div>
{#if toast}<div class="toast">{toast}</div>{/if}
