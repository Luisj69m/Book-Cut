package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.Barbero;
import com.darkmatter.bookcut.model.Cita;
import com.darkmatter.bookcut.model.EstadoCita;
import com.darkmatter.bookcut.repository.CitaRepository;
import com.darkmatter.bookcut.service.CitaService;
import com.darkmatter.bookcut.repository.BarberoRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/citas")
public class CitaController {

    // 1. Declaramos la variable del servicio
    private final CitaService servicioDeCitas;
    @Autowired
    private CitaRepository citaRepository;
    @Autowired
    private BarberoRepository barberoRepository;

    // 2. El constructor es el que quita el "rojo" porque conecta la clase
    public CitaController(CitaService servicioDeCitas) {
        this.servicioDeCitas = servicioDeCitas;
    }

    @PutMapping("/{idCita}/estado")
    public ResponseEntity<String> actualizarEstado(@PathVariable Long idCita, @RequestBody String nuevoEstado) {
        // 1. Limpieza agresiva: quitamos comillas, saltos de línea y cualquier carácter no alfanumérico
        String estadoLimpio = nuevoEstado.replaceAll("[^a-zA-Z]", "").trim().toUpperCase();

        System.out.println("DEBUG: El estado que llega procesado es: [" + estadoLimpio + "]");

        // 2. Convertimos a Enum
        try {
            EstadoCita estadoEnum = EstadoCita.valueOf(estadoLimpio);
            citaRepository.actualizarEstadoDirecto(idCita, estadoEnum);
            return ResponseEntity.ok("Estado actualizado a " + estadoLimpio);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().body("Error: '" + estadoLimpio + "' no es un estado válido.");
        }
    }

    @PostMapping("/reservar")
    public Cita reservar(@RequestBody Cita nuevaCita) {
        return servicioDeCitas.crearNuevaCita(nuevaCita);
    }

    @GetMapping("/historial/{idUsuario}")
    public List<Cita> historial(@PathVariable Long idUsuario) {
        return servicioDeCitas.obtenerCitasPorUsuario(idUsuario);
    }

    @GetMapping("/barbero/{idUsuario}/{estado}")
    public List<Cita> listarCitasPorBarberoYEstado(@PathVariable Long idUsuario, @PathVariable String estado) {
        // 1. Buscamos el perfil de barbero usando el ID de usuario que nos manda Dani
        Barbero barbero = barberoRepository.findByUsuarioAsignadoIdUsuario(idUsuario)
                .orElseThrow(() -> new RuntimeException("No se encontró perfil de barbero para el usuario: " + idUsuario));

        // 2. Convertimos el texto a Enum (como hicimos antes)
        EstadoCita estadoEnum = EstadoCita.valueOf(estado.toUpperCase().trim());

        // 3. Buscamos las citas que coincidan con ese barbero y ese estado
        return citaRepository.findByBarberoAsignadoAndEstadoCita(barbero, estadoEnum);
    }

    @DeleteMapping("/cancelar/{idCita}")
    public void cancelar(@PathVariable Long idCita) {
        servicioDeCitas.cancelarCita(idCita);
    }

    @GetMapping("/barbero/{idBarbero}/fecha/{fecha}")
    public List<Cita> obtenerCitasPorBarberoYFecha(
            @PathVariable Long idBarbero,
            @PathVariable String fecha) {

        // Filtramos todas las citas del barbero y nos quedamos solo con las de ese día
        return citaRepository.findByBarberoAsignado_IdPerfilBarbero(idBarbero)
                .stream()
                .filter(c -> c.getFechaHoraCita().toLocalDate().toString().equals(fecha))
                .toList();
    }
}