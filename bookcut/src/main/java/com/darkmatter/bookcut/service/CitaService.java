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
        // 1. Buscamos la cita para tener los datos del cliente antes de borrarla
        Cita cita = repositorioDeCitas.findById(idCita)
                .orElseThrow(() -> new RuntimeException("No se puede cancelar: La cita no existe."));

        String correoCliente = cita.getClienteReserva().getCorreoElectronico();

        // 2. Borramos la cita de la base de datos
        repositorioDeCitas.deleteById(idCita);

        // 3. Enviamos el correo de confirmación de cancelación
        try {
            emailService.enviarCorreo(
                    correoCliente,
                    "Cancelación de Cita - Book&Cut",
                    "Hola, te confirmamos que tu cita ha sido cancelada correctamente. ¡Esperamos verte pronto de nuevo!"
            );
        } catch (Exception e) {
            System.err.println("Error al enviar correo de cancelación: " + e.getMessage());
        }
    }

    public List<Cita> obtenerCitasPorBarbero(Long idBarbero) {
        return repositorioDeCitas.findByBarberoAsignado_IdPerfilBarbero(idBarbero);
    }

    public List<Cita> obtenerCitasPorUsuario(Long idUsuario) {
        return repositorioDeCitas.findByClienteReserva_IdUsuario(idUsuario);
    }

    public Cita actualizarEstadoCita(Long idCita, String nuevoEstado) {
        Cita cita = repositorioDeCitas.findById(idCita)
                .orElseThrow(() -> new RuntimeException("Cita no encontrada"));

        cita.setEstadoCita(com.darkmatter.bookcut.model.EstadoCita.valueOf(nuevoEstado.toUpperCase()));
        Cita citaActualizada = repositorioDeCitas.save(cita);

        String asunto = "";
        String mensaje = "";

        if ("ACEPTADA".equalsIgnoreCase(nuevoEstado)) {
            asunto = "¡Cita Confirmada! - Book&Cut";
            mensaje = "Hola, tu barbero ha aceptado tu cita para la fecha solicitada. ¡Te esperamos!";
        } else if ("RECHAZADA".equalsIgnoreCase(nuevoEstado)) {
            asunto = "Cita Rechazada - Book&Cut";
            mensaje = "Hola, lo sentimos pero el barbero ha rechazado tu solicitud. Por favor, selecciona otro horario.";
        }

        if (!asunto.isEmpty()) {
            try {
                emailService.enviarCorreo(citaActualizada.getClienteReserva().getCorreoElectronico(), asunto, mensaje);
            } catch (Exception e) {
                System.err.println("Error al enviar notificación de estado: " + e.getMessage());
            }
        }

        return citaActualizada;
    }

}