<script lang="ts">
  import StatCard from '$lib/components/StatCard.svelte';
</script>

<div class="dashboard">
  <header class="dashboard-header">
    <div class="header-content">
      <h1>Security Overview</h1>
      <p class="subtitle">Real-time telemetry and autonomous triage status</p>
    </div>
    <div class="time-range glass">
      <span class="label">Time Range:</span>
      <select>
        <option>Last 24 Hours</option>
        <option>Last 7 Days</option>
        <option>Last 30 Days</option>
      </select>
    </div>
  </header>

  <section class="stats-grid">
    <StatCard 
      title="Active Storylines" 
      value="12" 
      trend="+2" 
      trendType="negative" 
      accent="var(--accent-cyan)" 
    />
    <StatCard 
      title="AI Triage Efficiency" 
      value="94.2%" 
      trend="+5.1%" 
      trendType="positive" 
      accent="var(--accent-violet)" 
    />
    <StatCard 
      title="Disruptions Executed" 
      value="1,204" 
      trend="-12%" 
      trendType="neutral" 
      accent="var(--accent-green)" 
    />
    <StatCard 
      title="Deception Hits" 
      value="3" 
      trend="Critical" 
      trendType="negative" 
      accent="var(--accent-amber)" 
    />
  </section>

  <div class="main-grid">
    <section class="storyline-reconstruction glass">
      <div class="section-header">
        <h2>Live Storyline Correlation</h2>
        <button class="btn-text">View All</button>
      </div>
      <div class="graph-placeholder">
        <div class="node-network">
          <!-- Mocking a graph visual -->
          <div class="node pulse cyan" style="top: 30%; left: 20%;"></div>
          <div class="node pulse violet" style="top: 50%; left: 40%;"></div>
          <div class="node pulse amber" style="top: 40%; left: 70%;"></div>
          <svg class="connections">
            <line x1="20%" y1="30%" x2="40%" y2="50%" stroke="var(--accent-cyan)" stroke-dasharray="4" />
            <line x1="40%" y1="50%" x2="70%" y2="40%" stroke="var(--accent-violet)" stroke-dasharray="4" />
          </svg>
        </div>
        <div class="graph-info">
          <span class="info-label">Current Blast Radius:</span>
          <span class="info-value glow-cyan">3 Endpoints, 1 Cloud Identity</span>
        </div>
      </div>
    </section>

    <section class="ai-triage-log glass">
      <div class="section-header">
        <h2>Recursive AI Logs</h2>
        <div class="status-badge processing">AI Active</div>
      </div>
      <div class="log-entries">
        <div class="log-entry">
          <div class="time">10:24:02</div>
          <div class="content">
            <span class="source">[AUTH]</span> New login from <span class="highlight">Sofia, BG</span> (ISP: Vivacom)
          </div>
        </div>
        <div class="log-entry recursive">
          <div class="time">10:24:05</div>
          <div class="content">
            <span class="source">[AI]</span> Executing loop: <span class="cmd">check_calendar(user="j.doe")</span>
          </div>
        </div>
        <div class="log-entry recursive">
          <div class="time">10:24:08</div>
          <div class="content">
            <span class="source">[AI]</span> Result: Confirmed "Business Trip to Sofia" in O365.
          </div>
        </div>
        <div class="log-entry success">
          <div class="time">10:24:10</div>
          <div class="content">
            <span class="source">[AI]</span> Verdict: <span class="verdict">BENIGN (High Confidence)</span>
          </div>
        </div>
      </div>
    </section>
  </div>
</div>

<style>
  .dashboard {
    display: flex;
    flex-direction: column;
    gap: 2rem;
  }

  .dashboard-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
  }

  h1 {
    font-size: 2.5rem;
    margin-bottom: 0.25rem;
  }

  .subtitle {
    color: var(--text-secondary);
    font-size: 1rem;
  }

  .time-range {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding: 0.5rem 1rem;
  }

  .time-range select {
    background: transparent;
    border: none;
    color: var(--text-primary);
    font-family: var(--font-main);
    font-weight: 600;
    cursor: pointer;
    outline: none;
  }

  .stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
    gap: 1.5rem;
  }

  .main-grid {
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: 1.5rem;
  }

  .section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1.5rem;
  }

  .glass {
    padding: 1.5rem;
  }

  h2 {
    font-size: 1.25rem;
    color: var(--text-primary);
  }

  .btn-text {
    background: transparent;
    border: none;
    color: var(--accent-cyan);
    font-weight: 600;
    cursor: pointer;
    font-size: 0.9rem;
  }

  /* Graph Mockup */
  .graph-placeholder {
    height: 300px;
    background: rgba(0, 0, 0, 0.2);
    border-radius: 8px;
    position: relative;
    overflow: hidden;
    display: flex;
    flex-direction: column;
  }

  .node-network {
    flex: 1;
    position: relative;
  }

  .node {
    position: absolute;
    width: 12px;
    height: 12px;
    border-radius: 50%;
    z-index: 2;
  }

  .node.cyan { background: var(--accent-cyan); box-shadow: 0 0 15px var(--accent-cyan); }
  .node.violet { background: var(--accent-violet); box-shadow: 0 0 15px var(--accent-violet); }
  .node.amber { background: var(--accent-amber); box-shadow: 0 0 15px var(--accent-amber); }

  .pulse::after {
    content: '';
    position: absolute;
    top: -4px;
    left: -4px;
    right: -4px;
    bottom: -4px;
    border-radius: 50%;
    border: 1px solid currentColor;
    animation: pulse 2s infinite;
  }

  @keyframes pulse {
    0% { transform: scale(1); opacity: 1; }
    100% { transform: scale(3); opacity: 0; }
  }

  .connections {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    z-index: 1;
  }

  .graph-info {
    padding: 1rem;
    background: rgba(0, 0, 0, 0.4);
    display: flex;
    gap: 0.5rem;
    font-size: 0.9rem;
    font-weight: 500;
  }

  .info-label { color: var(--text-secondary); }

  /* AI Log */
  .log-entries {
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
    font-family: var(--font-mono);
    font-size: 0.8rem;
  }

  .log-entry {
    display: flex;
    gap: 1rem;
    padding: 0.5rem;
    border-radius: 4px;
    background: rgba(255, 255, 255, 0.02);
  }

  .time { color: var(--text-muted); min-width: 60px; }
  .source { font-weight: 700; color: var(--text-secondary); }
  .highlight { color: var(--accent-cyan); font-weight: 600; }
  .cmd { color: var(--accent-violet); }
  
  .recursive { border-left: 2px solid var(--accent-violet); padding-left: 1rem; }
  .success { border-left: 2px solid var(--accent-green); background: rgba(0, 255, 136, 0.05); }
  .verdict { color: var(--accent-green); font-weight: 800; }

  .status-badge {
    padding: 0.25rem 0.75rem;
    border-radius: 20px;
    font-size: 0.7rem;
    font-weight: 700;
    text-transform: uppercase;
  }

  .status-badge.processing {
    background: rgba(112, 0, 255, 0.2);
    color: var(--accent-violet);
    border: 1px solid var(--accent-violet);
  }
</style>
