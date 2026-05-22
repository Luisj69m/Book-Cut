import React from 'react';

const ModalConfirmar = ({ visible, titulo, mensaje, onConfirmar, onCancelar }) => {
  if (!visible) return null;

  return (
    <div style={{
      position: 'fixed', inset: 0, backgroundColor: 'rgba(0,0,0,0.5)',
      display: 'flex', alignItems: 'center', justifyContent: 'center', zIndex: 9999
    }}>
      <div className="animar-entrada" style={{
        backgroundColor: 'white', borderRadius: '12px', padding: '32px',
        maxWidth: '420px', width: '90%', boxShadow: '0 20px 40px rgba(0,0,0,0.25)'
      }}>
        <h3 style={{ margin: '0 0 8px 0', color: '#111827', fontSize: '18px', fontWeight: '600' }}>
          {titulo}
        </h3>
        <p style={{ margin: '0 0 28px 0', color: '#6b7280', fontSize: '14px', lineHeight: '1.6' }}>
          {mensaje}
        </p>
        <div style={{ display: 'flex', gap: '12px', justifyContent: 'flex-end' }}>
          <button
            onClick={onCancelar}
            style={{
              padding: '10px 20px', backgroundColor: '#f3f4f6', color: '#374151',
              border: '1px solid #d1d5db', borderRadius: '6px', cursor: 'pointer',
              fontWeight: '500', fontSize: '14px', transition: 'background-color 0.2s'
            }}
            onMouseOver={(e) => e.target.style.backgroundColor = '#e5e7eb'}
            onMouseOut={(e) => e.target.style.backgroundColor = '#f3f4f6'}
          >
            Cancelar
          </button>
          <button
            onClick={onConfirmar}
            style={{
              padding: '10px 20px', backgroundColor: '#dc2626', color: 'white',
              border: 'none', borderRadius: '6px', cursor: 'pointer',
              fontWeight: '600', fontSize: '14px', transition: 'background-color 0.2s'
            }}
            onMouseOver={(e) => e.target.style.backgroundColor = '#b91c1c'}
            onMouseOut={(e) => e.target.style.backgroundColor = '#dc2626'}
          >
            Confirmar
          </button>
        </div>
      </div>
    </div>
  );
};

export default ModalConfirmar;
