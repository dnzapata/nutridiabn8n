import { useState, useEffect } from 'react';
import { nutridiabApi } from '../services/nutridiabApi';
import './Users.css';

function UsersDebug() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [rawResponse, setRawResponse] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalUsers, setTotalUsers] = useState(0);
  const usersPerPage = 15;

  useEffect(() => {
    fetchUsers();
  }, [currentPage, searchTerm]);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      console.log('🔍 Fetching users...');
      
      const response = await nutridiabApi.getUsers({
        page: currentPage,
        limit: usersPerPage,
        search: searchTerm
      });

      console.log('📦 Raw Response:', response);
      console.log('📦 Response Type:', typeof response);
      console.log('📦 Is Array:', Array.isArray(response));
      
      setRawResponse(JSON.stringify(response, null, 2));

      // Manejar diferentes formatos de respuesta de n8n
      let usersData = [];
      let total = 0;

      if (Array.isArray(response)) {
        console.log('✅ Response is array, length:', response.length);
        usersData = response;
        total = response.length;
      } else if (response && typeof response === 'object') {
        console.log('📋 Response is object, keys:', Object.keys(response));
        usersData = response.data || response.users || response.usuarios || [];
        total = response.total || response.totalUsers || usersData.length;
        console.log('📋 Extracted users:', usersData.length);
      }

      console.log('👥 Final users data:', usersData);
      console.log('📊 Total users:', total);

      setUsers(usersData);
      setTotalUsers(total);
      setError(null);
    } catch (err) {
      console.error('❌ Error al cargar usuarios:', err);
      console.error('❌ Error details:', err.response?.data);
      console.error('❌ Error status:', err.response?.status);
      setError('Error al cargar los usuarios. Verifica que el workflow de n8n esté activo.');
      setUsers([]);
      setRawResponse(JSON.stringify({
        error: err.message,
        response: err.response?.data,
        status: err.response?.status
      }, null, 2));
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateString) => {
    if (!dateString) return 'N/A';
    const date = new Date(dateString);
    return date.toLocaleDateString('es-MX', {
      year: 'numeric',
      month: 'long',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  if (loading && users.length === 0) {
    return (
      <div className="users-container">
        <div className="loading">
          <div className="spinner"></div>
          <p>Cargando usuarios...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="users-container">
      <div className="users-header">
        <h1>🔍 DEBUG: Gestión de Usuarios</h1>
        <p className="subtitle">Total de usuarios registrados: {totalUsers}</p>
      </div>

      {/* DEBUG INFO */}
      <div style={{
        background: '#f8f9fa',
        border: '2px solid #dee2e6',
        borderRadius: '8px',
        padding: '1rem',
        marginBottom: '2rem',
        fontFamily: 'monospace',
        fontSize: '0.875rem'
      }}>
        <h3 style={{ marginTop: 0 }}>📊 Debug Info:</h3>
        <ul style={{ listStyle: 'none', padding: 0 }}>
          <li>✅ Users array length: {users.length}</li>
          <li>✅ Total users: {totalUsers}</li>
          <li>✅ Loading: {loading ? 'true' : 'false'}</li>
          <li>✅ Error: {error || 'null'}</li>
        </ul>
        
        <h4>📦 Raw API Response:</h4>
        <pre style={{
          background: '#fff',
          padding: '1rem',
          borderRadius: '4px',
          overflow: 'auto',
          maxHeight: '400px'
        }}>
          {rawResponse || 'No response yet'}
        </pre>
      </div>

      {/* Barra de búsqueda y filtros */}
      <div className="users-controls">
        <div className="search-box">
          <span className="search-icon">🔍</span>
          <input
            type="text"
            placeholder="Buscar..."
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            className="search-input"
          />
        </div>
        <button 
          className="btn btn-primary"
          onClick={fetchUsers}
          disabled={loading}
        >
          🔄 Actualizar
        </button>
      </div>

      {error && (
        <div className="error-message">
          <span className="error-icon">⚠️</span>
          <span>{error}</span>
          <button onClick={fetchUsers} className="btn btn-secondary btn-sm">
            Reintentar
          </button>
        </div>
      )}

      {/* Tabla simplificada */}
      <div className="users-table-container">
        <table className="users-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Nombre</th>
              <th>Email</th>
              <th>Estado</th>
              <th>Fecha</th>
            </tr>
          </thead>
          <tbody>
            {users.length === 0 ? (
              <tr>
                <td colSpan="5" className="no-data">
                  📭 No hay usuarios (Array vacío)
                </td>
              </tr>
            ) : (
              users.map((user, index) => (
                <tr key={user.id || index}>
                  <td>{user.id || 'N/A'}</td>
                  <td>{user.nombre || 'N/A'} {user.apellido || ''}</td>
                  <td>{user.email || 'N/A'}</td>
                  <td>
                    <span className={`status-badge ${user.status === 'active' ? 'active' : 'inactive'}`}>
                      {user.status || 'N/A'}
                    </span>
                  </td>
                  <td>{formatDate(user.created_at)}</td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}

export default UsersDebug;


