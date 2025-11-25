import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { nutridiabApi } from '../services/nutridiabApi';
import './Dashboard.css';

function Dashboard() {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [recentActivity, setRecentActivity] = useState([]);

  useEffect(() => {
    fetchDashboardData();
  }, []);

  const fetchDashboardData = async () => {
    try {
      setLoading(true);
      
      // Obtener estadísticas reales desde n8n
      const statsResponse = await nutridiabApi.getStats();
      
      // Manejar diferentes formatos de respuesta de n8n
      // PostgreSQL en n8n devuelve un array, tomamos el primer elemento
      let statsData = {};
      if (Array.isArray(statsResponse) && statsResponse.length > 0) {
        statsData = statsResponse[0];
      } else if (statsResponse && typeof statsResponse === 'object') {
        statsData = statsResponse.data || statsResponse.stats || statsResponse;
      }
      
      // Transformar datos de Supabase al formato del componente
      const transformedStats = {
        totalUsers: statsData.total_usuarios || 0,
        totalConsultas: statsData.total_consultas || 0,
        totalCost: parseFloat(statsData.costo_total) || 0,
        avgCostPerQuery: statsData.total_consultas > 0 
          ? (parseFloat(statsData.costo_total) / statsData.total_consultas).toFixed(4)
          : 0,
        consultasHoy: statsData.consultas_hoy || 0,
        newUsersToday: statsData.usuarios_hoy || 0,
        tipoStats: {
          texto: statsData.consultas_texto || 0,
          imagen: statsData.consultas_imagen || 0,
          audio: statsData.consultas_audio || 0
        }
      };

      // Obtener actividad reciente
      const consultasResponse = await nutridiabApi.getRecentQueries(10);
      
      // Manejar diferentes formatos de respuesta de n8n
      // n8n puede devolver un array directamente o un objeto con los datos
      let consultasRecientes = [];
      if (Array.isArray(consultasResponse)) {
        consultasRecientes = consultasResponse;
      } else if (consultasResponse && typeof consultasResponse === 'object') {
        // Si es un objeto, intentar extraer el array
        consultasRecientes = consultasResponse.data || consultasResponse.results || consultasResponse.consultas || [];
      }
      
      const transformedActivity = consultasRecientes.map(consulta => ({
        id: consulta.id,
        usuario: consulta.nombre && consulta.apellido 
          ? `${consulta.nombre} ${consulta.apellido}` 
          : consulta.email || 'Usuario',
        tipo: consulta.tipo,
        consulta: consulta.resultado ? consulta.resultado.substring(0, 50) + '...' : 'Sin resultado',
        resultado: consulta.resultado || 'Procesando...',
        fecha: consulta.created_at,
        costo: parseFloat(consulta.Costo) || 0
      }));

      setStats(transformedStats);
      setRecentActivity(transformedActivity);
      setError(null);
    } catch (err) {
      console.error('Error al cargar dashboard:', err);
      setError('Error al cargar el dashboard. Verifica que los workflows de n8n estén activos.');
      
      // Fallback a datos de ejemplo si hay error
      const mockStats = {
        totalUsers: 0,
        totalConsultas: 0,
        totalCost: 0,
        avgCostPerQuery: 0,
        consultasHoy: 0,
        newUsersToday: 0,
        tipoStats: {
          texto: 0,
          imagen: 0,
          audio: 0
        }
      };
      setStats(mockStats);
      setRecentActivity([]);
    } finally {
      setLoading(false);
    }
  };

  const formatCurrency = (amount) => {
    return new Intl.NumberFormat('es-US', {
      style: 'currency',
      currency: 'USD',
      minimumFractionDigits: 2
    }).format(amount);
  };

  const formatDate = (dateString) => {
    const date = new Date(dateString);
    const now = new Date();
    const diff = now - date;
    const minutes = Math.floor(diff / 60000);
    
    if (minutes < 1) return 'Hace un momento';
    if (minutes < 60) return `Hace ${minutes} minutos`;
    if (minutes < 1440) return `Hace ${Math.floor(minutes / 60)} horas`;
    return date.toLocaleDateString('es-MX');
  };

  const getTipoIcon = (tipo) => {
    switch (tipo) {
      case 'texto': return '📝';
      case 'imagen': return '📸';
      case 'audio': return '🎤';
      default: return '❓';
    }
  };

  if (loading) {
    return <div className="loading">Cargando dashboard...</div>;
  }

  if (error) {
    return (
      <div className="error">
        {error}
        <button onClick={fetchDashboardData} className="btn btn-secondary">
          Reintentar
        </button>
      </div>
    );
  }

  return (
    <div className="dashboard">
      <div className="dashboard-header">
        <h1>🩺 Dashboard NutriDiab</h1>
        <p className="subtitle">Panel de administración del asistente nutricional</p>
      </div>

      {/* Estadísticas principales */}
      <div className="stats-grid">
        <div className="stat-card primary">
          <div className="stat-icon">👥</div>
          <div className="stat-content">
            <h3>Usuarios Totales</h3>
            <p className="stat-number">{stats.totalUsers}</p>
            <span className="stat-badge">+{stats.newUsersToday} hoy</span>
          </div>
        </div>

        <div className="stat-card success">
          <div className="stat-icon">💬</div>
          <div className="stat-content">
            <h3>Consultas Totales</h3>
            <p className="stat-number">{stats.totalConsultas.toLocaleString()}</p>
            <span className="stat-badge">{stats.consultasHoy} hoy</span>
          </div>
        </div>

        <div className="stat-card warning">
          <div className="stat-icon">💰</div>
          <div className="stat-content">
            <h3>Costo Total</h3>
            <p className="stat-number">{formatCurrency(stats.totalCost)}</p>
            <span className="stat-badge">{formatCurrency(stats.avgCostPerQuery)}/consulta</span>
          </div>
        </div>

        <div className="stat-card info">
          <div className="stat-icon">📊</div>
          <div className="stat-content">
            <h3>Promedio Diario</h3>
            <p className="stat-number">{Math.round(stats.totalConsultas / 30)}</p>
            <span className="stat-badge">últimos 30 días</span>
          </div>
        </div>
      </div>

      {/* Distribución por tipo */}
      <div className="card">
        <h2>Distribución de Consultas por Tipo</h2>
        <div className="tipo-stats">
          <div className="tipo-item">
            <div className="tipo-header">
              <span className="tipo-icon">📝</span>
              <span className="tipo-name">Texto</span>
            </div>
            <div className="tipo-progress">
              <div 
                className="tipo-bar texto" 
                style={{ width: `${(stats.tipoStats.texto / stats.totalConsultas) * 100}%` }}
              />
            </div>
            <div className="tipo-count">{stats.tipoStats.texto} consultas</div>
          </div>

          <div className="tipo-item">
            <div className="tipo-header">
              <span className="tipo-icon">📸</span>
              <span className="tipo-name">Imagen</span>
            </div>
            <div className="tipo-progress">
              <div 
                className="tipo-bar imagen" 
                style={{ width: `${(stats.tipoStats.imagen / stats.totalConsultas) * 100}%` }}
              />
            </div>
            <div className="tipo-count">{stats.tipoStats.imagen} consultas</div>
          </div>

          <div className="tipo-item">
            <div className="tipo-header">
              <span className="tipo-icon">🎤</span>
              <span className="tipo-name">Audio</span>
            </div>
            <div className="tipo-progress">
              <div 
                className="tipo-bar audio" 
                style={{ width: `${(stats.tipoStats.audio / stats.totalConsultas) * 100}%` }}
              />
            </div>
            <div className="tipo-count">{stats.tipoStats.audio} consultas</div>
          </div>
        </div>
      </div>

      {/* Actividad reciente */}
      <div className="card">
        <div className="card-header-with-action">
          <h2>Actividad Reciente</h2>
          <button className="btn btn-secondary btn-sm" onClick={fetchDashboardData}>
            🔄 Actualizar
          </button>
        </div>
        <div className="activity-list">
          {recentActivity.map((activity) => (
            <div key={activity.id} className="activity-item">
              <div className="activity-icon">
                {getTipoIcon(activity.tipo)}
              </div>
              <div className="activity-content">
                <div className="activity-user">{activity.usuario}</div>
                <div className="activity-query">{activity.consulta}</div>
                <div className="activity-result">→ {activity.resultado}</div>
              </div>
              <div className="activity-meta">
                <div className="activity-time">{formatDate(activity.fecha)}</div>
                <div className="activity-cost">{formatCurrency(activity.costo)}</div>
              </div>
            </div>
          ))}
        </div>
      </div>

      {/* Quick Actions */}
      <div className="quick-actions">
        <h2>Acciones Rápidas</h2>
        <div className="actions-grid">
          <Link to="/users" className="action-button">
            <span className="action-icon">👥</span>
            <span className="action-text">Ver Usuarios</span>
          </Link>
          <Link to="/consultas" className="action-button">
            <span className="action-icon">💬</span>
            <span className="action-text">Ver Consultas</span>
          </Link>
          <Link to="/costos" className="action-button">
            <span className="action-icon">💰</span>
            <span className="action-text">Análisis de Costos</span>
          </Link>
          <a href="https://wf.zynaptic.tech" target="_blank" rel="noopener noreferrer" className="action-button">
            <span className="action-icon">⚙️</span>
            <span className="action-text">Configurar n8n</span>
          </a>
        </div>
      </div>
    </div>
  );
}

export default Dashboard;

