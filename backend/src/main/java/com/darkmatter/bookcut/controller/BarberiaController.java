package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.Barberia;
import com.darkmatter.bookcut.model.Usuario;
import com.darkmatter.bookcut.repository.BarberiaRepository;
import com.darkmatter.bookcut.repository.BarberoRepository;
import com.darkmatter.bookcut.service.UsuarioService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/barberias")
public class BarberiaController {

    private final BarberiaRepository repositorioDeBarberias;
    private final UsuarioService usuarioService;
    @Autowired
    private BarberoRepository barberoRepository;

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
    public ResponseEntity<?> guardarOActualizarBarberia(
            @PathVariable String correoBarbero,
            @RequestBody Barberia datosBarberia,
            @AuthenticationPrincipal String usernameLogueado) { // Cogemos el usuario del Token

        // 1. PROTECCIÓN PRUEBA 5: ¿Es el dueño de la cuenta?
        if (!correoBarbero.equalsIgnoreCase(usernameLogueado)) {
            return ResponseEntity.status(403).body("No tienes permiso para editar una barbería que no es tuya.");
        }

        // 2. PROTECCIÓN PRUEBA 7: ¿El usuario existe?
        Usuario barberoEncontrado = usuarioService.obtenerUsuarioPorCorreo(correoBarbero);
        if (barberoEncontrado == null) {
            return ResponseEntity.status(404).body("El barbero con correo " + correoBarbero + " no existe.");
        }

        // 3. PROTECCIÓN PRUEBA 6: Evitar Nulos en campos obligatorios
        if (datosBarberia.getNombre() == null || datosBarberia.getNombre().isEmpty() ||
                datosBarberia.getDireccionCompleta() == null || datosBarberia.getDireccionCompleta().isEmpty()) {
            return ResponseEntity.status(400).body("El nombre y la dirección completa son obligatorios.");
        }

        try {
            Barberia barberiaFinal = repositorioDeBarberias.findByBarberoPropietario_CorreoElectronico(correoBarbero)
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

            return ResponseEntity.ok(barberiaFinal);

        } catch (Exception e) {
            // Captura cualquier otro error para que no salga el 500 feo
            return ResponseEntity.status(500).body("Error interno al guardar: " + e.getMessage());
        }
    }

    @GetMapping("/asignada/{correoBarbero}")
    public org.springframework.http.ResponseEntity<?> obtenerBarberiaAsignada(@PathVariable String correoBarbero) {
        java.util.Optional<com.darkmatter.bookcut.model.Barbero> barberoEncontrado = barberoRepository.findByUsuarioAsignado_CorreoElectronico(correoBarbero);

        if (barberoEncontrado.isPresent()) {
            return org.springframework.http.ResponseEntity.ok(barberoEncontrado.get().getBarberiaAsignada());
        }
        return org.springframework.http.ResponseEntity.status(404).body("El trabajador no existe o no tiene barberia asignada");
    }

    @PostMapping("/crear")
    public org.springframework.http.ResponseEntity<?> crearBarberia(@RequestBody com.darkmatter.bookcut.model.Barberia nuevaBarberia) {
        try {
            com.darkmatter.bookcut.model.Barberia barberiaGuardada = repositorioDeBarberias.save(nuevaBarberia);
            return org.springframework.http.ResponseEntity.status(201).body(barberiaGuardada);
        } catch (Exception excepcionCreacion) {
            return org.springframework.http.ResponseEntity.status(400).body("Error al crear la barberia: " + excepcionCreacion.getMessage());
        }
    }
}