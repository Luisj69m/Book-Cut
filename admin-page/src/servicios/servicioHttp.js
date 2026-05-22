import axios from 'axios';

const servicioHttp = axios.create({
  baseURL: 'https://book-cut.onrender.com/api',
  headers: {
    'Content-Type': 'application/json',
  },
});

servicioHttp.interceptors.request.use(
  (configuracion) => {
    const tokenGuardado = localStorage.getItem('token');
    if (tokenGuardado) {
      configuracion.headers.Authorization = `Bearer ${tokenGuardado}`;
    }
    return configuracion;
  },
  (errorPeticion) => {
    return Promise.reject(errorPeticion);
  }
);

servicioHttp.interceptors.response.use(
  (respuesta) => respuesta,
  (error) => {
    if (error.response?.status === 401) {
      localStorage.removeItem('token');
      localStorage.removeItem('usuario');
      window.location.href = '/login';
    }
    return Promise.reject(error);
  }
);

export default servicioHttp;