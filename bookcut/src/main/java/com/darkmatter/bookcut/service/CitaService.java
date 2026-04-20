package com.darkmatter.bookcut.service;

import com.darkmatter.bookcut.model.Cita;
import com.darkmatter.bookcut.repository.CitaRepository;
import org.springframework.stereotype.Service;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class CitaService {

    private final CitaRepository repositorioDeCitas;
    private final EmailService emailService;

    // Constructor para la inyección de dependencias
    public CitaService(CitaRepository repositorioDeCitas, EmailService emailService) {
        this.repositorioDeCitas = repositorioDeCitas;
        this.emailService = emailService;
    }

    public Cita crearNuevaCita(Cita nuevaCita) {
        // 1. COMPROBACIÓN: Usamos el método que creamos en el Repository para ver si ya existe esa cita
        boolean ocupado = repositorioDeCitas.existsByBarberoAsignadoAndFechaHoraCita(
                nuevaCita.getBarberoAsignado(),
                nuevaCita.getFechaHoraCita()
        );

        if (ocupado) {
            throw new RuntimeException("Error: El barbero ya tiene una cita a esa hora.");
        }

        // 2. GUARDAR
        Cita citaGuardada = repositorioDeCitas.save(nuevaCita);

        // 3. FORMATEAR FECHA
        DateTimeFormatter formateador = DateTimeFormatter.ofPattern("dd/MM/yyyy 'a las' HH:mm");
        String fechaFormateada = citaGuardada.getFechaHoraCita().format(formateador);

        // 4. ENVIAR CORREO
        try {
            emailService.enviarCorreoConfirmacion(
                    citaGuardada.getClienteReserva().getCorreoElectronico(),
                    fechaFormateada
            );
        } catch (Exception e) {
            System.out.println("ERROR al enviar correo: " + e.getMessage());
        }

        return citaGuardada;
    }

    public List<Cita> obtenerHistorialDeCliente(Long idUsuario) {
        return repositorioDeCitas.findByClienteReserva_IdUsuario(idUsuario);
    }

    public boolean estaBarberoDisponible(Long idBarbero, java.time.LocalDateTime fechaHora) {
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