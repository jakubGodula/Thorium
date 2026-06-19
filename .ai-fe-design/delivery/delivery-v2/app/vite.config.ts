import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'

// base:'./' + hash routing => IPFS-safe static build
export default defineConfig({
  base: './',
  plugins: [svelte()],
  server: { port: 5173 },
})
