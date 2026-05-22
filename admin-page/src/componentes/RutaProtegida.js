import React, { useCallback, useState } from 'react';
import { Navigate, Outlet, useNavigate } from 'react-router-dom';
import BarraNavegacion from './BarraNavegacion';
import useInactividad from '../hooks/useInactividad';

const tokenEsValido = (token) => {
  try {
    const payload = JSON.parse(atob(token.split('.')[1]));
    return payload.exp * 1000 > Date.now();
  } catch {
    return false;
  }
};

export const RutaProtegida = () => {
  const token = localStorage.getItem('token');
  const datosUsuarioTexto = localStorage.getItem('usuario');
  const navigate = useNavigate();

  // --- TODOS LOS HOOKS PRIMERO, SIN EXCEPCIÓN ---
  const [menuAbierto, setMenuAbierto] = useState(false);

  const cerrarSesionPorInactividad = useCallback(() => {
    localStorage.removeItem('token');
    localStorage.removeItem('usuario');
    navigate('/login', { state: { motivoCierre: 'inactividad' } });
  }, [navigate]);

  useInactividad(15, cerrarSesionPorInactividad);

  // --- LÓGICA CONDICIONAL DESPUÉS DE LOS HOOKS ---

  if (token && !tokenEsValido(token)) {
    localStorage.removeItem('token');
    localStorage.removeItem('usuario');
    return <Navigate to="/login" replace />;
  }

  let usuario = null;
  if (datosUsuarioTexto) {
    usuario = JSON.parse(datosUsuarioTexto);
  }

  const esAdministrador = token && usuario && usuario.rolUsuario === 'ADMIN';

  if (!esAdministrador) {
    return <Navigate to="/login" replace />;
  }

  return (
    <div className="layout-principal">
      <BarraNavegacion menuAbierto={menuAbierto} onCerrar={() => setMenuAbierto(false)} />

      {menuAbierto && (
        <div className="overlay-menu" onClick={() => setMenuAbierto(false)} />
      )}

      <div className="contenido-principal">
        <div className="barra-movil">
          <button className="boton-hamburguesa" onClick={() => setMenuAbierto(true)}>☰</button>
          <span style={{ fontWeight: '700', fontSize: '18px', letterSpacing: '-0.5px' }}>
            BOOK<span style={{ color: '#e96d71' }}>&</span>CUT
          </span>
        </div>
        <Outlet />
      </div>
    </div>
  );
};
