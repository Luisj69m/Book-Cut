package com.darkmatter.bookcut.controller;
import com.darkmatter.bookcut.model.Cita;
import com.darkmatter.bookcut.service.CitaService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
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
}