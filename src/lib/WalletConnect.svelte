<script lang="ts">
  import { onMount, onDestroy } from 'svelte';
  import { getWallets } from '@mysten/wallet-standard';
  import { walletStore, suiClient } from '$lib/wallet.svelte';

  let walletsAPI: any;
  let availableWallets: any[] = $state.raw([]);
  let showDropdown = $state(false);

  onMount(() => {
    walletsAPI = getWallets();
    availableWallets = walletsAPI.get();
    
    // Listen for new wallets
    const unsubscribe = walletsAPI.on('change', (newWallets: any[]) => {
      availableWallets = walletsAPI.get();
    });

    return () => {
      if (unsubscribe) unsubscribe();
    };
  });

  async function connectWallet(walletName: string) {
    try {
      // Find the wallet directly from the API to avoid Svelte proxy objects
      const wallet = walletsAPI.get().find((w: any) => w.name === walletName);
      if (!wallet) {
        alert("Wallet not found!");
        return;
      }

      console.log("Attempting to connect to:", wallet.name);
      console.log("Wallet supported features:", Object.keys(wallet.features));
      
      // Some wallets implement standard:connect poorly, so we prefer sui:connect if available
      const connectFeature = wallet.features['sui:connect'] || wallet.features['standard:connect'];
      
      if (connectFeature) {
        const result = await connectFeature.connect();
        console.log("Connection result:", result);
        walletStore.connectedWallet = wallet;
        
        // Some wallets return accounts in the result, others update wallet.accounts directly
        const accounts = result?.accounts || wallet.accounts;
        if (accounts && accounts.length > 0) {
          walletStore.connectedAccount = accounts[0];
          await fetchBalance();
        } else {
          console.warn("Connected, but no accounts found in the wallet.");
        }
        showDropdown = false;
      } else {
        console.error("This wallet does not support the required connect features.", wallet);
        alert("This wallet does not support the required connection standard.");
      }
    } catch (e) {
      console.error("Failed to connect wallet:", e);
      alert("Failed to connect: " + (e instanceof Error ? e.message : String(e)));
    }
  }

  async function disconnect() {
    if (walletStore.connectedWallet && walletStore.connectedWallet.features['standard:disconnect']) {
      try {
        await walletStore.connectedWallet.features['standard:disconnect'].disconnect();
      } catch (e) {
        console.error("Failed to disconnect", e);
      }
    }
    walletStore.connectedWallet = null;
    walletStore.connectedAccount = null;
    showDropdown = false;
  }

  async function fetchBalance() {
    if (!walletStore.connectedAccount) return;
    try {
      const balance = await suiClient.getBalance({
        owner: walletStore.connectedAccount.address,
      });
      // Convert mist to SUI (1 SUI = 10^9 mist)
      walletStore.suiBalance = (Number(balance.totalBalance) / 1000000000).toFixed(4);
    } catch (e) {
      console.error("Failed to fetch balance", e);
    }
  }
  
  function formatAddress(addr: string) {
    if (!addr) return '';
    return `${addr.slice(0, 6)}...${addr.slice(-4)}`;
  }
</script>

