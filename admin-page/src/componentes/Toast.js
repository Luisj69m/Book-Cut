import React, { useEffect } from 'react';

const Toast = ({ visible, mensaje, tipo = 'exito', onOcultar }) => {
  useEffect(() => {
    if (!visible) return;
    const t = setTimeout(onOcultar, 3500);
    return () => clearTimeout(t);
  }, [visible, onOcultar]);

  if (!visible) return null;

  return (
    <div className={`mensaje-alerta ${tipo === 'exito' ? 'alerta-exito' : 'alerta-error'}`}>
      <span style={{ fontSize: '16px', fontWeight: '700' }}>
        {tipo === 'exito' ? '✓' : '✕'}
      </span>
      {mensaje}
    </div>
  );
};

export default Toast;
