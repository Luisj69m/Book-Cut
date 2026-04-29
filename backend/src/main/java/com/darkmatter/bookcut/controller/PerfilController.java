package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.DTO.PerfilRequestDTO;
import com.darkmatter.bookcut.DTO.PerfilResponseDTO;
import com.darkmatter.bookcut.service.UsuarioService;
import com.darkmatter.bookcut.service.CloudinaryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/perfil")
@CrossOrigin(origins = "*")
public class PerfilController {

    @Autowired
    private UsuarioService usuarioService;

    @GetMapping
    public ResponseEntity<PerfilResponseDTO> obtenerPerfil() {
        String correoElectronico = SecurityContextHolder.getContext().getAuthentication().getName();
        return ResponseEntity.ok(usuarioService.obtenerPerfil(correoElectronico));
    }

    @PutMapping
    public ResponseEntity<PerfilResponseDTO> actualizarPerfil(@RequestBody PerfilRequestDTO datosActualizados) {
        String correoElectronico = SecurityContextHolder.getContext().getAuthentication().getName();
        return ResponseEntity.ok(usuarioService.actualizarPerfil(correoElectronico, datosActualizados));
    }
}
