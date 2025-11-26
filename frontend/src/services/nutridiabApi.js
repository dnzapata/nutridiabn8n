import api from './api';

/**
 * API Service para NutriDiab
 * Endpoints para consultar datos del sistema de análisis nutricional
 */

export const nutridiabApi = {
  /**
   * Dashboard - Estadísticas generales
   */
  getDashboardStats: async () => {
    try {
      const response = await api.get('/webhook/nutridiab/admin/stats');
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  /**
   * Obtener todos los usuarios
   */
  getUsers: async (params = {}) => {
    try {
      const { page = 1, limit = 10, search = '' } = params;
      const response = await api.get('/webhook/nutridiab/admin/usuarios', {
        params: { page, limit, search }
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  /**
   * Obtener un usuario específico por ID
   */
  getUser: async (userId) => {
    try {
      const response = await api.get(`/webhook/nutridiab/admin/usuarios/${userId}`);
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  /**
   * Actualizar un usuario
   */
  updateUser: async (userId, userData) => {
    try {
      const response = await api.put(`/webhook/nutridiab/admin/usuarios/${userId}`, userData);
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  /**
   * Obtener todas las consultas
   */
  getConsultas: async (params = {}) => {
    try {
      const { page = 1, limit = 10, tipo = '', userId = '' } = params;
      const response = await api.get('/webhook/nutridiab/admin/consultas', {
        params: { page, limit, tipo, userId }
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  /**
   * Obtener consultas de un usuario específico
   */
  getUserConsultas: async (userId, params = {}) => {
    try {
      const { page = 1, limit = 10 } = params;
      const response = await api.get(`/webhook/nutridiab/admin/usuarios/${userId}/consultas`, {
        params: { page, limit }
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  /**
   * Obtener estadísticas de costos
   */
  getCostStats: async (params = {}) => {
    try {
      const { startDate = '', endDate = '' } = params;
      const response = await api.get('/webhook/nutridiab/admin/costs', {
        params: { startDate, endDate }
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  /**
   * Obtener estadísticas por tipo de consulta
   */
  getTypeStats: async () => {
    try {
      const response = await api.get('/webhook/nutridiab/admin/stats/types');
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  /**
   * Obtener actividad reciente (consultas recientes)
   */
  getRecentActivity: async (limit = 10) => {
    try {
      const response = await api.get('/webhook/nutridiab/admin/consultas', {
        params: { limit }
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  /**
   * Buscar usuarios por remoteJid o nombre
   */
  searchUsers: async (query) => {
    try {
      const response = await api.get('/webhook/nutridiab/admin/usuarios/search', {
        params: { q: query }
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  /**
   * Exportar consultas a CSV
   */
  exportConsultas: async (params = {}) => {
    try {
      const response = await api.get('/webhook/nutridiab/admin/export/consultas', {
        params,
        responseType: 'blob'
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  /**
   * Obtener gráficos de uso por fecha
   */
  getUsageChart: async (period = '7days') => {
    try {
      const response = await api.get('/webhook/nutridiab/admin/charts/usage', {
        params: { period }
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // Aliases para compatibilidad
  getStats: async () => {
    return nutridiabApi.getDashboardStats();
  },

  getRecentQueries: async (limit = 10) => {
    return nutridiabApi.getRecentActivity(limit);
  },

  /**
   * AUTENTICACIÓN
   */

  /**
   * Login de usuario
   */
  login: async (username, password) => {
    try {
      const response = await api.post('/webhook/nutridiab/auth/login', {
        username,
        password
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  /**
   * Validar sesión actual
   */
  validateSession: async (token) => {
    try {
      const response = await api.post('/webhook/nutridiab/auth/validate', {
        token
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  /**
   * Logout de usuario
   */
  logout: async (token) => {
    try {
      const response = await api.post('/webhook/nutridiab/auth/logout', {
        token
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  /**
   * Verificar si usuario es administrador
   */
  checkAdmin: async (token) => {
    try {
      const response = await api.post('/webhook/nutridiab/auth/check-admin', {
        token
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  }
};

export default nutridiabApi;

