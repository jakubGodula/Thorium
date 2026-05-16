<script lang="ts">
  import { onMount } from 'svelte';
  
  type Node = {
    id: string;
    type: 'endpoint' | 'process' | 'identity' | 'network';
    label: string;
    status: 'clean' | 'suspicious' | 'malicious';
    x: number;
    y: number;
  };

  type Link = {
    source: string;
    target: string;
    label: string;
  };

  let nodes: Node[] = [
    { id: 'e1', type: 'endpoint', label: 'FIN-LAPTOP-04', status: 'suspicious', x: 100, y: 200 },
    { id: 'p1', type: 'process', label: 'powershell.exe', status: 'malicious', x: 300, y: 150 },
    { id: 'p2', type: 'process', label: 'svchost.exe', status: 'clean', x: 300, y: 250 },
    { id: 'i1', type: 'identity', label: 'adm-svc-sql', status: 'malicious', x: 500, y: 100 },
    { id: 'n1', type: 'network', label: '185.22.14.9', status: 'malicious', x: 700, y: 150 },
    { id: 'e2', type: 'endpoint', label: 'SQL-PROD-01', status: 'malicious', x: 500, y: 300 }
  ];

  let links: Link[] = [
    { source: 'e1', target: 'p1', label: 'Executes' },
    { source: 'e1', target: 'p2', label: 'Parent' },
    { source: 'p1', target: 'i1', label: 'Token Theft' },
    { source: 'i1', target: 'n1', label: 'C2 Connection' },
    { source: 'i1', target: 'e2', label: 'Lateral Movement' }
  ];

  let selectedNode: Node | null = null;

  function findNode(id: string) {
    return nodes.find(n => n.id === id);
  }

  function handleNodeClick(node: Node) {
    selectedNode = node;
  }
</script>

