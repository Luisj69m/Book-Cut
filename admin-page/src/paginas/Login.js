import React, { useState, useEffect } from 'react';
import axios from 'axios';
import { useNavigate, useLocation } from 'react-router-dom';

// Intentos permitidos antes de cada bloqueo y duración del bloqueo
const NIVELES_BLOQUEO = [
  { intentosPermitidos: 4, bloqueoSegundos: 30  },
  { intentosPermitidos: 3, bloqueoSegundos: 60  },
  { intentosPermitidos: 2, bloqueoSegundos: 120 },
  { intentosPermitidos: 1, bloqueoSegundos: 300 },
];

const Login = () => {
  const [correo, setCorreo] = useState('');
  const [contrasena, setContrasena] = useState('');
  const [error, setError] = useState('');
  const [cargando, setCargando] = useState(false);
  const [nivelActual, setNivelActual] = useState(0);
  const [intentosEnNivel, setIntentosEnNivel] = useState(0);
  const [segundosRestantes, setSegundosRestantes] = useState(0);
  const navigate = useNavigate();
  const location = useLocation();
  const cerradoPorInactividad = location.state?.motivoCierre === 'inactividad';

  // Cuenta regresiva del bloqueo
  useEffect(() => {
    if (segundosRestantes <= 0) return;
    const temporizador = setTimeout(() => setSegundosRestantes(s => s - 1), 1000);
    return () => clearTimeout(temporizador);
  }, [segundosRestantes]);

  const manejarEnvio = async (e) => {
    e.preventDefault();
    if (segundosRestantes > 0) return;

    setError('');
    setCargando(true);

    try {
      const respuesta = await axios.post('https://book-cut.onrender.com/api/usuarios/login', {
        correoElectronico: correo,
        contrasenaUsuario: contrasena
      });

      localStorage.setItem('token', respuesta.data.token);
      localStorage.setItem('usuario', JSON.stringify(respuesta.data.usuario));
      navigate('/panel');
    } catch (err) {
      const nivel = NIVELES_BLOQUEO[Math.min(nivelActual, NIVELES_BLOQUEO.length - 1)];
      const nuevosIntentos = intentosEnNivel + 1;
      const intentosRestantes = nivel.intentosPermitidos - nuevosIntentos;

      if (nuevosIntentos >= nivel.intentosPermitidos) {
        // Se agotaron los intentos de este nivel → bloquear
        setSegundosRestantes(nivel.bloqueoSegundos);
        setNivelActual(n => Math.min(n + 1, NIVELES_BLOQUEO.length - 1));
        setIntentosEnNivel(0);
        setError(`Demasiados intentos fallidos. Espera ${nivel.bloqueoSegundos} segundos.`);
      } else {
        // Aún quedan intentos en este nivel → solo avisar
        setIntentosEnNivel(nuevosIntentos);
        setError(`Credenciales incorrectas. Te ${intentosRestantes === 1 ? 'queda' : 'quedan'} ${intentosRestantes} intento${intentosRestantes === 1 ? '' : 's'} antes del bloqueo.`);
      }
      setCargando(false);
    }
  };

  return (
    <div style={{ 
      minHeight: '100vh', 
      display: 'flex', 
      alignItems: 'center', 
      justifyContent: 'center',
      background: 'linear-gradient(135deg, #381483 0%, #e96d71 100%)' // Fondo espectacular
    }}>
      
      <div className="animar-entrada tarjeta-login" style={{
        background: 'rgba(255, 255, 255, 0.95)',
        padding: '50px 40px',
        borderRadius: '20px',
        boxShadow: '0 20px 40px rgba(0,0,0,0.2)',
        width: '100%',
        maxWidth: '420px',
        textAlign: 'center'
      }}>
        
      <img 
          src="/logo.png"
          alt="Logo Book&Cut" 
          style={{ 
          width: '130px', 
          height: 'auto', 
          marginBottom: '15px',
          borderRadius: '50%', /* Asegura que el borde se vea perfectamente redondo */
          boxShadow: '0 8px 16px rgba(0,0,0,0.1)' /* Sombra suave para que resalte sobre el fondo blanco */
        }}
      />
        <p style={{ color: '#6b7280', marginBottom: '30px', fontSize: '15px' }}>Panel de Administración Segura</p>
        
        {cerradoPorInactividad && (
          <div style={{ backgroundColor: '#fef3c7', color: '#92400e', padding: '12px', borderRadius: '8px', marginBottom: '20px', fontSize: '14px' }}>
            Sesión cerrada por inactividad. Vuelve a iniciar sesión.
          </div>
        )}

        {error && (
          <div style={{ backgroundColor: '#fee2e2', color: '#b91c1c', padding: '12px', borderRadius: '8px', marginBottom: '20px', fontSize: '14px' }}>
            {error}
          </div>
        )}
        
        <form onSubmit={manejarEnvio} style={{ display: 'flex', flexDirection: 'column', gap: '20px' }}>
          <div>
            <input
              type="email"
              className="input-moderno"
              placeholder="Correo electrónico"
              value={correo}
              onChange={(e) => setCorreo(e.target.value)}
              required
            />
          </div>
          <div>
            <input
              type="password"
              className="input-moderno"
              placeholder="Contraseña"
              value={contrasena}
              onChange={(e) => setContrasena(e.target.value)}
              required
            />
          </div>
          
          <button
            type="submit"
            className="boton-primario"
            disabled={cargando || segundosRestantes > 0}
            style={{ marginTop: '10px', opacity: segundosRestantes > 0 ? 0.6 : 1 }}
          >
            {cargando ? 'Verificando...' : segundosRestantes > 0 ? `Bloqueado (${segundosRestantes}s)` : 'Acceder al Panel'}
          </button>
        </form>
      </div>
    </div>
  );
};

export default Login;