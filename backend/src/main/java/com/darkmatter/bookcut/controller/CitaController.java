package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.*;
import com.darkmatter.bookcut.repository.*;
import com.darkmatter.bookcut.service.CitaService;
import com.darkmatter.bookcut.service.UsuarioService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

/**
 * Controlador principal para la gestión de citas.
 * Gestiona la creación, modificación de estados y consultas de historial,
 * aplicando estrictas validaciones de identidad mediante el token JWT.
 */
@RestController
@RequestMapping("/api/citas")
public class CitaController {

    private final CitaService servicioCitas;
    private final CitaRepository repositorioCitas;
    private final BarberoRepository repositorioBarberos;
    private final UsuarioService servicioUsuarios;
    private final BarberiaRepository repositorioBarberias;
    private final ServicioRepository repositorioServicios;

    public CitaController(CitaService servicioCitas, CitaRepository repositorioCitas, BarberoRepository repositorioBarberos, UsuarioService servicioUsuarios, BarberiaRepository repositorioBarberias, ServicioRepository repositorioServicios) {
        this.servicioCitas = servicioCitas;
        this.repositorioCitas = repositorioCitas;
        this.repositorioBarberos = repositorioBarberos;
        this.servicioUsuarios = servicioUsuarios;
        this.repositorioBarberias = repositorioBarberias;
        this.repositorioServicios = repositorioServicios;
    }

    @PostMapping("/crear")
    public ResponseEntity<?> crearCita(@RequestBody Map<String, Object> datosPeticion, @AuthenticationPrincipal String correoCliente) {
        try {
            Long identificadorBarberia = Long.valueOf(datosPeticion.get("idBarberia").toString());
            Long identificadorServicio = Long.valueOf(datosPeticion.get("idServicio").toString());
            String fechaTexto = datosPeticion.get("fechaHoraCita").toString();

            Usuario clienteSolicitante = servicioUsuarios.obtenerUsuarioPorCorreo(correoCliente);

            Barberia barberiaEncontrada = repositorioBarberias.findById(identificadorBarberia)
                    .orElseThrow(() -> new RuntimeException("La barbería especificada no existe."));
            Servicio servicioSolicitado = repositorioServicios.findById(identificadorServicio)
                    .orElseThrow(() -> new RuntimeException("El servicio especificado no existe."));

            LocalDateTime fechaProgramada;
            try {
                fechaProgramada = LocalDateTime.parse(fechaTexto);
            } catch (Exception excepcionFormato) {
                return ResponseEntity.status(400).body("Formato de fecha inválido. Utilice: YYYY-MM-DDTHH:mm:ss");
            }

            if (fechaProgramada.isBefore(LocalDateTime.now())) {
                return ResponseEntity.status(400).body("Violación de regla de negocio: No se pueden programar citas en el pasado.");
            }

            int horaSolicitada = fechaProgramada.getHour();
            if (horaSolicitada < 9 || horaSolicitada >= 22) {
                return ResponseEntity.status(400).body("Horario no válido. Las reservas solo están permitidas entre las 09:00 y las 22:00.");
            }

            Barbero barberoDisponible = repositorioBarberos.findFirstByBarberiaAsignadaIdBarberia(identificadorBarberia)
                    .orElseThrow(() -> new RuntimeException("Esta barbería actualmente no tiene trabajadores asignados."));

            Cita citaPreparada = new Cita();
            citaPreparada.setClienteReserva(clienteSolicitante);
            citaPreparada.setServicioContratado(servicioSolicitado);
            citaPreparada.setFechaHoraCita(fechaProgramada);
            citaPreparada.setEstadoCita(EstadoCita.PENDIENTE);
            citaPreparada.setBarberoAsignado(barberoDisponible);

            Cita citaGuardada = servicioCitas.crearNuevaCita(citaPreparada);

            return ResponseEntity.status(201).body(citaGuardada);

        } catch (Exception excepcion) {
            return ResponseEntity.status(400).body("Error al procesar la reserva: " + excepcion.getMessage());
        }
    }

    @PutMapping("/{idCita}/estado")
    public ResponseEntity<String> actualizarEstado(@PathVariable Long idCita, @RequestBody String nuevoEstado, @AuthenticationPrincipal String usuarioAutenticado) {
        Cita citaEncontrada = repositorioCitas.findById(idCita).orElse(null);
        if (citaEncontrada == null) {
            return ResponseEntity.status(404).body("La cita no existe en los registros.");
        }

        String correoElectronicoBarbero = citaEncontrada.getBarberoAsignado().getUsuarioAsignado().getCorreoElectronico();
        if (!correoElectronicoBarbero.equalsIgnoreCase(usuarioAutenticado)) {
            return ResponseEntity.status(403).body("Acceso denegado: Solo el trabajador asignado puede modificar el estado de la cita.");
        }

        String estadoSaneado = nuevoEstado.replaceAll("[^a-zA-Z]", "").trim().toUpperCase();
        try {
            // Nota arquitectónica: La lógica de fijar el precioFinal al pasar a ACEPTADA reside en la capa de servicio
            servicioCitas.actualizarEstadoCita(idCita, estadoSaneado);
            return ResponseEntity.ok("Estado de la cita actualizado correctamente a " + estadoSaneado);
        } catch (Exception excepcion) {
            return ResponseEntity.badRequest().body("Error durante la actualización: " + excepcion.getMessage());
        }
    }

