package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.HorarioBarbero;
import com.darkmatter.bookcut.repository.HorarioBarberoRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * Controlador para la consulta de la disponibilidad horaria de los trabajadores.
 * Nota de arquitectura: Este controlador ataca directamente al HorarioBarberoRepository,
 * prescindiendo de una capa HorarioService, ya que son consultas de solo lectura directas.
 */
@RestController
@RequestMapping("/api/horarios")
public class HorarioController {

    private final HorarioBarberoRepository repositorioHorarios;

    public HorarioController(HorarioBarberoRepository repositorioHorarios) {
        this.repositorioHorarios = repositorioHorarios;
    }

    @GetMapping("/barbero/{idBarbero}")
    public List<HorarioBarbero> obtenerHorariosPorBarbero(@PathVariable Long idBarbero) {
        return repositorioHorarios.findByBarbero_IdPerfilBarbero(idBarbero);
    }
}
