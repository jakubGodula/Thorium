import { defineConfig } from 'vite'
import { svelte } from '@sveltejs/vite-plugin-svelte'

// https://vite.dev/config/
export default defineConfig({
  plugins: [svelte()],
  server: {
    proxy: {
      '/api': {
        target: {
          protocol: 'http:',
          host: '127.0.0.1',
          port: 9090
        },
        changeOrigin: true
      }
    }
  }
})
