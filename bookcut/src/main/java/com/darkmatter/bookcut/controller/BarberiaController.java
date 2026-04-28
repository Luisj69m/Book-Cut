package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.Barberia;
import com.darkmatter.bookcut.model.Usuario;
import com.darkmatter.bookcut.repository.BarberiaRepository;
import com.darkmatter.bookcut.security.JwtUtils;
import com.darkmatter.bookcut.service.UsuarioService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/barberias")
public class BarberiaController {

    private final BarberiaRepository repositorioDeBarberias;
    private final UsuarioService usuarioService;
    private final JwtUtils jwtUtil;

    public BarberiaController(BarberiaRepository repositorioDeBarberias, UsuarioService usuarioService, JwtUtils jwtUtil) {
        this.repositorioDeBarberias = repositorioDeBarberias;
        this.usuarioService = usuarioService;
        this.jwtUtil = jwtUtil;
    }

    @GetMapping
    public List<Barberia> obtenerTodasLasBarberias() {
        return repositorioDeBarberias.findAll();
    }

    @PostMapping("/admin/crear")
    public ResponseEntity<?> crearBarberia(
            @RequestHeader("Authorization") String tokenHeader,
            @RequestBody Barberia nuevaBarberia) {
        try {
            String tokenLimpio = tokenHeader.substring(7);
            String correoAdmin = jwtUtil.obtenerUsernameDeToken(tokenLimpio);
            Usuario admin = usuarioService.obtenerUsuarioPorCorreo(correoAdmin);

            if (!admin.getRolUsuario().name().equals("ADMIN")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No eres administrador");
            }

            return ResponseEntity.ok(repositorioDeBarberias.save(nuevaBarberia));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }
}