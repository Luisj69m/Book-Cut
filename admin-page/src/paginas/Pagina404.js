import React from 'react';
import { useNavigate } from 'react-router-dom';

const Pagina404 = () => {
  const navigate = useNavigate();

  return (
    <div style={{
      display: 'flex', flexDirection: 'column', alignItems: 'center',
      justifyContent: 'center', height: '100vh', textAlign: 'center',
      padding: '40px', backgroundColor: '#f4f7fb'
    }} className="animar-entrada">

      <div style={{
        fontSize: '120px', fontWeight: '800', letterSpacing: '-6px',
        background: 'linear-gradient(135deg, #381483 0%, #e96d71 100%)',
        WebkitBackgroundClip: 'text', WebkitTextFillColor: 'transparent',
        lineHeight: 1, marginBottom: '10px', userSelect: 'none'
      }}>
        404
      </div>

      <h2 style={{ color: '#111827', fontSize: '22px', fontWeight: '600', margin: '0 0 10px 0' }}>
        Página no encontrada
      </h2>
      <p style={{ color: '#6b7280', fontSize: '15px', maxWidth: '380px', lineHeight: '1.6', margin: '0 0 35px 0' }}>
        La ruta que intentas visitar no existe o ha sido eliminada. Vuelve al panel para continuar trabajando.
      </p>

      <button
        onClick={() => navigate('/panel')}
        className="boton-primario"
        style={{ width: 'auto', padding: '12px 32px', fontSize: '15px' }}
      >
        Volver al Panel
      </button>

    </div>
  );
};

export default Pagina404;
