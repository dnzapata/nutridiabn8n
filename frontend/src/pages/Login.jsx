import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { nutridiabApi } from '../services/nutridiabApi';
import './Login.css';

function Login() {
  const navigate = useNavigate();
  const [formData, setFormData] = useState({
    username: '',
    password: ''
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  // Verificar si ya hay sesión activa
  useEffect(() => {
    const token = localStorage.getItem('nutridiab_token');
    if (token) {
      // Validar token y redirigir si es válido
      validateAndRedirect(token);
    }
  }, []);

  const validateAndRedirect = async (token) => {
    try {
      const response = await nutridiabApi.validateSession(token);
      if (response.valida) {
        navigate('/dashboard');
      } else {
        localStorage.removeItem('nutridiab_token');
        localStorage.removeItem('nutridiab_user');
      }
    } catch (err) {
      console.error('Error validando sesión:', err);
      localStorage.removeItem('nutridiab_token');
      localStorage.removeItem('nutridiab_user');
    }
  };

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
    setError(null); // Limpiar error al escribir
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      const response = await nutridiabApi.login(
        formData.username,
        formData.password
      );

      if (response.success) {
        // Guardar token y datos del usuario en localStorage
        localStorage.setItem('nutridiab_token', response.token);
        localStorage.setItem('nutridiab_user', JSON.stringify({
          user_id: response.user_id,
          username: response.username,
          nombre: response.nombre,
          apellido: response.apellido,
          email: response.email,
          rol: response.rol
        }));

        // Redirigir al dashboard
        navigate('/dashboard');
      } else {
        setError(response.message || 'Usuario o contraseña incorrectos');
      }
    } catch (err) {
      console.error('Error en login:', err);
      setError('Error al iniciar sesión. Por favor, intenta de nuevo.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="login-container">
      <div className="login-card">
        <div className="login-header">
          <div className="logo">🩺</div>
          <h1>NutriDiab</h1>
          <p className="subtitle">Panel de Administración</p>
        </div>

        {error && (
          <div className="alert alert-error">
            <span className="alert-icon">⚠️</span>
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="login-form">
          <div className="form-group">
            <label htmlFor="username">
              <span className="label-icon">👤</span>
              Usuario
            </label>
            <input
              type="text"
              id="username"
              name="username"
              value={formData.username}
              onChange={handleChange}
              required
              autoFocus
              placeholder="Ingresa tu usuario"
              autoComplete="username"
            />
          </div>

          <div className="form-group">
            <label htmlFor="password">
              <span className="label-icon">🔒</span>
              Contraseña
            </label>
            <input
              type="password"
              id="password"
              name="password"
              value={formData.password}
              onChange={handleChange}
              required
              placeholder="Ingresa tu contraseña"
              autoComplete="current-password"
            />
          </div>

          <button 
            type="submit" 
            className="btn btn-primary btn-large"
            disabled={loading}
          >
            {loading ? (
              <>
                <span className="spinner-small"></span>
                Iniciando sesión...
              </>
            ) : (
              <>
                <span className="btn-icon">🔓</span>
                Iniciar Sesión
              </>
            )}
          </button>
        </form>

        <div className="login-footer">
          <p className="help-text">
            Sistema de administración NutriDiab
          </p>
          <p className="version">v1.0</p>
        </div>
      </div>

      <div className="background-decoration">
        <div className="circle circle-1"></div>
        <div className="circle circle-2"></div>
        <div className="circle circle-3"></div>
      </div>
    </div>
  );
}

export default Login;

