import { useState, useEffect } from 'react';
import { useSearchParams, useNavigate } from 'react-router-dom';
import api from '../services/api';
import './UserRegistration.css';

function UserRegistration() {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const token = searchParams.get('token');

  const [loading, setLoading] = useState(true);
  const [validatingToken, setValidatingToken] = useState(true);
  const [tokenValid, setTokenValid] = useState(false);
  const [userData, setUserData] = useState(null);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(false);

  const [formData, setFormData] = useState({
    nombre: '',
    apellido: '',
    email: '',
    telefono: '',
    fecha_nacimiento: '',
    tipo_diabetes: '',
    anios_diagnostico: '',
    usa_insulina: false,
    medicamentos: ''
  });

  useEffect(() => {
    if (!token) {
      setError('Token no proporcionado');
      setValidatingToken(false);
      setLoading(false);
      return;
    }

    validateToken();
  }, [token]);

  const validateToken = async () => {
    try {
      const response = await api.post('/webhook/nutridiab/validate-token', { token });
      
      if (response.data.valid) {
        setTokenValid(true);
        setUserData(response.data.user);
        
        // Pre-llenar formulario si hay datos
        if (response.data.user) {
          setFormData(prev => ({
            ...prev,
            nombre: response.data.user.nombre || '',
            apellido: response.data.user.apellido || '',
            email: response.data.user.email || '',
            telefono: response.data.user.telefono || '',
            fecha_nacimiento: response.data.user.fecha_nacimiento || '',
            tipo_diabetes: response.data.user.tipo_diabetes || '',
            anios_diagnostico: response.data.user.anios_diagnostico || '',
            usa_insulina: response.data.user.usa_insulina || false,
            medicamentos: response.data.user.medicamentos || ''
          }));
        }
      } else {
        setError(response.data.expired ? 
          'El enlace ha expirado. Por favor, solicita uno nuevo desde WhatsApp.' :
          'El enlace no es válido.'
        );
      }
    } catch (err) {
      setError('Error al validar el enlace. Por favor, intenta de nuevo.');
      console.error('Error validando token:', err);
    } finally {
      setValidatingToken(false);
      setLoading(false);
    }
  };

  const handleChange = (e) => {
    const { name, value, type, checked } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: type === 'checkbox' ? checked : value
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);

    try {
      const response = await api.post('/webhook/nutridiab/complete-registration', {
        token,
        ...formData
      });

      if (response.data.success) {
        setSuccess(true);
        setTimeout(() => {
          navigate('/registro-exitoso');
        }, 3000);
      } else {
        setError(response.data.message || 'Error al guardar los datos');
      }
    } catch (err) {
      setError('Error al guardar los datos. Por favor, intenta de nuevo.');
      console.error('Error al guardar:', err);
    } finally {
      setLoading(false);
    }
  };

  if (validatingToken) {
    return (
      <div className="registration-container">
        <div className="loading-card">
          <div className="spinner"></div>
          <p>Validando enlace...</p>
        </div>
      </div>
    );
  }

  if (!tokenValid || error) {
    return (
      <div className="registration-container">
        <div className="error-card">
          <div className="error-icon">⚠️</div>
          <h2>Enlace Inválido</h2>
          <p>{error}</p>
          <div className="error-help">
            <p>Para obtener un nuevo enlace:</p>
            <ol>
              <li>Envía un mensaje por WhatsApp</li>
              <li>Sigue las instrucciones del asistente</li>
            </ol>
          </div>
        </div>
      </div>
    );
  }

  if (success) {
    return (
      <div className="registration-container">
        <div className="success-card">
          <div className="success-icon">✅</div>
          <h2>¡Registro Completado!</h2>
          <p>Tus datos se han guardado correctamente.</p>
          <p className="success-message">
            Ahora puedes regresar a WhatsApp y empezar a usar NutriDiab. 
            Te enviaremos un mensaje de confirmación.
          </p>
          <div className="success-animation">
            <div className="checkmark-circle">
              <div className="checkmark"></div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="registration-container">
      <div className="registration-card">
        <div className="registration-header">
          <div className="logo">🩺 NutriDiab</div>
          <h1>Completa tu Perfil</h1>
          <p className="subtitle">
            Necesitamos algunos datos para brindarte un mejor servicio personalizado
          </p>
        </div>

        {error && (
          <div className="alert alert-error">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="registration-form">
          {/* Datos Personales */}
          <div className="form-section">
            <h3>📋 Datos Personales</h3>
            
            <div className="form-row">
              <div className="form-group">
                <label htmlFor="nombre">Nombre *</label>
                <input
                  type="text"
                  id="nombre"
                  name="nombre"
                  value={formData.nombre}
                  onChange={handleChange}
                  required
                  placeholder="Tu nombre"
                />
              </div>

              <div className="form-group">
                <label htmlFor="apellido">Apellido *</label>
                <input
                  type="text"
                  id="apellido"
                  name="apellido"
                  value={formData.apellido}
                  onChange={handleChange}
                  required
                  placeholder="Tu apellido"
                />
              </div>
            </div>

            <div className="form-group">
              <label htmlFor="email">Email *</label>
              <input
                type="email"
                id="email"
                name="email"
                value={formData.email}
                onChange={handleChange}
                required
                placeholder="tu@email.com"
              />
              <small>Te enviaremos un email de verificación</small>
            </div>

            <div className="form-row">
              <div className="form-group">
                <label htmlFor="telefono">Teléfono</label>
                <input
                  type="tel"
                  id="telefono"
                  name="telefono"
                  value={formData.telefono}
                  onChange={handleChange}
                  placeholder="+52 123 456 7890"
                />
              </div>

              <div className="form-group">
                <label htmlFor="fecha_nacimiento">Fecha de Nacimiento</label>
                <input
                  type="date"
                  id="fecha_nacimiento"
                  name="fecha_nacimiento"
                  value={formData.fecha_nacimiento}
                  onChange={handleChange}
                />
              </div>
            </div>
          </div>

          {/* Datos Médicos */}
          <div className="form-section">
            <h3>💉 Información Médica</h3>

            <div className="form-group">
              <label htmlFor="tipo_diabetes">Tipo de Diabetes *</label>
              <select
                id="tipo_diabetes"
                name="tipo_diabetes"
                value={formData.tipo_diabetes}
                onChange={handleChange}
                required
              >
                <option value="">Selecciona una opción</option>
                <option value="tipo1">Diabetes Tipo 1</option>
                <option value="tipo2">Diabetes Tipo 2</option>
                <option value="gestacional">Diabetes Gestacional</option>
                <option value="prediabetes">Prediabetes</option>
                <option value="otro">Otro</option>
              </select>
            </div>

            <div className="form-group">
              <label htmlFor="anios_diagnostico">Años desde el diagnóstico</label>
              <input
                type="number"
                id="anios_diagnostico"
                name="anios_diagnostico"
                value={formData.anios_diagnostico}
                onChange={handleChange}
                min="0"
                max="100"
                placeholder="¿Cuántos años?"
              />
            </div>

            <div className="form-group checkbox-group">
              <label className="checkbox-label">
                <input
                  type="checkbox"
                  name="usa_insulina"
                  checked={formData.usa_insulina}
                  onChange={handleChange}
                />
                <span>Uso insulina</span>
              </label>
            </div>

            <div className="form-group">
              <label htmlFor="medicamentos">Medicamentos que tomas (opcional)</label>
              <textarea
                id="medicamentos"
                name="medicamentos"
                value={formData.medicamentos}
                onChange={handleChange}
                rows="4"
                placeholder="Ej: Metformina 850mg, Insulina Lantus 20UI..."
              />
              <small>Lista los medicamentos que tomas actualmente</small>
            </div>
          </div>

          {/* Privacy Notice */}
          <div className="privacy-notice">
            <p>
              🔒 Tus datos están protegidos y solo serán usados para mejorar 
              tu experiencia con NutriDiab. No compartiremos tu información 
              con terceros.
            </p>
          </div>

          {/* Submit Button */}
          <button 
            type="submit" 
            className="btn btn-primary btn-large"
            disabled={loading}
          >
            {loading ? (
              <>
                <span className="spinner-small"></span>
                Guardando...
              </>
            ) : (
              <>
                Guardar y Continuar
              </>
            )}
          </button>

          <p className="form-footer">
            * Campos obligatorios
          </p>
        </form>
      </div>
    </div>
  );
}

export default UserRegistration;

