import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'
import './Layout.css'

function Layout({ children }) {
  const { user, logout, isAdmin } = useAuth()
  const navigate = useNavigate()

  const handleLogout = async () => {
    await logout()
    navigate('/login')
  }

  return (
    <div className="layout">
      <nav className="navbar">
        <div className="navbar-container">
          <Link to="/dashboard" className="navbar-brand">
            🩺 Nutridiab
          </Link>
          <ul className="navbar-menu">
            {isAdmin() && (
              <li>
                <Link to="/dashboard" className="navbar-link">
                  Dashboard
                </Link>
              </li>
            )}
            <li>
              <Link to="/about" className="navbar-link">
                Acerca de
              </Link>
            </li>
          </ul>
          <div className="navbar-user">
            <span className="user-info">
              <span className="user-icon">👤</span>
              <span className="user-name">
                {user?.nombre || user?.username}
                {user?.rol === 'administrador' && (
                  <span className="user-badge">Admin</span>
                )}
              </span>
            </span>
            <button onClick={handleLogout} className="btn-logout">
              🚪 Salir
            </button>
          </div>
        </div>
      </nav>
      <main className="main-content">
        {children}
      </main>
      <footer className="footer">
        <div className="footer-container">
          <p>© 2025 Nutridiab - Control Nutricional para Diabéticos - Powered by React + n8n</p>
        </div>
      </footer>
    </div>
  )
}

export default Layout

