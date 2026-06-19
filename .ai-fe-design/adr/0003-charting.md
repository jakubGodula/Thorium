# ADR-0003: ECharts + uPlot for charts and time-series

**Status:** Accepted (v2, provisional — confirm at v2→v3 R16)
**Date:** 2026-06-19

## Context
User allowed charting libraries (Q2), explicitly fine with "heavy" early, targeting
ELK/Datadog-grade dashboards. Needs: rich dashboards (host map, heatmaps, pies,
gauges) and dense fleet time-series (`TelemetryReported` cpu/ram/disk).

## Decision
- **ECharts** for rich, interactive dashboard visuals (Datadog/ELK-grade).
- **uPlot** for dense, high-performance time-series panels.
- Both **lazy-loaded per route** via a `Chart.svelte` / `TimeSeries.svelte`
  wrapper so they don't bloat the initial bundle.

## Consequences
- + Professional fidelity out of the box; huge chart vocabulary.
- + uPlot keeps telemetry panels fast even with many series.
- − Larger bundles (mitigated by lazy-load + later optimization pass).
- − Two libraries to wrap; standardize the theme to Tailwind tokens.
- Alternatives weighed: LayerChart/Layer Cake (lighter, less batteries-included),
  Observable Plot (great static, weaker interactivity). Revisit at **R16**.
