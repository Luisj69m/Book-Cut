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
    public Cita reservarCita(@RequestBody Cita datosDeLaCita) {
        return servicioDeCitas.crearNuevaCita(datosDeLaCita);
    }
    @GetMapping("/historial/{idUsuario}")
    public List<Cita> verHistorial(@PathVariable Long idUsuario) {
        return servicioDeCitas.obtenerHistorialDeCliente(idUsuario);
    }
}