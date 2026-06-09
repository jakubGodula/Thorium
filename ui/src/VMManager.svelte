<script lang="ts">
  import { onMount, onDestroy } from 'svelte';

  interface VM {
    name: string;
    status: 'running' | 'stopped' | 'not_created' | 'provisioning' | 'unknown';
    host_port: number;
    template: string;
    ip_address?: string;
    hostname?: string;
    agent_status?: string;
    fingerprint?: string;
    agentStatus?: string;
    agentLogs?: string;
    owner_name?: string;
    machine_type?: string;
    hardware?: any;
    showLogs?: boolean;
    showHardware?: boolean;
    logInterval?: ReturnType<typeof setInterval>;
  }

  let vms: VM[] = [];
  let pollInterval: ReturnType<typeof setInterval>;
  let showCreateModal = false;
  let creating = false;
  let createError = '';

  // Form state
  let newVmName = '';
  let newVmPort = 9091;
  let newVmOwner = 'Jakub';
  let newVmType = 'Workstation';

  const fetchVms = async () => {
    try {
      const res = await fetch('/api/vm/lista');
      if (res.ok) {
        const data = await res.json();
        // Merge with existing to preserve showLogs and showHardware state
        vms = (Array.isArray(data) ? data : []).map((v: VM) => {
          const existing = vms.find(e => e.name === v.name);
          return { 
            ...v, 
            showLogs: existing?.showLogs ?? false, 
            showHardware: existing?.showHardware ?? false,
            agentLogs: existing?.agentLogs ?? '',
            agentStatus: v.agent_status && v.agent_status !== 'offline' ? v.agent_status : existing?.agentStatus
          };
        });
      }
    } catch (_) {}
  };

  const createVm = async () => {
    if (!newVmName.trim()) { createError = 'Podaj nazwę VM'; return; }
    if (newVmPort < 1024 || newVmPort > 65535) { createError = 'Port musi być między 1024 a 65535'; return; }
    creating = true;
    createError = '';
    try {
      const res = await fetch('/api/vm/lista');
      const existing = await res.json().catch(() => []);
      if (existing.find((v: VM) => v.name === newVmName)) {
        createError = `VM '${newVmName}' już istnieje`; creating = false; return;
      }
      
      const r = await fetch('/api/vm/lista'); // trigger creation via RPC
      const rpcRes = await fetch('/api/rpc', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          jsonrpc: '2.0', method: 'vm_create',
          params: { name: newVmName, port: newVmPort, owner: newVmOwner, type: newVmType }, id: Date.now()
        })
      });
      
      showCreateModal = false;
      newVmName = '';
      await fetchVms();
    } catch (e) {
      createError = 'Błąd połączenia z agentem';
    } finally {
      creating = false;
    }
  };

  const vmAction = async (action: 'start' | 'stop' | 'usun', name: string) => {
    if (action === 'usun' && !confirm(`Usunąć VM '${name}'? Tej operacji nie można cofnąć.`)) return;
    try {
      await fetch(`/api/vm/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name })
      });
      if (action === 'usun') {
        vms = vms.filter(v => v.name !== name);
      } else {
        const vm = vms.find(v => v.name === name);
        if (vm) vm.status = action === 'start' ? 'provisioning' : 'stopped';
        vms = [...vms];
      }
      setTimeout(fetchVms, 2000);
    } catch (_) {}
  };

  const toggleLogs = async (vm: VM) => {
    vm.showLogs = !vm.showLogs;
    vms = [...vms];
    if (vm.showLogs) {
      await fetchAgentLogs(vm);
      vm.logInterval = setInterval(() => fetchAgentLogs(vm), 2000) as any;
    } else {
      if (vm.logInterval) clearInterval(vm.logInterval as any);
    }
  };

  const toggleHardware = (vm: VM) => {
    vm.showHardware = !vm.showHardware;
    vms = [...vms];
  };

  const fetchAgentLogs = async (vm: VM) => {
    try {
      const targetUrl = vm.ip_address 
        ? `http://[${vm.ip_address}]:9090/api/rpc`
        : `http://127.0.0.1:${vm.host_port}/api/rpc`;
      const res = await fetch(targetUrl, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ jsonrpc: '2.0', method: 'get_logs', params: {}, id: 1 })
      });
      if (res.ok) {
        const data = await res.json();
        vm.agentLogs = data.result?.logs ?? 'Brak logów';
        vm.agentStatus = data.result?.status;
      }
    } catch (_) {
      vm.agentLogs = `⚠️ Agent niedostępny na adresie ${vm.ip_address ?? '127.0.0.1'}`;
    }
    vms = [...vms];
  };

  const statusColor = (s: string) => {
    if (s === 'running') return '#10b981';
    if (s === 'stopped') return '#f59e0b';
    if (s === 'not_created') return '#6b7280';
    if (s === 'provisioning') return '#3b82f6';
    return '#94a3b8';
  };

  const statusLabel = (s: string) => ({
    running: '● Online',
    stopped: '◎ Stopped',
    not_created: '○ Not Created',
    provisioning: '⟳ Provisioning',
    unknown: '? Unknown',
  }[s] ?? s);

  onMount(() => {
    fetchVms();
    pollInterval = setInterval(fetchVms, 5000);
  });

  onDestroy(() => {
    clearInterval(pollInterval);
    vms.forEach(v => { if (v.logInterval) clearInterval(v.logInterval as any); });
  });
