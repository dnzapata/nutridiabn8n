import { Link } from 'react-router-dom'
import './Layout.css'

function Layout({ children }) {
  return (
    <div className="layout">
      <nav className="navbar">
        <div className="navbar-container">
          <Link to="/" className="navbar-brand">
            🥗 NutriDia
          </Link>
          <ul className="navbar-menu">
            <li>
              <Link to="/" className="navbar-link">
                Inicio
              </Link>
            </li>
            <li>
              <Link to="/dashboard" className="navbar-link">
                Dashboard
              </Link>
            </li>
            <li>
              <Link to="/items" className="navbar-link">
                Items
              </Link>
            </li>
            <li>
              <Link to="/about" className="navbar-link">
                Acerca de
              </Link>
            </li>
          </ul>
        </div>
      </nav>
      <main className="main-content">
        {children}
      </main>
      <footer className="footer">
        <div className="footer-container">
          <p>© 2025 NutriDia - Powered by React + n8n</p>
        </div>
      </footer>
    </div>
  )
}

export default Layout

