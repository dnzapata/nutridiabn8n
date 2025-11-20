import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/webhook': {
        target: 'http://localhost:5678',
        changeOrigin: true,
      }
    }
  }
})

