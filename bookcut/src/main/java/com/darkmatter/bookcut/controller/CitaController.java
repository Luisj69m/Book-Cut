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
    private ServicioRepository  servicioRepository;

    @PostMapping("/crear")
    public ResponseEntity<?> crearCita(@RequestBody Map<String, Object> payload, @AuthenticationPrincipal String clienteEmail) {
        try {
            // 1. Extraer IDs del JSON
            Long idBarberia = Long.valueOf(payload.get("idBarberia").toString());
            Long idServicio = Long.valueOf(payload.get("idServicio").toString());
            String fechaStr = payload.get("fechaHoraCita").toString();

            // 2. Buscar objetos en la BD (Evita el error 11)
            Usuario cliente = usuarioService.obtenerUsuarioPorCorreo(clienteEmail);
            Optional<Barberia> barberiaOpt = barberiaRepository.findById(idBarberia);
            Optional<Servicio> servicioOpt = servicioRepository.findById(idServicio);

            if (barberiaOpt.isEmpty() || servicioOpt.isEmpty()) {
                return ResponseEntity.status(404).body("La barbería o el servicio no existen.");
            }

            // 3. Validar Fecha (Evita el error 10 y 12)
            LocalDateTime fechaCita;
            try {
                fechaCita = LocalDateTime.parse(fechaStr);
            } catch (Exception e) {
                return ResponseEntity.status(400).body("Formato de fecha inválido. Usa: YYYY-MM-DDTHH:mm:ss");
            }

            if (fechaCita.isBefore(LocalDateTime.now())) {
                return ResponseEntity.status(400).body("No puedes programar citas en el pasado.");
            }

            // 4. Crear y guardar la cita
            Cita nuevaCita = new Cita();

// Usamos los nombres exactos de tus setters en Cita.java
            nuevaCita.setClienteReserva(cliente); // Antes tenías setCliente
            nuevaCita.setServicioContratado(servicioOpt.get()); // Antes tenías setServicio
            nuevaCita.setFechaHoraCita(fechaCita);

            nuevaCita.setEstadoCita(EstadoCita.PENDIENTE);

            if (barberiaOpt.isPresent()) {
                // Buscamos el objeto Barbero que pertenece a esa barbería
                Barbero barberoReal = barberoRepository.findFirstByBarberiaAsignadaIdBarberia(idBarberia)
                        .orElseThrow(() -> new RuntimeException("Esta barbería no tiene barberos asignados"));

                nuevaCita.setBarberoAsignado(barberoReal);
            }

            return ResponseEntity.status(201).body(citaRepository.save(nuevaCita));

        } catch (Exception e) {
            // Esto captura cualquier otro error y evita el 500 genérico
            return ResponseEntity.status(400).body("Error en los datos enviados: " + e.getMessage());
        }
    }

    @PutMapping("/{idCita}/estado")
    public ResponseEntity<String> actualizarEstado(@PathVariable Long idCita, @RequestBody String nuevoEstado) {
        String estadoLimpio = nuevoEstado.replaceAll("[^a-zA-Z]", "").trim().toUpperCase();

        try {
            citaService.actualizarEstadoCita(idCita, estadoLimpio);
            return ResponseEntity.ok("Estado actualizado a " + estadoLimpio + " y cliente notificado.");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error al actualizar estado: " + e.getMessage());
        }
    }

    @GetMapping("/historial/{idUsuario}")
    public List<CitaResponseDTO> historial(@PathVariable Long idUsuario) {
        return citaService.obtenerCitasPorUsuarioDTO(idUsuario);
    }

    @GetMapping("/barbero/{idUsuario}/{estado}")
    public List<Cita> listarCitasPorBarberoYEstado(@PathVariable Long idUsuario, @PathVariable String estado) {
        Barbero barbero = barberoRepository.findByUsuarioAsignadoIdUsuario(idUsuario)
                .orElseThrow(() -> new RuntimeException("No se encontró perfil de barbero"));

        EstadoCita estadoEnum = EstadoCita.valueOf(estado.toUpperCase().trim());
        return citaRepository.findByBarberoAsignadoAndEstadoCita(barbero, estadoEnum);
    }

    @PutMapping("/cancelar/{idCita}")
    public ResponseEntity<String> cancelar(@PathVariable Long idCita) {
        citaService.cancelarCita(idCita);
        return ResponseEntity.ok("La cita ha sido marcada como CANCELADA y el cliente ha sido notificado.");
    }

    @GetMapping("/barbero/{idBarbero}/fecha/{fecha}")
    public List<Cita> obtenerCitasPorBarberoYFecha(@PathVariable Long idBarbero, @PathVariable String fecha) {
        return citaRepository.findByBarberoAsignado_IdPerfilBarbero(idBarbero)
                .stream()
                .filter(c -> c.getFechaHoraCita().toLocalDate().toString().equals(fecha))
                .toList();
    }

    @PutMapping("/{idCita}/finalizar")
    public ResponseEntity<String> finalizarCita(@PathVariable Long idCita) {
        try {
            citaService.actualizarEstadoCita(idCita, "COMPLETADA");
            return ResponseEntity.ok("Cita completada correctamente. El servicio ha sido cobrado.");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error al finalizar la cita: " + e.getMessage());
        }
    }
}