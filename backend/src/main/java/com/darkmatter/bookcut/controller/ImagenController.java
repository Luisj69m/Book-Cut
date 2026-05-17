package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.Barberia;
import com.darkmatter.bookcut.model.Usuario;
import com.darkmatter.bookcut.repository.BarberiaRepository;
import com.darkmatter.bookcut.repository.UsuarioRepository;
import com.darkmatter.bookcut.service.SupabaseStorageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/imagenes")
public class ImagenController {

    @Autowired
    private SupabaseStorageService supabaseStorageService;

    @Autowired
    private BarberiaRepository barberiaRepository;

    @Autowired
    private UsuarioRepository usuarioRepository;

    // ==========================================
    // ENDPOINTS PARA BARBERÍAS
    // ==========================================

    @PostMapping("/subir")
    public ResponseEntity<?> subirImagenBarberia(@RequestParam("file") MultipartFile archivo) {
        try {
            String urlImagen = supabaseStorageService.subirImagenBarberia(archivo);
            return ResponseEntity.ok(Map.of("url", urlImagen));
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error al subir imagen: " + e.getMessage());
        }
    }

    @GetMapping("/listar")
    public ResponseEntity<?> listarImagenesBarberias() {
        try {
            List<Map<String, String>> imagenes = supabaseStorageService.listarImagenesBarberias();
            return ResponseEntity.ok(imagenes);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error al listar imágenes: " + e.getMessage());
        }
    }

    @PutMapping("/asignar/{idBarberia}")
    public ResponseEntity<?> asignarImagenABarberia(@PathVariable Long idBarberia, @RequestBody Map<String, String> body) {
        try {
            String urlImagen = body.get("urlImagen");

            Barberia barberia = barberiaRepository.findById(idBarberia)
                    .orElseThrow(() -> new RuntimeException("Barbería no encontrada"));

            barberia.setUrlImagen(urlImagen);
            barberiaRepository.save(barberia);

            return ResponseEntity.ok(barberia);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error al asignar imagen: " + e.getMessage());
        }
    }

    // ==========================================
    // ENDPOINTS PARA FOTOS DE PERFIL
    // ==========================================

    @PostMapping("/perfil/subir")
    public ResponseEntity<?> subirFotoPerfil(@RequestParam("file") MultipartFile archivo) {
        try {
            String urlFoto = supabaseStorageService.subirFotoPerfil(archivo);
            return ResponseEntity.ok(Map.of("url", urlFoto));
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error al subir foto de perfil: " + e.getMessage());
        }
    }

    @GetMapping("/perfil/listar")
    public ResponseEntity<?> listarFotosPerfil() {
        try {
            List<Map<String, String>> fotos = supabaseStorageService.listarFotosPerfil();
            return ResponseEntity.ok(fotos);
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error al listar fotos: " + e.getMessage());
        }
    }

    @PutMapping("/perfil/asignar")
    public ResponseEntity<?> asignarFotoPerfil(@RequestBody Map<String, String> body, @AuthenticationPrincipal String correoUsuario) {
        try {
            String urlFoto = body.get("urlFotoPerfil");

            Usuario usuario = usuarioRepository.findByCorreoElectronico(correoUsuario)
                    .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

            usuario.setUrlFotoPerfil(urlFoto);
            usuarioRepository.save(usuario);

            return ResponseEntity.ok(Map.of(
                    "mensaje", "Foto de perfil actualizada correctamente",
                    "urlFotoPerfil", urlFoto
            ));
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error al asignar foto de perfil: " + e.getMessage());
        }
    }
}