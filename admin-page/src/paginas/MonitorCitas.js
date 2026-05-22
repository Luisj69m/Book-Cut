import React, { useState, useEffect } from 'react';
import servicioHttp from '../servicios/servicioHttp';
import { Calendar, momentLocalizer, Views } from 'react-big-calendar';
import moment from 'moment';
import 'moment/locale/es';
import 'react-big-calendar/lib/css/react-big-calendar.css';

moment.locale('es');
const localizer = momentLocalizer(moment);

const MonitorCitas = () => {
  const [listaCitas, setListaCitas] = useState([]);
  const [listaBarberias, setListaBarberias] = useState([]);
  const [sucursalSeleccionada, setSucursalSeleccionada] = useState('');
  
  const [cargando, setCargando] = useState(true);
  const [vistaActiva, setVistaActiva] = useState('calendario');
  const [fechaCalendario, setFechaCalendario] = useState(new Date());
  const [vistaTipoCalendario, setVistaTipoCalendario] = useState(Views.WEEK);

  // 1. Cargar las sucursales una sola vez al entrar a la página
  useEffect(() => {
    const cargarBarberias = async () => {
      try {
        const respuesta = await servicioHttp.get('/barberias');
        setListaBarberias(respuesta.data);
      } catch (error) {
        console.error("Error al obtener la lista de sucursales", error);
      }
    };
    cargarBarberias();
  }, []);

  // 2. Cargar las citas cada vez que el usuario cambie el menú desplegable
useEffect(() => {
    const obtenerCitas = async () => {
      setCargando(true);
      try {
        const ruta = sucursalSeleccionada === '' 
          ? '/citas/todas' 
          : `/citas/barberia/${sucursalSeleccionada}`;
          
        const respuesta = await servicioHttp.get(ruta);
        
        // ESCUDO PROTECTOR: Comprobamos si lo que envía Iván es realmente un Array
        if (Array.isArray(respuesta.data)) {
          setListaCitas(respuesta.data);
        } else {
          console.warn("El servidor no ha devuelto una lista. Probablemente haya un error en el backend:", respuesta.data);
          setListaCitas([]); // Forzamos un array vacío para que el .map() no explote
        }

      } catch (error) {
        console.error("Error al obtener las citas", error);
        setListaCitas([]); // Si da error 404 o 500, también forzamos el array vacío
      } finally {
        setCargando(false);
      }
    };
    
    obtenerCitas();
  }, [sucursalSeleccionada]);
  
  const obtenerNombreCliente = (cita) => cita.nombreCliente || cita.correoCliente || '-';
  const obtenerServicio      = (cita) => cita.nombreServicio  || '-';
  const obtenerNombreBarbero = (cita) => cita.nombreBarbero   || '-';
  const obtenerNombreBarberia= (cita) => cita.nombreBarberia  || '-';

  // Parseo robusto: acepta "2026-05-10T11:00:00", "2026-05-10 11:00:00" y timestamps
  const parsearFecha = (fechaStr) => {
    if (!fechaStr) return null;
    // Intento 1: formato estándar
    let fecha = new Date(fechaStr);
    if (!isNaN(fecha.getTime())) return fecha;
    // Intento 2: espacio en vez de T
    fecha = new Date(String(fechaStr).replace(' ', 'T'));
    if (!isNaN(fecha.getTime())) return fecha;
    return null;
  };

  const eventosCalendario = listaCitas.map(cita => {
    const fechaInicio = parsearFecha(cita.fechaHoraCita) || new Date();
    const fechaFin = new Date(fechaInicio.getTime() + 60 * 60 * 1000);
    return {
      id: cita.idCita || cita.id,
      title: `${obtenerNombreCliente(cita)} · ${obtenerNombreBarbero(cita)}`,
      start: fechaInicio,
      end: fechaFin,
      estado: cita.estadoCita || 'PENDIENTE'
    };
  });

  const estiloEvento = (evento) => {
    let backgroundColor = '#3b82f6';
    if (evento.estado?.toUpperCase() === 'ACEPTADA')   backgroundColor = '#8b5cf6';
    if (evento.estado?.toUpperCase() === 'COMPLETADA') backgroundColor = '#10b981';
    if (evento.estado?.toUpperCase() === 'CANCELADA')  backgroundColor = '#ef4444';
    if (evento.estado?.toUpperCase() === 'RECHAZADA')  backgroundColor = '#6b7280';
    if (evento.estado?.toUpperCase() === 'VENCIDA')    backgroundColor = '#f97316';

    return {
      style: {
        backgroundColor,
        border: 'none',
        borderRadius: '6px',
        opacity: 0.9,
        color: 'white',
        fontSize: '12px',
        fontWeight: '500',
        padding: '3px 6px'
      }
    };
  };

  const obtenerEstiloEstadoTabla = (estado) => {
    const base = { padding: '4px 10px', borderRadius: '4px', fontSize: '11px', fontWeight: '600', textTransform: 'uppercase', letterSpacing: '0.5px' };
    switch (estado?.toUpperCase()) {
      case 'ACEPTADA':   return { ...base, backgroundColor: '#f5f3ff', color: '#5b21b6', border: '1px solid #ddd6fe' };
      case 'COMPLETADA': return { ...base, backgroundColor: '#f0fdf4', color: '#166534', border: '1px solid #bbf7d0' };
      case 'CANCELADA':  return { ...base, backgroundColor: '#fef2f2', color: '#991b1b', border: '1px solid #fecaca' };
      case 'RECHAZADA':  return { ...base, backgroundColor: '#f9fafb', color: '#374151', border: '1px solid #d1d5db' };
      case 'VENCIDA':    return { ...base, backgroundColor: '#fff7ed', color: '#9a3412', border: '1px solid #fed7aa' };
      default:           return { ...base, backgroundColor: '#f8fafc', color: '#475569', border: '1px solid #e2e8f0' }; 
    }
  };

  const BotonVista = ({ tipo, texto }) => (
    <button 
      onClick={() => setVistaActiva(tipo)}
      className={`boton-toggle ${vistaActiva === tipo ? 'activo' : ''} ${tipo === 'tabla' ? 'izquierdo' : 'derecho'}`}
    >
      {texto}
    </button>
  );

  return (
    <div style={{ padding: '40px', maxWidth: '1200px', margin: '0 auto', height: '100vh', display: 'flex', flexDirection: 'column' }} className="animar-entrada">
      
      <div style={{ marginBottom: '30px', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', flexWrap: 'wrap', gap: '15px' }}>
        <div>
          <h1 style={{ color: '#111827', margin: '0 0 5px 0', fontSize: '28px', fontWeight: '600', letterSpacing: '-0.5px' }}>Monitor de Citas</h1>
          <p style={{ color: '#6b7280', margin: 0, fontSize: '14px' }}>Control global de reservas y asignaciones de la jornada.</p>
        </div>
        
        <div style={{ display: 'flex', alignItems: 'center', gap: '20px' }}>
          
          <select 
            value={sucursalSeleccionada}
            onChange={(e) => setSucursalSeleccionada(e.target.value)}
            style={{ 
              padding: '8px 16px', 
              borderRadius: '6px', 
              border: '1px solid #d1d5db', 
              backgroundColor: 'white', 
              color: '#374151', 
              fontSize: '14px', 
              fontWeight: '500', 
              cursor: 'pointer',
              outline: 'none'
            }}
          >
            <option value="">Todas las Sucursales</option>
            {listaBarberias.map((barberia) => {
              const id = barberia.idBarberia || barberia.id;
              return (
                <option key={id} value={id}>
                  {barberia.nombre}
                </option>
              );
            })}
          </select>

          <div style={{ display: 'flex' }}>
            <BotonVista tipo="tabla" texto="Vista de Tabla" />
            <BotonVista tipo="calendario" texto="Vista de Agenda" />
          </div>
        </div>
      </div>

      {cargando ? (
        <p style={{ color: '#6b7280', fontSize: '14px' }}>Sincronizando agenda...</p>
      ) : (
        <div style={{ flexGrow: 1, minHeight: '500px', backgroundColor: 'white', borderRadius: '8px', padding: vistaActiva === 'calendario' ? '20px' : '0', border: vistaActiva === 'calendario' ? '1px solid #e5e7eb' : 'none' }} className={vistaActiva === 'calendario' ? 'contenedor-calendario' : ''}>
          
          {vistaActiva === 'calendario' ? (
            <Calendar
              localizer={localizer}
              events={eventosCalendario}
              startAccessor="start"
              endAccessor="end"
              style={{ height: '100%' }}
              view={vistaTipoCalendario}
              onView={(nuevaVista) => setVistaTipoCalendario(nuevaVista)}
              date={fechaCalendario}
              onNavigate={(nuevaFecha) => setFechaCalendario(nuevaFecha)}
              views={[Views.MONTH, Views.WEEK, Views.DAY, Views.AGENDA]}
              min={new Date(1970, 1, 1, 8, 0, 0)}
              max={new Date(1970, 1, 1, 23, 59, 59)}
              step={30}
              timeslots={2}
              eventPropGetter={estiloEvento}
              messages={{
                next: "Siguiente",
                previous: "Anterior",
                today: "Hoy",
                month: "Mes",
                week: "Semana",
                day: "Día",
                agenda: "Lista",
                noEventsInRange: "No hay citas en este rango de fechas.",
                allDay: "Todo el día",
                date: "Fecha",
                time: "Hora",
                event: "Reserva",
                showMore: (total) => `+ Ver más (${total})`
              }}
            />
          ) : (
            <div className="contenedor-tabla" style={{ border: '1px solid #e5e7eb', boxShadow: 'none', margin: 0 }}>
              <table className="tabla-moderna" style={{ fontSize: '13px' }}>
                <thead>
                  <tr>
                    <th style={{ backgroundColor: '#f8fafc' }}>Referencia</th>
                    <th style={{ backgroundColor: '#f8fafc' }}>Fecha y Hora</th>
                    <th style={{ backgroundColor: '#f8fafc' }}>Cliente</th>
                    <th style={{ backgroundColor: '#f8fafc' }}>Profesional</th>
                    <th style={{ backgroundColor: '#f8fafc' }}>Sucursal</th>
                    <th style={{ backgroundColor: '#f8fafc' }}>Servicio</th>
                    <th style={{ backgroundColor: '#f8fafc' }}>Estado</th>
                  </tr>
                </thead>
                <tbody>
                  {listaCitas.length > 0 ? (
                    listaCitas.map((cita) => (
                      <tr key={cita.idCita || cita.id}>
                        <td style={{ color: '#6b7280', fontFamily: 'monospace' }}>{String(cita.idCita || cita.id).padStart(5, '0')}</td>
                        <td style={{ fontWeight: '500', color: '#111827' }}>{cita.fechaHoraCita ? new Date(cita.fechaHoraCita).toLocaleString('es-ES', { dateStyle: 'short', timeStyle: 'short' }) : 'Fecha por confirmar'}</td>
                        <td>{obtenerNombreCliente(cita)}</td>
                        <td style={{ color: '#4b5563' }}>{obtenerNombreBarbero(cita)}</td>
                        <td style={{ color: '#4b5563', fontSize: '13px' }}>{obtenerNombreBarberia(cita)}</td>
                        <td style={{ color: '#4b5563', fontSize: '13px', fontWeight: '500' }}>
                          {obtenerServicio(cita)}
                        </td>
                        <td>
                          <span style={obtenerEstiloEstadoTabla(cita.estadoCita || 'PENDIENTE')}>
                            {cita.estadoCita || 'PENDIENTE'}
                          </span>
                        </td>
                      </tr>
                    ))
                  ) : (
                    <tr><td colSpan={7} style={{ textAlign: 'center', padding: '60px 20px', color: '#9ca3af' }}>No hay citas registradas en el sistema para esta selección.</td></tr>
                  )}
                </tbody>
              </table>
            </div>
          )}
        </div>
      )}
    </div>
  );
};

export default MonitorCitas;