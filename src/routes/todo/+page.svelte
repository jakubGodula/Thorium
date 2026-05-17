<script lang="ts">
  let activeSlide = $state(0);

  const slides = [
    {
      title: "Phase 1: Rust/Tauri Endpoint Agent",
      icon: "🦀",
      status: "In Progress",
      items: [
        "Headless Tauri 2.0 daemon running with system privileges.",
        "Local cryptographic keypair generation (Ed25519) within Secure Enclave/TPM.",
        "Hardware fingerprinting (Motherboard + MAC) for unique Endpoint ID.",
        "eBPF/OS-level telemetry hooks: Process trees, Network Sockets, File I/O.",
        "Autonomous disruption modules: Host isolation, process termination."
      ]
    },
    {
      title: "Phase 2: Web3 Identity & Provisioning",
      icon: "⛓️",
      status: "Designed",
      items: [
        "Zero-Touch MDM Bulk Enrollment via Thorium Web UI.",
        "Sui zkLogin integration for admin authentication (OIDC -> JWT -> zk-SNARK).",
        "Move Smart Contract (thorium::registry) to manage Agent Identities.",
        "Minting non-transferable Soulbound Tokens to anchor endpoints on-chain.",
        "Smart Contract revocation (Kill-switch) for compromised agents."
      ]
    },
    {
      title: "Phase 3: Hybrid XDR Data Lake",
      icon: "🌊",
      status: "Planned",
      items: [
        "High-throughput off-chain Data Lake (e.g., ClickHouse) for raw telemetry.",
        "Periodic batching of agent events into Merkle Trees.",
        "Anchoring Merkle Roots to the Sui Blockchain for absolute immutability.",
        "Cryptographic verification of off-chain data prior to autonomous AI actions.",
        "End-to-end mTLS communication between Agents and the Relayer Backend."
      ]
    },
    {
      title: "Phase 4: Recursive AI & UI Command Center",
      icon: "🧠",
      status: "Prototyping",
      items: [
        "Glassmorphic SvelteKit Dashboard for real-time SOC visualization.",
        "Storyline Reconstruction: Graph-based tracking of lateral movement.",
        "Recursive AI Core: Spawns autonomous workers to investigate alerts.",
        "Visual 'Verified by Sui' badges on telemetry proven against the blockchain.",
        "ITDR (Identity Threat Detection) and Honeytoken active deception management."
      ]
    }
  ];

  function nextSlide() {
    if (activeSlide < slides.length - 1) activeSlide++;
  }

  function prevSlide() {
    if (activeSlide > 0) activeSlide--;
  }
</script>

