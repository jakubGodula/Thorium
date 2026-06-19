<script lang="ts">
  // L-E1: ECharts adoption (lazy-loaded; graceful if it fails)
  import { onMount, onDestroy } from 'svelte'
  let { option } = $props<{ option: any }>()
  let el: HTMLDivElement
  let chart: any = null
  onMount(async () => {
    try {
      const echarts = await import('echarts')
      chart = echarts.init(el, undefined, { renderer: 'canvas' })
      chart.setOption(option)
      window.addEventListener('resize', resize)
    } catch { /* fallback: leave the empty box */ }
  })
  function resize() { chart?.resize() }
  $effect(() => { if (chart && option) chart.setOption(option) })
  onDestroy(() => { window.removeEventListener('resize', resize); chart?.dispose() })
</script>
<div bind:this={el} class="echart"></div>
<style>.echart{width:100%;height:240px}</style>
