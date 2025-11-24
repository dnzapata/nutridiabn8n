import { createContext, useContext, useState, useEffect } from 'react';
import { nutridiabApi } from '../services/nutridiabApi';

const AuthContext = createContext(null);

export const AuthProvider = ({ children }) => {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);
  const [isAuthenticated, setIsAuthenticated] = useState(false);

  // Verificar sesión al cargar la aplicación
  useEffect(() => {
    checkSession();
  }, []);

  const checkSession = async () => {
    try {
      const token = localStorage.getItem('nutridiab_token');
      const userData = localStorage.getItem('nutridiab_user');

      if (token && userData) {
        // Validar token con el servidor
        const response = await nutridiabApi.validateSession(token);
        
        if (response.valida) {
          setUser(JSON.parse(userData));
          setIsAuthenticated(true);
        } else {
          // Token inválido o expirado
          clearSession();
        }
      }
    } catch (error) {
      console.error('Error verificando sesión:', error);
      clearSession();
    } finally {
      setLoading(false);
    }
  };

  const login = async (username, password) => {
    try {
      const response = await nutridiabApi.login(username, password);

      if (response.success) {
        const userData = {
          user_id: response.user_id,
          username: response.username,
          nombre: response.nombre,
          apellido: response.apellido,
          email: response.email,
          rol: response.rol
        };

        // Guardar en localStorage
        localStorage.setItem('nutridiab_token', response.token);
        localStorage.setItem('nutridiab_user', JSON.stringify(userData));

        // Actualizar estado
        setUser(userData);
        setIsAuthenticated(true);

        return { success: true };
      } else {
        return { 
          success: false, 
          message: response.message || 'Credenciales incorrectas' 
        };
      }
    } catch (error) {
      console.error('Error en login:', error);
      return { 
        success: false, 
        message: 'Error al iniciar sesión. Intenta de nuevo.' 
      };
    }
  };

  const logout = async () => {
    try {
      const token = localStorage.getItem('nutridiab_token');
      if (token) {
        await nutridiabApi.logout(token);
      }
    } catch (error) {
      console.error('Error en logout:', error);
    } finally {
      clearSession();
    }
  };

  const clearSession = () => {
    localStorage.removeItem('nutridiab_token');
    localStorage.removeItem('nutridiab_user');
    setUser(null);
    setIsAuthenticated(false);
  };

  const isAdmin = () => {
    return user && user.rol === 'administrador';
  };

  const getToken = () => {
    return localStorage.getItem('nutridiab_token');
  };

  const value = {
    user,
    loading,
    isAuthenticated,
    isAdmin,
    login,
    logout,
    getToken,
    checkSession
  };

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
};

export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth debe ser usado dentro de un AuthProvider');
  }
  return context;
};

export default AuthContext;

