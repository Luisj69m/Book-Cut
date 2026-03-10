package com.darkmatter.bookcut.controller;
import com.darkmatter.bookcut.model.Cita;
import com.darkmatter.bookcut.service.CitaService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/citas")
public class CitaController {
    private final CitaService servicioDeCitas;
    public CitaController(CitaService servicioDeCitas) {
        this.servicioDeCitas = servicioDeCitas;
    }
    @PostMapping("/reservar")
    public Cita reservar(@RequestBody Cita nuevaCita) {
        // Asegúrate de llamar a crearNuevaCita del SERVICIO, no al save del repositorio
        return servicioDeCitas.crearNuevaCita(nuevaCita);
    }
    @GetMapping("/historial/{idUsuario}")
    public List<Cita> verHistorial(@PathVariable Long idUsuario) {
        return servicioDeCitas.obtenerHistorialDeCliente(idUsuario);
    }
}