<div class="wallet-container">
  {#if walletStore.connectedAccount}
    <div class="user-profile" role="button" tabindex="0" on:click={() => showDropdown = !showDropdown} on:keypress={(e) => e.key === 'Enter' && (showDropdown = !showDropdown)}>
      <div class="status-indicator"></div>
      <div class="profile-info">
        <span class="user-name">{formatAddress(walletStore.connectedAccount.address)}</span>
        <span class="balance">{walletStore.suiBalance} SUI</span>
      </div>
    </div>
    
    {#if showDropdown}
      <div class="dropdown glass-dropdown">
        <div class="dropdown-header">
          <span class="label">Connected to Testnet</span>
          <span class="wallet-name">{walletStore.connectedWallet?.name || 'Wallet'}</span>
        </div>
        <button class="btn-disconnect" on:click={disconnect}>Disconnect</button>
      </div>
    {/if}
  {:else}
    <button class="btn-connect" on:click={() => showDropdown = !showDropdown}>
      Connect Wallet
    </button>
    
    {#if showDropdown}
      <div class="dropdown glass-dropdown wallets-list">
        <h3>Available Wallets</h3>
        {#if availableWallets.length === 0}
          <p class="no-wallets">No Sui wallets detected. Please install Sui Wallet or Suiet.</p>
        {:else}
          {#each availableWallets as wallet}
            <button class="wallet-option" on:click={() => connectWallet(wallet.name)}>
              <img src={wallet.icon} alt={wallet.name} class="wallet-icon" />
              <span>{wallet.name}</span>
            </button>
          {/each}
        {/if}
      </div>
    {/if}
  {/if}
</div>

<style>
  .wallet-container {
    position: relative;
    font-family: inherit;
  }

  .btn-connect {
    background: linear-gradient(90deg, var(--accent-cyan), var(--accent-violet));
    border: none;
    padding: 0.6rem 1.2rem;
    border-radius: 20px;
    color: white;
    font-weight: 600;
    font-size: 0.9rem;
    cursor: pointer;
    transition: transform 0.2s, box-shadow 0.2s;
  }

  .btn-connect:hover {
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(0, 255, 136, 0.3);
  }

  .user-profile {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.5rem 1rem;
    border-radius: 20px;
    background: rgba(255, 255, 255, 0.05);
    cursor: pointer;
    border: 1px solid rgba(255, 255, 255, 0.1);
    transition: background 0.2s;
  }

  .user-profile:hover {
    background: rgba(255, 255, 255, 0.1);
  }

  .status-indicator {
    width: 8px;
    height: 8px;
    background-color: #00ff88;
    border-radius: 50%;
    box-shadow: 0 0 8px #00ff88;
  }

  .profile-info {
    display: flex;
    flex-direction: column;
  }

  .user-name {
    font-size: 0.85rem;
    font-weight: 600;
    color: var(--text-primary);
  }

  .balance {
    font-size: 0.7rem;
    color: var(--text-secondary);
  }

  .glass-dropdown {
    position: absolute;
    top: calc(100% + 0.5rem);
    right: 0;
    background: rgba(20, 20, 30, 0.9);
    backdrop-filter: blur(12px);
    border: 1px solid rgba(255, 255, 255, 0.1);
    border-radius: 12px;
    padding: 1rem;
    min-width: 200px;
    box-shadow: 0 8px 32px rgba(0, 0, 0, 0.5);
    z-index: 1000;
  }

  .dropdown-header {
    display: flex;
    flex-direction: column;
    margin-bottom: 1rem;
    padding-bottom: 0.5rem;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
  }

  .label {
    font-size: 0.7rem;
    color: var(--text-secondary);
    text-transform: uppercase;
  }

  .wallet-name {
    font-size: 0.9rem;
    font-weight: 600;
    color: var(--accent-cyan);
  }

  .btn-disconnect {
    width: 100%;
    background: rgba(255, 51, 102, 0.1);
    border: 1px solid rgba(255, 51, 102, 0.3);
    color: #ff3366;
    padding: 0.5rem;
    border-radius: 6px;
    cursor: pointer;
    font-weight: 500;
    transition: all 0.2s;
  }

  .btn-disconnect:hover {
    background: rgba(255, 51, 102, 0.2);
  }

  .wallets-list h3 {
    margin: 0 0 1rem 0;
    font-size: 0.9rem;
    color: var(--text-secondary);
  }

  .no-wallets {
    font-size: 0.8rem;
    color: var(--accent-orange, #ff9900);
    margin: 0;
  }

  .wallet-option {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    width: 100%;
    background: transparent;
    border: none;
    color: var(--text-primary);
    padding: 0.5rem;
    border-radius: 6px;
    cursor: pointer;
    transition: background 0.2s;
  }

  .wallet-option:hover {
    background: rgba(255, 255, 255, 0.1);
  }

  .wallet-icon {
    width: 24px;
    height: 24px;
    border-radius: 4px;
  }
</style>
