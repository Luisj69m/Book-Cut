package com.darkmatter.bookcut.controller;
import com.darkmatter.bookcut.model.Barbero;
import com.darkmatter.bookcut.repository.BarberoRepository;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/barberos")
public class BarberoController {
    private final BarberoRepository repositorioDeBarberos;
    public BarberoController(BarberoRepository repositorioDeBarberos) {
        this.repositorioDeBarberos = repositorioDeBarberos;
    }
    @GetMapping("/barberia/{identificadorBarberia}")
    public List<Barbero> obtenerBarberosPorBarberia(@PathVariable Long identificadorBarberia) {
        // Fíjate aquí: he quitado el guion bajo para que coincida con el Repository
        return repositorioDeBarberos.findByBarberiaAsignadaIdBarberia(identificadorBarberia);
    }

    @GetMapping("/todos")
    public List<Barbero> listarTodos() {
        return repositorioDeBarberos.findAll();
    }
}