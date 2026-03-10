package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.Barberia;
import com.darkmatter.bookcut.repository.BarberiaRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/api/barberias")
public class BarberiaController {

    private final BarberiaRepository repositorioDeBarberias;

    public BarberiaController(BarberiaRepository repositorioDeBarberias) {
        this.repositorioDeBarberias = repositorioDeBarberias;
    }

    @GetMapping
    public List<Barberia> obtenerTodasLasBarberias() {
        return repositorioDeBarberias.findAll();
    }
}
