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
            if (citaExistente.getEstadoCita() == EstadoCita.CANCELADA) {
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

        DateTimeFormatter formateador = DateTimeFormatter.ofPattern("dd/MM/yyyy 'a las' HH:mm");
        String fechaFormateada = citaGuardada.getFechaHoraCita().format(formateador);

        try {
            String nombreCliente = citaGuardada.getClienteReserva().getNombre();
            String correoCliente = citaGuardada.getClienteReserva().getCorreoElectronico();
            String nombreBarbero = citaGuardada.getBarberoAsignado().getUsuarioAsignado().getNombre();
            String nombreBarberia = citaGuardada.getBarberoAsignado().getBarberiaAsignada().getNombre();
            String nombreServicio = citaGuardada.getServicioContratado().getNombreServicio();
            String precio = String.format("%.2f", citaGuardada.getServicioContratado().getPrecioServicio());

            emailService.enviarCorreoCitaCreada(
                    correoCliente,
                    nombreCliente,
                    nombreBarbero,
                    nombreBarberia,
                    fechaFormateada,
                    nombreServicio,
                    precio
            );
        } catch (Exception excepcionCorreo) {
            System.out.println("ERROR al enviar correo: " + excepcionCorreo.getMessage());
        }

        return citaGuardada;
    }

    public List<Cita> obtenerHistorialDeCliente(Long idUsuario) {
        return repositorioDeCitas.findByClienteReserva_IdUsuario(idUsuario);
    }

    public boolean estaBarberoDisponible(Long idBarbero, LocalDateTime fechaHora) {
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

        DateTimeFormatter formateador = DateTimeFormatter.ofPattern("dd/MM/yyyy 'a las' HH:mm");
        String fechaFormateada = cita.getFechaHoraCita().format(formateador);

        try {
            String nombreCliente = cita.getClienteReserva().getNombre();
            String correoCliente = cita.getClienteReserva().getCorreoElectronico();
            String nombreBarbero = cita.getBarberoAsignado().getUsuarioAsignado().getNombre();
            String nombreBarberia = cita.getBarberoAsignado().getBarberiaAsignada().getNombre();
            String nombreServicio = cita.getServicioContratado().getNombreServicio();

            emailService.enviarCorreoCitaCancelada(
                    correoCliente,
                    nombreCliente,
                    nombreBarbero,
                    nombreBarberia,
                    fechaFormateada,
                    nombreServicio
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
                .map(this::convertirACitaResponseDTO)
                .toList();
    }

    public Cita actualizarEstadoCita(Long idCita, String nuevoEstado) {
        Cita cita = repositorioDeCitas.findById(idCita)
                .orElseThrow(() -> new RuntimeException("Cita no encontrada"));

        EstadoCita estadoActual = cita.getEstadoCita();
        EstadoCita estadoSolicitado = EstadoCita.valueOf(nuevoEstado.toUpperCase());

        if (estadoActual == EstadoCita.COMPLETADA
                || estadoActual == EstadoCita.CANCELADA
                || estadoActual == EstadoCita.RECHAZADA
                || estadoActual == EstadoCita.VENCIDA) {
            throw new RuntimeException("Error: Una cita " + estadoActual + " es definitiva y no puede cambiar de estado.");
        }

        if (estadoSolicitado == EstadoCita.VENCIDA) {
            throw new RuntimeException("Error: El estado VENCIDA solo se asigna automáticamente por el sistema.");
        }

        if (estadoActual == EstadoCita.PENDIENTE) {
            if (estadoSolicitado != EstadoCita.ACEPTADA
                    && estadoSolicitado != EstadoCita.RECHAZADA
                    && estadoSolicitado != EstadoCita.CANCELADA) {
                throw new RuntimeException("Error: Una cita PENDIENTE solo puede pasar a ACEPTADA, RECHAZADA o CANCELADA.");
            }
        }

        if (estadoActual == EstadoCita.ACEPTADA) {
            if (estadoSolicitado != EstadoCita.COMPLETADA
                    && estadoSolicitado != EstadoCita.CANCELADA) {
                throw new RuntimeException("Error: Una cita ACEPTADA solo puede pasar a COMPLETADA o CANCELADA.");
            }
        }

        if (estadoSolicitado == EstadoCita.COMPLETADA) {
            if (LocalDateTime.now().isBefore(cita.getFechaHoraCita())) {
                throw new RuntimeException("Error: No se puede finalizar una cita antes de que ocurra.");
            }
        }

        if (estadoSolicitado == EstadoCita.CANCELADA) {
            if (LocalDateTime.now().isAfter(cita.getFechaHoraCita())) {
                throw new RuntimeException("Error: No se puede cancelar una cita cuya fecha ya ha pasado.");
            }
        }

        if (estadoSolicitado == EstadoCita.ACEPTADA) {
            if (cita.getServicioContratado() != null && cita.getServicioContratado().getPrecioServicio() != null) {
                cita.setPrecioFinal(cita.getServicioContratado().getPrecioServicio());
            }
        }

        cita.setEstadoCita(estadoSolicitado);
        Cita citaActualizada = repositorioDeCitas.save(cita);

        DateTimeFormatter formateador = DateTimeFormatter.ofPattern("dd/MM/yyyy 'a las' HH:mm");
        String fechaFormateada = citaActualizada.getFechaHoraCita().format(formateador);

        try {
            String nombreCliente = citaActualizada.getClienteReserva().getNombre();
            String correoCliente = citaActualizada.getClienteReserva().getCorreoElectronico();
            String nombreBarbero = citaActualizada.getBarberoAsignado().getUsuarioAsignado().getNombre();
            String nombreBarberia = citaActualizada.getBarberoAsignado().getBarberiaAsignada().getNombre();
            String nombreServicio = citaActualizada.getServicioContratado().getNombreServicio();
            String precio = String.format("%.2f", citaActualizada.getServicioContratado().getPrecioServicio());

            if (estadoSolicitado == EstadoCita.ACEPTADA) {
                emailService.enviarCorreoCitaAceptada(
                        correoCliente,
                        nombreCliente,
                        nombreBarbero,
                        nombreBarberia,
                        fechaFormateada,
                        nombreServicio,
                        precio
                );
            } else if (estadoSolicitado == EstadoCita.RECHAZADA) {
                emailService.enviarCorreoCitaRechazada(
                        correoCliente,
                        nombreCliente,
                        nombreBarbero,
                        nombreBarberia,
                        fechaFormateada,
                        nombreServicio
                );
            } else if (estadoSolicitado == EstadoCita.COMPLETADA) {
                emailService.enviarCorreoCitaCompletada(
                        correoCliente,
                        nombreCliente,
                        nombreBarbero,
                        nombreBarberia,
                        fechaFormateada,
                        nombreServicio,
                        precio
                );
            } else if (estadoSolicitado == EstadoCita.CANCELADA) {
                emailService.enviarCorreoCitaCancelada(
                        correoCliente,
                        nombreCliente,
                        nombreBarbero,
                        nombreBarberia,
                        fechaFormateada,
                        nombreServicio
                );
            }
        } catch (Exception excepcionCorreo) {
            System.err.println("Error al enviar correo: " + excepcionCorreo.getMessage());
        }

        return citaActualizada;
    }

    public CitaResponseDTO convertirACitaResponseDTO(Cita cita) {
        CitaResponseDTO dto = new CitaResponseDTO();

        dto.setIdCita(cita.getIdCita());
        dto.setFechaHoraCita(cita.getFechaHoraCita());
        dto.setEstadoCita(cita.getEstadoCita());
        dto.setPrecioFinal(cita.getPrecioFinal());

        dto.setIdCliente(cita.getClienteReserva().getIdUsuario());
        dto.setNombreCliente(cita.getClienteReserva().getNombre());
        dto.setCorreoCliente(cita.getClienteReserva().getCorreoElectronico());

        dto.setIdPerfilBarbero(cita.getBarberoAsignado().getIdPerfilBarbero());
        dto.setNombreBarbero(cita.getBarberoAsignado().getUsuarioAsignado().getNombre());

        dto.setIdBarberia(cita.getBarberoAsignado().getBarberiaAsignada().getIdBarberia());
        dto.setNombreBarberia(cita.getBarberoAsignado().getBarberiaAsignada().getNombre());

        dto.setIdServicio(cita.getServicioContratado().getIdServicio());
        dto.setNombreServicio(cita.getServicioContratado().getNombreServicio());
        dto.setPrecioServicio(cita.getServicioContratado().getPrecioServicio());
        dto.setDuracionMinutos(cita.getServicioContratado().getDuracionMinutos());

        return dto;
    }
}