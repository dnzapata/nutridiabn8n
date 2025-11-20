import { useState, useEffect } from 'react'
import { apiService } from '../services/api'
import './Home.css'

function Home() {
  const [health, setHealth] = useState(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)

  useEffect(() => {
    checkHealth()
  }, [])

  const checkHealth = async () => {
    try {
      setLoading(true)
      const data = await apiService.healthCheck()
      setHealth(data)
      setError(null)
    } catch (err) {
      setError('No se pudo conectar con el backend de n8n. Asegúrate de que esté ejecutándose.')
      console.error('Error al verificar health:', err)
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="home">
      <div className="hero">
        <h1>🥗 Bienvenido a NutriDia</h1>
        <p className="hero-subtitle">
          Gestión nutricional inteligente con React + n8n
        </p>
      </div>

      <div className="status-section">
        <h2>Estado del Backend</h2>
        {loading && <div className="loading">Verificando conexión...</div>}
        
        {error && (
          <div className="error">
            <p>{error}</p>
            <button onClick={checkHealth} className="btn btn-secondary">
              Reintentar
            </button>
          </div>
        )}
        
        {health && (
          <div className="success">
            <h3>✓ Backend conectado correctamente</h3>
            <div className="health-details">
              <p><strong>Estado:</strong> {health.status}</p>
              <p><strong>Servicio:</strong> {health.service}</p>
              <p><strong>Versión:</strong> {health.version || 'N/A'}</p>
              <p><strong>Timestamp:</strong> {new Date(health.timestamp).toLocaleString('es-MX')}</p>
            </div>
          </div>
        )}
      </div>

      <div className="features">
        <h2>Características</h2>
        <div className="grid">
          <div className="card feature-card">
            <div className="feature-icon">⚡</div>
            <h3>Rápido y Eficiente</h3>
            <p>React con Vite para un desarrollo ágil y HMR instantáneo</p>
          </div>
          
          <div className="card feature-card">
            <div className="feature-icon">🔄</div>
            <h3>Backend Automatizado</h3>
            <p>n8n gestiona toda la lógica de negocio mediante workflows visuales</p>
          </div>
          
          <div className="card feature-card">
            <div className="feature-icon">🎨</div>
            <h3>UI Moderna</h3>
            <p>Interfaz limpia y responsiva con las mejores prácticas de UX</p>
          </div>
          
          <div className="card feature-card">
            <div className="feature-icon">🔧</div>
            <h3>Fácil de Extender</h3>
            <p>Arquitectura modular lista para escalar tu aplicación</p>
          </div>
        </div>
      </div>

      <div className="quick-start">
        <h2>Inicio Rápido</h2>
        <div className="card">
          <ol className="steps-list">
            <li>
              <strong>Inicia n8n:</strong> 
              <code>docker-compose up -d</code>
            </li>
            <li>
              <strong>Accede a n8n:</strong> 
              <a href="http://localhost:5678" target="_blank" rel="noopener noreferrer">
                http://localhost:5678
              </a>
            </li>
            <li>
              <strong>Importa los workflows:</strong> Ve a la carpeta n8n/workflows/
            </li>
            <li>
              <strong>Explora la aplicación:</strong> Navega por las diferentes secciones
            </li>
          </ol>
        </div>
      </div>
    </div>
  )
}

export default Home

