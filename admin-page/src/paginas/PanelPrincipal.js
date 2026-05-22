import React, { useState, useEffect } from 'react';
import servicioHttp from '../servicios/servicioHttp';
import { BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';
import { SkeletonTarjeta, SkeletonBloque } from '../componentes/Skeleton';

const PanelPrincipal = () => {
  const [estadisticas, setEstadisticas] = useState({ totalUsuarios: 0, totalBarberias: 0, totalAdmins: 0, totalBarberos: 0 });
  const [actividadReciente, setActividadReciente] = useState([]);
  const [datosGrafico, setDatosGrafico] = useState([]);
  const [cargando, setCargando] = useState(true);

  useEffect(() => {
    const cargarDatos = async () => {
      try {
        const [resUsuarios, resBarberias] = await Promise.all([
          servicioHttp.get('/usuarios/listar'),
          servicioHttp.get('/barberias')
        ]);
        
        const usuarios = resUsuarios.data;
        const totalAdmins = usuarios.filter(u => u.rolUsuario === 'ADMIN' || u.rol_usuario === 'ADMIN').length;
        const totalBarberos = usuarios.filter(u => u.rolUsuario === 'BARBERO' || u.rol_usuario === 'BARBERO').length;
        const totalClientes = usuarios.length - totalAdmins - totalBarberos;
        
        setEstadisticas({
          totalUsuarios: usuarios.length,
          totalBarberias: resBarberias.data.length,
          totalAdmins,
          totalBarberos
        });

        // Preparamos los datos para el gráfico de barras
        setDatosGrafico([
          { grupo: 'Clientes', cantidad: totalClientes },
          { grupo: 'Staff', cantidad: totalBarberos },
          { grupo: 'Admins', cantidad: totalAdmins }
        ]);

        const ultimosMovimientos = usuarios
          .sort((a, b) => (b.idUsuario || b.id) - (a.idUsuario || a.id))
          .slice(0, 5);
        
        setActividadReciente(ultimosMovimientos);
        setCargando(false);
      } catch (error) { 
        console.error("Error al cargar el dashboard", error);
        setCargando(false); 
      }
    };
    cargarDatos();
  }, []);

  const Tarjeta = ({ titulo, valor, color }) => (
    <div className="tarjeta-hover" style={{ backgroundColor: 'white', padding: '25px', borderRadius: '8px', flex: '1', minWidth: '200px', borderTop: `4px solid ${color}`, boxShadow: '0 1px 3px rgba(0,0,0,0.05)' }}>
      <h3 style={{ margin: '0 0 10px 0', color: '#6b7280', fontSize: '13px', fontWeight: '600', textTransform: 'uppercase', letterSpacing: '0.5px' }}>{titulo}</h3>
      <p style={{ margin: 0, fontSize: '32px', fontWeight: '700', color: '#111827', letterSpacing: '-1px' }}>{valor}</p>
    </div>
  );

  return (
    <div style={{ padding: '40px', maxWidth: '1200px', margin: '0 auto' }} className="animar-entrada">
      <div style={{ marginBottom: '30px' }}>
        <h1 style={{ color: '#111827', margin: '0 0 5px 0', fontSize: '28px', fontWeight: '600', letterSpacing: '-0.5px' }}>Visión General</h1>
        <p style={{ color: '#6b7280', margin: 0, fontSize: '14px' }}>Métricas principales del sistema de reservas.</p>
      </div>

      {cargando ? (
        <>
          <div className="fila-tarjetas" style={{ display: 'flex', gap: '20px', flexWrap: 'wrap', marginBottom: '30px' }}>
            <SkeletonTarjeta /><SkeletonTarjeta /><SkeletonTarjeta /><SkeletonTarjeta />
          </div>
          <div className="grid-dashboard" style={{ display: 'grid', gridTemplateColumns: 'minmax(300px, 2fr) minmax(300px, 1fr)', gap: '20px' }}>
            <div style={{ backgroundColor: 'white', padding: '30px', borderRadius: '8px', border: '1px solid #e5e7eb' }}>
              <SkeletonBloque alto="320px" />
            </div>
            <div style={{ backgroundColor: 'white', padding: '30px', borderRadius: '8px', border: '1px solid #e5e7eb' }}>
              <SkeletonBloque alto="320px" />
            </div>
          </div>
        </>
      ) : (
        <>
          {/* Tarjetas superiores */}
          <div className="fila-tarjetas" style={{ display: 'flex', gap: '20px', flexWrap: 'wrap', marginBottom: '30px' }}>
            <Tarjeta titulo="Usuarios Registrados" valor={estadisticas.totalUsuarios} color="#3b82f6" />
            <Tarjeta titulo="Sedes Activas" valor={estadisticas.totalBarberias} color="#e96d71" />
            <Tarjeta titulo="Profesionales" valor={estadisticas.totalBarberos} color="#8b5cf6" />
            <Tarjeta titulo="Administradores" valor={estadisticas.totalAdmins} color="#10b981" />
          </div>

          {/* Contenedor dividido: Gráfico a la izquierda, Log a la derecha */}
          <div className="grid-dashboard" style={{ display: 'grid', gridTemplateColumns: 'minmax(300px, 2fr) minmax(300px, 1fr)', gap: '20px' }}>
            
            {/* Sección del Gráfico */}
            <div style={{ backgroundColor: 'white', padding: '30px', borderRadius: '8px', border: '1px solid #e5e7eb' }}>
              <div style={{ marginBottom: '25px', borderBottom: '1px solid #f3f4f6', paddingBottom: '15px' }}>
                <h2 style={{ margin: 0, fontSize: '16px', fontWeight: '600', color: '#111827' }}>Distribución de Usuarios</h2>
              </div>
              <div style={{ width: '100%', height: '300px' }}>
                <ResponsiveContainer width="100%" height="100%">
                  <BarChart data={datosGrafico} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
                    <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#e5e7eb" />
                    <XAxis dataKey="grupo" axisLine={false} tickLine={false} tick={{ fontSize: 13, fill: '#6b7280' }} dy={10} />
                    <YAxis axisLine={false} tickLine={false} tick={{ fontSize: 13, fill: '#6b7280' }} />
                    <Tooltip 
                      cursor={{ fill: 'rgba(0,0,0,0.02)' }} 
                      contentStyle={{ borderRadius: '8px', border: 'none', boxShadow: '0 4px 6px rgba(0,0,0,0.1)' }}
                    />
                    <Bar dataKey="cantidad" fill="#8b5cf6" radius={[4, 4, 0, 0]} barSize={40} />
                  </BarChart>
                </ResponsiveContainer>
              </div>
            </div>

            {/* Sección del Registro de Actividad */}
            <div style={{ backgroundColor: 'white', padding: '30px', borderRadius: '8px', border: '1px solid #e5e7eb' }}>
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '25px', borderBottom: '1px solid #f3f4f6', paddingBottom: '15px' }}>
                <h2 style={{ margin: 0, fontSize: '16px', fontWeight: '600', color: '#111827' }}>Actividad Reciente</h2>
              </div>
              <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
                {actividadReciente.map((log, indice) => (
                  <div key={indice} style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '12px 15px', borderRadius: '6px', backgroundColor: '#f9fafb', borderLeft: `3px solid ${log.rolUsuario === 'ADMIN' || log.rol_usuario === 'ADMIN' ? '#10b981' : '#3b82f6'}` }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: '15px' }}>
                      <div style={{ width: '32px', height: '32px', borderRadius: '50%', backgroundColor: '#e5e7eb', color: '#4b5563', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: '12px', fontWeight: '600', textTransform: 'uppercase' }}>
                        {log.correoElectronico ? log.correoElectronico.charAt(0) : (log.correo_electronico ? log.correo_electronico.charAt(0) : 'U')}
                      </div>
                      <div>
                        <p style={{ margin: 0, fontWeight: '500', color: '#111827', fontSize: '14px' }}>
                          {log.correoElectronico || log.correo_electronico}
                        </p>
                        <p style={{ margin: 0, fontSize: '12px', color: '#6b7280' }}>Rol: {log.rolUsuario || log.rol_usuario}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>

          </div>
        </>
      )}
    </div>
  );
};

export default PanelPrincipal;