package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.DTO.CitaResponseDTO;
import com.darkmatter.bookcut.model.*;
import com.darkmatter.bookcut.repository.*;
import com.darkmatter.bookcut.service.CitaService;
import com.darkmatter.bookcut.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/citas")
public class CitaController {

    @Autowired
    private CitaService citaService;
    @Autowired
    private CitaRepository citaRepository;
    @Autowired
    private BarberoRepository barberoRepository;
    @Autowired
    private UsuarioService usuarioService;
    @Autowired
    private BarberiaRepository barberiaRepository;
    @Autowired
    private ServicioRepository servicioRepository;

    @PostMapping("/crear")
    public ResponseEntity<?> crearCita(@RequestBody Map<String, Object> datosPeticion, @AuthenticationPrincipal String correoCliente){
        try {
            Long identificadorBarberia = Long.valueOf(datosPeticion.get("idBarberia").toString());
            Long identificadorServicio = Long.valueOf(datosPeticion.get("idServicio").toString());
            String fechaTexto = datosPeticion.get("fechaHoraCita").toString();

            Usuario clienteSolicitante = usuarioService.obtenerUsuarioPorCorreo(correoCliente);

            Barberia barberiaEncontrada = barberiaRepository.findById(identificadorBarberia)
                    .orElseThrow(() -> new RuntimeException("La barbería no existe."));
            Servicio servicioSolicitado = servicioRepository.findById(identificadorServicio)
                    .orElseThrow(() -> new RuntimeException("El servicio no existe."));

            LocalDateTime fechaProgramada;
            try {
                fechaProgramada = LocalDateTime.parse(fechaTexto);
            } catch (Exception excepcionFormato) {
                return ResponseEntity.status(400).body("Formato de fecha inválido. Usa: YYYY-MM-DDTHH:mm:ss");
            }

            if (fechaProgramada.isBefore(LocalDateTime.now())) {
                return ResponseEntity.status(400).body("No puedes programar citas en el pasado.");
            }

            int horaSolicitada = fechaProgramada.getHour();
            if (horaSolicitada < 9 || horaSolicitada >= 22) {
                return ResponseEntity.status(400).body("Horario no válido. Las reservas solo están permitidas entre las 09:00 y las 22:00.");
            }

            Barbero barberoDisponible = barberoRepository.findFirstByBarberiaAsignadaIdBarberia(identificadorBarberia)
                    .orElseThrow(() -> new RuntimeException("Esta barbería no tiene barberos asignados."));

            Cita citaPreparada = new Cita();
            citaPreparada.setClienteReserva(clienteSolicitante);
            citaPreparada.setServicioContratado(servicioSolicitado);
            citaPreparada.setFechaHoraCita(fechaProgramada);
            citaPreparada.setEstadoCita(EstadoCita.PENDIENTE);
            citaPreparada.setBarberoAsignado(barberoDisponible);

            Cita citaGuardada = citaService.crearNuevaCita(citaPreparada);

            return ResponseEntity.status(201).body(citaGuardada);

        } catch (Exception excepcionGeneral) {
            return ResponseEntity.status(400).body("Error al procesar la reserva: " + excepcionGeneral.getMessage());
        }
    }

    @PutMapping("/{idCita}/estado")
    public ResponseEntity<String> actualizarEstado(@PathVariable Long idCita, @RequestBody String nuevoEstado, @AuthenticationPrincipal String usuarioLogueado) {
        Cita cita = citaRepository.findById(idCita).orElse(null);
        if (cita == null) return ResponseEntity.status(404).body("Cita no encontrada.");
        String emailBarbero = cita.getBarberoAsignado().getUsuarioAsignado().getCorreoElectronico();
        if (!emailBarbero.equalsIgnoreCase(usuarioLogueado)) {
            return ResponseEntity.status(403).body("Solo el barbero asignado puede cambiar el estado.");
        }
        String estadoLimpio = nuevoEstado.replaceAll("[^a-zA-Z]", "").trim().toUpperCase();
        try {
            citaService.actualizarEstadoCita(idCita, estadoLimpio);
            return ResponseEntity.ok("Estado actualizado a " + estadoLimpio);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }

    @GetMapping("/historial/{idUsuario}")
    public ResponseEntity<?> historial(@PathVariable Long idUsuario, @AuthenticationPrincipal String correoLogueado) {
        Usuario usuarioAutenticado = usuarioService.obtenerUsuarioPorCorreo(correoLogueado);
        if (!usuarioAutenticado.getIdUsuario().equals(idUsuario)) {
            return ResponseEntity.status(403).body("Acceso denegado: No puedes ver el historial de otro cliente.");
        }
        return ResponseEntity.ok(citaService.obtenerCitasPorUsuarioDTO(idUsuario));
    }

    @GetMapping("/barbero/{idUsuario}/{estado}")
    public List<Cita> listarCitasPorBarberoYEstado(@PathVariable Long idUsuario, @PathVariable String estado) {
        Barbero barbero = barberoRepository.findByUsuarioAsignadoIdUsuario(idUsuario).orElseThrow(() -> new RuntimeException("No se encontró perfil de barbero"));
        EstadoCita estadoEnum = EstadoCita.valueOf(estado.toUpperCase().trim());
        return citaRepository.findByBarberoAsignadoAndEstadoCita(barbero, estadoEnum);
    }

    @PutMapping("/cancelar/{idCita}")
    public ResponseEntity<String> cancelar(@PathVariable Long idCita, @AuthenticationPrincipal String usuarioLogueado) {
        Cita citaEncontrada = citaRepository.findById(idCita).orElse(null);

        if (citaEncontrada == null) {
            return ResponseEntity.status(404).body("Cita no encontrada.");
        }

        String correoCliente = citaEncontrada.getClienteReserva().getCorreoElectronico();
        String correoBarbero = citaEncontrada.getBarberoAsignado().getUsuarioAsignado().getCorreoElectronico();

        if (!usuarioLogueado.equalsIgnoreCase(correoCliente) && !usuarioLogueado.equalsIgnoreCase(correoBarbero)) {
            return ResponseEntity.status(403).body("No tienes permiso para cancelar esta cita.");
        }

        try {
            citaService.cancelarCita(idCita);
            return ResponseEntity.ok("Cita cancelada correctamente.");
        } catch (RuntimeException excepcionEstado) {
            return ResponseEntity.status(400).body(excepcionEstado.getMessage());
        }
    }

    @GetMapping("/barbero/{idBarbero}/fecha/{fecha}")
    public List<Cita> obtenerCitasPorBarberoYFecha(@PathVariable Long idBarbero, @PathVariable String fecha) {
        return citaRepository.findByBarberoAsignado_IdPerfilBarbero(idBarbero).stream().filter(c -> c.getFechaHoraCita().toLocalDate().toString().equals(fecha)).toList();
    }

    @PutMapping("/{idCita}/finalizar")
    public ResponseEntity<String> finalizarCita(@PathVariable Long idCita, @AuthenticationPrincipal String usuarioLogueado) {
        Cita cita = citaRepository.findById(idCita).orElse(null);
        if (cita == null) return ResponseEntity.status(404).body("Cita no encontrada.");
        String emailBarbero = cita.getBarberoAsignado().getUsuarioAsignado().getCorreoElectronico();
        if (!emailBarbero.equalsIgnoreCase(usuarioLogueado)) {
            return ResponseEntity.status(403).body("Solo el barbero puede finalizar la cita.");
        }
        try {
            citaService.actualizarEstadoCita(idCita, "COMPLETADA");
            return ResponseEntity.ok("Cita finalizada.");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }
}