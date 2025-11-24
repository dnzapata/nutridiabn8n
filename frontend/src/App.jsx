import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { AuthProvider } from './context/AuthContext'
import Layout from './components/Layout'
import ProtectedRoute from './components/ProtectedRoute'
import Login from './pages/Login'
import Dashboard from './pages/Dashboard'
import About from './pages/About'
import UserRegistration from './pages/UserRegistration'
import RegistrationSuccess from './pages/RegistrationSuccess'
import './App.css'

function App() {
  return (
    <AuthProvider>
      <Router>
        <Routes>
          {/* Ruta raíz redirige al login */}
          <Route path="/" element={<Navigate to="/login" replace />} />
          
          {/* Login sin protección */}
          <Route path="/login" element={<Login />} />
          
          {/* Dashboard - Solo administradores */}
          <Route 
            path="/dashboard" 
            element={
              <ProtectedRoute requireAdmin={true}>
                <Layout>
                  <Dashboard />
                </Layout>
              </ProtectedRoute>
            } 
          />
          
          {/* About - Protegido pero no requiere admin */}
          <Route 
            path="/about" 
            element={
              <ProtectedRoute>
                <Layout>
                  <About />
                </Layout>
              </ProtectedRoute>
            } 
          />
          
          {/* Rutas sin Layout (fullscreen) - No protegidas */}
          <Route path="/registro" element={<UserRegistration />} />
          <Route path="/registro-exitoso" element={<RegistrationSuccess />} />
          
          {/* Ruta catch-all para URLs no encontradas */}
          <Route path="*" element={<Navigate to="/login" replace />} />
        </Routes>
      </Router>
    </AuthProvider>
  )
}

export default App

