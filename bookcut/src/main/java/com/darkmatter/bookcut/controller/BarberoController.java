package com.darkmatter.bookcut.controller;
import com.darkmatter.bookcut.model.Barbero;
import com.darkmatter.bookcut.repository.BarberoRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;
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
}