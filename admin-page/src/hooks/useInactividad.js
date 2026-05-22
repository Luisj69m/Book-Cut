import { useEffect, useRef, useCallback } from 'react';

const EVENTOS_ACTIVIDAD = ['mousedown', 'mousemove', 'keydown', 'scroll', 'touchstart', 'click'];

const useInactividad = (minutosLimite = 15, alCaducar) => {
  const temporizador = useRef(null);

  const reiniciarTemporizador = useCallback(() => {
    clearTimeout(temporizador.current);
    temporizador.current = setTimeout(() => {
      alCaducar();
    }, minutosLimite * 60 * 1000);
  }, [minutosLimite, alCaducar]);

  useEffect(() => {
    EVENTOS_ACTIVIDAD.forEach(evento =>
      window.addEventListener(evento, reiniciarTemporizador, { passive: true })
    );
    reiniciarTemporizador();

    return () => {
      clearTimeout(temporizador.current);
      EVENTOS_ACTIVIDAD.forEach(evento =>
        window.removeEventListener(evento, reiniciarTemporizador)
      );
    };
  }, [reiniciarTemporizador]);
};

export default useInactividad;
