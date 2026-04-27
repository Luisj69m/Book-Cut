package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.DTO.PerfilRequestDTO;
import com.darkmatter.bookcut.DTO.PerfilResponseDTO;
import com.darkmatter.bookcut.service.UsuarioService;
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
        String correo = SecurityContextHolder.getContext().getAuthentication().getName();
        return ResponseEntity.ok(usuarioService.obtenerPerfil(correo));
    }

    @PutMapping
    public ResponseEntity<PerfilResponseDTO> actualizarPerfil(@RequestBody PerfilRequestDTO datosActualizados) {
        String correo = SecurityContextHolder.getContext().getAuthentication().getName();
        return ResponseEntity.ok(usuarioService.actualizarPerfil(correo, datosActualizados));
    }

    @PostMapping("/imagen")
    public ResponseEntity<String> subirImagen(@RequestParam("file") MultipartFile archivo) { // <--- Cambiado de "imagen" a "file"
        String correo = SecurityContextHolder.getContext().getAuthentication().getName();
        try {
            String rutaImagen = usuarioService.guardarImagenPerfil(correo, archivo);
            return ResponseEntity.ok("Imagen subida con éxito: " + rutaImagen);
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error al subir imagen: " + e.getMessage());
        }
    }

    @GetMapping("/imagen/{nombreArchivo:.+}")
    public ResponseEntity<org.springframework.core.io.Resource> obtenerImagen(@PathVariable String nombreArchivo) {
        try {
            // La ruta donde guardas las fotos (asegúrate que coincide con tu lógica de guardado)
            java.nio.file.Path rutaArchivo = java.nio.file.Paths.get("uploads").resolve(nombreArchivo);
            org.springframework.core.io.Resource recurso = new org.springframework.core.io.UrlResource(rutaArchivo.toUri());

            if (recurso.exists() || recurso.isReadable()) {
                return ResponseEntity.ok()
                        .header(org.springframework.http.HttpHeaders.CONTENT_TYPE, "image/jpeg") // O detecta el tipo dinámicamente
                        .body(recurso);
            } else {
                return ResponseEntity.notFound().build();
            }
        } catch (Exception e) {
            return ResponseEntity.internalServerError().build();
        }
    }
}
