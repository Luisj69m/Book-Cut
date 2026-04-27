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

    @Autowired
    private CloudinaryService servicioCloudinary;

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

    @PostMapping("/imagen")
    public ResponseEntity<String> subirImagen(@RequestParam("file") MultipartFile archivoImagen) {
        String correoElectronico = SecurityContextHolder.getContext().getAuthentication().getName();
        try {
            String urlImagenNube = servicioCloudinary.subirImagen(archivoImagen);
            usuarioService.actualizarUrlImagen(correoElectronico, urlImagenNube);
            return ResponseEntity.ok(urlImagenNube);
        } catch (Exception excepcionSubida) {
            return ResponseEntity.badRequest().body("Error al subir imagen a la nube: " + excepcionSubida.getMessage());
        }
    }
}
