package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.Barberia;
import com.darkmatter.bookcut.model.Servicio;
import com.darkmatter.bookcut.repository.BarberiaRepository;
import com.darkmatter.bookcut.repository.CitaRepository;
import com.darkmatter.bookcut.repository.ServicioRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Controlador para la gestión del catálogo de servicios.
 * Permite operaciones CRUD sobre los servicios ofrecidos por cada barbería,
 * garantizando la integridad referencial con el histórico de citas.
 */
@RestController
@RequestMapping("/api/servicios")
public class ServicioController {

    private final ServicioRepository repositorioServicios;
    private final BarberiaRepository repositorioBarberias;
    private final CitaRepository repositorioCitas;

    public ServicioController(ServicioRepository repositorioServicios, BarberiaRepository repositorioBarberias, CitaRepository repositorioCitas) {
        this.repositorioServicios = repositorioServicios;
        this.repositorioBarberias = repositorioBarberias;
        this.repositorioCitas = repositorioCitas;
    }

    @GetMapping("/listar")
    public List<Servicio> obtenerTodosLosServicios() {
        return repositorioServicios.findAll();
    }

    @PostMapping("/barberia/{idBarberia}")
    public ResponseEntity<?> crearServicioParaBarberia(@PathVariable Long idBarberia, @RequestBody Servicio nuevoServicio) {
        try {
            Optional<Barberia> barberiaEncontrada = repositorioBarberias.findById(idBarberia);

            if (barberiaEncontrada.isPresent()) {
                nuevoServicio.setBarberiaAsignada(barberiaEncontrada.get());
                Servicio servicioGuardado = repositorioServicios.save(nuevoServicio);
                return ResponseEntity.ok(servicioGuardado);
            } else {
                return ResponseEntity.status(404).body("La barbería especificada no existe.");
            }
        } catch (Exception excepcion) {
            return ResponseEntity.badRequest().body("Error interno al crear el servicio: " + excepcion.getMessage());
        }
    }

    @PutMapping("/actualizar/{idServicio}")
    public ResponseEntity<?> actualizarServicio(@PathVariable Long idServicio, @RequestBody Servicio detallesServicio) {
        try {
            return repositorioServicios.findById(idServicio)
                    .map(servicioEncontrado -> {
                        servicioEncontrado.setNombreServicio(detallesServicio.getNombreServicio());
                        servicioEncontrado.setPrecioServicio(detallesServicio.getPrecioServicio());
                        return ResponseEntity.ok(repositorioServicios.save(servicioEncontrado));
                    })
                    .orElse(ResponseEntity.notFound().build());
        } catch (Exception excepcion) {
            return ResponseEntity.badRequest().body("Error interno al actualizar el servicio: " + excepcion.getMessage());
        }
    }

    @DeleteMapping("/eliminar/{idServicio}")
    public ResponseEntity<String> eliminarServicio(@PathVariable Long idServicio) {
        try {
            if (!repositorioServicios.existsById(idServicio)) {
                return ResponseEntity.status(404).body("El servicio especificado no existe.");
            }

            // Validación de integridad: Previene la eliminación si hay citas asociadas
            boolean tieneCitasRelacionadas = repositorioCitas.existsByServicioContratadoIdServicio(idServicio);

            if (tieneCitasRelacionadas) {
                return ResponseEntity.status(400).body("Violación de integridad: No se puede eliminar un servicio que está asociado a citas existentes en el sistema.");
            }

            repositorioServicios.deleteById(idServicio);
            return ResponseEntity.ok("Servicio eliminado correctamente.");

        } catch (Exception excepcion) {
            return ResponseEntity.status(500).body("Error interno durante la eliminación: " + excepcion.getMessage());
        }
    }

    @GetMapping("/barberia/{idBarberia}")
    public ResponseEntity<?> obtenerServiciosPorBarberia(@PathVariable Long idBarberia) {
        try {
            List<Servicio> listadoServicios = repositorioServicios.findByBarberiaAsignada_IdBarberia(idBarberia);
            if (listadoServicios.isEmpty()) {
                return ResponseEntity.noContent().build();
            }
            return ResponseEntity.ok(listadoServicios);
        } catch (Exception excepcion) {
            return ResponseEntity.status(500).body("Error interno al obtener los servicios del local: " + excepcion.getMessage());
        }
    }
}