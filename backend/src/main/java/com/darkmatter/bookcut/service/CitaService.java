package com.darkmatter.bookcut.service;

import com.darkmatter.bookcut.DTO.CitaResponseDTO;
import com.darkmatter.bookcut.DTO.ServicioDTO;
import com.darkmatter.bookcut.model.Cita;
import com.darkmatter.bookcut.model.EstadoCita;
import com.darkmatter.bookcut.repository.CitaRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Servicio central para la gestión del ciclo de vida de las citas.
 * Incluye el motor de validación de solapamiento horario y la máquina de estados
 * que rige las transiciones permitidas (Pendiente, Aceptada, etc.).
 */
@Service
public class CitaService {

    private final CitaRepository repositorioCitas;
    private final EmailService servicioEmail;

    public CitaService(CitaRepository repositorioCitas, EmailService servicioEmail) {
        this.repositorioCitas = repositorioCitas;
        this.servicioEmail = servicioEmail;
    }

    /**
     * Registra una nueva cita verificando que el barbero no tenga compromisos
     * previos que se solapen en el rango de tiempo calculado.
     */
    @Transactional
    public Cita crearNuevaCita(Cita nuevaCita) {
        LocalDateTime inicioNuevaCita = nuevaCita.getFechaHoraCita();
        int duracionMinutos = nuevaCita.getServicioContratado().getDuracionMinutos();
        LocalDateTime finNuevaCita = inicioNuevaCita.plusMinutes(duracionMinutos);

        LocalDateTime inicioDelDia = inicioNuevaCita.toLocalDate().atStartOfDay();
        LocalDateTime finDelDia = inicioDelDia.plusDays(1).minusNanos(1);

        // Validamos disponibilidad horaria
        List<Cita> citasDelDia = repositorioCitas.findByBarberoAsignadoAndFechaHoraCitaBetween(
                nuevaCita.getBarberoAsignado(), inicioDelDia, finDelDia);

        for (Cita citaExistente : citasDelDia) {
            if (citaExistente.getEstadoCita() == EstadoCita.CANCELADA) continue;

            LocalDateTime inicioExistente = citaExistente.getFechaHoraCita();
            int duracionExistente = citaExistente.getServicioContratado().getDuracionMinutos();
            LocalDateTime finExistente = inicioExistente.plusMinutes(duracionExistente);

            if (inicioNuevaCita.isBefore(finExistente) && finNuevaCita.isAfter(inicioExistente)) {
                throw new RuntimeException("Error: El barbero ya tiene una cita asignada hasta las " + finExistente.toLocalTime());
            }
        }

        Cita citaGuardada = repositorioCitas.save(nuevaCita);

        // Notificación de reserva al cliente
        try {
            DateTimeFormatter formateador = DateTimeFormatter.ofPattern("dd/MM/yyyy 'a las' HH:mm");
            String fechaTexto = citaGuardada.getFechaHoraCita().format(formateador);
            servicioEmail.enviarCorreoConfirmacion(citaGuardada.getClienteReserva().getCorreoElectronico(), fechaTexto);
        } catch (Exception e) {
            // Error no crítico para la persistencia
        }

        return citaGuardada;
    }

