import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { RutaProtegida } from './componentes/RutaProtegida';
import Login from './paginas/Login';
import GestionBarberos from './paginas/GestionBarberos';
import ListadoUsuarios from './paginas/ListadoUsuarios';
import GestionBarberias from './paginas/GestionBarberias';
import PanelPrincipal from './paginas/PanelPrincipal';
import MonitorCitas from './paginas/MonitorCitas';
import Pagina404 from './paginas/Pagina404';


function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Login />} />

        {/* RUTAS PROTEGIDAS */}
        <Route element={<RutaProtegida />}>
          <Route path="/" element={<Navigate to="/panel" replace />} />
          <Route path="/panel" element={<PanelPrincipal />} />
          <Route path="/barberos" element={<GestionBarberos />} />
          <Route path="/usuarios" element={<ListadoUsuarios />} />
          <Route path="/barberias" element={<GestionBarberias />} />
          <Route path="/citas" element={<MonitorCitas />} />
          <Route path="*" element={<Pagina404 />} />
        </Route>

        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </BrowserRouter>
  );
}

export default App;