import { useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import './UserRegistration.css';

function RegistrationSuccess() {
  const navigate = useNavigate();

  useEffect(() => {
    // Redirigir al home después de 10 segundos
    const timer = setTimeout(() => {
      navigate('/');
    }, 10000);

    return () => clearTimeout(timer);
  }, [navigate]);

  return (
    <div className="registration-container">
      <div className="success-card">
        <div className="success-icon">🎉</div>
        <h2>¡Registro Completado Exitosamente!</h2>
        <p>Tus datos se han guardado y verificado correctamente.</p>
        
        <div className="success-animation">
          <div className="checkmark-circle">
            <div className="checkmark"></div>
          </div>
        </div>

        <div className="success-message">
          <h3 style={{ marginTop: '40px', color: '#333' }}>
            Próximos Pasos:
          </h3>
          <ol style={{ textAlign: 'left', maxWidth: '400px', margin: '20px auto', lineHeight: '2' }}>
            <li>Revisa tu email para verificar tu cuenta</li>
            <li>Regresa a WhatsApp</li>
            <li>¡Empieza a enviar tus consultas!</li>
          </ol>

          <div style={{ 
            marginTop: '30px', 
            padding: '20px', 
            background: '#f0f7ff', 
            borderRadius: '8px',
            border: '2px solid #2196F3'
          }}>
            <p style={{ margin: 0, color: '#1976D2', fontWeight: 600 }}>
              💬 Te hemos enviado un mensaje de confirmación por WhatsApp
            </p>
          </div>

          <p style={{ marginTop: '30px', fontSize: '14px', color: '#999' }}>
            Serás redirigido automáticamente en unos segundos...
          </p>
        </div>

        <button 
          onClick={() => navigate('/')}
          className="btn btn-primary"
          style={{ marginTop: '30px' }}
        >
          Ir al Inicio
        </button>
      </div>
    </div>
  );
}

export default RegistrationSuccess;

