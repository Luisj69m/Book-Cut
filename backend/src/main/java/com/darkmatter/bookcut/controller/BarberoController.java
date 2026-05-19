package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.DTO.BarberoDTO;
import com.darkmatter.bookcut.model.Barbero;
import com.darkmatter.bookcut.repository.BarberoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/barberos")
public class BarberoController {

    @Autowired
    private BarberoRepository barberoRepository;

    @GetMapping("/todos")
    public List<Barbero> listarTodos() {
        return barberoRepository.findAll();
    }

    @GetMapping("/barberia/{idBarberia}")
    public ResponseEntity<?> listarPorBarberia(@PathVariable Long idBarberia) {
        try {
            List<Barbero> barberos = barberoRepository.findByBarberiaAsignada_IdBarberia(idBarberia);

            if (barberos.isEmpty()) {
                return ResponseEntity.noContent().build();
            }

            // Convertir a DTO para el frontend
            List<BarberoDTO> barberosDTO = barberos.stream()
                    .map(barbero -> new BarberoDTO(
                            barbero.getIdPerfilBarbero(),
                            barbero.getUsuarioAsignado().getNombre(),
                            barbero.getUsuarioAsignado().getApellidos(),
                            barbero.getEspecialidadCorte(),
                            barbero.getUsuarioAsignado().getUrlFotoPerfil(),
                            barbero.getBarberiaAsignada().getIdBarberia()
                    ))
                    .collect(Collectors.toList());

            return ResponseEntity.ok(barberosDTO);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error al obtener barberos: " + e.getMessage());
        }
    }

    @GetMapping("/usuario/{idUsuario}")
    public ResponseEntity<?> obtenerPorUsuario(@PathVariable Long idUsuario) {
        return barberoRepository.findByUsuarioAsignadoIdUsuario(idUsuario)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }
}