    @GetMapping("/historial/{idUsuario}")
    public ResponseEntity<?> obtenerHistorial(@PathVariable Long idUsuario, @AuthenticationPrincipal String correoAutenticado) {
        Usuario usuarioConsultor = servicioUsuarios.obtenerUsuarioPorCorreo(correoAutenticado);

        if (!usuarioConsultor.getIdUsuario().equals(idUsuario)) {
            return ResponseEntity.status(403).body("Acceso denegado: Violación de privacidad al intentar consultar el historial de otro cliente.");
        }

        return ResponseEntity.ok(servicioCitas.obtenerCitasPorUsuarioDTO(idUsuario));
    }

    @GetMapping("/barbero/{idUsuario}/{estado}")
    public List<Cita> listarCitasPorBarberoYEstado(@PathVariable Long idUsuario, @PathVariable String estado) {
        Barbero perfilBarbero = repositorioBarberos.findByUsuarioAsignadoIdUsuario(idUsuario)
                .orElseThrow(() -> new RuntimeException("No se encontró un perfil de trabajador asociado a este usuario."));
        EstadoCita enumeracionEstado = EstadoCita.valueOf(estado.toUpperCase().trim());

        return repositorioCitas.findByBarberoAsignadoAndEstadoCita(perfilBarbero, enumeracionEstado);
    }

    @PutMapping("/cancelar/{idCita}")
    public ResponseEntity<String> cancelarCita(@PathVariable Long idCita, @AuthenticationPrincipal String usuarioAutenticado) {
        Cita citaObjetivo = repositorioCitas.findById(idCita).orElse(null);

        if (citaObjetivo == null) {
            return ResponseEntity.status(404).body("La cita indicada no existe.");
        }

        String correoElectronicoCliente = citaObjetivo.getClienteReserva().getCorreoElectronico();
        String correoElectronicoBarbero = citaObjetivo.getBarberoAsignado().getUsuarioAsignado().getCorreoElectronico();

        if (!usuarioAutenticado.equalsIgnoreCase(correoElectronicoCliente) && !usuarioAutenticado.equalsIgnoreCase(correoElectronicoBarbero)) {
            return ResponseEntity.status(403).body("Acceso denegado: No participa en esta cita y no puede cancelarla.");
        }

        try {
            servicioCitas.cancelarCita(idCita);
            return ResponseEntity.ok("La cita ha sido cancelada exitosamente.");
        } catch (RuntimeException excepcionValidacion) {
            return ResponseEntity.status(400).body(excepcionValidacion.getMessage());
        }
    }

    @GetMapping("/barbero/{idBarbero}/fecha/{fecha}")
    public List<Cita> obtenerCitasPorBarberoYFecha(@PathVariable Long idBarbero, @PathVariable String fecha) {
        return repositorioCitas.findByBarberoAsignado_IdPerfilBarbero(idBarbero).stream()
                .filter(cita -> cita.getFechaHoraCita().toLocalDate().toString().equals(fecha))
                .toList();
    }

    @PutMapping("/{idCita}/finalizar")
    public ResponseEntity<String> finalizarCita(@PathVariable Long idCita, @AuthenticationPrincipal String usuarioAutenticado) {
        Cita citaObjetivo = repositorioCitas.findById(idCita).orElse(null);
        if (citaObjetivo == null) {
            return ResponseEntity.status(404).body("La cita indicada no existe.");
        }

        String correoElectronicoBarbero = citaObjetivo.getBarberoAsignado().getUsuarioAsignado().getCorreoElectronico();
        if (!correoElectronicoBarbero.equalsIgnoreCase(usuarioAutenticado)) {
            return ResponseEntity.status(403).body("Acceso denegado: Solo el trabajador encargado puede marcar la cita como completada.");
        }

        try {
            servicioCitas.actualizarEstadoCita(idCita, EstadoCita.COMPLETADA.name());
            return ResponseEntity.ok("La cita ha finalizado correctamente.");
        } catch (Exception excepcion) {
            return ResponseEntity.badRequest().body("Error al finalizar la cita: " + excepcion.getMessage());
        }
    }

    @GetMapping("/todas")
    public ResponseEntity<?> obtenerTodasLasCitasAbsolutas() {
        try {
            List<Cita> registroTotalCitas = repositorioCitas.findAll();
            if (registroTotalCitas.isEmpty()) {
                return ResponseEntity.noContent().build();
            }
            return ResponseEntity.ok(registroTotalCitas);
        } catch (Exception excepcion) {
            return ResponseEntity.status(500).body("Error interno al volcar el registro general de citas: " + excepcion.getMessage());
        }
    }

    @GetMapping("/barberia/{idBarberia}")
    public ResponseEntity<?> obtenerCitasPorBarberia(@PathVariable Long idBarberia) {
        try {
            List<Cita> citasDelEstablecimiento = repositorioCitas.findByBarberoAsignado_BarberiaAsignada_IdBarberia(idBarberia);
            if (citasDelEstablecimiento.isEmpty()) {
                return ResponseEntity.noContent().build();
            }
            return ResponseEntity.ok(citasDelEstablecimiento);
        } catch (Exception excepcion) {
            return ResponseEntity.status(500).body("Error interno al obtener el listado del establecimiento: " + excepcion.getMessage());
        }
    }
}