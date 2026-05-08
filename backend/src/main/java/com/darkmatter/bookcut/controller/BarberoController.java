package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.Barbero;
import com.darkmatter.bookcut.repository.BarberoRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * Controlador para la consulta de la entidad pivote Barbero.
 * Permite la obtención de empleados por local asignado o por usuario vinculado.
 */
@RestController
@RequestMapping("/api/barberos")
public class BarberoController {

    private final BarberoRepository repositorioBarberos;

    public BarberoController(BarberoRepository repositorioBarberos) {
        this.repositorioBarberos = repositorioBarberos;
    }

    @GetMapping("/barberia/{identificadorBarberia}")
    public List<Barbero> obtenerBarberosPorBarberia(@PathVariable Long identificadorBarberia) {
        return repositorioBarberos.findByBarberiaAsignadaIdBarberia(identificadorBarberia);
    }

    @GetMapping("/todos")
    public List<Barbero> listarTodos() {
        return repositorioBarberos.findAll();
    }

    @GetMapping("/usuario/{idUsuario}")
    public ResponseEntity<Barbero> obtenerPerfilBarberoPorUsuario(@PathVariable Long idUsuario) {
        return repositorioBarberos.findByUsuarioAsignadoIdUsuario(idUsuario)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}