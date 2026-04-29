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
    public ResponseEntity<?> crearCita(@RequestBody Map<String, Object> payload, @AuthenticationPrincipal String clienteEmail) {
        try {
            Long idBarberia = Long.valueOf(payload.get("idBarberia").toString());
            Long idServicio = Long.valueOf(payload.get("idServicio").toString());
            String fechaStr = payload.get("fechaHoraCita").toString();
            Usuario cliente = usuarioService.obtenerUsuarioPorCorreo(clienteEmail);
            Optional<Barberia> barberiaOpt = barberiaRepository.findById(idBarberia);
            Optional<Servicio> servicioOpt = servicioRepository.findById(idServicio);
            if (barberiaOpt.isEmpty() || servicioOpt.isEmpty()) {
                return ResponseEntity.status(404).body("La barbería o el servicio no existen.");
            }
            LocalDateTime fechaCita;
            try {
                fechaCita = LocalDateTime.parse(fechaStr);
            } catch (Exception e) {
                return ResponseEntity.status(400).body("Formato de fecha inválido. Usa: YYYY-MM-DDTHH:mm:ss");
            }
            if (fechaCita.isBefore(LocalDateTime.now())) {
                return ResponseEntity.status(400).body("No puedes programar citas en el pasado.");
            }
            Cita nuevaCita = new Cita();
            nuevaCita.setClienteReserva(cliente);
            nuevaCita.setServicioContratado(servicioOpt.get());
            nuevaCita.setFechaHoraCita(fechaCita);
            nuevaCita.setEstadoCita(EstadoCita.PENDIENTE);
            if (barberiaOpt.isPresent()) {
                Barbero barberoReal = barberoRepository.findFirstByBarberiaAsignadaIdBarberia(idBarberia).orElseThrow(() -> new RuntimeException("Esta barbería no tiene barberos asignados"));
                boolean citaOcupada = citaRepository.existsByBarberoAsignadoAndFechaHoraCita(barberoReal, fechaCita);
                if (citaOcupada) {
                    return ResponseEntity.status(400).body("El barbero ya tiene una reserva a esa hora exacta.");
                }
                nuevaCita.setBarberoAsignado(barberoReal);
            }
            return ResponseEntity.status(201).body(citaRepository.save(nuevaCita));
        } catch (Exception e) {
            return ResponseEntity.status(400).body("Error en los datos enviados: " + e.getMessage());
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
    public List<CitaResponseDTO> historial(@PathVariable Long idUsuario) {
        return citaService.obtenerCitasPorUsuarioDTO(idUsuario);
    }

    @GetMapping("/barbero/{idUsuario}/{estado}")
    public List<Cita> listarCitasPorBarberoYEstado(@PathVariable Long idUsuario, @PathVariable String estado) {
        Barbero barbero = barberoRepository.findByUsuarioAsignadoIdUsuario(idUsuario).orElseThrow(() -> new RuntimeException("No se encontró perfil de barbero"));
        EstadoCita estadoEnum = EstadoCita.valueOf(estado.toUpperCase().trim());
        return citaRepository.findByBarberoAsignadoAndEstadoCita(barbero, estadoEnum);
    }

    @PutMapping("/cancelar/{idCita}")
    public ResponseEntity<String> cancelar(@PathVariable Long idCita, @AuthenticationPrincipal String usuarioLogueado) {
        Cita cita = citaRepository.findById(idCita).orElse(null);
        if (cita == null) return ResponseEntity.status(404).body("Cita no encontrada.");
        String emailCliente = cita.getClienteReserva().getCorreoElectronico();
        String emailBarbero = cita.getBarberoAsignado().getUsuarioAsignado().getCorreoElectronico();
        if (!usuarioLogueado.equalsIgnoreCase(emailCliente) && !usuarioLogueado.equalsIgnoreCase(emailBarbero)) {
            return ResponseEntity.status(403).body("No tienes permiso para cancelar esta cita.");
        }
        citaService.cancelarCita(idCita);
        return ResponseEntity.ok("Cita cancelada correctamente.");
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