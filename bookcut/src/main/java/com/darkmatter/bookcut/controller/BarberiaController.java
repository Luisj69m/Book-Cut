package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.Barberia;
import com.darkmatter.bookcut.model.Usuario;
import com.darkmatter.bookcut.repository.BarberiaRepository;
import com.darkmatter.bookcut.service.UsuarioService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/barberias")
public class BarberiaController {

    private final BarberiaRepository repositorioDeBarberias;
    private final UsuarioService usuarioService;

    public BarberiaController(BarberiaRepository repositorioDeBarberias, UsuarioService usuarioService) {
        this.repositorioDeBarberias = repositorioDeBarberias;
        this.usuarioService = usuarioService;
    }

    @GetMapping
    public List<Barberia> obtenerTodasLasBarberias() {
        return repositorioDeBarberias.findAll();
    }

    @GetMapping("/mi-barberia/{correoBarbero}")
    public ResponseEntity<Barberia> obtenerBarberiaPorCorreo(@PathVariable String correoBarbero) {
        return repositorioDeBarberias.findByBarberoPropietario_CorreoElectronico(correoBarbero)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/mi-barberia/{correoBarbero}")
    public ResponseEntity<Barberia> guardarOActualizarBarberia(@PathVariable String correoBarbero, @RequestBody Barberia datosBarberia) {
        Usuario barberoEncontrado = usuarioService.obtenerUsuarioPorCorreo(correoBarbero);

        Barberia barberiaGuardada = repositorioDeBarberias.findByBarberoPropietario_CorreoElectronico(correoBarbero)
                .map(existente -> {
                    existente.setNombre(datosBarberia.getNombre());
                    existente.setDireccionCompleta(datosBarberia.getDireccionCompleta());
                    existente.setZona(datosBarberia.getZona());
                    existente.setHorario(datosBarberia.getHorario());
                    existente.setDescripcion(datosBarberia.getDescripcion());
                    return repositorioDeBarberias.save(existente);
                })
                .orElseGet(() -> {
                    datosBarberia.setBarberoPropietario(barberoEncontrado);
                    return repositorioDeBarberias.save(datosBarberia);
                });

        return ResponseEntity.ok(barberiaGuardada);
    }
}