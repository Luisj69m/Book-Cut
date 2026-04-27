package com.darkmatter.bookcut.controller;
import com.darkmatter.bookcut.model.DatosLogin;
import com.darkmatter.bookcut.model.Usuario;
import com.darkmatter.bookcut.service.UsuarioService;
import org.springframework.web.bind.annotation.*;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {

    private final UsuarioService usuarioService;

    public UsuarioController(UsuarioService usuarioService) {
        this.usuarioService = usuarioService;
    }

    @PostMapping("/login")
    public Usuario login(@RequestBody Usuario credenciales) {
        return usuarioService.validarLogin(
                credenciales.getCorreoElectronico(),
                credenciales.getContrasenaUsuario()
        );
    }

    @PostMapping("/registrar")
    public Usuario registrar(@RequestBody Usuario nuevoUsuario) {
        return usuarioService.registrarNuevoUsuario(nuevoUsuario);
    }

    @DeleteMapping("/eliminar/{idUsuario}")
    public org.springframework.http.ResponseEntity<String> eliminarCuenta(@PathVariable Long idUsuario) {
        try {
            usuarioService.eliminarCuentaDeUsuario(idUsuario);
            return org.springframework.http.ResponseEntity.ok("Cuenta y datos asociados eliminados correctamente");
        } catch (Exception excepcion) {
            return org.springframework.http.ResponseEntity.badRequest().body("Error al intentar eliminar la cuenta");
        }
    }

    @PostMapping("/solicitar-recuperacion")
    public org.springframework.http.ResponseEntity<String> solicitarRecuperacionContrasena(@RequestBody java.util.Map<String, String> peticion) {
        String correoElectronico = peticion.get("correoElectronico");
        usuarioService.enviarEmailRecuperacion(correoElectronico);
        return org.springframework.http.ResponseEntity.ok("Si el correo existe, se enviaran instrucciones.");
    }

    @PostMapping("/confirmar-recuperacion")
    public org.springframework.http.ResponseEntity<String> confirmarRecuperacionContrasena(@RequestBody java.util.Map<String, String> peticion) {
        String codigoDeRecuperacion = peticion.get("codigo");
        String contrasenaNueva = peticion.get("nuevaContrasena");

        // Aqui llamaras al servicio real mas adelante
        // usuarioService.actualizarContrasena(codigoDeRecuperacion, contrasenaNueva);

        return org.springframework.http.ResponseEntity.ok("Contrasena actualizada");
    }
}
