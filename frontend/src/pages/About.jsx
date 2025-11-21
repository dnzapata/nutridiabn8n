import './About.css'

function About() {
  return (
    <div className="about-page">
      <div className="hero-about">
        <h1>Acerca de Nutridiab</h1>
        <p>Sistema de control nutricional para diabéticos con arquitectura moderna</p>
      </div>

      <div className="card">
        <h2>🎯 ¿Qué es este proyecto?</h2>
        <p>
          Nutridiab es una Single Page Application (SPA) construida con React que utiliza 
          n8n como backend. Esta aplicación para el control nutricional de diabéticos permite 
          crear workflows visuales para manejar toda la lógica de negocio sin necesidad de 
          escribir un backend tradicional.
        </p>
      </div>

      <div className="card">
        <h2>🏗️ Arquitectura</h2>
        <div className="architecture-diagram">
          <div className="arch-box">
            <div className="arch-title">Frontend</div>
            <ul>
              <li>React 18</li>
              <li>React Router</li>
              <li>Axios</li>
              <li>Vite</li>
            </ul>
          </div>
          <div className="arch-arrow">→</div>
          <div className="arch-box">
            <div className="arch-title">Backend</div>
            <ul>
              <li>n8n Workflows</li>
              <li>Webhooks</li>
              <li>API REST</li>
              <li>Docker</li>
            </ul>
          </div>
        </div>
      </div>

      <div className="card">
        <h2>✨ Características Principales</h2>
        <ul className="features-list">
          <li>
            <strong>React + Vite:</strong> Desarrollo rápido con Hot Module Replacement (HMR)
          </li>
          <li>
            <strong>n8n Backend:</strong> Workflows visuales para lógica de negocio
          </li>
          <li>
            <strong>Docker:</strong> Fácil despliegue y configuración
          </li>
          <li>
            <strong>Responsive:</strong> Diseño adaptable a todos los dispositivos
          </li>
          <li>
            <strong>Modular:</strong> Arquitectura escalable y mantenible
          </li>
          <li>
            <strong>API REST:</strong> Comunicación mediante webhooks de n8n
          </li>
        </ul>
      </div>

      <div className="card">
        <h2>🚀 Casos de Uso</h2>
        <div className="use-cases">
          <div className="use-case">
            <h3>📊 Gestión de Datos</h3>
            <p>CRUD completo con workflows personalizables</p>
          </div>
          <div className="use-case">
            <h3>🔄 Automatización</h3>
            <p>Procesos automáticos sin código backend tradicional</p>
          </div>
          <div className="use-case">
            <h3>🔗 Integraciones</h3>
            <p>Conecta con múltiples servicios y APIs fácilmente</p>
          </div>
          <div className="use-case">
            <h3>📧 Notificaciones</h3>
            <p>Envío automático de emails, SMS, y más</p>
          </div>
        </div>
      </div>

      <div className="card">
        <h2>📚 Tecnologías Utilizadas</h2>
        <div className="tech-stack">
          <div className="tech-item">
            <div className="tech-icon">⚛️</div>
            <div className="tech-name">React</div>
          </div>
          <div className="tech-item">
            <div className="tech-icon">⚡</div>
            <div className="tech-name">Vite</div>
          </div>
          <div className="tech-item">
            <div className="tech-icon">🔄</div>
            <div className="tech-name">n8n</div>
          </div>
          <div className="tech-item">
            <div className="tech-icon">🐳</div>
            <div className="tech-name">Docker</div>
          </div>
          <div className="tech-item">
            <div className="tech-icon">🌐</div>
            <div className="tech-name">Axios</div>
          </div>
          <div className="tech-item">
            <div className="tech-icon">🎨</div>
            <div className="tech-name">CSS3</div>
          </div>
        </div>
      </div>

      <div className="card cta-card">
        <h2>¿Listo para comenzar?</h2>
        <p>Consulta la documentación en el README.md del proyecto</p>
        <div className="cta-buttons">
          <a 
            href="https://wf.zynaptic.tech" 
            target="_blank" 
            rel="noopener noreferrer"
            className="btn btn-primary"
          >
            Abrir n8n
          </a>
          <a 
            href="https://docs.n8n.io/" 
            target="_blank" 
            rel="noopener noreferrer"
            className="btn btn-secondary"
          >
            Documentación n8n
          </a>
        </div>
      </div>
    </div>
  )
}

export default About

