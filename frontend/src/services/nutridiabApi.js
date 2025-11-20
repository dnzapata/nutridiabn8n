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
      const response = await api.get('/webhook/nutridiab/stats');
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
      const response = await api.get('/webhook/nutridiab/users', {
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
      const response = await api.get(`/webhook/nutridiab/users/${userId}`);
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
      const response = await api.get('/webhook/nutridiab/consultas', {
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
      const response = await api.get(`/webhook/nutridiab/users/${userId}/consultas`, {
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
      const response = await api.get('/webhook/nutridiab/costs', {
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
      const response = await api.get('/webhook/nutridiab/stats/types');
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  /**
   * Obtener actividad reciente
   */
  getRecentActivity: async (limit = 10) => {
    try {
      const response = await api.get('/webhook/nutridiab/activity', {
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
      const response = await api.get('/webhook/nutridiab/users/search', {
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
      const response = await api.get('/webhook/nutridiab/export/consultas', {
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
      const response = await api.get('/webhook/nutridiab/charts/usage', {
        params: { period }
      });
      return response.data;
    } catch (error) {
      throw error;
    }
  }
};

export default nutridiabApi;

