<script lang="ts">
  type AgentStep = {
    id: string;
    timestamp: string;
    action: string;
    detail: string;
    status: 'pending' | 'working' | 'completed' | 'failed';
    type: 'request' | 'lookup' | 'validation' | 'verdict';
  };

  let steps: AgentStep[] = [
    { id: '1', timestamp: '10:45:01', action: 'Inbound Alert', detail: 'Impossible Travel detected for user: s.miller@corp.com', status: 'completed', type: 'request' },
    { id: '2', timestamp: '10:45:03', action: 'Identity Lookup', detail: 'Fetching Azure AD sign-in logs and MFA history', status: 'completed', type: 'lookup' },
    { id: '3', timestamp: '10:45:05', action: 'Context Harvesting', detail: 'Checking Outlook Calendar for "Travel" or "OOO" keywords', status: 'completed', type: 'lookup' },
    { id: '4', timestamp: '10:45:08', action: 'Device Health', detail: 'Verifying MDM compliance for device: MAC-BOOK-772', status: 'completed', type: 'validation' },
    { id: '5', timestamp: '10:45:10', action: 'Risk Analysis', detail: 'Correlating IP reputation (192.15.2.4) with known VPN exits', status: 'working', type: 'validation' },
    { id: '6', timestamp: '---', action: 'Final Verdict', detail: 'Awaiting data enrichment...', status: 'pending', type: 'verdict' }
  ];

  let isAnalyzing = true;
</script>

