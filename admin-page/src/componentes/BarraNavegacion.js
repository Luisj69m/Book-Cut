import React, { useState, useEffect } from 'react';
import { Link, useNavigate, useLocation } from 'react-router-dom';

const BarraNavegacion = ({ menuAbierto = false, onCerrar = () => {} }) => {
  const navigate = useNavigate();
  const location = useLocation();
  
  // Estado para el modo oscuro (por defecto falso)
  const [modoOscuro, setModoOscuro] = useState(false);

  // Al cargar el menú, comprobamos si el usuario ya tenía el modo oscuro guardado
  useEffect(() => {
    const temaGuardado = localStorage.getItem('tema');
    if (temaGuardado === 'dark') {
      setModoOscuro(true);
      document.body.classList.add('dark-theme');
    }
  }, []);

  // Función para alternar el tema
  const cambiarTema = () => {
    if (modoOscuro) {
      document.body.classList.remove('dark-theme');
      localStorage.setItem('tema', 'light');
      setModoOscuro(false);
    } else {
      document.body.classList.add('dark-theme');
      localStorage.setItem('tema', 'dark');
      setModoOscuro(true);
    }
  };

  const cerrarSesion = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('usuario');
    // Si cerramos sesión, podemos devolver el tema a la normalidad
    document.body.classList.remove('dark-theme'); 
    navigate('/login');
  };

  const estiloEnlace = (ruta) => {
    const activo = location.pathname === ruta;
    return {
      color: activo ? 'white' : '#a78bfa',
      textDecoration: 'none',
      fontSize: '15px',
      fontWeight: activo ? '600' : '400',
      padding: '10px 15px',
      borderRadius: '6px',
      backgroundColor: activo ? 'rgba(255, 255, 255, 0.1)' : 'transparent',
      transition: 'all 0.2s ease',
      display: 'block',
      letterSpacing: '0.3px'
    };
  };

  return (
<div
      className={`barra-lateral${menuAbierto ? ' menu-abierto' : ''}`}
      style={{
        width: '260px',
        height: '100vh',
        position: 'sticky',
        top: 0,
        overflowY: 'auto',
        backgroundColor: '#2e1065',
        color: 'white',
        display: 'flex',
        flexDirection: 'column',
        padding: '30px 20px',
        boxSizing: 'border-box',
        borderRight: '1px solid #1e1b4b'
      }}
    >
      
      <div style={{ marginBottom: '50px', padding: '0 10px' }}>
        <h2 style={{ margin: 0, fontSize: '22px', fontWeight: '700', letterSpacing: '-0.5px' }}>
          BOOK<span style={{ color: '#e96d71' }}>&</span>CUT
        </h2>
        <span style={{ fontSize: '11px', color: '#a78bfa', textTransform: 'uppercase', letterSpacing: '1px' }}>
          Workspace
        </span>
      </div>
      
      <div style={{ display: 'flex', flexDirection: 'column', gap: '8px', flexGrow: 1 }}>
        <p style={{ fontSize: '11px', color: '#8b5cf6', textTransform: 'uppercase', letterSpacing: '1px', marginBottom: '10px', paddingLeft: '10px', fontWeight: '600' }}>
          General
        </p>
        <Link to="/panel" style={estiloEnlace('/panel')} onClick={onCerrar}>Dashboard</Link>
        <Link to="/citas" style={estiloEnlace('/citas')} onClick={onCerrar}>Monitor de Citas</Link>

        <p style={{ fontSize: '11px', color: '#8b5cf6', textTransform: 'uppercase', letterSpacing: '1px', margin: '25px 0 10px 0', paddingLeft: '10px', fontWeight: '600' }}>
          Administración
        </p>
        <Link to="/barberos" style={estiloEnlace('/barberos')} onClick={onCerrar}>Profesionales</Link>
        <Link to="/barberias" style={estiloEnlace('/barberias')} onClick={onCerrar}>Sucursales</Link>
        <Link to="/usuarios" style={estiloEnlace('/usuarios')} onClick={onCerrar}>Directorio de Usuarios</Link>
      </div>

      {/* ZONA INFERIOR: Tema y Sesión */}
      <div style={{ borderTop: '1px solid rgba(255,255,255,0.1)', paddingTop: '20px', display: 'flex', flexDirection: 'column', gap: '5px' }}>

        {/* Indicador de sesión activa */}
        {(() => {
          try {
            const usuario = JSON.parse(localStorage.getItem('usuario'));
            const correo = usuario?.correoElectronico || usuario?.correo_electronico || usuario?.correo;
            if (!correo) return null;
            return (
              <div style={{ padding: '8px 15px', marginBottom: '5px' }}>
                <p style={{ margin: 0, fontSize: '10px', color: '#8b5cf6', textTransform: 'uppercase', letterSpacing: '1px', fontWeight: '600' }}>
                  Sesión activa
                </p>
                <p style={{ margin: '3px 0 0 0', fontSize: '12px', color: '#c4b5fd', wordBreak: 'break-all' }}>
                  {correo}
                </p>
              </div>
            );
          } catch { return null; }
        })()}
        
        {/* Botón Minimalista de Modo Oscuro */}
        <button 
          onClick={cambiarTema} 
          style={{ 
            width: '100%',
            padding: '10px 15px', 
            backgroundColor: 'transparent', 
            color: '#a78bfa', 
            border: 'none', 
            cursor: 'pointer', 
            fontWeight: '500',
            fontSize: '14px',
            textAlign: 'left',
            transition: 'color 0.2s'
          }}
          onMouseOver={(e) => e.target.style.color = 'white'}
          onMouseOut={(e) => e.target.style.color = '#a78bfa'}
        >
          {modoOscuro ? 'Cambiar a Tema Claro' : 'Cambiar a Tema Oscuro'}
        </button>

        <button 
          onClick={cerrarSesion} 
          style={{ 
            width: '100%',
            padding: '10px 15px', 
            backgroundColor: 'transparent', 
            color: '#fca5a5', 
            border: 'none', 
            cursor: 'pointer', 
            fontWeight: '500',
            fontSize: '14px',
            textAlign: 'left',
            transition: 'color 0.2s'
          }}
          onMouseOver={(e) => e.target.style.color = '#ef4444'}
          onMouseOut={(e) => e.target.style.color = '#fca5a5'}
        >
          Cerrar Sesión
        </button>
      </div>
    </div>
  );
};

export default BarraNavegacion;