package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.DTO.PerfilRequestDTO;
import com.darkmatter.bookcut.DTO.PerfilResponseDTO;
import com.darkmatter.bookcut.service.UsuarioService;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

/**
 * Controlador para la gestión del perfil del usuario autenticado.
 * Utiliza el token JWT para garantizar que un usuario solo pueda ver y modificar sus propios datos.
 */
@RestController
@RequestMapping("/api/perfil")
public class PerfilController {

    private final UsuarioService servicioUsuarios;

    public PerfilController(UsuarioService servicioUsuarios) {
        this.servicioUsuarios = servicioUsuarios;
    }

    @GetMapping
    public ResponseEntity<PerfilResponseDTO> obtenerPerfil(@AuthenticationPrincipal String correoElectronico) {
        return ResponseEntity.ok(servicioUsuarios.obtenerPerfil(correoElectronico));
    }

    @PutMapping
    public ResponseEntity<PerfilResponseDTO> actualizarPerfil(
            @RequestBody PerfilRequestDTO datosActualizados,
            @AuthenticationPrincipal String correoElectronico) {

        return ResponseEntity.ok(servicioUsuarios.actualizarPerfil(correoElectronico, datosActualizados));
    }
}
