import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'

// base:'./' + hash routing => IPFS-safe static build
export default defineConfig({
  base: './',
  plugins: [svelte()],
  // allow tunnels (loca.lt / trycloudflare / ngrok) to reach dev+preview servers
  server: { port: 5173, host: true, allowedHosts: true },
  preview: { port: 5173, host: true, allowedHosts: true },
})
