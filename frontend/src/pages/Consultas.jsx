import { useState, useEffect } from 'react';
import { nutridiabApi } from '../services/nutridiabApi';
import './Consultas.css';

function Consultas() {
  const [consultas, setConsultas] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [tipoFilter, setTipoFilter] = useState('todos');
  const [currentPage, setCurrentPage] = useState(1);
  const [totalConsultas, setTotalConsultas] = useState(0);
  const [selectedConsulta, setSelectedConsulta] = useState(null);
  const [showConsultaDetail, setShowConsultaDetail] = useState(false);
  const consultasPerPage = 20;

  useEffect(() => {
    fetchConsultas();
  }, [currentPage, searchTerm, tipoFilter]);

  const fetchConsultas = async () => {
    try {
      setLoading(true);
      const response = await nutridiabApi.getConsultas({
        page: currentPage,
        limit: consultasPerPage,
        search: searchTerm,
        tipo: tipoFilter !== 'todos' ? tipoFilter : undefined
      });

      // Manejar diferentes formatos de respuesta de n8n
      let consultasData = [];
      let total = 0;

      if (Array.isArray(response)) {
        consultasData = response;
        total = response.length;
      } else if (response && typeof response === 'object') {
        // Soportar múltiples formatos: data, consultas, results, value
        consultasData = response.data || response.consultas || response.results || response.value || [];
        total = response.total || response.totalConsultas || response.Count || consultasData.length;
      }

      setConsultas(consultasData);
      setTotalConsultas(total);
      setError(null);
    } catch (err) {
      console.error('Error al cargar consultas:', err);
      setError('Error al cargar las consultas. Verifica que el workflow de n8n esté activo.');
      setConsultas([]);
    } finally {
      setLoading(false);
    }
  };

  const handleSearch = (e) => {
    setSearchTerm(e.target.value);
    setCurrentPage(1); // Resetear a primera página al buscar
  };

  const handleTipoFilter = (tipo) => {
    setTipoFilter(tipo);
    setCurrentPage(1);
  };

  const handleConsultaClick = (consulta) => {
    setSelectedConsulta(consulta);
    setShowConsultaDetail(true);
  };

  const closeConsultaDetail = () => {
    setShowConsultaDetail(false);
    setSelectedConsulta(null);
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

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('es-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 4
    }).format(amount);
  };

  const getTipoIcon = (tipo) => {
    switch (tipo?.toLowerCase()) {
      case 'texto': return '📝';
      case 'imagen': return '📸';
      case 'audio': return '🎤';
      default: return '❓';
    }
  };

  const getTipoBadgeClass = (tipo) => {
    switch (tipo?.toLowerCase()) {
      case 'texto': return 'tipo-texto';
      case 'imagen': return 'tipo-imagen';
      case 'audio': return 'tipo-audio';
      default: return 'tipo-default';
    }
  };

  const totalPages = Math.ceil(totalConsultas / consultasPerPage);

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

  if (loading && consultas.length === 0) {
    return (
      <div className="consultas-container">
        <div className="loading">
          <div className="spinner"></div>
          <p>Cargando consultas...</p>
        </div>
      </div>
    );
  }

  return (
    <div className="consultas-container">
      <div className="consultas-header">
        <h1>💬 Gestión de Consultas</h1>
        <p className="subtitle">Total de consultas realizadas: {totalConsultas}</p>
      </div>

      {/* Barra de búsqueda y filtros */}
      <div className="consultas-controls">
        <div className="search-box">
          <span className="search-icon">🔍</span>
          <input
            type="text"
            placeholder="Buscar por usuario, email o contenido..."
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

        {/* Filtros por tipo */}
        <div className="filter-buttons">
          <button 
            className={`filter-btn ${tipoFilter === 'todos' ? 'active' : ''}`}
            onClick={() => handleTipoFilter('todos')}
          >
            Todos
          </button>
          <button 
            className={`filter-btn ${tipoFilter === 'texto' ? 'active' : ''}`}
            onClick={() => handleTipoFilter('texto')}
          >
            📝 Texto
          </button>
          <button 
            className={`filter-btn ${tipoFilter === 'imagen' ? 'active' : ''}`}
            onClick={() => handleTipoFilter('imagen')}
          >
            📸 Imagen
          </button>
          <button 
            className={`filter-btn ${tipoFilter === 'audio' ? 'active' : ''}`}
            onClick={() => handleTipoFilter('audio')}
          >
            🎤 Audio
          </button>
        </div>

        <button 
          className="btn btn-primary"
          onClick={fetchConsultas}
          disabled={loading}
        >
          🔄 Actualizar
        </button>
      </div>

      {error && (
        <div className="error-message">
          <span className="error-icon">⚠️</span>
          <span>{error}</span>
          <button onClick={fetchConsultas} className="btn btn-secondary btn-sm">
            Reintentar
          </button>
        </div>
      )}

      {/* Tabla de consultas */}
      <div className="consultas-table-container">
        <table className="consultas-table">
          <thead>
            <tr>
              <th>ID</th>
              <th>Usuario</th>
              <th>Email</th>
              <th>RemoteJid</th>
              <th>Tipo</th>
              <th>Resultado</th>
              <th>Costo</th>
              <th>Fecha</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            {consultas.length === 0 ? (
              <tr>
                <td colSpan="9" className="no-data">
                  {searchTerm || tipoFilter !== 'todos'
                    ? '🔍 No se encontraron consultas con ese criterio de búsqueda'
                    : '📭 No hay consultas registradas'
                  }
                </td>
              </tr>
            ) : (
              consultas.map((consulta) => (
                <tr 
                  key={consulta.id} 
                  onClick={() => handleConsultaClick(consulta)} 
                  className="consulta-row"
                >
                  <td className="consulta-id">{consulta.id}</td>
                  <td className="consulta-usuario">
                    {consulta.nombre && consulta.apellido 
                      ? `${consulta.nombre} ${consulta.apellido}`
                      : 'N/A'}
                  </td>
                  <td className="consulta-email">{consulta.email || 'N/A'}</td>
                  <td className="consulta-remotejid">{consulta.remoteJid || 'N/A'}</td>
                  <td>
                    <span className={`tipo-badge ${getTipoBadgeClass(consulta.tipo)}`}>
                      {getTipoIcon(consulta.tipo)} {consulta.tipo}
                    </span>
                  </td>
                  <td className="consulta-resultado">
                    {consulta.resultado 
                      ? consulta.resultado.substring(0, 60) + (consulta.resultado.length > 60 ? '...' : '')
                      : 'Sin resultado'}
                  </td>
                  <td className="consulta-costo">
                    {formatCurrency(parseFloat(consulta.Costo) || 0)}
                  </td>
                  <td className="consulta-fecha">{formatDate(consulta.created_at)}</td>
                  <td>
                    <button 
                      className="btn-icon"
                      onClick={(e) => {
                        e.stopPropagation();
                        handleConsultaClick(consulta);
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

      {/* Modal de detalles de la consulta */}
      {showConsultaDetail && selectedConsulta && (
        <div className="modal-overlay" onClick={closeConsultaDetail}>
          <div className="modal-content" onClick={(e) => e.stopPropagation()}>
            <div className="modal-header">
              <h2>📋 Detalles de la Consulta</h2>
              <button className="close-button" onClick={closeConsultaDetail}>
                ✕
              </button>
            </div>
            <div className="modal-body">
              <div className="detail-section">
                <h3>Información de la Consulta</h3>
                <div className="detail-grid">
                  <div className="detail-item">
                    <span className="detail-label">ID:</span>
                    <span className="detail-value">{selectedConsulta.id}</span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Tipo:</span>
                    <span className={`tipo-badge ${getTipoBadgeClass(selectedConsulta.tipo)}`}>
                      {getTipoIcon(selectedConsulta.tipo)} {selectedConsulta.tipo}
                    </span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Costo:</span>
                    <span className="detail-value">
                      {formatCurrency(parseFloat(selectedConsulta.Costo) || 0)}
                    </span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Fecha:</span>
                    <span className="detail-value">{formatDate(selectedConsulta.created_at)}</span>
                  </div>
                </div>
              </div>

              <div className="detail-section">
                <h3>Información del Usuario</h3>
                <div className="detail-grid">
                  <div className="detail-item">
                    <span className="detail-label">Nombre:</span>
                    <span className="detail-value">
                      {selectedConsulta.nombre && selectedConsulta.apellido 
                        ? `${selectedConsulta.nombre} ${selectedConsulta.apellido}`
                        : 'N/A'}
                    </span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Email:</span>
                    <span className="detail-value">{selectedConsulta.email || 'N/A'}</span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">RemoteJid (WhatsApp):</span>
                    <span className="detail-value">{selectedConsulta.remoteJid || 'N/A'}</span>
                  </div>
                </div>
              </div>

              <div className="detail-section">
                <h3>Resultado</h3>
                <div className="resultado-container">
                  <p className="resultado-text">
                    {selectedConsulta.resultado || 'Sin resultado disponible'}
                  </p>
                </div>
              </div>
            </div>
            <div className="modal-footer">
              <button className="btn btn-secondary" onClick={closeConsultaDetail}>
                Cerrar
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default Consultas;

