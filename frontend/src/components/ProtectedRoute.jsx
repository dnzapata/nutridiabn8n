import { Navigate } from 'react-router-dom';
import { useAuth } from '../context/AuthContext';

function ProtectedRoute({ children, requireAdmin = false }) {
  const { isAuthenticated, isAdmin, loading } = useAuth();

  // Mostrar loading mientras verifica la sesión
  if (loading) {
    return (
      <div style={{
        display: 'flex',
        justifyContent: 'center',
        alignItems: 'center',
        minHeight: '100vh',
        fontSize: '18px',
        color: '#718096'
      }}>
        <div>
          <div style={{ fontSize: '48px', marginBottom: '20px', textAlign: 'center' }}>🩺</div>
          <div>Cargando...</div>
        </div>
      </div>
    );
  }

  // Si no está autenticado, redirigir al login
  if (!isAuthenticated) {
    return <Navigate to="/login" replace />;
  }

  // Si requiere admin y no es admin, mostrar mensaje de error
  if (requireAdmin && !isAdmin()) {
    return (
      <div style={{
        display: 'flex',
        flexDirection: 'column',
        justifyContent: 'center',
        alignItems: 'center',
        minHeight: '100vh',
        padding: '20px',
        textAlign: 'center'
      }}>
        <div style={{
          background: 'white',
          padding: '40px',
          borderRadius: '20px',
          boxShadow: '0 10px 40px rgba(0,0,0,0.1)',
          maxWidth: '500px'
        }}>
          <div style={{ fontSize: '64px', marginBottom: '20px' }}>⛔</div>
          <h1 style={{ color: '#2d3748', marginBottom: '10px' }}>Acceso Denegado</h1>
          <p style={{ color: '#718096', marginBottom: '20px' }}>
            No tienes permisos para acceder a esta sección.
            Esta área está reservada solo para administradores.
          </p>
          <a 
            href="/login"
            style={{
              display: 'inline-block',
              padding: '12px 24px',
              background: '#667eea',
              color: 'white',
              textDecoration: 'none',
              borderRadius: '10px',
              fontWeight: '600'
            }}
          >
            Volver al inicio
          </a>
        </div>
      </div>
    );
  }

  return children;
}

export default ProtectedRoute;

