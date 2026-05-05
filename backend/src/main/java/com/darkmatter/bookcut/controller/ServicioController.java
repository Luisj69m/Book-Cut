package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.Barberia;
import com.darkmatter.bookcut.model.Servicio;
import com.darkmatter.bookcut.repository.BarberiaRepository;
import com.darkmatter.bookcut.repository.CitaRepository;
import com.darkmatter.bookcut.repository.ServicioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/servicios")
public class ServicioController {

    private final ServicioRepository repositorioDeServicios;

    @Autowired
    private BarberiaRepository  barberiaRepository;

    @Autowired
    private CitaRepository citaRepository;

    public ServicioController(ServicioRepository repositorioDeServicios) {
        this.repositorioDeServicios = repositorioDeServicios;
    }

    @GetMapping("/listar")
    public List<Servicio> obtenerTodosLosServicios() {
        return repositorioDeServicios.findAll();
    }


    @PostMapping("/barberia/{idBarberia}")
    public ResponseEntity<?> crearServicioParaBarberia(@PathVariable Long idBarberia, @RequestBody Servicio nuevoServicio) {
        try {
            java.util.Optional<Barberia> barberiaEncontrada = barberiaRepository.findById(idBarberia);

            if (barberiaEncontrada.isPresent()) {
                nuevoServicio.setBarberia(barberiaEncontrada.get());
                Servicio servicioGuardado = repositorioDeServicios.save(nuevoServicio);
                return ResponseEntity.ok(servicioGuardado);
            } else {
                return ResponseEntity.status(404).body("La barbería no existe.");
            }
        } catch (Exception excepcionCreacion) {
            return ResponseEntity.badRequest().body("Error al crear servicio: " + excepcionCreacion.getMessage());
        }
    }

    @PutMapping("/actualizar/{idServicio}")
    public ResponseEntity<?> actualizarServicio(@PathVariable Long idServicio, @RequestBody Servicio detallesServicio) {
        try {
            return repositorioDeServicios.findById(idServicio)
                    .map(servicioEncontrado -> {
                        servicioEncontrado.setNombreServicio(detallesServicio.getNombreServicio());
                        servicioEncontrado.setPrecioServicio(detallesServicio.getPrecioServicio());
                        return ResponseEntity.ok(repositorioDeServicios.save(servicioEncontrado));
                    })
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error al actualizar: " + e.getMessage());
        }
    }

    @DeleteMapping("/eliminar/{idServicio}")
    public ResponseEntity<String> eliminarServicio(@PathVariable Long idServicio) {
        try {
            if (!repositorioDeServicios.existsById(idServicio)) {
                return ResponseEntity.status(404).body("Servicio no encontrado");
            }

            // Comprobación manual de integridad
            boolean tieneCitasRelacionadas = citaRepository.existsByServicioContratadoIdServicio(idServicio);

            if (tieneCitasRelacionadas) {
                return ResponseEntity.status(400).body("No se puede eliminar: el servicio está asociado a citas existentes");
            }

            repositorioDeServicios.deleteById(idServicio);
            return ResponseEntity.ok("Servicio eliminado correctamente");

        } catch (Exception excepcion) {
            return ResponseEntity.status(500).body("Error interno: " + excepcion.getMessage());
        }
    }

    @GetMapping("/barberia/{idBarberia}")
    public ResponseEntity<?> obtenerServiciosPorBarberia(@PathVariable Long idBarberia) {
        try {
            List<Servicio> listadoServicios = repositorioDeServicios.findByBarberia_IdBarberia(idBarberia);
            if (listadoServicios.isEmpty()) {
                return ResponseEntity.noContent().build();
            }
            return ResponseEntity.ok(listadoServicios);
        } catch (Exception excepcionConsulta) {
            return ResponseEntity.status(500).body("Error al obtener servicios: " + excepcionConsulta.getMessage());
        }
    }
}