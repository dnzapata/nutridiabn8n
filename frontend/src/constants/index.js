// Constantes de la aplicación

export const APP_NAME = import.meta.env.VITE_APP_NAME || 'Nutridiab';
export const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:5678';
export const ENV = import.meta.env.VITE_ENV || 'development';

// Endpoints
export const ENDPOINTS = {
  HEALTH: '/webhook/health',
  ITEMS: '/webhook/items',
  AUTH: {
    LOGIN: '/webhook/auth/login',
    REGISTER: '/webhook/auth/register',
    LOGOUT: '/webhook/auth/logout'
  }
};

// Rutas de la aplicación
export const ROUTES = {
  HOME: '/',
  ITEMS: '/items',
  ABOUT: '/about'
};

// Configuración de paginación
export const PAGINATION = {
  DEFAULT_PAGE: 1,
  DEFAULT_LIMIT: 10,
  PAGE_SIZE_OPTIONS: [5, 10, 25, 50]
};

// Mensajes
export const MESSAGES = {
  ERROR: {
    GENERIC: 'Ha ocurrido un error. Por favor, intenta de nuevo.',
    NETWORK: 'Error de conexión. Verifica tu conexión a internet.',
    NOT_FOUND: 'Recurso no encontrado.',
    UNAUTHORIZED: 'No autorizado. Por favor, inicia sesión.'
  },
  SUCCESS: {
    CREATED: 'Creado exitosamente',
    UPDATED: 'Actualizado exitosamente',
    DELETED: 'Eliminado exitosamente'
  }
};

// Estados HTTP
export const HTTP_STATUS = {
  OK: 200,
  CREATED: 201,
  BAD_REQUEST: 400,
  UNAUTHORIZED: 401,
  FORBIDDEN: 403,
  NOT_FOUND: 404,
  SERVER_ERROR: 500
};

// Configuración de tiempo
export const TIMEOUTS = {
  API_REQUEST: 30000, // 30 segundos
  DEBOUNCE: 300, // 300ms
  NOTIFICATION: 3000 // 3 segundos
};

// Expresiones regulares comunes
export const REGEX = {
  EMAIL: /^[^\s@]+@[^\s@]+\.[^\s@]+$/,
  PHONE: /^\d{10}$/,
  URL: /^https?:\/\/.+/
};

export default {
  APP_NAME,
  API_URL,
  ENV,
  ENDPOINTS,
  ROUTES,
  PAGINATION,
  MESSAGES,
  HTTP_STATUS,
  TIMEOUTS,
  REGEX
};

