<script lang="ts">
  import { onMount } from 'svelte';
  import { walletStore } from '$lib/wallet.svelte';
  import { Transaction } from '@mysten/sui/transactions';
  
  // Mock State
  let enrollmentToken: string | null = $state(null);
  let isGenerating = $state(false);
  
  let endpoints = [
    { id: 'hash_win10_dev_01', os: 'Windows 10', ip: '192.168.1.105', status: 'Active', lastSync: 'Just now' },
    { id: 'hash_macbook_pro_m2', os: 'macOS 14.1', ip: '10.0.0.52', status: 'Active', lastSync: '2 min ago' },
    { id: 'hash_ubuntu_srv_99', os: 'Ubuntu 22.04', ip: '172.16.0.4', status: 'Isolated', lastSync: '1 hr ago' },
  ];

  async function generateToken() {
    if (!walletStore.connectedAccount) {
      alert("Please connect your Sui Wallet first using the button in the top right.");
      return;
    }

    isGenerating = true;
    try {
      const tx = new Transaction();
      
      // Placeholder IDs for the actual deployed contract
      const PACKAGE_ID = "0x0000000000000000000000000000000000000000000000000000000000000000"; 
      const ADMIN_CAP_ID = "0x0000000000000000000000000000000000000000000000000000000000000000";
      
      // Simulate backend values that would be used to mint the identity
      const simulatedEndpointId = "hash_bulk_deploy_" + Math.floor(Math.random() * 1000);
      const domain = "thorium-xdr.local";
      const simulatedPubKey = "ed25519_pub_mock";

      tx.moveCall({
        target: `${PACKAGE_ID}::registry::register_agent`,
        arguments: [
          tx.object(ADMIN_CAP_ID),
          tx.pure.string(simulatedEndpointId),
          tx.pure.string(domain),
          tx.pure.string(simulatedPubKey)
        ]
      });

      const feature = walletStore.connectedWallet.features['sui:signAndExecuteTransactionBlock'] 
                   || walletStore.connectedWallet.features['sui:signAndExecuteTransaction'];
                   
      if (!feature) throw new Error("Wallet does not support transaction signing.");

      console.log("Requesting wallet signature for contract call...");
      
      // Attempt to execute the transaction
      // (This will fail in the wallet because PACKAGE_ID is 0x0, which is expected during this UI design phase)
      await feature.signAndExecuteTransactionBlock({
        transactionBlock: tx,
        account: walletStore.connectedAccount,
        chain: 'sui:testnet'
      });

      enrollmentToken = 'th_env_' + Math.random().toString(36).substring(2, 15) + Math.random().toString(36).substring(2, 15);
      
    } catch (e: any) {
      console.error("Transaction Error / Simulation Error:", e);
      alert(`Wallet interaction triggered!\n\n(It failed because the Package ID is mocked: ${e.message})\n\nGenerating a mock UI token anyway.`);
      enrollmentToken = 'th_env_mock_' + Math.random().toString(36).substring(2, 15);
    } finally {
      isGenerating = false;
    }
  }

  function copyToken() {
    if (enrollmentToken) {
      navigator.clipboard.writeText(enrollmentToken);
      // You'd typically show a toast notification here
      alert("Token copied to clipboard!");
    }
  }
</script>

