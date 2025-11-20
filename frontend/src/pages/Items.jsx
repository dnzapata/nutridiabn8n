import { useState, useEffect } from 'react'
import { apiService } from '../services/api'
import './Items.css'

function Items() {
  const [items, setItems] = useState([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState(null)
  const [showForm, setShowForm] = useState(false)
  const [formData, setFormData] = useState({
    name: '',
    description: ''
  })

  useEffect(() => {
    fetchItems()
  }, [])

  const fetchItems = async () => {
    try {
      setLoading(true)
      const data = await apiService.getItems()
      setItems(Array.isArray(data) ? data : [])
      setError(null)
    } catch (err) {
      setError('Error al cargar los items. Verifica que el workflow esté activo en n8n.')
      console.error('Error al obtener items:', err)
    } finally {
      setLoading(false)
    }
  }

  const handleSubmit = async (e) => {
    e.preventDefault()
    try {
      await apiService.createItem(formData)
      setFormData({ name: '', description: '' })
      setShowForm(false)
      fetchItems()
    } catch (err) {
      setError('Error al crear el item')
      console.error('Error al crear item:', err)
    }
  }

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    })
  }

  return (
    <div className="items-page">
      <div className="page-header">
        <h1>Gestión de Items</h1>
        <button 
          onClick={() => setShowForm(!showForm)} 
          className="btn btn-primary"
        >
          {showForm ? '✕ Cancelar' : '+ Nuevo Item'}
        </button>
      </div>

      {error && (
        <div className="error">
          {error}
          <button onClick={fetchItems} className="btn btn-secondary" style={{ marginLeft: '16px' }}>
            Reintentar
          </button>
        </div>
      )}

      {showForm && (
        <div className="card form-card">
          <h2>Crear Nuevo Item</h2>
          <form onSubmit={handleSubmit}>
            <div className="form-group">
              <label htmlFor="name">Nombre:</label>
              <input
                type="text"
                id="name"
                name="name"
                value={formData.name}
                onChange={handleChange}
                required
                placeholder="Ingresa el nombre del item"
              />
            </div>
            <div className="form-group">
              <label htmlFor="description">Descripción:</label>
              <textarea
                id="description"
                name="description"
                value={formData.description}
                onChange={handleChange}
                required
                placeholder="Ingresa una descripción"
                rows="4"
              />
            </div>
            <button type="submit" className="btn btn-primary">
              Crear Item
            </button>
          </form>
        </div>
      )}

      {loading ? (
        <div className="loading">Cargando items...</div>
      ) : (
        <div className="items-grid">
          {items.length === 0 ? (
            <div className="card empty-state">
              <p>No hay items disponibles. ¡Crea el primero!</p>
            </div>
          ) : (
            items.map((item) => (
              <div key={item.id} className="card item-card">
                <div className="item-header">
                  <h3>{item.name}</h3>
                  <span className="item-id">#{item.id}</span>
                </div>
                <p className="item-description">{item.description}</p>
                {item.createdAt && (
                  <p className="item-date">
                    Creado: {new Date(item.createdAt).toLocaleString('es-MX')}
                  </p>
                )}
                <div className="item-actions">
                  <button className="btn btn-secondary btn-sm">
                    Editar
                  </button>
                  <button className="btn btn-danger btn-sm">
                    Eliminar
                  </button>
                </div>
              </div>
            ))
          )}
        </div>
      )}
    </div>
  )
}

export default Items

