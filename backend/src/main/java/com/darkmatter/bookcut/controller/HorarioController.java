package com.darkmatter.bookcut.controller;
import com.darkmatter.bookcut.model.HorarioBarbero;
import com.darkmatter.bookcut.repository.HorarioBarberoRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;
@RestController
@RequestMapping("/api/horarios")
public class HorarioController {
    private final HorarioBarberoRepository repositorioDeHorarios;
    public HorarioController(HorarioBarberoRepository repositorioDeHorarios) {
        this.repositorioDeHorarios = repositorioDeHorarios;
    }
    @GetMapping("/barbero/{idBarbero}")
    public List<HorarioBarbero> obtenerHorariosPorBarbero(@PathVariable Long idBarbero) {
        return repositorioDeHorarios.findByBarbero_IdPerfilBarbero(idBarbero);
    }
}
