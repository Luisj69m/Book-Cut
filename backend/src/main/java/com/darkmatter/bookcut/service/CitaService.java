package com.darkmatter.bookcut.service;

import com.darkmatter.bookcut.DTO.CitaResponseDTO;
import com.darkmatter.bookcut.DTO.ServicioDTO;
import com.darkmatter.bookcut.model.Cita;
import com.darkmatter.bookcut.repository.CitaRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
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
        LocalDateTime inicioNuevaCita = nuevaCita.getFechaHoraCita();
        int duracionNuevaCita = nuevaCita.getServicioContratado().getDuracionMinutos();
        LocalDateTime finNuevaCita = inicioNuevaCita.plusMinutes(duracionNuevaCita);

        LocalDateTime inicioDelDia = inicioNuevaCita.toLocalDate().atStartOfDay();
        LocalDateTime finDelDia = inicioDelDia.plusDays(1).minusNanos(1);

        List<Cita> citasDelDia = repositorioDeCitas.findByBarberoAsignadoAndFechaHoraCitaBetween(
                nuevaCita.getBarberoAsignado(), inicioDelDia, finDelDia);

        for (Cita citaExistente : citasDelDia) {
            if (citaExistente.getEstadoCita() == com.darkmatter.bookcut.model.EstadoCita.CANCELADA) {
                continue;
            }

            LocalDateTime inicioExistente = citaExistente.getFechaHoraCita();
            int duracionExistente = citaExistente.getServicioContratado().getDuracionMinutos();
            LocalDateTime finExistente = inicioExistente.plusMinutes(duracionExistente);

            if (inicioNuevaCita.isBefore(finExistente) && finNuevaCita.isAfter(inicioExistente)) {
                throw new RuntimeException("Error: El servicio se solapa con una cita que dura hasta las " + finExistente.toLocalTime());
            }
        }

        Cita citaGuardada = repositorioDeCitas.save(nuevaCita);

        java.time.format.DateTimeFormatter formateador = java.time.format.DateTimeFormatter.ofPattern("dd/MM/yyyy 'a las' HH:mm");
        String fechaFormateada = citaGuardada.getFechaHoraCita().format(formateador);

        try {
            emailService.enviarCorreoConfirmacion(citaGuardada.getClienteReserva().getCorreoElectronico(), fechaFormateada);
        } catch (Exception excepcionCorreo) {
            System.out.println("ERROR al enviar correo: " + excepcionCorreo.getMessage());
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
        Cita cita = repositorioDeCitas.findById(idCita)
                .orElseThrow(() -> new RuntimeException("Cita no encontrada"));

        // Cambiamos estado en lugar de borrar
        cita.setEstadoCita(com.darkmatter.bookcut.model.EstadoCita.CANCELADA);
        repositorioDeCitas.save(cita);

        // Enviar correo (el código que ya tienes)
        emailService.enviarCorreo(cita.getClienteReserva().getCorreoElectronico(),
                "Cancelación", "Tu cita ahora figura como CANCELADA.");
    }

    public List<Cita> obtenerCitasPorBarbero(Long idBarbero) {
        return repositorioDeCitas.findByBarberoAsignado_IdPerfilBarbero(idBarbero);
    }

    public List<CitaResponseDTO> obtenerCitasPorUsuarioDTO(Long idUsuario) {
        List<Cita> citas = repositorioDeCitas.findByClienteReserva_IdUsuario(idUsuario);
        return citas.stream()
                .map(this::convertirADto)
                .toList();
    }

    public Cita actualizarEstadoCita(Long idCita, String nuevoEstado) {
        Cita cita = repositorioDeCitas.findById(idCita)
                .orElseThrow(() -> new RuntimeException("Cita no encontrada"));

        if ("FINALIZADA".equalsIgnoreCase(nuevoEstado) || "COMPLETADA".equalsIgnoreCase(nuevoEstado)) {
            if (java.time.LocalDateTime.now().isBefore(cita.getFechaHoraCita())) {
                throw new RuntimeException("Error: No se puede finalizar una cita antes de que ocurra.");
            }
        }

        cita.setEstadoCita(com.darkmatter.bookcut.model.EstadoCita.valueOf(nuevoEstado.toUpperCase()));
        Cita citaActualizada = repositorioDeCitas.save(cita);

        String asuntoCorreo = "";
        String mensajeCorreo = "";

        if ("ACEPTADA".equalsIgnoreCase(nuevoEstado)) {
            asuntoCorreo = "Cita Confirmada - Book&Cut";
            mensajeCorreo = "Hola, tu barbero ha aceptado tu cita.";
        } else if ("RECHAZADA".equalsIgnoreCase(nuevoEstado)) {
            asuntoCorreo = "Cita Rechazada - Book&Cut";
            mensajeCorreo = "Hola, el barbero ha rechazado tu solicitud.";
        }

        if (!asuntoCorreo.isEmpty()) {
            try {
                emailService.enviarCorreo(citaActualizada.getClienteReserva().getCorreoElectronico(), asuntoCorreo, mensajeCorreo);
            } catch (Exception excepcionCorreo) {
                System.err.println("Error al enviar correo: " + excepcionCorreo.getMessage());
            }
        }

        return citaActualizada;
    }

    private CitaResponseDTO convertirADto(Cita cita) {
        CitaResponseDTO dto = new CitaResponseDTO();
        dto.setIdCita(cita.getIdCita());
        dto.setFechaHoraCita(cita.getFechaHoraCita());
        dto.setEstadoCita(cita.getEstadoCita());

        ServicioDTO servicioDto = new ServicioDTO();

        // Nombres corregidos según tu Servicio.java
        servicioDto.setNombre(cita.getServicioContratado().getNombreServicio());

        // Convertimos BigDecimal a Double para el DTO
        if (cita.getServicioContratado().getPrecioServicio() != null) {
            servicioDto.setPrecio(cita.getServicioContratado().getPrecioServicio().doubleValue());
        }

        servicioDto.setDuracionMinutos(cita.getServicioContratado().getDuracionMinutos());

        dto.setServicioContratado(servicioDto);
        return dto;
    }

}