package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.Usuario;
import com.darkmatter.bookcut.repository.UsuarioRepository;
import com.darkmatter.bookcut.security.JwtUtils;
import com.darkmatter.bookcut.service.AuthService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private JwtUtils jwtUtils;
    @Autowired
    private AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> loginRequest) {
        String correo = loginRequest.get("correoElectronico");
        String password = loginRequest.get("contrasena");

        // 1. Buscamos al usuario por correo
        Optional<Usuario> usuarioOpt = usuarioRepository.findByCorreoElectronico(correo);

        if (usuarioOpt.isPresent()) {
            Usuario usuario = usuarioOpt.get();

            // 2. Comprobamos la contraseña (aquí deberías usar BCrypt si estuvieran cifradas)
            if (usuario.getContrasenaUsuario().equals(password)) {

                // 3. Generamos el Token JWT
                String token = jwtUtils.generarToken(usuario.getCorreoElectronico(), usuario.getRolUsuario().name());
                // 4. Preparamos la respuesta que Dani espera
                Map<String, Object> response = new HashMap<>();
                response.put("token", token);
                response.put("idUsuario", usuario.getIdUsuario());
                response.put("correoElectronico", usuario.getCorreoElectronico());
                response.put("rol", usuario.getRolUsuario().name());

                return ResponseEntity.ok(response);
            }
        }

        // Si algo falla, devolvemos un 401 (No autorizado)
        return ResponseEntity.status(401).body("Error: Correo o contraseña incorrectos");
    }

    @PostMapping("/solicitar-recuperacion")
    public ResponseEntity<String> solicitar(@RequestBody Map<String, String> request) {
        try {
            String correo = request.get("correoElectronico");
            // Lógica para generar token y enviar mail
            authService.crearTokenRecuperacion(correo);
            return ResponseEntity.ok("Si el correo existe, se ha enviado un código de recuperación.");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }

    @PostMapping("/confirmar-recuperacion")
    public ResponseEntity<String> confirmar(@RequestBody Map<String, String> request) {
        try {
            // Dani manda "codigo", así que buscamos "codigo"
            String token = request.get("codigo");
            String nuevaPass = request.get("nuevaContrasena");

            if (token == null || nuevaPass == null) {
                return ResponseEntity.badRequest().body("Faltan datos en el envío (codigo o nuevaContrasena)");
            }

            authService.cambiarContrasenaConToken(token, nuevaPass);
            return ResponseEntity.ok("Contraseña actualizada con éxito.");
        } catch (Exception e) {
            return ResponseEntity.badRequest().body("Error: " + e.getMessage());
        }
    }
}
