package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.Barbero;
import com.darkmatter.bookcut.model.Cita;
import com.darkmatter.bookcut.model.EstadoCita;
import com.darkmatter.bookcut.repository.CitaRepository;
import com.darkmatter.bookcut.service.CitaService;
import com.darkmatter.bookcut.repository.BarberoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

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

    @PutMapping("/{idCita}/estado")
    public ResponseEntity<String> actualizarEstado(@PathVariable Long idCita, @RequestBody String nuevoEstado) {
        String estadoLimpio = nuevoEstado.replaceAll("[^a-zA-Z]", "").trim().toUpperCase();

        // Usamos el nuevo método del servicio para que envíe correos al aceptar/rechazar
        try {
            citaService.actualizarEstadoCita(idCita, estadoLimpio);
            return ResponseEntity.ok("Estado actualizado a " + estadoLimpio + " y cliente notificado.");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error al actualizar estado: " + e.getMessage());
        }
    }

    @PostMapping("/reservar")
    public Cita reservar(@RequestBody Cita nuevaCita) {
        return citaService.crearNuevaCita(nuevaCita);
    }

    @PostMapping
    public ResponseEntity<Cita> crearCita(@RequestBody Cita cita) {
        Cita nuevaCita = citaService.crearNuevaCita(cita);
        return ResponseEntity.ok(nuevaCita);
    }

    @GetMapping("/historial/{idUsuario}")
    public List<Cita> historial(@PathVariable Long idUsuario) {
        return citaService.obtenerCitasPorUsuario(idUsuario);
    }

    @GetMapping("/barbero/{idUsuario}/{estado}")
    public List<Cita> listarCitasPorBarberoYEstado(@PathVariable Long idUsuario, @PathVariable String estado) {
        Barbero barbero = barberoRepository.findByUsuarioAsignadoIdUsuario(idUsuario)
                .orElseThrow(() -> new RuntimeException("No se encontró perfil de barbero"));

        EstadoCita estadoEnum = EstadoCita.valueOf(estado.toUpperCase().trim());
        return citaRepository.findByBarberoAsignadoAndEstadoCita(barbero, estadoEnum);
    }

    @DeleteMapping("/cancelar/{idCita}")
    public ResponseEntity<String> cancelar(@PathVariable Long idCita) {
        citaService.cancelarCita(idCita);
        return ResponseEntity.ok("Cita cancelada y cliente notificado.");
    }

    @GetMapping("/barbero/{idBarbero}/fecha/{fecha}")
    public List<Cita> obtenerCitasPorBarberoYFecha(@PathVariable Long idBarbero, @PathVariable String fecha) {
        return citaRepository.findByBarberoAsignado_IdPerfilBarbero(idBarbero)
                .stream()
                .filter(c -> c.getFechaHoraCita().toLocalDate().toString().equals(fecha))
                .toList();
    }
}