    /**
     * Gestiona las transiciones de estado de una cita aplicando reglas de negocio estrictas.
     */
    @Transactional
    public Cita actualizarEstadoCita(Long idCita, String nuevoEstadoTexto) {
        Cita cita = repositorioCitas.findById(idCita)
                .orElseThrow(() -> new RuntimeException("Cita no encontrada"));

        EstadoCita estadoActual = cita.getEstadoCita();
        EstadoCita estadoSolicitado = EstadoCita.valueOf(nuevoEstadoTexto.toUpperCase());

        // 1. Validaciones de estados terminales
        if (List.of(EstadoCita.COMPLETADA, EstadoCita.CANCELADA, EstadoCita.RECHAZADA, EstadoCita.VENCIDA).contains(estadoActual)) {
            throw new RuntimeException("Error: La cita ya se encuentra en un estado definitivo: " + estadoActual);
        }

        // 2. Restricciones de transición
        if (estadoActual == EstadoCita.PENDIENTE && !List.of(EstadoCita.ACEPTADA, EstadoCita.RECHAZADA, EstadoCita.CANCELADA).contains(estadoSolicitado)) {
            throw new RuntimeException("Transición no permitida para citas PENDIENTES.");
        }

        if (estadoActual == EstadoCita.ACEPTADA && !List.of(EstadoCita.COMPLETADA, EstadoCita.CANCELADA).contains(estadoSolicitado)) {
            throw new RuntimeException("Transición no permitida para citas ACEPTADAS.");
        }

        // 3. Lógica de negocio específica por estado solicitado
        if (estadoSolicitado == EstadoCita.ACEPTADA) {
            // Congelamos el precio en el momento de la aceptación
            if (cita.getServicioContratado() != null) {
                cita.setPrecioFinal(cita.getServicioContratado().getPrecioServicio());
            }
        }

        if (estadoSolicitado == EstadoCita.COMPLETADA && LocalDateTime.now().isBefore(cita.getFechaHoraCita())) {
            throw new RuntimeException("Error: No se puede completar una cita antes de su fecha programada.");
        }

        cita.setEstadoCita(estadoSolicitado);
        Cita actualizada = repositorioCitas.save(cita);

        notificarCambioEstado(actualizada, estadoSolicitado);

        return actualizada;
    }

    /**
     * Método de conveniencia para cancelar una cita desde el controlador.
     * Delega en la lógica central de actualización de estados.
     */
    @Transactional
    public void cancelarCita(Long idCita) {
        this.actualizarEstadoCita(idCita, "CANCELADA");
    }

    private void notificarCambioEstado(Cita cita, EstadoCita estado) {
        String asunto = "Actualización de tu cita - Book&Cut";
        String mensaje = switch (estado) {
            case ACEPTADA -> "Tu cita ha sido aceptada por el barbero.";
            case RECHAZADA -> "Lo sentimos, el barbero ha rechazado tu solicitud.";
            case COMPLETADA -> "Tu cita ha finalizado correctamente. ¡Gracias!";
            case CANCELADA -> "Tu cita ha sido cancelada.";
            default -> "";
        };

        if (!mensaje.isEmpty()) {
            try {
                servicioEmail.enviarCorreo(cita.getClienteReserva().getCorreoElectronico(), asunto, mensaje);
            } catch (Exception ignored) {}
        }
    }

    public List<CitaResponseDTO> obtenerCitasPorUsuarioDTO(Long idUsuario) {
        return repositorioCitas.findByClienteReserva_IdUsuario(idUsuario).stream()
                .map(this::convertirADto)
                .toList();
    }

    private CitaResponseDTO convertirADto(Cita cita) {
        CitaResponseDTO respuesta = new CitaResponseDTO();
        respuesta.setIdCita(cita.getIdCita());
        respuesta.setFechaHoraCita(cita.getFechaHoraCita());
        respuesta.setEstadoCita(cita.getEstadoCita());

        ServicioDTO servicio = new ServicioDTO();
        servicio.setNombre(cita.getServicioContratado().getNombreServicio());
        if (cita.getServicioContratado().getPrecioServicio() != null) {
            servicio.setPrecio(cita.getServicioContratado().getPrecioServicio().doubleValue());
        }
        servicio.setDuracionMinutos(cita.getServicioContratado().getDuracionMinutos());

        respuesta.setServicioContratado(servicio);

        if (cita.getBarberoAsignado() != null && cita.getBarberoAsignado().getBarberiaAsignada() != null) {
            respuesta.setNombreBarberia(cita.getBarberoAsignado().getBarberiaAsignada().getNombre());
        }
        return respuesta;
    }

    // Métodos de consulta simples
    public List<Cita> obtenerHistorialDeCliente(Long idUsuario) { return repositorioCitas.findByClienteReserva_IdUsuario(idUsuario); }
    public List<Cita> obtenerCitasPorBarbero(Long idBarbero) { return repositorioCitas.findByBarberoAsignado_IdPerfilBarbero(idBarbero); }
    public boolean estaBarberoDisponible(Long idBarbero, LocalDateTime fecha) { return !repositorioCitas.existsByBarberoAsignado_IdPerfilBarberoAndFechaHoraCita(idBarbero, fecha); }
}