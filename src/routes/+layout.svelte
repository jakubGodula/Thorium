<script lang="ts">
  import '../app.css';
  let { children } = $props();
</script>

<div class="app-container">
  <nav class="glass main-nav">
    <div class="logo">
      <span class="logo-text">THORIUM</span>
      <span class="logo-dot"></span>
    </div>
    <div class="nav-links">
      <a href="/" class="active">Dashboard</a>
      <a href="/storyline">Storylines</a>
      <a href="/triage">AI Triage</a>
      <a href="/identity">Identity</a>
    </div>
    <div class="user-profile">
      <div class="status-indicator"></div>
      <span class="user-name">Admin</span>
    </div>
  </nav>

  <main>
    {@render children()}
  </main>
</div>

<style>
  .app-container {
    min-height: 100vh;
    display: flex;
    flex-direction: column;
  }

  .main-nav {
    position: fixed;
    top: 1rem;
    left: 1rem;
    right: 1rem;
    height: 64px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 2rem;
    z-index: 1000;
  }

  .logo {
    display: flex;
    align-items: center;
    gap: 0.5rem;
  }

  .logo-text {
    font-weight: 800;
    font-size: 1.25rem;
    letter-spacing: 0.1em;
    background: linear-gradient(90deg, var(--accent-cyan), var(--accent-violet));
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
  }

  .logo-dot {
    width: 8px;
    height: 8px;
    background-color: var(--accent-cyan);
    border-radius: 50%;
    box-shadow: 0 0 10px var(--accent-cyan);
  }

  .nav-links {
    display: flex;
    gap: 2rem;
  }

  .nav-links a {
    text-decoration: none;
    color: var(--text-secondary);
    font-size: 0.9rem;
    font-weight: 500;
    transition: all 0.2s ease;
    position: relative;
  }

  .nav-links a:hover, .nav-links a.active {
    color: var(--text-primary);
  }

  .nav-links a.active::after {
    content: '';
    position: absolute;
    bottom: -4px;
    left: 0;
    width: 100%;
    height: 2px;
    background: var(--accent-cyan);
    box-shadow: 0 0 8px var(--accent-cyan);
  }

  .user-profile {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.5rem 1rem;
    border-radius: 20px;
    background: rgba(255, 255, 255, 0.05);
  }

  .status-indicator {
    width: 8px;
    height: 8px;
    background-color: #00ff88;
    border-radius: 50%;
    box-shadow: 0 0 8px #00ff88;
  }

  .user-name {
    font-size: 0.85rem;
    font-weight: 600;
  }

  main {
    flex: 1;
    padding-top: 6rem;
    padding-left: 2rem;
    padding-right: 2rem;
    padding-bottom: 2rem;
    max-width: 1600px;
    margin: 0 auto;
    width: 100%;
  }
</style>
