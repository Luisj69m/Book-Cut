package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.Barberia;
import com.darkmatter.bookcut.model.Barbero;
import com.darkmatter.bookcut.model.Usuario;
import com.darkmatter.bookcut.repository.BarberiaRepository;
import com.darkmatter.bookcut.repository.BarberoRepository;
import com.darkmatter.bookcut.service.UsuarioService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

/**
 * Controlador para la gestión de locales (Barberías).
 * Controla la creación, actualización y consulta de barberías, aplicando
 * validaciones estrictas sobre la propiedad del local.
 */
@RestController
@RequestMapping("/api/barberias")
public class BarberiaController {

    private final BarberiaRepository repositorioBarberias;
    private final UsuarioService servicioUsuarios;
    private final BarberoRepository repositorioBarberos;

    public BarberiaController(BarberiaRepository repositorioBarberias, UsuarioService servicioUsuarios, BarberoRepository repositorioBarberos) {
        this.repositorioBarberias = repositorioBarberias;
        this.servicioUsuarios = servicioUsuarios;
        this.repositorioBarberos = repositorioBarberos;
    }

    @GetMapping
    public List<Barberia> obtenerTodasLasBarberias() {
        return repositorioBarberias.findAll();
    }

    @GetMapping("/mi-barberia/{correoBarbero}")
    public ResponseEntity<Barberia> obtenerBarberiaPorCorreo(@PathVariable String correoBarbero) {
        return repositorioBarberias.findByBarberoPropietario_CorreoElectronico(correoBarbero)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/mi-barberia/{correoBarbero}")
    public ResponseEntity<?> guardarOActualizarBarberia(
            @PathVariable String correoBarbero,
            @RequestBody Barberia datosBarberia,
            @AuthenticationPrincipal String usuarioAutenticado) {

        // Capa 1: Validación de identidad mediante el token JWT
        if (!correoBarbero.equalsIgnoreCase(usuarioAutenticado)) {
            return ResponseEntity.status(403).body("Acceso denegado: No tiene permisos para editar este registro.");
        }

        // Capa 2: Validación de existencia del propietario en base de datos
        Usuario propietarioEncontrado = servicioUsuarios.obtenerUsuarioPorCorreo(correoBarbero);
        if (propietarioEncontrado == null) {
            return ResponseEntity.status(404).body("El usuario especificado no existe.");
        }

        // Capa 3: Validación de campos obligatorios
        if (datosBarberia.getNombre() == null || datosBarberia.getNombre().isEmpty() ||
                datosBarberia.getDireccionCompleta() == null || datosBarberia.getDireccionCompleta().isEmpty()) {
            return ResponseEntity.status(400).body("Error de validación: El nombre y la dirección completa son obligatorios.");
        }

        try {
            Barberia barberiaProcesada = repositorioBarberias.findByBarberoPropietario_CorreoElectronico(correoBarbero)
                    .map(barberiaExistente -> {
                        barberiaExistente.setNombre(datosBarberia.getNombre());
                        barberiaExistente.setDireccionCompleta(datosBarberia.getDireccionCompleta());
                        barberiaExistente.setZona(datosBarberia.getZona());
                        barberiaExistente.setHorario(datosBarberia.getHorario());
                        barberiaExistente.setDescripcion(datosBarberia.getDescripcion());
                        return repositorioBarberias.save(barberiaExistente);
                    })
                    .orElseGet(() -> {
                        datosBarberia.setBarberoPropietario(propietarioEncontrado);
                        return repositorioBarberias.save(datosBarberia);
                    });

            return ResponseEntity.ok(barberiaProcesada);

        } catch (Exception excepcion) {
            return ResponseEntity.status(500).body("Error interno del servidor al procesar la barbería: " + excepcion.getMessage());
        }
    }

    @GetMapping("/asignada/{correoBarbero}")
    public ResponseEntity<?> obtenerBarberiaAsignada(@PathVariable String correoBarbero) {
        Optional<Barbero> empleadoEncontrado = repositorioBarberos.findByUsuarioAsignado_CorreoElectronico(correoBarbero);

        if (empleadoEncontrado.isPresent()) {
            return ResponseEntity.ok(empleadoEncontrado.get().getBarberiaAsignada());
        }
        return ResponseEntity.status(404).body("El trabajador especificado no existe o no tiene un local asignado.");
    }

    @PostMapping("/crear")
    public ResponseEntity<?> crearBarberia(@RequestBody Barberia nuevaBarberia) {
        try {
            Barberia barberiaGuardada = repositorioBarberias.save(nuevaBarberia);
            return ResponseEntity.status(201).body(barberiaGuardada);
        } catch (Exception excepcion) {
            return ResponseEntity.status(400).body("Error de persistencia al crear la barbería: " + excepcion.getMessage());
        }
    }

    @DeleteMapping("/{idBarberia}")
    public ResponseEntity<?> eliminarBarberia(@PathVariable Long idBarberia) {
        return repositorioBarberias.findById(idBarberia)
                .map(barberia -> {
                    try {
                        repositorioBarberias.delete(barberia);
                        return ResponseEntity.ok().body("Registro eliminado con éxito.");
                    } catch (Exception excepcion) {
                        return ResponseEntity.status(400).body("Violación de integridad: No se puede eliminar debido a registros dependientes.");
                    }
                })
                .orElse(ResponseEntity.notFound().build());
    }

    @PutMapping("/{idBarberia}")
    public ResponseEntity<?> actualizarBarberiaGeneral(
            @PathVariable Long idBarberia,
            @RequestBody Barberia nuevosDatos) {

        return repositorioBarberias.findById(idBarberia)
                .map(barberia -> {
                    barberia.setNombre(nuevosDatos.getNombre());
                    barberia.setDireccionCompleta(nuevosDatos.getDireccionCompleta());
                    barberia.setZona(nuevosDatos.getZona());
                    barberia.setHorario(nuevosDatos.getHorario());
                    barberia.setDescripcion(nuevosDatos.getDescripcion());

                    return ResponseEntity.ok(repositorioBarberias.save(barberia));
                })
                .orElse(ResponseEntity.notFound().build());
    }
}