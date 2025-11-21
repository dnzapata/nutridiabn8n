import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    proxy: {
      '/webhook': {
        target: process.env.VITE_API_URL || 'https://wf.zynaptic.tech',
        changeOrigin: true,
        secure: true,
      }
    }
  }
})

