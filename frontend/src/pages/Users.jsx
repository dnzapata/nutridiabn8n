import { useState, useEffect } from 'react';
import { nutridiabApi } from '../services/nutridiabApi';
import './Users.css';

function Users() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalUsers, setTotalUsers] = useState(0);
  const [selectedUser, setSelectedUser] = useState(null);
  const [showUserDetail, setShowUserDetail] = useState(false);
  const usersPerPage = 15;

  useEffect(() => {
    fetchUsers();
  }, [currentPage, searchTerm]);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const response = await nutridiabApi.getUsers({
        page: currentPage,
        limit: usersPerPage,
        search: searchTerm
      });

      // Manejar diferentes formatos de respuesta de n8n
      let usersData = [];
      let total = 0;

      if (Array.isArray(response)) {
        usersData = response;
        total = response.length;
      } else if (response && typeof response === 'object') {
        usersData = response.data || response.users || response.usuarios || [];
        total = response.total || response.totalUsers || usersData.length;
      }

      setUsers(usersData);
      setTotalUsers(total);
      setError(null);
    } catch (err) {
      console.error('Error al cargar usuarios:', err);
      setError('Error al cargar los usuarios. Verifica que el workflow de n8n esté activo.');
      setUsers([]);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = (e) => {
    setSearchTerm(e.target.value);
    setCurrentPage(1); // Resetear a primera página al buscar
  };

  const handleUserClick = async (user) => {
    try {
      setSelectedUser(user);
      setShowUserDetail(true);
    } catch (err) {
      console.error('Error al cargar detalles del usuario:', err);
    }
  };

  const closeUserDetail = () => {
    setShowUserDetail(false);
    setSelectedUser(null);
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

  const totalPages = Math.ceil(totalUsers / usersPerPage);

  const goToNextPage = () => {
    if (currentPage < totalPages) {
      setCurrentPage(currentPage + 1);
    }
  };

  const goToPreviousPage = () => {
    if (currentPage > 1) {
      setCurrentPage(currentPage - 1);
    }
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
        <h1>👥 Gestión de Usuarios</h1>
        <p className="subtitle">Total de usuarios registrados: {totalUsers}</p>
      </div>

      {/* Barra de búsqueda y filtros */}
      <div className="users-controls">
        <div className="search-box">
          <span className="search-icon">🔍</span>
          <input
            type="text"
            placeholder="Buscar por nombre, apellido, email o teléfono..."
            value={searchTerm}
            onChange={handleSearch}
            className="search-input"
          />
          {searchTerm && (
            <button 
              className="clear-search"
              onClick={() => setSearchTerm('')}
              title="Limpiar búsqueda"
            >
              ✕
            </button>
          )}
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

      {/* Tabla de usuarios */}
      <div className="users-table-container">
        <table className="users-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Nombre</th>
              <th>Apellido</th>
              <th>Email</th>
              <th>Teléfono</th>
              <th>Estado</th>
              <th>Verificado</th>
              <th>Rol</th>
              <th>Fecha Registro</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            {users.length === 0 ? (
              <tr>
                <td colSpan="10" className="no-data">
                  {searchTerm 
                    ? '🔍 No se encontraron usuarios con ese criterio de búsqueda'
                    : '📭 No hay usuarios registrados'
                  }
                </td>
              </tr>
            ) : (
              users.map((user) => (
                <tr key={user.id} onClick={() => handleUserClick(user)} className="user-row">
                  <td className="user-id">{user.id}</td>
                  <td className="user-name">{user.nombre || 'N/A'}</td>
                  <td className="user-lastname">{user.apellido || 'N/A'}</td>
                  <td className="user-email">{user.email || 'N/A'}</td>
                  <td className="user-phone">{user.remotejid || user.telefono || 'N/A'}</td>
                  <td>
                    <span className={`status-badge ${user.status === 'active' ? 'active' : 'inactive'}`}>
                      {user.status === 'active' ? '✓ Activo' : '✗ Inactivo'}
                    </span>
                  </td>
                  <td>
                    <span className={`verified-badge ${user.verified ? 'verified' : 'not-verified'}`}>
                      {user.verified ? '✓ Sí' : '✗ No'}
                    </span>
                  </td>
                  <td>
                    <span className={`role-badge ${user.role || 'user'}`}>
                      {user.role === 'admin' ? '👑 Admin' : '👤 Usuario'}
                    </span>
                  </td>
                  <td className="user-date">{formatDate(user.created_at)}</td>
                  <td>
                    <button 
                      className="btn-icon"
                      onClick={(e) => {
                        e.stopPropagation();
                        handleUserClick(user);
                      }}
                      title="Ver detalles"
                    >
                      👁️
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Paginación */}
      {totalPages > 1 && (
        <div className="pagination">
          <button
            onClick={goToPreviousPage}
            disabled={currentPage === 1 || loading}
            className="btn btn-secondary"
          >
            ← Anterior
          </button>
          <span className="page-info">
            Página {currentPage} de {totalPages}
          </span>
          <button
            onClick={goToNextPage}
            disabled={currentPage >= totalPages || loading}
            className="btn btn-secondary"
          >
            Siguiente →
          </button>
        </div>
      )}

      {/* Modal de detalles del usuario */}
      {showUserDetail && selectedUser && (
        <div className="modal-overlay" onClick={closeUserDetail}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>📋 Detalles del Usuario</h2>
              <button className="close-button" onClick={closeUserDetail}>
                ✕
              </button>
            </div>
            <div className="modal-body">
              <div className="detail-section">
                <h3>Información Personal</h3>
                <div className="detail-grid">
                  <div className="detail-item">
                    <span className="detail-label">ID:</span>
                    <span className="detail-value">{selectedUser.id}</span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Nombre Completo:</span>
                    <span className="detail-value">
                      {selectedUser.nombre} {selectedUser.apellido}
                    </span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Email:</span>
                    <span className="detail-value">{selectedUser.email || 'N/A'}</span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Teléfono:</span>
                    <span className="detail-value">{selectedUser.remotejid || selectedUser.telefono || 'N/A'}</span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Edad:</span>
                    <span className="detail-value">{selectedUser.edad || 'N/A'}</span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Peso:</span>
                    <span className="detail-value">{selectedUser.peso ? `${selectedUser.peso} kg` : 'N/A'}</span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Altura:</span>
                    <span className="detail-value">{selectedUser.altura ? `${selectedUser.altura} cm` : 'N/A'}</span>
                  </div>
                </div>
              </div>

              <div className="detail-section">
                <h3>Estado de la Cuenta</h3>
                <div className="detail-grid">
                  <div className="detail-item">
                    <span className="detail-label">Estado:</span>
                    <span className={`status-badge ${selectedUser.status === 'active' ? 'active' : 'inactive'}`}>
                      {selectedUser.status === 'active' ? '✓ Activo' : '✗ Inactivo'}
                    </span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Verificado:</span>
                    <span className={`verified-badge ${selectedUser.verified ? 'verified' : 'not-verified'}`}>
                      {selectedUser.verified ? '✓ Sí' : '✗ No'}
                    </span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Rol:</span>
                    <span className={`role-badge ${selectedUser.role || 'user'}`}>
                      {selectedUser.role === 'admin' ? '👑 Administrador' : '👤 Usuario'}
                    </span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Fecha de Registro:</span>
                    <span className="detail-value">{formatDate(selectedUser.created_at)}</span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Última Actualización:</span>
                    <span className="detail-value">{formatDate(selectedUser.updated_at)}</span>
                  </div>
                </div>
              </div>

              {selectedUser.objetivos && (
                <div className="detail-section">
                  <h3>Objetivos</h3>
                  <p className="detail-text">{selectedUser.objetivos}</p>
                </div>
              )}

              {selectedUser.restricciones && (
                <div className="detail-section">
                  <h3>Restricciones Alimentarias</h3>
                  <p className="detail-text">{selectedUser.restricciones}</p>
                </div>
              )}
            </div>
            <div className="modal-footer">
              <button className="btn btn-secondary" onClick={closeUserDetail}>
                Cerrar
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default Users;