<div class="presentation-container">
  <header class="page-header">
    <div>
      <h1>Thorium XDR Master Roadmap</h1>
      <p class="subtitle">Architectural design and implementation phases</p>
    </div>
    
    <div class="progress-bar">
      {#each slides as _, i}
        <div class="progress-step {i <= activeSlide ? 'active' : ''}" on:click={() => activeSlide = i} role="button" tabindex="0" on:keypress={(e) => e.key === 'Enter' && (activeSlide = i)}></div>
      {/each}
    </div>
  </header>

  <div class="slide-viewer glass">
    <div class="slide-content" class:fade-in={true}>
      <div class="slide-header">
        <span class="slide-icon">{slides[activeSlide].icon}</span>
        <div class="slide-title-area">
          <h2>{slides[activeSlide].title}</h2>
          <span class="status-badge {slides[activeSlide].status.toLowerCase().replace(' ', '-')}">{slides[activeSlide].status}</span>
        </div>
      </div>
      
      <ul class="task-list">
        {#each slides[activeSlide].items as item}
          <li>
            <svg class="check-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
            <span>{item}</span>
          </li>
        {/each}
      </ul>
    </div>

    <div class="slide-controls">
      <button class="btn-nav" on:click={prevSlide} disabled={activeSlide === 0}>
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="19" y1="12" x2="5" y2="12"></line><polyline points="12 19 5 12 12 5"></polyline></svg>
        Previous
      </button>
      <span class="slide-counter">Phase {activeSlide + 1} of {slides.length}</span>
      <button class="btn-nav" on:click={nextSlide} disabled={activeSlide === slides.length - 1}>
        Next
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
      </button>
    </div>
  </div>
</div>

<style>
  .presentation-container {
    display: flex;
    flex-direction: column;
    gap: 2rem;
    height: calc(100vh - 120px);
    max-width: 1000px;
    margin: 0 auto;
  }

  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-end;
  }

  h1 {
    font-size: 2.2rem;
    margin: 0 0 0.5rem 0;
    font-weight: 700;
    background: linear-gradient(90deg, #fff, var(--accent-cyan));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }

  .subtitle {
    color: var(--text-secondary);
    margin: 0;
    font-size: 1.1rem;
  }

  .progress-bar {
    display: flex;
    gap: 0.5rem;
  }

  .progress-step {
    width: 40px;
    height: 6px;
    background: rgba(255, 255, 255, 0.1);
    border-radius: 4px;
    cursor: pointer;
    transition: all 0.3s ease;
  }

  .progress-step:hover {
    background: rgba(255, 255, 255, 0.3);
  }

  .progress-step.active {
    background: var(--accent-cyan);
    box-shadow: 0 0 10px rgba(0, 255, 136, 0.5);
  }

  .slide-viewer {
    flex: 1;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    padding: 3rem;
    border-radius: 24px;
    position: relative;
    overflow: hidden;
  }

  .slide-header {
    display: flex;
    align-items: center;
    gap: 1.5rem;
    margin-bottom: 3rem;
  }

  .slide-icon {
    font-size: 4rem;
    background: rgba(255,255,255,0.05);
    width: 100px;
    height: 100px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 20px;
    border: 1px solid rgba(255,255,255,0.1);
  }

  .slide-title-area h2 {
    font-size: 2rem;
    margin: 0 0 0.5rem 0;
    font-weight: 600;
  }

  .status-badge {
    display: inline-block;
    padding: 0.3rem 0.8rem;
    border-radius: 20px;
    font-size: 0.8rem;
    font-weight: 700;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .status-badge.in-progress { background: rgba(0, 204, 255, 0.1); color: #00ccff; }
  .status-badge.designed { background: rgba(0, 255, 136, 0.1); color: #00ff88; }
  .status-badge.planned { background: rgba(255, 153, 0, 0.1); color: #ff9900; }
  .status-badge.prototyping { background: rgba(153, 51, 255, 0.1); color: #9933ff; }

  .task-list {
    list-style: none;
    padding: 0;
    margin: 0;
    display: flex;
    flex-direction: column;
    gap: 1.25rem;
  }

  .task-list li {
    display: flex;
    align-items: flex-start;
    gap: 1rem;
    font-size: 1.2rem;
    color: var(--text-primary);
    line-height: 1.5;
    background: rgba(0,0,0,0.2);
    padding: 1.25rem;
    border-radius: 12px;
    border-left: 4px solid var(--accent-violet);
    transition: transform 0.2s ease;
  }

  .task-list li:hover {
    transform: translateX(5px);
    background: rgba(0,0,0,0.3);
  }

  .check-icon {
    width: 24px;
    height: 24px;
    color: var(--accent-cyan);
    flex-shrink: 0;
    margin-top: 2px;
  }

  .slide-controls {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-top: 2rem;
    padding-top: 2rem;
    border-top: 1px solid rgba(255,255,255,0.1);
  }

  .btn-nav {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    background: rgba(255,255,255,0.05);
    border: 1px solid rgba(255,255,255,0.1);
    color: white;
    padding: 0.75rem 1.5rem;
    border-radius: 30px;
    font-size: 1rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s ease;
  }

  .btn-nav svg {
    width: 20px;
    height: 20px;
  }

  .btn-nav:hover:not(:disabled) {
    background: rgba(255,255,255,0.15);
    border-color: var(--accent-cyan);
  }

  .btn-nav:disabled {
    opacity: 0.3;
    cursor: not-allowed;
  }

  .slide-counter {
    color: var(--text-secondary);
    font-weight: 500;
    letter-spacing: 0.1em;
    text-transform: uppercase;
    font-size: 0.9rem;
  }

  .fade-in {
    animation: fadeIn 0.4s ease-out forwards;
  }

  @keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
  }
</style>
