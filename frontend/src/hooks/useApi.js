import { useState, useEffect } from 'react';

/**
 * Hook personalizado para manejar llamadas a la API
 * 
 * @param {Function} apiFunction - Función de API a ejecutar
 * @param {boolean} immediate - Si debe ejecutarse inmediatamente
 * @returns {Object} - { data, loading, error, refetch }
 */
export const useApi = (apiFunction, immediate = true) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  const execute = async (...params) => {
    try {
      setLoading(true);
      setError(null);
      const result = await apiFunction(...params);
      setData(result);
      return result;
    } catch (err) {
      setError(err.message || 'Error en la petición');
      throw err;
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (immediate) {
      execute();
    }
  }, []);

  return {
    data,
    loading,
    error,
    execute,
    refetch: execute
  };
};

export default useApi;

