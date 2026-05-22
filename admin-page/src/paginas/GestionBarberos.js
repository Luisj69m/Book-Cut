import React, { useState, useEffect, useCallback } from 'react';
import servicioHttp from '../servicios/servicioHttp';
import Toast from '../componentes/Toast';

const GestionBarberos = () => {
  // 1. Estados iniciales
  const [formulario, setFormulario] = useState({
    nombre: '',
    apellidos: '',
    telefono: '',
    correo: '',
    contrasena: '',
    idBarberia: '' 
  });

  const [listaSucursales, setListaSucursales] = useState([]);
  const [cargando, setCargando] = useState(false);
  const [mensaje, setMensaje] = useState('');
  const [toast, setToast] = useState({ visible: false, mensaje: '', tipo: 'exito' });

  const mostrarToast = (mensaje, tipo = 'exito') => setToast({ visible: true, mensaje, tipo });
  const ocultarToast = useCallback(() => setToast(t => ({ ...t, visible: false })), []);

  // 2. Descargar las sucursales al abrir la página
  useEffect(() => {
    const obtenerSucursales = async () => {
      try {
        const respuesta = await servicioHttp.get('/barberias');
        setListaSucursales(respuesta.data);
      } catch (error) {
        console.error("Error al cargar las sucursales:", error);
      }
    };
    obtenerSucursales();
  }, []);

  // 3. Manejar cambios con validaciones estrictas
  const manejarCambio = (e) => {
    const { name, value } = e.target;

    // Validación para el teléfono: solo números y máximo 9 dígitos
    if (name === 'telefono') {
      const soloNumeros = value.replace(/[^0-9]/g, '');
      const soloNueve = soloNumeros.slice(0, 9);
      setFormulario({ ...formulario, [name]: soloNueve });
      return;
    }

    // Validación para nombre y apellidos: solo letras y espacios
    if (name === 'nombre' || name === 'apellidos') {
      const soloLetras = value.replace(/[^a-zA-ZáéíóúÁÉÍÓÚñÑ\s]/g, '');
      setFormulario({ ...formulario, [name]: soloLetras });
      return;
    }

    // Resto de campos
    setFormulario({ ...formulario, [name]: value });
  };

  // 4. Enviar los datos al servidor
  const manejarEnvio = async (e) => {
    e.preventDefault();

    // Bloqueo de seguridad: Validar que la sucursal esté seleccionada
    if (!formulario.idBarberia || formulario.idBarberia === '') {
      mostrarToast("Debes asignar una sucursal al profesional.", 'error');
      return;
    }

    if (formulario.telefono.length !== 9) {
      mostrarToast("El teléfono debe tener exactamente 9 dígitos.", 'error');
      return;
    }

    setCargando(true);
    setMensaje('');

    // Transformamos nuestros datos al formato exacto que pide Iván
    const datosParaBackend = {
      nombreUsuario: formulario.nombre.trim(),
      apellidos: formulario.apellidos.trim(),
      correoElectronico: formulario.correo,
      contrasenaUsuario: formulario.contrasena,
      telefonoUsuario: formulario.telefono,
      idBarberia: Number(formulario.idBarberia)
    };

    console.log('📤 Enviando al backend:', JSON.stringify(datosParaBackend, null, 2));

    try {
      // Enviamos a la nueva ruta exacta que te ha pasado Iván
      await servicioHttp.post('/usuarios/admin/registrar-barbero', datosParaBackend);
      setMensaje("Profesional creado y asignado a la sucursal correctamente.");
      mostrarToast("Profesional creado correctamente.");
      setFormulario({ nombre: '', apellidos: '', telefono: '', correo: '', contrasena: '', idBarberia: '' });
    } catch (error) {
      const status = error?.response?.status;
      const data = error?.response?.data;
      console.error('❌ Error del servidor:', status, data);
      const mensajeServidor = data?.message || data?.error || (typeof data === 'string' ? data : '');
      setMensaje(mensajeServidor || "Error al crear el profesional. Comprueba la conexión o los datos.");
      mostrarToast(mensajeServidor || "Error al crear el profesional.", 'error');
    } finally {
      setCargando(false);
    }
  };

  return (
    <div style={{ padding: '40px', maxWidth: '800px', margin: '0 auto' }}>
      <Toast visible={toast.visible} mensaje={toast.mensaje} tipo={toast.tipo} onOcultar={ocultarToast} />
      <h2 style={{ marginBottom: '5px', color: '#111827' }}>Añadir Profesional</h2>
      <p style={{ color: '#6b7280', marginBottom: '30px' }}>Registra un nuevo barbero en la plataforma y asígnale su centro de trabajo.</p>

      <form onSubmit={manejarEnvio} autoComplete="off" style={{ backgroundColor: 'white', padding: '30px', borderRadius: '8px', border: '1px solid #e5e7eb' }}>

        {/* Señuelo para que Chrome no muestre el gestor de contraseñas */}
        <input type="text" style={{ display: 'none' }} readOnly />
        <input type="password" style={{ display: 'none' }} readOnly />

        <div className="fila-formulario" style={{ display: 'flex', gap: '20px', marginBottom: '20px' }}>
          <input
            type="text"
            name="nombre"
            placeholder="Nombre"
            value={formulario.nombre}
            onChange={manejarCambio}
            required
            autoComplete="off" style={{ flex: 1, padding: '12px', borderRadius: '6px', border: '1px solid #d1d5db', outline: 'none' }}
          />
          <input
            type="text"
            name="apellidos"
            placeholder="Apellidos"
            value={formulario.apellidos}
            onChange={manejarCambio}
            required
            autoComplete="off" style={{ flex: 1, padding: '12px', borderRadius: '6px', border: '1px solid #d1d5db', outline: 'none' }}
          />
        </div>

        <div style={{ marginBottom: '20px' }}>
          <input
            type="text"
            name="telefono"
            placeholder="Teléfono (9 dígitos)"
            value={formulario.telefono}
            onChange={manejarCambio}
            maxLength="9"
            required
            autoComplete="off" style={{ width: '100%', padding: '12px', borderRadius: '6px', border: '1px solid #d1d5db', boxSizing: 'border-box', outline: 'none' }}
          />
        </div>

        <div className="fila-formulario" style={{ display: 'flex', gap: '20px', marginBottom: '20px' }}>
          <input
            type="text"
            name="correo"
            placeholder="Correo Electrónico"
            value={formulario.correo}
            onChange={manejarCambio}
            required
            autoComplete="nope" style={{ flex: 1, padding: '12px', borderRadius: '6px', border: '1px solid #d1d5db', outline: 'none' }}
          />
          <input
            type="password"
            name="contrasena"
            placeholder="Contraseña"
            value={formulario.contrasena}
            onChange={manejarCambio}
            required
            autoComplete="new-password" style={{ flex: 1, padding: '12px', borderRadius: '6px', border: '1px solid #d1d5db', outline: 'none' }}
          />
        </div>

        <div style={{ marginBottom: '30px' }}>
          <select 
            name="idBarberia" 
            value={formulario.idBarberia} 
            onChange={manejarCambio}
            required
            style={{ 
              width: '100%', 
              padding: '12px', 
              borderRadius: '6px', 
              border: '1px solid #d1d5db',
              backgroundColor: '#f8fafc',
              color: formulario.idBarberia === '' ? '#9ca3af' : '#111827',
              fontSize: '14px',
              boxSizing: 'border-box',
              outline: 'none',
              cursor: 'pointer'
            }}
          >
            <option value="" disabled>-- Selecciona una sucursal de destino --</option>
            {listaSucursales.map((sucursal) => (
              <option key={sucursal.id || sucursal.idBarberia} value={sucursal.id || sucursal.idBarberia}>
                {sucursal.nombre} - {sucursal.direccion}
              </option>
            ))}
          </select>
        </div>

        <button 
          type="submit" 
          disabled={cargando}
          style={{ 
            width: '100%', 
            padding: '14px', 
            backgroundColor: '#4c1d95', 
            color: 'white', 
            border: 'none', 
            borderRadius: '6px',
            fontSize: '16px',
            fontWeight: 'bold',
            cursor: cargando ? 'not-allowed' : 'pointer',
            transition: 'background-color 0.2s'
          }}
        >
          {cargando ? 'Procesando...' : 'Confirmar y Crear Cuenta'}
        </button>

        {mensaje && (
          <div style={{ 
            marginTop: '20px', 
            padding: '12px', 
            textAlign: 'center', 
            backgroundColor: mensaje.includes('Error') ? '#fef2f2' : '#f0fdf4', 
            color: mensaje.includes('Error') ? '#991b1b' : '#166534', 
            borderRadius: '6px',
            border: `1px solid ${mensaje.includes('Error') ? '#fecaca' : '#bbf7d0'}`
          }}>
            {mensaje}
          </div>
        )}
      </form>
    </div>
  );
};

export default GestionBarberos;