<div class="triage-page">
  <header class="page-header">
    <div class="header-left">
      <h1>Recursive AI Triage</h1>
      <p class="subtitle">Autonomous decision loops for high-fidelity alerts</p>
    </div>
    <div class="ai-status {isAnalyzing ? 'active' : 'idle'}">
      <div class="brain-icon">
        <div class="core"></div>
        <div class="orbit"></div>
      </div>
      <span>{isAnalyzing ? 'AI Agent Processing...' : 'Agent Standby'}</span>
    </div>
  </header>

  <div class="triage-container">
    <div class="agent-timeline glass">
      <div class="timeline-header">
        <h2>Autonomous Reasoning Chain</h2>
        <div class="incident-id">INCIDENT-ID: TH-8821</div>
      </div>

      <div class="steps-list">
        {#each steps as step}
          <div class="step {step.status} {step.type}">
            <div class="step-meta">
              <span class="timestamp">{step.timestamp}</span>
              <div class="status-indicator"></div>
            </div>
            <div class="step-content">
              <div class="action">{step.action}</div>
              <div class="detail">{step.detail}</div>
            </div>
            {#if step.status === 'working'}
              <div class="loader-tiny"></div>
            {/if}
          </div>
        {/each}
      </div>
    </div>

    <aside class="triage-sidebar">
      <div class="telemetry-stack glass">
        <h3>Connected Intelligence</h3>
        <div class="stack-items">
          <div class="stack-item active">
            <span class="icon">☁️</span>
            <div class="item-info">
              <span class="name">Microsoft 365 API</span>
              <span class="status">Connected</span>
            </div>
          </div>
          <div class="stack-item active">
            <span class="icon">🆔</span>
            <div class="item-info">
              <span class="name">Okta Identity</span>
              <span class="status">Connected</span>
            </div>
          </div>
          <div class="stack-item pulse">
            <span class="icon">📱</span>
            <div class="item-info">
              <span class="name">Jamf MDM</span>
              <span class="status">Enriching...</span>
            </div>
          </div>
          <div class="stack-item">
            <span class="icon">🌐</span>
            <div class="item-info">
              <span class="name">ThreatIntel Feed</span>
              <span class="status">Standby</span>
            </div>
          </div>
        </div>
      </div>

      <div class="triage-settings glass">
        <h3>Agent Sensitivity</h3>
        <div class="slider-group">
          <label>Confidence Threshold</label>
          <input type="range" min="0" max="100" value="85" />
          <div class="value">85%</div>
        </div>
        <div class="toggle-group">
          <label>Auto-Disruption</label>
          <div class="toggle active">ON</div>
        </div>
      </div>
    </aside>
  </div>
</div>

<style>
  .triage-page {
    display: flex;
    flex-direction: column;
    gap: 2rem;
  }

  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .ai-status {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 0.5rem 1.5rem;
    background: rgba(112, 0, 255, 0.1);
    border: 1px solid var(--accent-violet);
    border-radius: 30px;
    font-weight: 700;
    color: var(--accent-violet);
  }

  .ai-status.active .brain-icon .core { animation: pulse 1.5s infinite; }
  .ai-status.active .brain-icon .orbit { animation: rotate 3s linear infinite; }

  .brain-icon {
    position: relative;
    width: 20px;
    height: 20px;
  }

  .core {
    position: absolute;
    top: 6px;
    left: 6px;
    width: 8px;
    height: 8px;
    background: var(--accent-violet);
    border-radius: 50%;
    box-shadow: 0 0 10px var(--accent-violet);
  }

  .orbit {
    position: absolute;
    top: 0;
    left: 0;
    width: 20px;
    height: 20px;
    border: 1px dashed var(--accent-violet);
    border-radius: 50%;
  }

  @keyframes rotate { from { transform: rotate(0deg); } to { transform: rotate(360deg); } }
  @keyframes pulse { 0% { opacity: 0.5; transform: scale(0.8); } 50% { opacity: 1; transform: scale(1.2); } 100% { opacity: 0.5; transform: scale(0.8); } }

  .triage-container {
    display: grid;
    grid-template-columns: 1fr 300px;
    gap: 1.5rem;
  }

  .agent-timeline {
    padding: 2rem;
  }

  .timeline-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid var(--border-bright);
  }

  .incident-id {
    font-family: var(--font-mono);
    color: var(--text-muted);
    font-size: 0.8rem;
  }

  .steps-list {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
    position: relative;
  }

  .steps-list::before {
    content: '';
    position: absolute;
    top: 0;
    left: 95px;
    bottom: 0;
    width: 2px;
    background: var(--border-bright);
  }

  .step {
    display: flex;
    gap: 2rem;
    position: relative;
    opacity: 0.5;
    transition: all 0.3s ease;
  }

  .step.completed, .step.working { opacity: 1; }

  .step-meta {
    width: 80px;
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 0.5rem;
  }

  .timestamp {
    font-family: var(--font-mono);
    font-size: 0.75rem;
    color: var(--text-muted);
  }

  .status-indicator {
    width: 12px;
    height: 12px;
    border-radius: 50%;
    background: var(--bg-card);
    border: 2px solid var(--border-bright);
    z-index: 2;
    margin-right: -27px;
    background-color: var(--bg-abyssal);
  }

  .step.completed .status-indicator { background: var(--accent-green); border-color: var(--accent-green); box-shadow: 0 0 10px var(--accent-green); }
  .step.working .status-indicator { background: var(--accent-violet); border-color: var(--accent-violet); box-shadow: 0 0 10px var(--accent-violet); }
  .step.pending .status-indicator { border-style: dashed; }

  .step-content {
    flex: 1;
    background: rgba(255, 255, 255, 0.02);
    padding: 1rem;
    border-radius: 8px;
    border: 1px solid transparent;
  }

  .step.working .step-content {
    background: rgba(112, 0, 255, 0.05);
    border-color: rgba(112, 0, 255, 0.2);
  }

  .action {
    font-weight: 800;
    font-size: 0.9rem;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    margin-bottom: 0.25rem;
  }

  .detail {
    font-size: 0.95rem;
    color: var(--text-secondary);
  }

  .step.request .action { color: var(--accent-cyan); }
  .step.lookup .action { color: var(--accent-violet); }
  .step.validation .action { color: var(--accent-amber); }
  .step.verdict .action { color: var(--accent-green); }

  .loader-tiny {
    width: 16px;
    height: 16px;
    border: 2px solid var(--accent-violet);
    border-top-color: transparent;
    border-radius: 50%;
    animation: rotate 1s linear infinite;
    position: absolute;
    right: 1rem;
    top: 1.5rem;
  }

  .triage-sidebar {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
  }

  .telemetry-stack h3, .triage-settings h3 {
    font-size: 0.8rem;
    text-transform: uppercase;
    color: var(--text-muted);
    margin-bottom: 1rem;
  }

  .stack-items {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .stack-item {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 0.75rem;
    background: rgba(255, 255, 255, 0.03);
    border-radius: 8px;
    opacity: 0.5;
  }

  .stack-item.active { opacity: 1; border-left: 2px solid var(--accent-green); }
  .stack-item.pulse { opacity: 1; border-left: 2px solid var(--accent-violet); animation: bg-pulse 2s infinite; }

  @keyframes bg-pulse { 0% { background: rgba(112, 0, 255, 0.05); } 50% { background: rgba(112, 0, 255, 0.15); } 100% { background: rgba(112, 0, 255, 0.05); } }

  .item-info { display: flex; flex-direction: column; }
  .name { font-size: 0.85rem; font-weight: 600; }
  .status { font-size: 0.7rem; color: var(--text-muted); }

  .slider-group {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    margin-bottom: 1.5rem;
  }

  .slider-group label { font-size: 0.85rem; }
  .slider-group .value { font-weight: 700; color: var(--accent-violet); }

  .toggle-group {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .toggle {
    padding: 0.25rem 0.75rem;
    background: var(--accent-green);
    color: var(--bg-abyssal);
    font-weight: 800;
    border-radius: 4px;
    font-size: 0.75rem;
  }
</style>