</script>

<div class="vm-manager">
  <!-- Header -->
  <div class="vm-header">
    <div class="vm-title">
      <span class="vm-icon">🖥️</span>
      <div>
        <h3>VM Fleet Manager</h3>
        <p class="vm-subtitle">Vagrant + KVM/libvirt • AlmaLinux 9</p>
      </div>
    </div>
    <button class="btn-create" on:click={() => showCreateModal = true}>
      <span>＋</span> New VM
    </button>
  </div>

  <!-- Empty state -->
  {#if vms.length === 0}
    <div class="empty-state">
      <div class="empty-icon">📦</div>
      <p>Brak maszyn wirtualnych</p>
      <p class="empty-sub">Kliknij "New VM" aby wdrożyć AlmaLinux 9 z agentem Thorium XDR</p>
    </div>
  {/if}

  <!-- VM Cards -->
  <div class="vm-grid">
    {#each vms as vm (vm.name)}
      <div class="vm-card" class:vm-running={vm.status === 'running'}>
        <div class="vm-card-header">
          <div style="display: flex; align-items: center;">
            <div class="vm-type-icon">
              {#if vm.machine_type === 'Workstation'}💻
              {:else if vm.machine_type === 'Server'}🖥️
              {:else if vm.machine_type === 'Network Device'}🔌
              {:else if vm.machine_type === 'Phone'}📱
              {:else if vm.machine_type === 'IoT'}💡
              {:else}⚙️
              {/if}
            </div>
            <div class="vm-info">
              <div class="vm-name">{vm.hostname || vm.name}</div>
              <div class="vm-template">{vm.template}</div>
            </div>
          </div>
          <div class="vm-status-badge" style="color: {statusColor(vm.status)}">
            {statusLabel(vm.status)}
          </div>
        </div>

        <div class="vm-card-body">
          <div class="vm-meta">
            <span class="meta-item">
              <span class="meta-label">IP Address</span>
              <code class="meta-value">{vm.ip_address ?? 'Brak'}</code>
            </span>
            <span class="meta-item">
              <span class="meta-label">Endpoint</span>
              <code class="meta-value">{vm.ip_address ? `[${vm.ip_address}]:9090` : `127.0.0.1:${vm.host_port}`}</code>
            </span>
            {#if vm.owner_name}
              <span class="meta-item">
                <span class="meta-label">Owner</span>
                <span class="meta-value">{vm.owner_name}</span>
              </span>
            {/if}
            {#if vm.machine_type}
              <span class="meta-item">
                <span class="meta-label">Device Type</span>
                <span class="meta-value">{vm.machine_type}</span>
              </span>
            {/if}
            {#if vm.agentStatus}
              <span class="meta-item">
                <span class="meta-label">XDR Status</span>
                <span class="meta-value agent-status" class:isolated={vm.agentStatus === 'Izolowany'}>
                  {vm.agentStatus}
                </span>
              </span>
            {/if}
          </div>
        </div>

        <!-- Log Viewer (expanded) -->
        {#if vm.showLogs}
          <div class="vm-logs-panel">
            <div class="logs-header">
              <span class="rpc-badge-sm">JSON-RPC 2.0</span>
              <span style="color: #64748b; font-size: 11px;">Live from {vm.ip_address ? `[${vm.ip_address}]:9090` : `port ${vm.host_port}`}</span>
            </div>
            <pre class="vm-log-pre">{vm.agentLogs || 'Ładowanie...'}</pre>
          </div>
        {/if}

        <!-- Hardware Viewer (expanded) -->
        {#if vm.showHardware}
          <div class="vm-logs-panel" style="border-top: 1px solid rgba(16, 185, 129, 0.2); padding: 12px; background: rgba(16, 185, 129, 0.02); display: flex; flex-direction: column; gap: 8px;">
            <div class="logs-header" style="margin-bottom: 8px; display: flex; justify-content: space-between; align-items: center;">
              <span class="rpc-badge-sm" style="background: rgba(16, 185, 129, 0.2); color: #10b981; border: 1px solid rgba(16, 185, 129, 0.4); padding: 2px 6px; border-radius: 4px; font-size: 10px; font-weight: 700;">Specs</span>
              <span style="color: #64748b; font-size: 11px;">Direct Motherboard hardware details</span>
            </div>
            
            {#if vm.hardware}
              <div style="display: flex; flex-direction: column; gap: 10px; font-size: 12px; max-height: 300px; overflow-y: auto; padding-right: 4px;">
                
                <div style="background: rgba(0,0,0,0.2); padding: 8px; border-radius: 6px; border: 1px solid rgba(255,255,255,0.03);">
                  <div style="color: #64748b; font-weight:600; font-size:10px; text-transform:uppercase; margin-bottom: 2px;">Operating System</div>
                  <div style="color: #e2e8f0; font-weight:500;">{vm.hardware.os_name} {vm.hardware.os_version}</div>
                  <div style="color: #475569; font-size:10px; font-family:monospace; margin-top:2px;">{vm.hardware.kernel}</div>
                </div>

                <div style="background: rgba(0,0,0,0.2); padding: 8px; border-radius: 6px; border: 1px solid rgba(255,255,255,0.03);">
                  <div style="color: #64748b; font-weight:600; font-size:10px; text-transform:uppercase; margin-bottom: 2px;">Processor (CPU)</div>
                  <div style="color: #e2e8f0; font-weight:500;">{vm.hardware.cpu?.model || 'Generic CPU'} ({vm.hardware.cpu?.cores || 1} Cores)</div>
                  <div style="color: #818cf8; font-size:10px; font-family:monospace; margin-top:2px; background: rgba(129, 140, 248, 0.08); padding: 1px 4px; border-radius: 3px; display: inline-block;">UID: {vm.hardware.cpu?.uid}</div>
                </div>

                <div style="background: rgba(0,0,0,0.2); padding: 8px; border-radius: 6px; border: 1px solid rgba(255,255,255,0.03);">
                  <div style="color: #64748b; font-weight:600; font-size:10px; text-transform:uppercase; margin-bottom: 2px;">Memory (RAM)</div>
                  <div style="color: #e2e8f0; font-weight:500;">{vm.hardware.ram?.formatted || '2.00 GB'}</div>
                  <div style="color: #818cf8; font-size:10px; font-family:monospace; margin-top:2px; background: rgba(129, 140, 248, 0.08); padding: 1px 4px; border-radius: 3px; display: inline-block;">UID: {vm.hardware.ram?.uid}</div>
                </div>

                <div style="background: rgba(0,0,0,0.2); padding: 8px; border-radius: 6px; border: 1px solid rgba(255,255,255,0.03);">
                  <div style="color: #64748b; font-weight:600; font-size:10px; text-transform:uppercase; margin-bottom: 4px;">Graphics (GPU)</div>
                  {#if vm.hardware.gpus && vm.hardware.gpus.length > 0}
                    {#each vm.hardware.gpus as gpu}
                      <div style="color: #e2e8f0; font-weight:500; text-overflow:ellipsis; overflow:hidden; white-space:nowrap;">{gpu.model}</div>
                      <div style="color: #818cf8; font-size:10px; font-family:monospace; margin-top:2px; background: rgba(129, 140, 248, 0.08); padding: 1px 4px; border-radius: 3px; display: inline-block;">UID: {gpu.uid}</div>
                    {/each}
                  {:else}
                    <div style="color: #64748b;">No GPU detected</div>
                  {/if}
                </div>

                <div style="background: rgba(0,0,0,0.2); padding: 8px; border-radius: 6px; border: 1px solid rgba(255,255,255,0.03);">
                  <div style="color: #64748b; font-weight:600; font-size:10px; text-transform:uppercase; margin-bottom: 6px;">Storage Drives</div>
                  {#if vm.hardware.drives && vm.hardware.drives.length > 0}
                    {#each vm.hardware.drives as disk}
                      <div style="margin-bottom: 6px; border-bottom: 1px solid rgba(255,255,255,0.03); padding-bottom: 4px;">
                        <div style="color:#e2e8f0; font-weight:500;">{disk.name} ({disk.formatted})</div>
                        <div style="color:#818cf8; font-family:monospace; font-size:10px; background: rgba(129, 140, 248, 0.08); padding: 1px 4px; border-radius: 3px; display: inline-block; margin-top:2px;">UID: {disk.uid}</div>
                      </div>
                    {/each}
                  {:else}
                    <div style="color: #64748b;">No disks detected</div>
                  {/if}
                </div>

                <div style="background: rgba(0,0,0,0.2); padding: 8px; border-radius: 6px; border: 1px solid rgba(255,255,255,0.03);">
                  <div style="color: #64748b; font-weight:600; font-size:10px; text-transform:uppercase; margin-bottom: 6px;">Network Interfaces</div>
                  {#if vm.hardware.network_cards && vm.hardware.network_cards.length > 0}
                    {#each vm.hardware.network_cards as net}
                      <div style="margin-bottom: 6px; border-bottom: 1px solid rgba(255,255,255,0.03); padding-bottom: 4px;">
                        <div style="color:#e2e8f0; font-weight:500;">{net.name} (MAC: {net.mac})</div>
                        <div style="color:#818cf8; font-family:monospace; font-size:10px; background: rgba(129, 140, 248, 0.08); padding: 1px 4px; border-radius: 3px; display: inline-block; margin-top:2px;">UID: {net.uid}</div>
                      </div>
                    {/each}
                  {:else}
                    <div style="color: #64748b;">No network interfaces</div>
                  {/if}
                </div>

                <div style="background: rgba(0,0,0,0.2); padding: 8px; border-radius: 6px; border: 1px solid rgba(255,255,255,0.03);">
                  <div style="color: #64748b; font-weight:600; font-size:10px; text-transform:uppercase; margin-bottom: 6px;">Peripherals, Printers & IoT Sensors</div>
                  {#if (vm.hardware.peripherals && vm.hardware.peripherals.length > 0) || (vm.hardware.other && vm.hardware.other.length > 0)}
                    {#if vm.hardware.peripherals}
                      {#each vm.hardware.peripherals as dev}
                        <div style="display: flex; flex-direction: column; gap: 2px; margin-bottom: 6px; border-bottom: 1px solid rgba(255,255,255,0.02); padding-bottom: 4px;">
                          <div style="display: flex; justify-content: space-between; align-items: center; font-size: 11px;">
                            <span style="color:#cbd5e1; font-weight: 500; text-overflow:ellipsis; overflow:hidden; white-space:nowrap; max-width: 140px;" title={dev.name}>{dev.name}</span>
                            <span style="color:#38bdf8; font-size: 9px; background: rgba(56, 189, 248, 0.1); padding: 1px 4px; border-radius: 3px;">{dev.category || dev.type}</span>
                          </div>
                          <div style="display: flex; justify-content: space-between; align-items: center; font-size: 9px; color: #64748b;">
                            <span>Addr: {dev.address || 'N/A'}</span>
                            <span>{dev.uid}</span>
                          </div>
                        </div>
                      {/each}
                    {/if}
                    {#if vm.hardware.other}
                      {#each vm.hardware.other as dev}
                        <div style="display: flex; flex-direction: column; gap: 2px; margin-bottom: 6px; border-bottom: 1px solid rgba(255,255,255,0.02); padding-bottom: 4px;">
                          <div style="display: flex; justify-content: space-between; align-items: center; font-size: 11px;">
                            <span style="color:#cbd5e1; font-weight: 500; text-overflow:ellipsis; overflow:hidden; white-space:nowrap; max-width: 140px;" title={dev.name}>{dev.name}</span>
                            <span style="color:#64748b; font-size: 9px; background: rgba(255, 255, 255, 0.05); padding: 1px 4px; border-radius: 3px;">PCI Slot</span>
                          </div>
                          <div style="display: flex; justify-content: space-between; align-items: center; font-size: 9px; color: #64748b;">
                            <span>Motherboard</span>
                            <span>{dev.uid}</span>
                          </div>
                        </div>
                      {/each}
                    {/if}
                  {:else}
                    <div style="color: #64748b;">No external peripherals detected</div>
                  {/if}
                </div>

              </div>
            {:else}
              <div style="color: #94a3b8; text-align: center; padding: 12px; font-size: 12px;">
                ⚠️ Hardware details not retrieved or VM not running.
              </div>
            {/if}
          </div>
        {/if}

        <div class="vm-card-actions">
          {#if vm.status === 'running'}
            <button class="action-btn action-logs" on:click={() => toggleLogs(vm)}>
              {vm.showLogs ? '▲ Logs' : '▼ Logs'}
            </button>
            <button class="action-btn action-logs" style="border-color: rgba(16, 185, 129, 0.3); color: #10b981;" on:click={() => toggleHardware(vm)}>
              {vm.showHardware ? '▲ Hardware' : '▼ Hardware'}
            </button>
            <button class="action-btn action-stop" on:click={() => vmAction('stop', vm.name)}>
              ⏹ Stop
            </button>
          {:else if vm.status === 'stopped' || vm.status === 'not_created'}
            <button class="action-btn action-start" on:click={() => vmAction('start', vm.name)}>
              ▶ Start
            </button>
          {:else}
            <button class="action-btn" disabled style="opacity:0.5; cursor:default;">
              ⟳ Working...
            </button>
          {/if}
          <button class="action-btn action-delete" on:click={() => vmAction('usun', vm.name)}>
            🗑 Delete
          </button>
        </div>
      </div>
    {/each}
  </div>
</div>

<!-- Create VM Modal -->
{#if showCreateModal}
  <!-- svelte-ignore a11y-click-events-have-key-events -->
  <!-- svelte-ignore a11y-no-static-element-interactions -->
  <div class="modal-backdrop" on:click={() => showCreateModal = false}>
    <div class="modal-box" on:click|stopPropagation>
      <div class="modal-hdr">
        <h3>🚀 New Virtual Machine</h3>
        <button class="close-btn" on:click={() => showCreateModal = false}>✕</button>
      </div>

      <div class="create-form">
        <div class="form-row">
          <div class="form-group">
            <label for="vm-name">VM Name</label>
            <input id="vm-name" type="text" placeholder="np. alma9-node-01"
              bind:value={newVmName} class="form-input" />
          </div>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label for="vm-port">Agent Host Port</label>
            <input id="vm-port" type="number" min="1024" max="65535"
              bind:value={newVmPort} class="form-input" />
          </div>
        </div>

        <div class="form-row" style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
          <div class="form-group">
            <label for="vm-owner">Owner Name</label>
            <input id="vm-owner" type="text" placeholder="np. Jakub"
              bind:value={newVmOwner} class="form-input" />
          </div>
          <div class="form-group">
            <label for="vm-type">Machine Type</label>
            <select id="vm-type" bind:value={newVmType} class="form-input" style="background: #0f172a; color: #fff;">
              <option value="Workstation">💻 Workstation</option>
              <option value="Server">🖥️ Server</option>
              <option value="Network Device">🔌 Network Device</option>
              <option value="Phone">📱 Phone</option>
              <option value="IoT">💡 IoT</option>
            </select>
          </div>
        </div>

        <div class="template-info">
          <div class="template-badge">
            <span>🐧</span>
            <div>
              <strong>AlmaLinux 9</strong>
              <span class="tmpl-sub">KVM / libvirt • 2 CPU • 2 GB RAM</span>
            </div>
          </div>
          <ul class="provision-list">
            <li>✅ Auto-install Thorium XDR Agent</li>
            <li>✅ systemd service + auto-start</li>
            <li>✅ Sui contract binding</li>
            <li>✅ Agent API on port {newVmPort}</li>
          </ul>
        </div>

        {#if createError}
          <div class="create-error">{createError}</div>
        {/if}

        <button class="btn-create-full" on:click={createVm} disabled={creating}>
          {#if creating}⟳ Provisioning VM...{:else}🚀 Create & Deploy{/if}
        </button>
        <p class="modal-note">Vagrant + libvirt uruchomi maszynę w tle. Provisioning zajmuje ~3-5 min.</p>
      </div>
    </div>
  </div>
{/if}

<style>
  .vm-manager {
    display: flex;
    flex-direction: column;
    gap: 16px;
    height: 100%;
  }

  .vm-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding-bottom: 12px;
    border-bottom: 1px solid rgba(255,255,255,0.06);
  }

  .vm-title {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .vm-icon { font-size: 28px; }

  .vm-title h3 {
    margin: 0;
    font-size: 16px;
    font-weight: 600;
    color: #f1f5f9;
  }

  .vm-subtitle {
    margin: 0;
    font-size: 11px;
    color: #64748b;
  }

  .btn-create {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 8px 16px;
    background: linear-gradient(135deg, #3b82f6, #6366f1);
    border: none;
    border-radius: 8px;
    color: white;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .btn-create:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 16px rgba(99, 102, 241, 0.4);
  }

  .empty-state {
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    padding: 48px 24px;
    color: #475569;
    text-align: center;
  }

  .empty-icon { font-size: 40px; margin-bottom: 12px; }
  .empty-state p { margin: 4px 0; font-size: 14px; }
  .empty-sub { font-size: 12px; color: #374151; }

  .vm-grid {
    display: flex;
    flex-direction: column;
    gap: 12px;
    overflow-y: auto;
  }

  .vm-card {
    background: rgba(255,255,255,0.04);
    border: 1px solid rgba(255,255,255,0.08);
    border-radius: 12px;
    overflow: hidden;
    transition: border-color 0.2s;
  }

  .vm-card.vm-running {
    border-color: rgba(16, 185, 129, 0.3);
    background: rgba(16, 185, 129, 0.04);
  }

  .vm-card-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 14px 16px 10px;
  }

  .vm-type-icon {
    font-size: 20px;
    margin-right: 12px;
    background: rgba(255,255,255,0.06);
    width: 36px;
    height: 36px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    border: 1px solid rgba(255,255,255,0.08);
  }

  .vm-name {
    font-size: 14px;
    font-weight: 700;
    color: #e2e8f0;
    font-family: 'JetBrains Mono', monospace;
  }

  .vm-template {
    font-size: 11px;
    color: #64748b;
    margin-top: 2px;
  }

  .vm-status-badge {
    font-size: 11px;
    font-weight: 600;
    white-space: nowrap;
  }

  .vm-card-body {
    padding: 0 16px 12px;
  }

  .vm-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
  }

  .meta-item {
    display: flex;
    flex-direction: column;
    gap: 2px;
  }

  .meta-label {
    font-size: 10px;
    color: #475569;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .meta-value {
    font-size: 12px;
    color: #94a3b8;
    font-family: 'JetBrains Mono', monospace;
  }

  .agent-status.isolated {
    color: #ef4444 !important;
  }

  .vm-logs-panel {
    margin: 0 16px 12px;
    background: rgba(0,0,0,0.4);
    border-radius: 8px;
    border: 1px solid rgba(255,255,255,0.06);
    overflow: hidden;
  }

  .logs-header {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 6px 12px;
    border-bottom: 1px solid rgba(255,255,255,0.05);
  }

  .rpc-badge-sm {
    font-size: 10px;
    background: rgba(16, 185, 129, 0.15);
    color: #10b981;
    border: 1px solid rgba(16, 185, 129, 0.3);
    border-radius: 4px;
    padding: 1px 6px;
    font-weight: 600;
  }

  .vm-log-pre {
    margin: 0;
    padding: 10px 12px;
    font-family: 'JetBrains Mono', 'Courier New', monospace;
    font-size: 10px;
    color: #7dd3fc;
    white-space: pre-wrap;
    word-break: break-all;
    max-height: 200px;
    overflow-y: auto;
    line-height: 1.6;
  }

  .vm-card-actions {
    display: flex;
    gap: 8px;
    padding: 10px 16px 14px;
    border-top: 1px solid rgba(255,255,255,0.05);
  }

  .action-btn {
    padding: 5px 12px;
    border-radius: 6px;
    border: 1px solid rgba(255,255,255,0.1);
    font-size: 12px;
    cursor: pointer;
    transition: all 0.15s;
    background: transparent;
    color: #94a3b8;
  }

  .action-btn:hover { transform: translateY(-1px); }
  .action-start { border-color: rgba(16, 185, 129, 0.4); color: #10b981; }
  .action-start:hover { background: rgba(16, 185, 129, 0.1); }
  .action-stop { border-color: rgba(245, 158, 11, 0.4); color: #f59e0b; }
  .action-stop:hover { background: rgba(245, 158, 11, 0.1); }
  .action-logs { border-color: rgba(59, 130, 246, 0.4); color: #3b82f6; }
  .action-logs:hover { background: rgba(59, 130, 246, 0.1); }
  .action-delete { border-color: rgba(239, 68, 68, 0.3); color: #ef4444; margin-left: auto; }
  .action-delete:hover { background: rgba(239, 68, 68, 0.1); }

  /* Modal */
  .modal-backdrop {
    position: fixed; inset: 0;
    background: rgba(0,0,0,0.7);
    backdrop-filter: blur(4px);
    z-index: 1000;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .modal-box {
    background: linear-gradient(135deg, #0f172a, #1e1b4b);
    border: 1px solid rgba(255,255,255,0.12);
    border-radius: 16px;
    width: 440px;
    max-width: 95vw;
    overflow: hidden;
  }

  .modal-hdr {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 20px 24px 16px;
    border-bottom: 1px solid rgba(255,255,255,0.08);
  }

  .modal-hdr h3 {
    margin: 0;
    font-size: 16px;
    font-weight: 700;
    color: #f1f5f9;
  }

  .close-btn {
    background: none;
    border: none;
    color: #64748b;
    font-size: 18px;
    cursor: pointer;
    padding: 0;
    line-height: 1;
  }

  .close-btn:hover { color: #f1f5f9; }

  .create-form {
    padding: 20px 24px 24px;
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .form-row { display: flex; gap: 12px; }
  .form-group { flex: 1; display: flex; flex-direction: column; gap: 6px; }
  .form-group label { font-size: 12px; color: #94a3b8; font-weight: 600; }

  .form-input {
    background: rgba(255,255,255,0.06);
    border: 1px solid rgba(255,255,255,0.12);
    border-radius: 8px;
    padding: 8px 12px;
    color: #e2e8f0;
    font-size: 13px;
    font-family: 'JetBrains Mono', monospace;
    outline: none;
    transition: border-color 0.2s;
  }

  .form-input:focus { border-color: #3b82f6; }

  .template-info {
    background: rgba(59, 130, 246, 0.06);
    border: 1px solid rgba(59, 130, 246, 0.2);
    border-radius: 10px;
    padding: 14px;
  }

  .template-badge {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 10px;
    font-size: 18px;
  }

  .template-badge strong { font-size: 14px; color: #e2e8f0; display: block; }

  .tmpl-sub { font-size: 11px; color: #64748b; }

  .provision-list {
    margin: 0;
    padding: 0 0 0 4px;
    list-style: none;
    display: flex;
    flex-direction: column;
    gap: 4px;
  }

  .provision-list li { font-size: 12px; color: #94a3b8; }

  .create-error {
    background: rgba(239, 68, 68, 0.1);
    border: 1px solid rgba(239, 68, 68, 0.3);
    border-radius: 8px;
    padding: 8px 12px;
    font-size: 12px;
    color: #ef4444;
  }

  .btn-create-full {
    width: 100%;
    padding: 12px;
    background: linear-gradient(135deg, #3b82f6, #6366f1);
    border: none;
    border-radius: 10px;
    color: white;
    font-size: 14px;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.2s;
  }

  .btn-create-full:hover:not(:disabled) {
    transform: translateY(-1px);
    box-shadow: 0 6px 20px rgba(99, 102, 241, 0.4);
  }

  .btn-create-full:disabled { opacity: 0.6; cursor: default; }

  .modal-note {
    margin: 0;
    font-size: 11px;
    color: #475569;
    text-align: center;
  }
</style>
