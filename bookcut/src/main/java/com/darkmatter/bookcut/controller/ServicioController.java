package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.Servicio;
import com.darkmatter.bookcut.repository.ServicioRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/servicios")
public class ServicioController {

    private final ServicioRepository repositorioDeServicios;

    public ServicioController(ServicioRepository repositorioDeServicios) {
        this.repositorioDeServicios = repositorioDeServicios;
    }

    // 1. Ver todos
    @GetMapping
    public List<Servicio> obtenerTodosLosServicios() {
        return repositorioDeServicios.findAll();
    }

    // 2. Crear un nuevo servicio
    @PostMapping
    public Servicio crearServicio(@RequestBody Servicio nuevoServicio) {
        return repositorioDeServicios.save(nuevoServicio);
    }

    // 3. Actualizar nombre o precio
    @PutMapping("/{id}")
    public ResponseEntity<Servicio> actualizarServicio(@PathVariable Long id, @RequestBody Servicio detallesServicio) {
        return repositorioDeServicios.findById(id)
                .map(servicio -> {
                    servicio.setNombreServicio(detallesServicio.getNombreServicio());
                    servicio.setPrecioServicio(detallesServicio.getPrecioServicio());
                    return ResponseEntity.ok(repositorioDeServicios.save(servicio));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    // 4. Eliminar un servicio
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminarServicio(@PathVariable Long id) {
        if (repositorioDeServicios.existsById(id)) {
            repositorioDeServicios.deleteById(id);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}