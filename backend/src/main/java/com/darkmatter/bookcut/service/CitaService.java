package com.darkmatter.bookcut.service;

import com.darkmatter.bookcut.DTO.CitaResponseDTO;
import com.darkmatter.bookcut.DTO.ServicioDTO;
import com.darkmatter.bookcut.model.Cita;
import com.darkmatter.bookcut.model.EstadoCita;
import com.darkmatter.bookcut.repository.CitaRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class CitaService {

    private final CitaRepository repositorioDeCitas;
    private final BrevoEmailService emailService;

    // Constructor para la inyección de dependencias
    public CitaService(CitaRepository repositorioDeCitas, BrevoEmailService emailService) {
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

        if (cita.getEstadoCita() == EstadoCita.COMPLETADA || cita.getEstadoCita() == EstadoCita.CANCELADA) {
            throw new RuntimeException("No se puede cancelar una cita que ya está " + cita.getEstadoCita());
        }

        if (LocalDateTime.now().isAfter(cita.getFechaHoraCita())) {
            throw new RuntimeException("No se puede cancelar una cita cuya fecha ya ha pasado.");
        }

        cita.setEstadoCita(EstadoCita.CANCELADA);
        repositorioDeCitas.save(cita);

        try {
            emailService.enviarCorreo(
                    cita.getClienteReserva().getCorreoElectronico(),
                    "Cita cancelada",
                    "Tu cita ha sido cancelada."
            );
        } catch (Exception e) {
            System.out.println("Error enviando correo de cancelación: " + e.getMessage());
        }
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

        com.darkmatter.bookcut.model.EstadoCita estadoActual = cita.getEstadoCita();
        com.darkmatter.bookcut.model.EstadoCita estadoSolicitado = com.darkmatter.bookcut.model.EstadoCita.valueOf(nuevoEstado.toUpperCase());

        if (estadoActual == com.darkmatter.bookcut.model.EstadoCita.COMPLETADA
                || estadoActual == com.darkmatter.bookcut.model.EstadoCita.CANCELADA
                || estadoActual == com.darkmatter.bookcut.model.EstadoCita.RECHAZADA
                || estadoActual == com.darkmatter.bookcut.model.EstadoCita.VENCIDA) {
            throw new RuntimeException("Error: Una cita " + estadoActual + " es definitiva y no puede cambiar de estado.");
        }

        if (estadoSolicitado == com.darkmatter.bookcut.model.EstadoCita.VENCIDA) {
            throw new RuntimeException("Error: El estado VENCIDA solo se asigna automáticamente por el sistema.");
        }

        if (estadoActual == com.darkmatter.bookcut.model.EstadoCita.PENDIENTE) {
            if (estadoSolicitado != com.darkmatter.bookcut.model.EstadoCita.ACEPTADA
                    && estadoSolicitado != com.darkmatter.bookcut.model.EstadoCita.RECHAZADA
                    && estadoSolicitado != com.darkmatter.bookcut.model.EstadoCita.CANCELADA) {
                throw new RuntimeException("Error: Una cita PENDIENTE solo puede pasar a ACEPTADA, RECHAZADA o CANCELADA.");
            }
        }

        if (estadoActual == com.darkmatter.bookcut.model.EstadoCita.ACEPTADA) {
            if (estadoSolicitado != com.darkmatter.bookcut.model.EstadoCita.COMPLETADA
                    && estadoSolicitado != com.darkmatter.bookcut.model.EstadoCita.CANCELADA) {
                throw new RuntimeException("Error: Una cita ACEPTADA solo puede pasar a COMPLETADA o CANCELADA.");
            }
        }

        if (estadoSolicitado == com.darkmatter.bookcut.model.EstadoCita.COMPLETADA) {
            if (java.time.LocalDateTime.now().isBefore(cita.getFechaHoraCita())) {
                throw new RuntimeException("Error: No se puede finalizar una cita antes de que ocurra.");
            }
        }

        if (estadoSolicitado == com.darkmatter.bookcut.model.EstadoCita.CANCELADA) {
            if (java.time.LocalDateTime.now().isAfter(cita.getFechaHoraCita())) {
                throw new RuntimeException("Error: No se puede cancelar una cita cuya fecha ya ha pasado.");
            }
        }

        if (estadoSolicitado == com.darkmatter.bookcut.model.EstadoCita.ACEPTADA) {
            if (cita.getServicioContratado() != null && cita.getServicioContratado().getPrecioServicio() != null) {
                cita.setPrecioFinal(cita.getServicioContratado().getPrecioServicio());
            }
        }

        cita.setEstadoCita(estadoSolicitado);
        Cita citaActualizada = repositorioDeCitas.save(cita);

        // Envío de correos según el nuevo estado
        try {
            String nombreCliente = citaActualizada.getClienteReserva().getNombre();
            String correoCliente = citaActualizada.getClienteReserva().getCorreoElectronico();
            String fechaHora = citaActualizada.getFechaHoraCita().toString();
            String nombreBarberia = citaActualizada.getBarberoAsignado().getBarberiaAsignada().getNombre();

            if (estadoSolicitado == com.darkmatter.bookcut.model.EstadoCita.ACEPTADA) {
                emailService.enviarCorreoCitaAceptada(correoCliente, nombreCliente, fechaHora, nombreBarberia);
            } else if (estadoSolicitado == com.darkmatter.bookcut.model.EstadoCita.RECHAZADA) {
                emailService.enviarCorreoCitaRechazada(correoCliente, nombreCliente, fechaHora, nombreBarberia);
            } else if (estadoSolicitado == com.darkmatter.bookcut.model.EstadoCita.COMPLETADA) {
                emailService.enviarCorreoCitaCompletada(correoCliente, nombreCliente, fechaHora, nombreBarberia);
            } else if (estadoSolicitado == com.darkmatter.bookcut.model.EstadoCita.CANCELADA) {
                emailService.enviarCorreoCitaCancelada(correoCliente, nombreCliente, fechaHora, nombreBarberia);
            }
        } catch (Exception excepcionCorreo) {
            System.err.println("Error al enviar correo: " + excepcionCorreo.getMessage());
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

        if (cita.getBarberoAsignado() != null && cita.getBarberoAsignado().getBarberiaAsignada() != null) {
            dto.setNombreBarberia(cita.getBarberoAsignado().getBarberiaAsignada().getNombre());
        }
        return dto;
    }

}