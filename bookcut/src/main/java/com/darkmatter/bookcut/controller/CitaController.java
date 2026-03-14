package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.Cita;
import com.darkmatter.bookcut.service.CitaService;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/citas")
public class CitaController {

    // 1. Declaramos la variable del servicio
    private final CitaService servicioDeCitas;

    // 2. El constructor es el que quita el "rojo" porque conecta la clase
    public CitaController(CitaService servicioDeCitas) {
        this.servicioDeCitas = servicioDeCitas;
    }

    @PostMapping("/reservar")
    public Cita reservar(@RequestBody Cita nuevaCita) {
        return servicioDeCitas.crearNuevaCita(nuevaCita);
    }

    @GetMapping("/historial/{idUsuario}")
    public List<Cita> historial(@PathVariable Long idUsuario) {
        return servicioDeCitas.obtenerCitasPorUsuario(idUsuario);
    }

    // El nuevo método para el barbero
    @GetMapping("/barbero/{idBarbero}")
    public List<Cita> listarCitasBarbero(@PathVariable Long idBarbero) {
        return servicioDeCitas.obtenerCitasPorBarbero(idBarbero);
    }

    @DeleteMapping("/cancelar/{idCita}")
    public void cancelar(@PathVariable Long idCita) {
        servicioDeCitas.cancelarCita(idCita);
    }
}