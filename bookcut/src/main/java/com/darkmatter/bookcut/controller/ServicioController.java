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

    @GetMapping("/listar")
    public List<Servicio> obtenerTodosLosServicios() {
        return repositorioDeServicios.findAll();
    }

    @PostMapping("/crear")
    public Servicio crearServicio(@RequestBody Servicio nuevoServicio) {
        return repositorioDeServicios.save(nuevoServicio);
    }

    @PutMapping("/actualizar/{idServicio}")
    public ResponseEntity<Servicio> actualizarServicio(@PathVariable Long idServicio, @RequestBody Servicio detallesServicio) {
        return repositorioDeServicios.findById(idServicio)
                .map(servicioEncontrado -> {
                    servicioEncontrado.setNombreServicio(detallesServicio.getNombreServicio());
                    servicioEncontrado.setPrecioServicio(detallesServicio.getPrecioServicio());
                    return ResponseEntity.ok(repositorioDeServicios.save(servicioEncontrado));
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/eliminar/{idServicio}")
    public ResponseEntity<Void> eliminarServicio(@PathVariable Long idServicio) {
        if (repositorioDeServicios.existsById(idServicio)) {
            repositorioDeServicios.deleteById(idServicio);
            return ResponseEntity.noContent().build();
        }
        return ResponseEntity.notFound().build();
    }
}