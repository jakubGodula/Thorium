<script lang="ts">
  let { 
    title, 
    value, 
    trend, 
    trendType = 'neutral', 
    accent = 'var(--accent-cyan)' 
  } = $props<{
    title: string;
    value: string | number;
    trend: string;
    trendType?: 'positive' | 'negative' | 'neutral';
    accent?: string;
  }>();
</script>

<div class="stat-card glass" style="--card-accent: {accent}">
  <div class="card-header">
    <span class="title">{title}</span>
    <div class="accent-line"></div>
  </div>
  <div class="card-body">
    <div class="value-container">
      <h2 class="value">{value}</h2>
      <span class="trend {trendType}">{trend}</span>
    </div>
  </div>
</div>

<style>
  .stat-card {
    padding: 1.5rem;
    position: relative;
    overflow: hidden;
    transition: transform 0.2s ease, box-shadow 0.2s ease;
  }

  .stat-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.4);
  }

  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
  }

  .title {
    color: var(--text-secondary);
    font-size: 0.8rem;
    font-weight: 600;
    text-transform: uppercase;
    letter-spacing: 0.05em;
  }

  .accent-line {
    width: 24px;
    height: 2px;
    background: var(--card-accent);
    box-shadow: 0 0 8px var(--card-accent);
  }

  .value-container {
    display: flex;
    align-items: baseline;
    gap: 0.75rem;
  }

  .value {
    font-size: 2rem;
    font-weight: 800;
    color: var(--text-primary);
  }

  .trend {
    font-size: 0.85rem;
    font-weight: 600;
  }

  .trend.positive { color: var(--accent-green); }
  .trend.negative { color: var(--accent-crimson); }
  .trend.neutral { color: var(--text-muted); }

  .stat-card::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: radial-gradient(circle at top right, var(--card-accent), transparent 100%);
    opacity: 0.03;
    pointer-events: none;
  }
</style>
