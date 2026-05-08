package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.Usuario;
import com.darkmatter.bookcut.repository.UsuarioRepository;
import com.darkmatter.bookcut.security.JwtUtils;
import com.darkmatter.bookcut.service.AuthService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

/**
 * Controlador para la autenticación y recuperación de credenciales.
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UsuarioRepository repositorioUsuarios;
    private final JwtUtils utilidadesJwt;
    private final AuthService servicioAutenticacion;

    public AuthController(UsuarioRepository repositorioUsuarios, JwtUtils utilidadesJwt, AuthService servicioAutenticacion) {
        this.repositorioUsuarios = repositorioUsuarios;
        this.utilidadesJwt = utilidadesJwt;
        this.servicioAutenticacion = servicioAutenticacion;
    }

    @PostMapping("/login")
    public ResponseEntity<?> iniciarSesion(@RequestBody Map<String, String> peticionLogin) {
        String correoElectronico = peticionLogin.get("correoElectronico");
        String contrasena = peticionLogin.get("contrasena");

        Optional<Usuario> usuarioOpcional = repositorioUsuarios.findByCorreoElectronico(correoElectronico);

        if (usuarioOpcional.isPresent()) {
            Usuario usuario = usuarioOpcional.get();

            // TODO: Migrar a BCryptPasswordEncoder para validación segura
            if (usuario.getContrasenaUsuario().equals(contrasena)) {
                String token = utilidadesJwt.generarToken(usuario.getCorreoElectronico(), usuario.getRolUsuario().name());

                Map<String, Object> respuesta = new HashMap<>();
                respuesta.put("token", token);
                respuesta.put("idUsuario", usuario.getIdUsuario());
                respuesta.put("correoElectronico", usuario.getCorreoElectronico());
                respuesta.put("rol", usuario.getRolUsuario().name());

                return ResponseEntity.ok(respuesta);
            }
        }

        return ResponseEntity.status(401).body("Error: Correo electrónico o contraseña incorrectos");
    }

    @PostMapping("/solicitar-recuperacion")
    public ResponseEntity<String> solicitarRecuperacion(@RequestBody Map<String, String> peticion) {
        try {
            String correoElectronico = peticion.get("correoElectronico");
            servicioAutenticacion.crearTokenRecuperacion(correoElectronico);
            return ResponseEntity.ok("Si el correo existe, se ha enviado un código de recuperación.");
        } catch (Exception excepcion) {
            return ResponseEntity.badRequest().body("Error: " + excepcion.getMessage());
        }
    }

    @PostMapping("/confirmar-recuperacion")
    public ResponseEntity<String> confirmarRecuperacion(@RequestBody Map<String, String> peticion) {
        try {
            String token = peticion.get("codigo");
            String nuevaContrasena = peticion.get("nuevaContrasena");

            if (token == null || nuevaContrasena == null) {
                return ResponseEntity.badRequest().body("Faltan datos obligatorios (código o nueva contraseña)");
            }

            servicioAutenticacion.cambiarContrasenaConToken(token, nuevaContrasena);
            return ResponseEntity.ok("Contraseña actualizada con éxito.");
        } catch (Exception excepcion) {
            return ResponseEntity.badRequest().body("Error: " + excepcion.getMessage());
        }
    }
}
