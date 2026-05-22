import React, { useState, useEffect, useCallback } from 'react';
import servicioHttp from '../servicios/servicioHttp';
import ModalConfirmar from '../componentes/ModalConfirmar';
import Toast from '../componentes/Toast';
import { SkeletonFila } from '../componentes/Skeleton';

const ListadoUsuarios = () => {
  const [listaUsuarios, setListaUsuarios] = useState([]);
  const [usuariosFiltrados, setUsuariosFiltrados] = useState([]);
  const [busqueda, setBusqueda] = useState('');
  const [cargando, setCargando] = useState(true);
  const [modal, setModal] = useState({ visible: false, titulo: '', mensaje: '', accion: null });
  const [toast, setToast] = useState({ visible: false, mensaje: '', tipo: 'exito' });

  const mostrarToast = (mensaje, tipo = 'exito') => setToast({ visible: true, mensaje, tipo });
  const ocultarToast = useCallback(() => setToast(t => ({ ...t, visible: false })), []);
  const confirmar = (titulo, mensaje, accion) => setModal({ visible: true, titulo, mensaje, accion });
  const ejecutarModal = () => { modal.accion?.(); setModal({ visible: false, titulo: '', mensaje: '', accion: null }); };
  const cancelarModal = () => setModal({ visible: false, titulo: '', mensaje: '', accion: null });

  useEffect(() => {
    const obtenerUsuarios = async () => {
      try {
        const respuesta = await servicioHttp.get('usuarios/listar');
        setListaUsuarios(respuesta.data);
        setUsuariosFiltrados(respuesta.data);
      } catch (error) { console.error(error); }
      finally { setCargando(false); }
    };
    obtenerUsuarios();
  }, []);

  const obtenerNombreSucursal = (usuario) => {
    const rol = (usuario.rol_usuario || usuario.rolUsuario || '').toUpperCase();
    
    if (rol === 'CLIENTE') return 'N/A';
    if (rol === 'ADMIN') return 'Acceso Global';
    if (usuario.nombreBarberia) return usuario.nombreBarberia;

    return 'Sin asignar';
  };

  useEffect(() => {
    if (!busqueda.trim()) {
      setUsuariosFiltrados(listaUsuarios);
      return;
    }
    
    const resultados = listaUsuarios.filter(usuario => {
      const correo = usuario.correo_electronico || usuario.correoElectronico || '';
      const rol = usuario.rol_usuario || usuario.rolUsuario || '';
      const id = usuario.id_usuario || usuario.idUsuario || usuario.id || '';
      const sucursal = obtenerNombreSucursal(usuario);
      
      return correo.toLowerCase().includes(busqueda.toLowerCase()) ||
             rol.toLowerCase().includes(busqueda.toLowerCase()) ||
             id.toString().includes(busqueda) ||
             sucursal.toLowerCase().includes(busqueda.toLowerCase());
    });
    setUsuariosFiltrados(resultados);
  }, [busqueda, listaUsuarios]);

  const obtenerClaseBadge = (rol) => {
    if (rol === 'ADMIN') return 'badge badge-admin';
    if (rol === 'BARBERO') return 'badge badge-barbero';
    return 'badge badge-cliente';
  };

  const darDeBaja = async (usuario) => {
    const idReal = usuario.id_usuario || usuario.idUsuario || usuario.id;
    const rol = (usuario.rol_usuario || usuario.rolUsuario || '').toUpperCase();
    const correo = usuario.correo_electronico || usuario.correoElectronico;

    // Diagnóstico temporal: muestra el id y el objeto completo en consola
    console.log('🗑️ Intentando dar de baja. idReal:', idReal, '| Objeto usuario:', usuario);

    if (rol === 'ADMIN') {
      mostrarToast('No se puede dar de baja a un administrador.', 'error');
      return;
    }

    if (!idReal) {
      mostrarToast('Error: no se pudo identificar al usuario. Recarga la página.', 'error');
      return;
    }

    confirmar(
      'Dar de baja usuario',
      `¿Estás seguro de que deseas dar de baja a este ${rol.toLowerCase()} (${correo})? Esta acción no se puede deshacer.`,
      async () => {
        try {
          await servicioHttp.delete(`/usuarios/eliminar/${idReal}`);
          setListaUsuarios(prev => prev.filter(u => (u.id_usuario || u.idUsuario || u.id) !== idReal));
          setUsuariosFiltrados(prev => prev.filter(u => (u.id_usuario || u.idUsuario || u.id) !== idReal));
          mostrarToast('Usuario dado de baja correctamente.');
        } catch (error) {
          const status = error?.response?.status;
          const data = error?.response?.data;
          const mensajeServidor = data?.message || data?.error || (typeof data === 'string' ? data : '');
          console.error('Error al eliminar usuario:', status, data);
          mostrarToast(mensajeServidor || `Error ${status || ''}: No se pudo dar de baja al usuario.`, 'error');
        }
      }
    );
  };

  const exportarAExcel = () => {
    let contenidoCsv = 'ID,Correo Electronico,Rol del Sistema,Sucursal\n';
    
    usuariosFiltrados.forEach(usuario => {
      const id = usuario.id_usuario || usuario.idUsuario || usuario.id || '-';
      const correo = usuario.correo_electronico || usuario.correoElectronico || '';
      const rol = usuario.rol_usuario || usuario.rolUsuario || '';
      const sucursal = obtenerNombreSucursal(usuario);
      
      contenidoCsv += `${id},${correo},${rol},${sucursal}\n`;
    });

    const blob = new Blob(["\ufeff", contenidoCsv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    
    const enlaceOculto = document.createElement('a');
    enlaceOculto.href = url;
    enlaceOculto.setAttribute('download', 'Usuarios_BookCut.csv');
    document.body.appendChild(enlaceOculto);
    enlaceOculto.click();
    document.body.removeChild(enlaceOculto);
  };

  return (
    <div style={{ padding: '40px', maxWidth: '1100px', margin: '0 auto' }} className="animar-entrada">
      <ModalConfirmar visible={modal.visible} titulo={modal.titulo} mensaje={modal.mensaje} onConfirmar={ejecutarModal} onCancelar={cancelarModal} />
      <Toast visible={toast.visible} mensaje={toast.mensaje} tipo={toast.tipo} onOcultar={ocultarToast} />
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', marginBottom: '30px', flexWrap: 'wrap', gap: '20px' }}>
        <div>
          <h1 style={{ color: '#111827', margin: '0 0 5px 0', fontSize: '28px' }}>Directorio de Usuarios</h1>
          <p style={{ color: '#6b7280', margin: 0 }}>Gestiona la base de datos de clientes y staff.</p>
        </div>
        
        <div style={{ display: 'flex', gap: '15px', alignItems: 'center' }}>
          <div style={{ position: 'relative', width: '280px' }}>
            <input 
              type="text" 
              className="input-moderno" 
              placeholder="Buscar email, rol, ID o sucursal..." 
              value={busqueda}
              onChange={(e) => setBusqueda(e.target.value)}
              style={{ padding: '10px 15px', fontSize: '13px', borderRadius: '6px', width: '100%', boxSizing: 'border-box' }}
            />
          </div>
          
          <button 
            onClick={exportarAExcel}
            style={{
              padding: '10px 16px',
              backgroundColor: '#111827',
              color: 'white',
              border: 'none',
              borderRadius: '6px',
              fontWeight: '500',
              fontSize: '13px',
              cursor: 'pointer',
              transition: 'background-color 0.2s',
              whiteSpace: 'nowrap'
            }}
            onMouseOver={(e) => e.target.style.backgroundColor = '#374151'}
            onMouseOut={(e) => e.target.style.backgroundColor = '#111827'}
          >
            Exportar CSV
          </button>
        </div>
      </div>

      {cargando ? (
        <div className="contenedor-tabla">
          <table className="tabla-moderna">
            <thead><tr><th>ID</th><th>Correo Electrónico</th><th>Rol del Sistema</th><th>Sucursal</th><th style={{ textAlign: 'right' }}>Acciones</th></tr></thead>
            <tbody>{Array.from({ length: 6 }).map((_, i) => <SkeletonFila key={i} columnas={5} />)}</tbody>
          </table>
        </div>
      ) : (
        <div className="contenedor-tabla">
          <table className="tabla-moderna">
            <thead>
              <tr>
                <th>ID</th>
                <th>Correo Electrónico</th>
                <th>Rol del Sistema</th>
                <th>Sucursal</th>
                <th style={{ textAlign: 'right' }}>Acciones</th>
              </tr>
            </thead>
            <tbody>
              {usuariosFiltrados.length > 0 ? (
                usuariosFiltrados.map((usuario) => (
                  <tr key={usuario.id_usuario || usuario.idUsuario || usuario.id}>
                    <td style={{ fontWeight: '600', color: '#6b7280' }}>#{usuario.id_usuario || usuario.idUsuario || usuario.id}</td>
                    <td>{usuario.correo_electronico || usuario.correoElectronico}</td>
                    <td>
                      <span className={obtenerClaseBadge(usuario.rol_usuario || usuario.rolUsuario)}>
                        {usuario.rol_usuario || usuario.rolUsuario}
                      </span>
                    </td>
                    <td style={{ color: '#4b5563', fontSize: '13px', fontWeight: '500' }}>
                      {obtenerNombreSucursal(usuario)}
                    </td>
                    <td style={{ textAlign: 'right' }}>
                      {/* El botón solo se muestra si el rol no es ADMIN */}
                      {(usuario.rol_usuario || usuario.rolUsuario || '').toUpperCase() !== 'ADMIN' && (
                        <button 
                          onClick={() => darDeBaja(usuario)}
                          style={{
                            padding: '6px 12px',
                            backgroundColor: 'transparent',
                            color: '#dc2626',
                            border: '1px solid #f87171',
                            borderRadius: '4px',
                            fontSize: '12px',
                            fontWeight: '600',
                            cursor: 'pointer',
                            transition: 'all 0.2s'
                          }}
                          onMouseOver={(e) => {
                            e.target.style.backgroundColor = '#fee2e2';
                          }}
                          onMouseOut={(e) => {
                            e.target.style.backgroundColor = 'transparent';
                          }}
                        >
                          Dar de baja
                        </button>
                      )}
                    </td>
                  </tr>
                ))
              ) : (
                <tr><td colSpan="5" style={{ textAlign: 'center', padding: '40px', color: '#9ca3af' }}>No se encontraron usuarios que coincidan con "{busqueda}".</td></tr>
              )}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};

export default ListadoUsuarios;