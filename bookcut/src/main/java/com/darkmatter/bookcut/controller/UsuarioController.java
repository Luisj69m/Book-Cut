package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.model.Usuario;
import com.darkmatter.bookcut.service.UsuarioService;
import com.darkmatter.bookcut.security.JwtUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;
import java.util.HashMap;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {

    private final UsuarioService usuarioService;

    @Autowired
    private JwtUtil jwtUtil;

    public UsuarioController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Usuario credenciales) {
        try {
            Usuario usuarioEncontrado = usuarioService.validarLogin(
                    credenciales.getCorreoElectronico(),
                    credenciales.getContrasenaUsuario()
            );
            String tokenGenerado = jwtUtil.generarToken(usuarioEncontrado.getCorreoElectronico(), usuarioEncontrado.getRolUsuario().name());
            Map<String, Object> respuesta = new HashMap<>();
            respuesta.put("usuario", usuarioEncontrado);
            respuesta.put("token", tokenGenerado);
            return ResponseEntity.ok(respuesta);
        } catch (RuntimeException excepcion) {
            Map<String, String> error = new HashMap<>();
            error.put("mensaje", "Credenciales incorrectas");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("mensaje", "Error interno: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    @PostMapping("/registrar")
    public Usuario registrar(@RequestBody Usuario nuevoUsuario) {
        return usuarioService.registrarNuevoUsuario(nuevoUsuario);
    }

    @DeleteMapping("/eliminar/{idUsuario}")
    public ResponseEntity<String> eliminarCuenta(@PathVariable Long idUsuario) {
        try {
            usuarioService.eliminarCuentaDeUsuario(idUsuario);
            return ResponseEntity.ok("Cuenta y datos asociados eliminados correctamente");
        } catch (Exception excepcion) {
            return ResponseEntity.badRequest().body("Error al intentar eliminar la cuenta");
        }
    }

    @PostMapping("/solicitar-recuperacion")
    public ResponseEntity<String> solicitarRecuperacionContrasena(@RequestBody Map<String, String> peticion) {
        String correoElectronico = peticion.get("correoElectronico");
        usuarioService.enviarEmailRecuperacion(correoElectronico);
        return ResponseEntity.ok("Si el correo existe, se enviaran instrucciones.");
    }

    @PostMapping("/confirmar-recuperacion")
    public ResponseEntity<String> confirmarRecuperacionContrasena(@RequestBody Map<String, String> peticion) {
        try {
            String codigoDeRecuperacion = peticion.get("codigo");
            String contrasenaNueva = peticion.get("nuevaContrasena");
            usuarioService.actualizarContrasena(codigoDeRecuperacion, contrasenaNueva);
            return ResponseEntity.ok("Contrasena actualizada correctamente");
        } catch (RuntimeException excepcion) {
            return ResponseEntity.badRequest().body(excepcion.getMessage());
        }
    }
}