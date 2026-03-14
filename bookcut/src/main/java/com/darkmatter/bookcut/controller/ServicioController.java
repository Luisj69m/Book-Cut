package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.Servicio;
import com.darkmatter.bookcut.repository.ServicioRepository;
import org.springframework.web.bind.annotation.CrossOrigin; // Importante
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@CrossOrigin(origins = "*") // Sin esto Dani no puede conectar
@RestController
@RequestMapping("/api/servicios")
public class ServicioController {

    private final ServicioRepository repositorioDeServicios;

    public ServicioController(ServicioRepository repositorioDeServicios) {
        this.repositorioDeServicios = repositorioDeServicios;
    }

    @GetMapping
    public List<Servicio> obtenerTodosLosServicios() {
        return repositorioDeServicios.findAll();
    }
}