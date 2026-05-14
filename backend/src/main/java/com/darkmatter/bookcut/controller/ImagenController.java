package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.Barberia;
import com.darkmatter.bookcut.repository.BarberiaRepository;
import com.darkmatter.bookcut.service.SupabaseStorageService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
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

    @PostMapping("/subir")
    public ResponseEntity<?> subirImagen(@RequestParam("file") MultipartFile archivo) {
        try {
            String urlImagen = supabaseStorageService.subirImagen(archivo);
            return ResponseEntity.ok(Map.of("url", urlImagen));
        } catch (Exception e) {
            return ResponseEntity.status(500).body("Error al subir imagen: " + e.getMessage());
        }
    }

    @GetMapping("/listar")
    public ResponseEntity<?> listarImagenes() {
        try {
            List<Map<String, String>> imagenes = supabaseStorageService.listarImagenes();
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
}