<div class="storyline-page">
  <header class="page-header">
    <div class="header-left">
      <h1>Storyline Reconstruction</h1>
      <div class="breadcrumb">
        <span>Incident #4922</span>
        <span class="sep">/</span>
        <span class="active">Dynamic Attack Graph</span>
      </div>
    </div>
    <div class="header-right">
      <div class="severity-badge critical">Critical Risk Score: 8.9</div>
      <button class="btn-primary">Automated Disruption Active</button>
    </div>
  </header>

  <div class="storyline-container">
    <div class="graph-viewer glass">
      <svg viewBox="0 0 800 400" preserveAspectRatio="xMidYMid meet" class="attack-graph">
        <!-- Links -->
        {#each links as link}
          {@const s = findNode(link.source)}
          {@const t = findNode(link.target)}
          {#if s && t}
            <path 
              d="M{s.x} {s.y} L{t.x} {t.y}" 
              class="link {s.status} {t.status}"
            />
            <text x={(s.x + t.x) / 2} y={(s.y + t.y) / 2 - 10} class="link-label">
              {link.label}
            </text>
          {/if}
        {/each}

        <!-- Nodes -->
        {#each nodes as node}
          <g 
            class="node-group {node.status}" 
            transform="translate({node.x}, {node.y})"
            on:click={() => handleNodeClick(node)}
          >
            <circle r="24" class="node-bg" />
            <circle r="20" class="node-inner" />
            <text y="45" text-anchor="middle" class="node-label">{node.label}</text>
            
            {#if node.type === 'endpoint'}
              <path d="M-8 -8 L8 -8 L8 8 L-8 8 Z" fill="white" opacity="0.8" />
            {:else if node.type === 'process'}
              <path d="M-8 0 L0 -8 L8 0 L0 8 Z" fill="white" opacity="0.8" />
            {:else if node.type === 'identity'}
              <circle r="6" fill="white" opacity="0.8" />
            {:else if node.type === 'network'}
              <path d="M-8 8 L0 -8 L8 8 Z" fill="white" opacity="0.8" />
            {/if}
          </g>
        {/each}
      </svg>
      
      <div class="legend glass">
        <div class="legend-item"><span class="dot endpoint"></span> Endpoint</div>
        <div class="legend-item"><span class="dot process"></span> Process</div>
        <div class="legend-item"><span class="dot identity"></span> Identity</div>
        <div class="legend-item"><span class="dot network"></span> Network</div>
      </div>
    </div>

    <aside class="details-sidebar glass">
      {#if selectedNode}
        <div class="selection-details">
          <div class="detail-header">
            <span class="type-badge {selectedNode.type}">{selectedNode.type}</span>
            <h2>{selectedNode.label}</h2>
          </div>
          
          <div class="telemetry-box">
            <h3>Telemetry Required</h3>
            <ul class="telemetry-list">
              {#if selectedNode.type === 'endpoint'}
                <li>Process creation trees</li>
                <li>Registry modifications</li>
                <li>Parent-child relationships</li>
              {:else if selectedNode.type === 'process'}
                <li>Command-line arguments</li>
                <li>Memory injection attempts</li>
                <li>Socket bindings</li>
              {:else if selectedNode.type === 'identity'}
                <li>Kerberos/NTLM tickets</li>
                <li>OAuth token grants</li>
                <li>Geo-velocity alerts</li>
              {:else if selectedNode.type === 'network'}
                <li>Flow data (NetFlow/IPFIX)</li>
                <li>SSL/TLS handshake metadata</li>
                <li>DNS query patterns</li>
              {/if}
            </ul>
          </div>

          <div class="actions">
            <button class="btn-action isolate">Isolate Host</button>
            <button class="btn-action rollback">Rollback Files</button>
          </div>
        </div>
      {:else}
        <div class="no-selection">
          <p>Select a node in the graph to view correlation details and required telemetry.</p>
        </div>
      {/if}
    </aside>
  </div>
</div>

<style>
  .storyline-page {
    display: flex;
    flex-direction: column;
    gap: 2rem;
    height: calc(100vh - 8rem);
  }

  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .breadcrumb {
    display: flex;
    gap: 0.5rem;
    color: var(--text-secondary);
    font-size: 0.9rem;
    font-family: var(--font-mono);
  }

  .breadcrumb .active { color: var(--accent-cyan); }

  .severity-badge {
    padding: 0.5rem 1rem;
    border-radius: 8px;
    font-weight: 800;
    font-size: 0.9rem;
    letter-spacing: 0.05em;
  }

  .severity-badge.critical {
    background: rgba(255, 51, 102, 0.2);
    color: var(--accent-crimson);
    border: 1px solid var(--accent-crimson);
    box-shadow: 0 0 20px rgba(255, 51, 102, 0.2);
  }

  .btn-primary {
    background: var(--accent-cyan);
    color: var(--bg-abyssal);
    border: none;
    padding: 0.6rem 1.2rem;
    border-radius: 8px;
    font-weight: 700;
    cursor: pointer;
    margin-left: 1rem;
  }

  .storyline-container {
    display: grid;
    grid-template-columns: 1fr 350px;
    gap: 1.5rem;
    flex: 1;
    min-height: 0;
  }

  .graph-viewer {
    position: relative;
    background: rgba(0, 0, 0, 0.3);
    overflow: hidden;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .attack-graph {
    width: 100%;
    height: 100%;
  }

  .link {
    fill: none;
    stroke: var(--text-muted);
    stroke-width: 2;
    transition: all 0.3s ease;
  }

  .link.malicious {
    stroke: var(--accent-crimson);
    stroke-width: 3;
    stroke-dasharray: 5;
    animation: flow 10s linear infinite;
  }

  @keyframes flow {
    from { stroke-dashoffset: 100; }
    to { stroke-dashoffset: 0; }
  }

  .link-label {
    font-size: 10px;
    fill: var(--text-secondary);
    font-family: var(--font-mono);
  }

  .node-group {
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .node-group:hover { filter: brightness(1.2); }

  .node-bg {
    fill: var(--bg-surface);
    stroke: var(--border-bright);
    stroke-width: 2;
  }

  .node-inner {
    fill: var(--bg-card);
    stroke-width: 2;
  }

  .node-group.clean .node-inner { stroke: var(--accent-green); fill: rgba(0, 255, 136, 0.1); }
  .node-group.suspicious .node-inner { stroke: var(--accent-amber); fill: rgba(255, 170, 0, 0.1); }
  .node-group.malicious .node-inner { stroke: var(--accent-crimson); fill: rgba(255, 51, 102, 0.1); }

  .node-label {
    fill: var(--text-primary);
    font-size: 12px;
    font-weight: 600;
  }

  .legend {
    position: absolute;
    bottom: 1rem;
    left: 1rem;
    padding: 0.75rem 1rem;
    display: flex;
    gap: 1.5rem;
  }

  .legend-item {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-size: 0.8rem;
    color: var(--text-secondary);
  }

  .dot { width: 8px; height: 8px; border-radius: 50%; }
  .dot.endpoint { background: var(--text-primary); }
  .dot.process { background: var(--accent-amber); }
  .dot.identity { background: var(--accent-violet); }
  .dot.network { background: var(--accent-cyan); }

  .details-sidebar {
    padding: 1.5rem;
    display: flex;
    flex-direction: column;
  }

  .detail-header {
    margin-bottom: 2rem;
  }

  .type-badge {
    display: inline-block;
    padding: 0.25rem 0.5rem;
    border-radius: 4px;
    font-size: 0.7rem;
    font-weight: 800;
    text-transform: uppercase;
    margin-bottom: 0.5rem;
    background: var(--bg-card);
    border: 1px solid var(--border-bright);
  }

  .type-badge.endpoint { color: var(--text-primary); }
  .type-badge.process { color: var(--accent-amber); }
  .type-badge.identity { color: var(--accent-violet); }
  .type-badge.network { color: var(--accent-cyan); }

  .telemetry-box {
    background: rgba(255, 255, 255, 0.03);
    padding: 1rem;
    border-radius: 8px;
    margin-bottom: 2rem;
  }

  .telemetry-box h3 {
    font-size: 0.85rem;
    color: var(--text-secondary);
    margin-bottom: 1rem;
    text-transform: uppercase;
  }

  .telemetry-list {
    list-style: none;
    font-size: 0.9rem;
  }

  .telemetry-list li {
    margin-bottom: 0.5rem;
    position: relative;
    padding-left: 1rem;
  }

  .telemetry-list li::before {
    content: '→';
    position: absolute;
    left: 0;
    color: var(--accent-cyan);
  }

  .actions {
    margin-top: auto;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .btn-action {
    width: 100%;
    padding: 0.8rem;
    border-radius: 8px;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .btn-action.isolate {
    background: transparent;
    border: 1px solid var(--accent-crimson);
    color: var(--accent-crimson);
  }

  .btn-action.isolate:hover {
    background: var(--accent-crimson);
    color: white;
  }

  .btn-action.rollback {
    background: var(--accent-green);
    border: none;
    color: var(--bg-abyssal);
  }

  .no-selection {
    display: flex;
    align-items: center;
    justify-content: center;
    height: 100%;
    text-align: center;
    color: var(--text-muted);
    font-style: italic;
  }
</style>
