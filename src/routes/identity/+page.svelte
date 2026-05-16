<script lang="ts">
  let honeytokens = [
    { id: '1', name: 'svc_backup_adm', type: 'Active Directory User', status: 'Armed', hits: 0 },
    { id: '2', name: 'aws_prod_deployer', type: 'AWS IAM Key', status: 'Hit Detected', hits: 1 },
    { id: '3', name: 'db_root_access', type: 'SQL Connection String', status: 'Armed', hits: 0 }
  ];

  let alerts = [
    { id: 'a1', time: '11:02:14', type: 'LSASS Access', severity: 'Critical', source: 'FIN-LAPTOP-04', detail: 'Unauthorized process "mimikatz.exe" attempted to read LSASS memory.' },
    { id: 'a2', time: '11:05:22', type: 'Honeytoken Hit', severity: 'Critical', source: 'DC-01', detail: 'Authentication attempt with deception object "svc_backup_adm" from 10.0.0.15.' }
  ];
</script>

<div class="identity-page">
  <header class="page-header">
    <div class="header-left">
      <h1>Identity & Deception</h1>
      <p class="subtitle">ITDR, Honeytokens, and Memory Protection</p>
    </div>
    <div class="action-group">
      <button class="btn-secondary">Generate Honeytoken</button>
      <button class="btn-primary">Force Global Logout</button>
    </div>
  </header>

  <div class="identity-grid">
    <section class="deception-manager glass">
      <div class="section-header">
        <h2>Honeytoken Fleet</h2>
        <span class="count">{honeytokens.length} Active</span>
      </div>
      
      <table class="deception-table">
        <thead>
          <tr>
            <th>Name</th>
            <th>Type</th>
            <th>Status</th>
            <th>Hits</th>
          </tr>
        </thead>
        <tbody>
          {#each honeytokens as token}
            <tr class={token.hits > 0 ? 'hit' : ''}>
              <td class="name">{token.name}</td>
              <td class="type">{token.type}</td>
              <td>
                <span class="status-pill {token.status.toLowerCase().replace(' ', '-')}">
                  {token.status}
                </span>
              </td>
              <td class="hits">{token.hits}</td>
            </tr>
          {/each}
        </tbody>
      </table>
    </section>

    <section class="lsass-monitoring glass">
      <div class="section-header">
        <h2>Memory & LSASS Alerts</h2>
        <div class="shield-icon active">🛡️</div>
      </div>
      
      <div class="alert-list">
        {#each alerts as alert}
          <div class="alert-card {alert.severity.toLowerCase()}">
            <div class="alert-header">
              <span class="type">{alert.type}</span>
              <span class="time">{alert.time}</span>
            </div>
            <div class="alert-body">
              <div class="source">Source: <strong>{alert.source}</strong></div>
              <p class="detail">{alert.detail}</p>
            </div>
            <div class="alert-footer">
              <button class="btn-small">Investigate</button>
              <button class="btn-small danger">Kill Process</button>
            </div>
          </div>
        {/each}
      </div>
    </section>

    <section class="idp-status glass">
      <h2>IdP Integration Health</h2>
      <div class="idp-grid">
        <div class="idp-card">
          <div class="idp-header">
            <img src="https://img.icons8.com/color/48/azure-active-directory.png" alt="Azure AD" width="24" />
            <span>Azure AD</span>
          </div>
          <div class="sync-status online">Syncing</div>
        </div>
        <div class="idp-card">
          <div class="idp-header">
            <img src="https://img.icons8.com/color/48/okta.png" alt="Okta" width="24" />
            <span>Okta</span>
          </div>
          <div class="sync-status online">Syncing</div>
        </div>
        <div class="idp-card">
          <div class="idp-header">
            <span class="icon">📁</span>
            <span>Active Directory</span>
          </div>
          <div class="sync-status warning">Latency Detected</div>
        </div>
      </div>
    </section>
  </div>
</div>

<style>
  .identity-page {
    display: flex;
    flex-direction: column;
    gap: 2rem;
  }

  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .action-group {
    display: flex;
    gap: 1rem;
  }

  .btn-primary { background: var(--accent-violet); color: white; border: none; padding: 0.6rem 1.2rem; border-radius: 8px; font-weight: 700; cursor: pointer; }
  .btn-secondary { background: transparent; color: var(--text-primary); border: 1px solid var(--border-bright); padding: 0.6rem 1.2rem; border-radius: 8px; font-weight: 700; cursor: pointer; }

  .identity-grid {
    display: grid;
    grid-template-columns: 3fr 2fr;
    grid-template-rows: auto auto;
    gap: 1.5rem;
  }

  .deception-manager { grid-row: span 2; }

  .section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
  }

  .count { font-size: 0.8rem; color: var(--text-muted); background: rgba(255, 255, 255, 0.05); padding: 0.2rem 0.6rem; border-radius: 10px; }

  .deception-table {
    width: 100%;
    border-collapse: collapse;
    font-size: 0.9rem;
  }

  .deception-table th {
    text-align: left;
    padding: 1rem;
    color: var(--text-muted);
    font-weight: 600;
    text-transform: uppercase;
    font-size: 0.75rem;
    border-bottom: 1px solid var(--border-bright);
  }

  .deception-table td { padding: 1.2rem 1rem; border-bottom: 1px solid var(--border-dim); }

  .name { font-weight: 700; font-family: var(--font-mono); color: var(--accent-cyan); }
  .type { color: var(--text-secondary); }
  
  .status-pill {
    padding: 0.25rem 0.6rem;
    border-radius: 4px;
    font-size: 0.75rem;
    font-weight: 700;
  }

  .status-pill.armed { background: rgba(0, 242, 255, 0.1); color: var(--accent-cyan); border: 1px solid var(--accent-cyan); }
  .status-pill.hit-detected { background: rgba(255, 51, 102, 0.1); color: var(--accent-crimson); border: 1px solid var(--accent-crimson); animation: flash 1s infinite; }

  @keyframes flash { 0% { opacity: 1; } 50% { opacity: 0.5; } 100% { opacity: 1; } }

  .hits { font-weight: 800; text-align: center; }
  tr.hit { background: rgba(255, 51, 102, 0.05); }

  .alert-list { display: flex; flex-direction: column; gap: 1rem; }
  
  .alert-card {
    background: rgba(255, 255, 255, 0.02);
    border-radius: 8px;
    padding: 1rem;
    border-left: 4px solid var(--border-bright);
  }

  .alert-card.critical { border-left-color: var(--accent-crimson); background: rgba(255, 51, 102, 0.05); }

  .alert-header { display: flex; justify-content: space-between; margin-bottom: 0.5rem; }
  .alert-header .type { font-weight: 800; font-size: 0.8rem; text-transform: uppercase; color: var(--accent-crimson); }
  .alert-header .time { font-size: 0.75rem; color: var(--text-muted); font-family: var(--font-mono); }

  .alert-body .source { font-size: 0.85rem; margin-bottom: 0.5rem; }
  .alert-body .detail { font-size: 0.9rem; color: var(--text-secondary); line-height: 1.4; }

  .alert-footer { display: flex; gap: 0.5rem; margin-top: 1rem; }
  
  .btn-small {
    padding: 0.4rem 0.8rem;
    font-size: 0.75rem;
    font-weight: 700;
    background: rgba(255, 255, 255, 0.05);
    border: 1px solid var(--border-bright);
    color: var(--text-primary);
    border-radius: 4px;
    cursor: pointer;
  }

  .btn-small.danger { color: var(--accent-crimson); border-color: var(--accent-crimson); }

  .idp-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(140px, 1fr)); gap: 1rem; margin-top: 1rem; }
  
  .idp-card {
    background: rgba(255, 255, 255, 0.03);
    padding: 1rem;
    border-radius: 8px;
    display: flex;
    flex-direction: column;
    gap: 0.75rem;
  }

  .idp-header { display: flex; align-items: center; gap: 0.5rem; font-size: 0.85rem; font-weight: 600; }
  
  .sync-status { font-size: 0.7rem; font-weight: 700; padding: 0.2rem 0.5rem; border-radius: 10px; width: fit-content; }
  .sync-status.online { background: rgba(0, 255, 136, 0.1); color: var(--accent-green); }
  .sync-status.warning { background: rgba(255, 170, 0, 0.1); color: var(--accent-amber); }
</style>