<div class="endpoints-container">
  <header class="page-header">
    <div>
      <h1>Endpoint Management</h1>
      <p class="subtitle">Manage enrolled devices and provisioning tokens</p>
    </div>
    <div class="stats glass">
      <div class="stat">
        <span class="label">Total Agents</span>
        <span class="value">{endpoints.length}</span>
      </div>
      <div class="stat">
        <span class="label">Isolated</span>
        <span class="value warning">1</span>
      </div>
    </div>
  </header>

  <div class="main-content">
    <section class="enrollment-panel glass">
      <div class="panel-header">
        <h2>Zero-Touch Bulk Enrollment</h2>
        <span class="badge">MDM Ready</span>
      </div>
      <p class="description">
        Generate a scoped enrollment token to deploy the Thorium Agent across your enterprise without manual user intervention. Tokens are bound to your Sui Identity.
      </p>

      <div class="token-action">
        {#if enrollmentToken}
          <div class="token-display">
            <code>{enrollmentToken}</code>
            <button class="btn-copy" on:click={copyToken}>
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>
            </button>
          </div>
          <div class="deployment-instructions">
            <h4>Deployment Script (PowerShell / Bash)</h4>
            <pre><code>thorium-agent --enrollment-token {enrollmentToken}</code></pre>
          </div>
        {:else}
          <button class="btn-generate" on:click={generateToken} disabled={isGenerating}>
            {#if isGenerating}
              <span class="loader"></span> Generating...
            {:else}
              Generate MDM Token
            {/if}
          </button>
        {/if}
      </div>
    </section>

    <section class="endpoints-list glass">
      <h2>Active Agents</h2>
      <div class="table-container">
        <table>
          <thead>
            <tr>
              <th>Endpoint ID</th>
              <th>OS</th>
              <th>IP Address</th>
              <th>Status</th>
              <th>Last Sync</th>
              <th>Actions</th>
            </tr>
          </thead>
          <tbody>
            {#each endpoints as ep}
              <tr>
                <td class="font-mono">{ep.id}</td>
                <td>{ep.os}</td>
                <td>{ep.ip}</td>
                <td>
                  <span class="status-badge {ep.status.toLowerCase()}">{ep.status}</span>
                </td>
                <td class="text-muted">{ep.lastSync}</td>
                <td>
                  <button class="btn-text">View</button>
                </td>
              </tr>
            {/each}
          </tbody>
        </table>
      </div>
    </section>
  </div>
</div>

<style>
  .endpoints-container {
    display: flex;
    flex-direction: column;
    gap: 2rem;
  }

  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  h1 {
    font-size: 2rem;
    margin: 0 0 0.5rem 0;
    font-weight: 600;
  }

  .subtitle {
    color: var(--text-secondary);
    margin: 0;
  }

  .stats {
    display: flex;
    gap: 2rem;
    padding: 1rem 2rem;
    border-radius: 12px;
  }

  .stat {
    display: flex;
    flex-direction: column;
    gap: 0.25rem;
  }

  .label {
    font-size: 0.85rem;
    color: var(--text-secondary);
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .value {
    font-size: 1.5rem;
    font-weight: 700;
    color: var(--text-primary);
  }

  .value.warning {
    color: var(--accent-orange, #ff9900);
  }

  .main-content {
    display: grid;
    grid-template-columns: 1fr;
    gap: 2rem;
  }

  .enrollment-panel, .endpoints-list {
    padding: 2rem;
    border-radius: 16px;
  }

  .panel-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
  }

  h2 {
    font-size: 1.25rem;
    margin: 0;
    font-weight: 600;
  }

  .badge {
    background: rgba(0, 255, 136, 0.1);
    color: #00ff88;
    padding: 0.25rem 0.75rem;
    border-radius: 12px;
    font-size: 0.8rem;
    font-weight: 600;
  }

  .description {
    color: var(--text-secondary);
    line-height: 1.6;
    margin-bottom: 2rem;
    max-width: 800px;
  }

  .token-action {
    display: flex;
    flex-direction: column;
    gap: 1.5rem;
  }

  .btn-generate {
    align-self: flex-start;
    background: linear-gradient(135deg, var(--accent-cyan), var(--accent-violet));
    border: none;
    padding: 0.8rem 1.5rem;
    border-radius: 8px;
    color: white;
    font-weight: 600;
    font-size: 1rem;
    cursor: pointer;
    transition: transform 0.2s, box-shadow 0.2s;
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .btn-generate:hover:not(:disabled) {
    transform: translateY(-2px);
    box-shadow: 0 4px 15px rgba(0, 255, 136, 0.3);
  }

  .btn-generate:disabled {
    opacity: 0.7;
    cursor: not-allowed;
  }

  .loader {
    width: 16px;
    height: 16px;
    border: 2px solid rgba(255,255,255,0.3);
    border-radius: 50%;
    border-top-color: white;
    animation: spin 1s linear infinite;
  }

  @keyframes spin {
    to { transform: rotate(360deg); }
  }

  .token-display {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    background: rgba(0,0,0,0.4);
    padding: 1rem;
    border-radius: 8px;
    border: 1px solid rgba(255,255,255,0.1);
    width: fit-content;
  }

  .token-display code {
    font-family: monospace;
    font-size: 1.1rem;
    color: var(--accent-cyan);
    letter-spacing: 0.05em;
  }

  .btn-copy {
    background: transparent;
    border: none;
    color: var(--text-secondary);
    cursor: pointer;
    padding: 0.25rem;
    border-radius: 4px;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: color 0.2s, background 0.2s;
  }

  .btn-copy:hover {
    color: white;
    background: rgba(255,255,255,0.1);
  }

  .deployment-instructions h4 {
    margin: 0 0 0.5rem 0;
    color: var(--text-secondary);
    font-size: 0.9rem;
  }

  .deployment-instructions pre {
    margin: 0;
    background: rgba(0,0,0,0.2);
    padding: 1rem;
    border-radius: 8px;
    border-left: 3px solid var(--accent-violet);
  }

  .deployment-instructions code {
    font-family: monospace;
    color: var(--text-primary);
  }

  /* Table Styles */
  .table-container {
    margin-top: 1.5rem;
    overflow-x: auto;
  }

  table {
    width: 100%;
    border-collapse: collapse;
    text-align: left;
  }

  th {
    padding: 1rem;
    color: var(--text-secondary);
    font-weight: 500;
    font-size: 0.9rem;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  }

  td {
    padding: 1rem;
    border-bottom: 1px solid rgba(255, 255, 255, 0.05);
    font-size: 0.95rem;
  }

  tr:last-child td {
    border-bottom: none;
  }

  .font-mono {
    font-family: monospace;
    color: var(--text-secondary);
  }

  .text-muted {
    color: var(--text-secondary);
  }

  .status-badge {
    padding: 0.25rem 0.5rem;
    border-radius: 4px;
    font-size: 0.8rem;
    font-weight: 600;
    text-transform: uppercase;
  }

  .status-badge.active {
    background: rgba(0, 255, 136, 0.1);
    color: #00ff88;
  }

  .status-badge.isolated {
    background: rgba(255, 51, 102, 0.1);
    color: #ff3366;
  }

  .btn-text {
    background: none;
    border: none;
    color: var(--accent-cyan);
    cursor: pointer;
    font-weight: 500;
    transition: text-shadow 0.2s;
  }

  .btn-text:hover {
    text-shadow: 0 0 8px rgba(0, 255, 136, 0.5);
  }
</style>
