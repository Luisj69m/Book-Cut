package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.DTO.PerfilRequestDTO;
import com.darkmatter.bookcut.model.Usuario;
import com.darkmatter.bookcut.service.UsuarioService;
import com.darkmatter.bookcut.security.JwtUtils;
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
    private JwtUtils jwtUtil;

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

    @PostMapping("/admin/registrar-barbero")
    public org.springframework.http.ResponseEntity<?> registrarBarbero(
            @RequestHeader("Authorization") String tokenHeader,
            @RequestBody Usuario nuevoBarbero) {
        try {
            String tokenLimpio = tokenHeader.substring(7);
            String correoAdmin = jwtUtil.obtenerUsernameDeToken(tokenLimpio);

            Usuario usuarioAdministrador = usuarioService.obtenerUsuarioPorCorreo(correoAdmin);

            if (!usuarioAdministrador.getRolUsuario().name().equals("ADMIN")) {
                return org.springframework.http.ResponseEntity.status(org.springframework.http.HttpStatus.FORBIDDEN).body("Acceso denegado: Requiere permisos de administrador");
            }

            nuevoBarbero.setRolUsuario(com.darkmatter.bookcut.model.RolUsuario.BARBERO);
            Usuario barberoGuardado = usuarioService.registrarUsuarioDesdeAdmin(nuevoBarbero);

            return org.springframework.http.ResponseEntity.ok(barberoGuardado);
        } catch (Exception excepcion) {
            return org.springframework.http.ResponseEntity.status(org.springframework.http.HttpStatus.INTERNAL_SERVER_ERROR).body(excepcion.getMessage());
        }
    }

    @GetMapping("/listar")
    public ResponseEntity<?> listarTodosLosUsuarios(@RequestHeader("Authorization") String tokenHeader) {
        try {
            String tokenLimpio = tokenHeader.substring(7);
            String correoAdmin = jwtUtil.obtenerUsernameDeToken(tokenLimpio);
            Usuario admin = usuarioService.obtenerUsuarioPorCorreo(correoAdmin);

            if (!admin.getRolUsuario().name().equals("ADMIN")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Acceso denegado");
            }

            // He visto que no tienes el método obtenerTodos() todavía,
            // así que usamos el findAll del repository directamente si quieres,
            // pero lo ideal es que añadas en UsuarioService:
            // public List<Usuario> listarTodo() { return usuarioRepository.findAll(); }
            return ResponseEntity.ok(usuarioService.obtenerTodosLosUsuarios());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @GetMapping("/perfil/{correo}")
    public ResponseEntity<?> obtenerPerfil(@PathVariable String correo) {
        return ResponseEntity.ok(usuarioService.obtenerPerfil(correo));
    }

    @PutMapping("/perfil/{correo}")
    public ResponseEntity<?> actualizarPerfil(@PathVariable String correo, @RequestBody PerfilRequestDTO dto) {
        return ResponseEntity.ok(usuarioService.actualizarPerfil(correo, dto));
    }
}