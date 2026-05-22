import React, { useState, useEffect, useCallback } from 'react';
import servicioHttp from '../servicios/servicioHttp';
import ModalConfirmar from '../componentes/ModalConfirmar';
import Toast from '../componentes/Toast';

const GestionBarberias = () => {
  const [formulario, setFormulario] = useState({
    nombre: '',
    direccion: '',
    codigoPostal: '',
    zona: '',
    horario: '',
    descripcion: ''
  });

  const [listaSucursales, setListaSucursales] = useState([]);
  const [cargando, setCargando] = useState(false);
  const [mensaje, setMensaje] = useState('');
  const [modal, setModal] = useState({ visible: false, titulo: '', mensaje: '', accion: null });
  const [toast, setToast] = useState({ visible: false, mensaje: '', tipo: 'exito' });

  const mostrarToast = (mensaje, tipo = 'exito') => setToast({ visible: true, mensaje, tipo });
  const ocultarToast = useCallback(() => setToast(t => ({ ...t, visible: false })), []);
  const confirmar = (titulo, mensaje, accion) => setModal({ visible: true, titulo, mensaje, accion });
  const ejecutarModal = () => { modal.accion?.(); setModal({ visible: false, titulo: '', mensaje: '', accion: null }); };
  const cancelarModal = () => setModal({ visible: false, titulo: '', mensaje: '', accion: null });

  const [modoEdicion, setModoEdicion] = useState(false);
  const [idEdicion, setIdEdicion] = useState(null);

  const obtenerSucursales = async () => {
    try {
      const respuesta = await servicioHttp.get('/barberias');
      setListaSucursales(respuesta.data);
    } catch (error) {
      console.error("Error al cargar las sucursales:", error);
    }
  };

  useEffect(() => {
    obtenerSucursales();
  }, []);

  const manejarCambio = (e) => {
    const { name, value } = e.target;
    setFormulario({ ...formulario, [name]: value });
  };

  const manejarEnvio = async (e) => {
    e.preventDefault();
    setCargando(true);
    setMensaje('');

    const datosParaBackend = {
      nombre: formulario.nombre,
      direccionCompleta: `${formulario.direccion.trim()}, CP: ${formulario.codigoPostal.trim()}`,
      zona: formulario.zona,
      horario: formulario.horario,
      descripcion: formulario.descripcion
    };

    try {
      if (modoEdicion) {
        await servicioHttp.put(`/barberias/${idEdicion}`, datosParaBackend);
        setMensaje("Sucursal actualizada correctamente.");
        mostrarToast("Sucursal actualizada con éxito.");
      } else {
        await servicioHttp.post('/barberias/crear', datosParaBackend);
        setMensaje("Sucursal registrada correctamente.");
        mostrarToast("Sucursal creada con éxito.");
      }

      cancelarEdicion();
      obtenerSucursales();
    } catch (error) {
      console.error("Error al guardar:", error);
      setMensaje("Error al guardar la sucursal. Comprueba los datos.");
      mostrarToast("Error al procesar la solicitud.", 'error');
    } finally {
      setCargando(false);
    }
  };

  const activarEdicion = (sucursal) => {
    const idReal = sucursal.id || sucursal.idBarberia;
    setModoEdicion(true);
    setIdEdicion(idReal);
    
    let dirPura = sucursal.direccionCompleta || '';
    let cpPuro = '';
    
    if (dirPura.includes(', CP: ')) {
      const partes = dirPura.split(', CP: ');
      dirPura = partes[0];
      cpPuro = partes[1];
    }

    setFormulario({
      nombre: sucursal.nombre || '',
      direccion: dirPura,
      codigoPostal: cpPuro,
      zona: sucursal.zona || '',
      horario: sucursal.horario || '',
      descripcion: sucursal.descripcion || ''
    });
    
    setMensaje('');
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const cancelarEdicion = () => {
    setModoEdicion(false);
    setIdEdicion(null);
    setFormulario({
      nombre: '',
      direccion: '',
      codigoPostal: '',
      zona: '',
      horario: '',
      descripcion: ''
    });
    setMensaje('');
  };

  const darDeBaja = (idSucursal) => {
    confirmar(
      'Dar de baja sucursal',
      '¿Estás seguro de que quieres dar de baja esta sucursal? Esta acción no se puede deshacer.',
      async () => {
        try {
          await servicioHttp.delete(`/barberias/${idSucursal}`);
          setListaSucursales(prev => prev.filter(s => (s.id || s.idBarberia) !== idSucursal));
          mostrarToast("Sucursal dada de baja con éxito.");
        } catch (error) {
          console.error("Error al eliminar:", error);
          mostrarToast("No se pudo dar de baja la sucursal. Es posible que tenga barberos asignados.", 'error');
        }
      }
    );
  };

  return (
    <div style={{ padding: '40px', maxWidth: '900px', margin: '0 auto' }}>
      <ModalConfirmar visible={modal.visible} titulo={modal.titulo} mensaje={modal.mensaje} onConfirmar={ejecutarModal} onCancelar={cancelarModal} />
      <Toast visible={toast.visible} mensaje={toast.mensaje} tipo={toast.tipo} onOcultar={ocultarToast} />
      <h2 style={{ marginBottom: '5px', color: '#111827' }}>Gestión de Sucursales</h2>
      <p style={{ color: '#6b7280', marginBottom: '30px' }}>Administra los locales físicos y puntos de servicio.</p>

      {/* FORMULARIO */}
      <div style={{ backgroundColor: 'white', padding: '30px', borderRadius: '8px', border: '1px solid #e5e7eb', marginBottom: '40px' }}>
        <h3 style={{ marginTop: 0, marginBottom: '20px', fontSize: '18px', color: '#374151' }}>
          {modoEdicion ? `Actualizar Datos de la Sucursal #${idEdicion}` : 'Registrar Nueva Barbería'}
        </h3>
        
        <form onSubmit={manejarEnvio} autoComplete="off">
          <div className="fila-formulario" style={{ display: 'flex', gap: '20px', marginBottom: '20px' }}>
            <div style={{ flex: 1 }}>
              <label style={{ display: 'block', fontSize: '14px', marginBottom: '8px', color: '#4b5563' }}>Nombre del Local</label>
              <input
                type="text"
                name="nombre"
                placeholder="Ej: Book&Cut Centro"
                value={formulario.nombre}
                onChange={manejarCambio}
                required
                autoComplete="off" style={{ width: '100%', padding: '12px', borderRadius: '6px', border: '1px solid #d1d5db', outline: 'none', boxSizing: 'border-box' }}
              />
            </div>
            <div style={{ flex: 1 }}>
              <label style={{ display: 'block', fontSize: '14px', marginBottom: '8px', color: '#4b5563' }}>Zona / Ciudad</label>
              <input
                type="text"
                name="zona"
                placeholder="Ej: Madrid Centro"
                value={formulario.zona}
                onChange={manejarCambio}
                required
                autoComplete="off" style={{ width: '100%', padding: '12px', borderRadius: '6px', border: '1px solid #d1d5db', outline: 'none', boxSizing: 'border-box' }}
              />
            </div>
          </div>

          <div className="fila-formulario" style={{ display: 'flex', gap: '20px', marginBottom: '20px' }}>
            <div style={{ flex: 3 }}>
              <label style={{ display: 'block', fontSize: '14px', marginBottom: '8px', color: '#4b5563' }}>Dirección Física</label>
              <input
                type="text"
                name="direccion"
                placeholder="Calle, Número, Planta..."
                value={formulario.direccion}
                onChange={manejarCambio}
                required
                autoComplete="off" style={{ width: '100%', padding: '12px', borderRadius: '6px', border: '1px solid #d1d5db', outline: 'none', boxSizing: 'border-box' }}
              />
            </div>
            <div style={{ flex: 1 }}>
              <label style={{ display: 'block', fontSize: '14px', marginBottom: '8px', color: '#4b5563' }}>Código Postal</label>
              <input
                type="text"
                name="codigoPostal"
                placeholder="Ej: 28001"
                value={formulario.codigoPostal}
                onChange={manejarCambio}
                required
                autoComplete="off" style={{ width: '100%', padding: '12px', borderRadius: '6px', border: '1px solid #d1d5db', outline: 'none', boxSizing: 'border-box' }}
              />
            </div>
          </div>

          <div style={{ marginBottom: '20px' }}>
            <label style={{ display: 'block', fontSize: '14px', marginBottom: '8px', color: '#4b5563' }}>Horario</label>
            <input
              type="text"
              name="horario"
              placeholder="Ej: Lunes a Viernes de 09:00 a 20:00"
              value={formulario.horario}
              onChange={manejarCambio}
              required
              autoComplete="off" style={{ width: '100%', padding: '12px', borderRadius: '6px', border: '1px solid #d1d5db', outline: 'none', boxSizing: 'border-box' }}
            />
          </div>

          <div style={{ marginBottom: '20px' }}>
            <label style={{ display: 'block', fontSize: '14px', marginBottom: '8px', color: '#4b5563' }}>Descripción</label>
            <textarea
              name="descripcion"
              placeholder="Añade detalles sobre la sucursal..."
              value={formulario.descripcion}
              onChange={manejarCambio}
              required
              rows="3"
              autoComplete="off" style={{ width: '100%', padding: '12px', borderRadius: '6px', border: '1px solid #d1d5db', outline: 'none', boxSizing: 'border-box', resize: 'vertical' }}
            />
          </div>

          <div style={{ display: 'flex', gap: '15px' }}>
            <button 
              type="submit" 
              disabled={cargando}
              style={{ 
                padding: '12px 24px', 
                backgroundColor: modoEdicion ? '#059669' : '#4c1d95', 
                color: 'white', 
                border: 'none', 
                borderRadius: '6px',
                fontSize: '16px',
                fontWeight: 'bold',
                cursor: cargando ? 'not-allowed' : 'pointer'
              }}
            >
              {cargando ? 'Guardando...' : (modoEdicion ? 'Actualizar Sucursal' : 'Añadir Sucursal')}
            </button>

            {modoEdicion && (
              <button 
                type="button" 
                onClick={cancelarEdicion}
                style={{ 
                  padding: '12px 24px', 
                  backgroundColor: '#f3f4f6', 
                  color: '#4b5563', 
                  border: '1px solid #d1d5db', 
                  borderRadius: '6px',
                  fontSize: '16px',
                  fontWeight: 'bold',
                  cursor: 'pointer'
                }}
              >
                Cancelar
              </button>
            )}
          </div>

          {mensaje && (
            <div style={{ 
              marginTop: '20px', 
              padding: '12px', 
              textAlign: 'center', 
              backgroundColor: mensaje.includes('Error') ? '#fef2f2' : '#f0fdf4', 
              color: mensaje.includes('Error') ? '#991b1b' : '#166534', 
              borderRadius: '6px',
              border: `1px solid ${mensaje.includes('Error') ? '#fecaca' : '#bbf7d0'}`,
              fontWeight: '500'
            }}>
              {mensaje}
            </div>
          )}
        </form>
      </div>

      {/* LISTADO DE SUCURSALES */}
      <div style={{ backgroundColor: 'white', padding: '30px', borderRadius: '8px', border: '1px solid #e5e7eb' }}>
        <h3 style={{ marginTop: 0, marginBottom: '20px', fontSize: '18px', color: '#374151' }}>Listado de Sedes Activas</h3>
        
        {listaSucursales.length === 0 ? (
          <p style={{ color: '#6b7280', textAlign: 'center', padding: '20px' }}>No hay sucursales registradas actualmente.</p>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
            {listaSucursales.map((sucursal) => {
              const idReal = sucursal.id || sucursal.idBarberia;
              return (
                <div key={idReal} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', padding: '15px', border: '1px solid #e5e7eb', borderRadius: '6px' }}>
                  <div style={{ maxWidth: '70%' }}>
                    <h4 style={{ margin: '0 0 5px 0', color: '#111827', fontSize: '16px' }}>
                      <span style={{ color: '#4c1d95', marginRight: '8px' }}>#{idReal}</span> 
                      {sucursal.nombre} <span style={{ color: '#6b7280', fontWeight: 'normal', fontSize: '14px' }}>({sucursal.zona})</span>
                    </h4>
                    <p style={{ margin: '0 0 4px 0', fontSize: '14px', color: '#4b5563' }}>
                      <strong>Ubicación:</strong> {sucursal.direccionCompleta}
                    </p>
                    <p style={{ margin: 0, fontSize: '13px', color: '#6b7280' }}>
                      <strong>Horario:</strong> {sucursal.horario}
                    </p>
                  </div>
                  <div style={{ display: 'flex', gap: '10px' }}>
                    <button 
                      onClick={() => activarEdicion(sucursal)}
                      style={{ 
                        padding: '8px 16px', 
                        backgroundColor: '#f3f4f6', 
                        color: '#374151', 
                        border: '1px solid #d1d5db', 
                        borderRadius: '6px',
                        cursor: 'pointer',
                        fontWeight: 'bold'
                      }}
                    >
                      Editar
                    </button>
                    <button 
                      onClick={() => darDeBaja(idReal)}
                      style={{ 
                        padding: '8px 16px', 
                        backgroundColor: '#fee2e2', 
                        color: '#dc2626', 
                        border: '1px solid #f87171', 
                        borderRadius: '6px',
                        cursor: 'pointer',
                        fontWeight: 'bold'
                      }}
                    >
                      Dar de baja
                    </button>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
};

export default GestionBarberias;