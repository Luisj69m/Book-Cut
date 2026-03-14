package com.darkmatter.bookcut.service;
import com.darkmatter.bookcut.model.Cita;
import com.darkmatter.bookcut.repository.CitaRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class CitaService {
    private final CitaRepository repositorioDeCitas;
    public CitaService(CitaRepository repositorioDeCitas) {
        this.repositorioDeCitas = repositorioDeCitas;
    }
    public Cita crearNuevaCita(Cita nuevaCita) {
        // 1. Extraemos los datos para la comprobación
        Long idBarbero = nuevaCita.getBarberoAsignado().getIdPerfilBarbero();
        java.time.LocalDateTime fecha = nuevaCita.getFechaHoraCita();

        // 2. Preguntamos al repositorio si ya existe esa combinación
        boolean estaOcupado = repositorioDeCitas.existsByBarberoAsignado_IdPerfilBarberoAndFechaHoraCita(idBarbero, fecha);

        if (estaOcupado) {
            // Si entra aquí, Java lanza una excepción y CORTA la ejecución (no llega al save)
            throw new RuntimeException("Error: El barbero ya tiene una cita a esa hora.");
        }

        return repositorioDeCitas.save(nuevaCita);
    }

    public List<Cita> obtenerHistorialDeCliente(Long idUsuario) {
        return repositorioDeCitas.findByClienteReserva_IdUsuario(idUsuario);
    }

    public boolean estaBarberoDisponible(Long idBarbero, java.time.LocalDateTime fechaHora) {
        // Aquí Dani consultará si el barbero ya tiene una cita en ese rango exacto
        return !repositorioDeCitas.existsByBarberoAsignado_IdPerfilBarberoAndFechaHoraCita(idBarbero, fechaHora);
    }

    public void cancelarCita(Long idCita) {
        if (!repositorioDeCitas.existsById(idCita)) {
            throw new RuntimeException("No se puede cancelar: La cita no existe.");
        }
        repositorioDeCitas.deleteById(idCita);
    }

    public List<Cita> obtenerCitasPorBarbero(Long idBarbero) {
        return repositorioDeCitas.findByBarberoAsignado_IdPerfilBarbero(idBarbero);
    }

    public List<Cita> obtenerCitasPorUsuario(Long idUsuario) {
        return repositorioDeCitas.findByClienteReserva_IdUsuario(idUsuario);
    }
}
