import axios from 'axios';

// Configuración base de axios
const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5678';

const api = axios.create({
  baseURL: API_URL,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor para requests
api.interceptors.request.use(
  (config) => {
    // Aquí puedes agregar tokens de autenticación si los necesitas
    // const token = localStorage.getItem('token');
    // if (token) {
    //   config.headers.Authorization = `Bearer ${token}`;
    // }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Interceptor para responses
api.interceptors.response.use(
  (response) => {
    return response;
  },
  (error) => {
    // Manejo centralizado de errores
    if (error.response) {
      // El servidor respondió con un código de error
      console.error('Error de respuesta:', error.response.data);
      console.error('Status:', error.response.status);
    } else if (error.request) {
      // La petición se hizo pero no hubo respuesta
      console.error('Error de red:', error.request);
    } else {
      // Algo sucedió al configurar la petición
      console.error('Error:', error.message);
    }
    return Promise.reject(error);
  }
);

// Funciones de la API
export const apiService = {
  // Health Check
  healthCheck: async () => {
    try {
      const response = await api.get('/webhook/health');
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // Items CRUD
  getItems: async () => {
    try {
      const response = await api.get('/webhook/items');
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  createItem: async (itemData) => {
    try {
      const response = await api.post('/webhook/items', itemData);
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  updateItem: async (id, itemData) => {
    try {
      const response = await api.put(`/webhook/items/${id}`, itemData);
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  deleteItem: async (id) => {
    try {
      const response = await api.delete(`/webhook/items/${id}`);
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  // Autenticación (ejemplo)
  login: async (credentials) => {
    try {
      const response = await api.post('/webhook/auth/login', credentials);
      return response.data;
    } catch (error) {
      throw error;
    }
  },

  register: async (userData) => {
    try {
      const response = await api.post('/webhook/auth/register', userData);
      return response.data;
    } catch (error) {
      throw error;
    }
  },
};

export default api;

