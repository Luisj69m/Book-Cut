package com.darkmatter.bookcut.controller;

import com.darkmatter.bookcut.DTO.PerfilRequestDTO;
import com.darkmatter.bookcut.model.Barberia;
import com.darkmatter.bookcut.model.Barbero;
import com.darkmatter.bookcut.model.RolUsuario;
import com.darkmatter.bookcut.model.Usuario;
import com.darkmatter.bookcut.repository.BarberiaRepository;
import com.darkmatter.bookcut.repository.BarberoRepository;
import com.darkmatter.bookcut.security.JwtUtils;
import com.darkmatter.bookcut.service.UsuarioService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Controlador principal de usuarios.
 * Gestiona autenticación, registro público, flujos de recuperación
 * y operaciones exclusivas de administración (listar usuarios y registrar empleados).
 */
@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {

    private final UsuarioService servicioUsuarios;
    private final BarberoRepository repositorioBarberos;
    private final BarberiaRepository repositorioBarberias;
    private final JwtUtils utilidadesJwt;

    public UsuarioController(UsuarioService servicioUsuarios, BarberoRepository repositorioBarberos, BarberiaRepository repositorioBarberias, JwtUtils utilidadesJwt) {
        this.servicioUsuarios = servicioUsuarios;
        this.repositorioBarberos = repositorioBarberos;
        this.repositorioBarberias = repositorioBarberias;
        this.utilidadesJwt = utilidadesJwt;
    }

    @PostMapping("/login")
    public ResponseEntity<?> iniciarSesion(@RequestBody Usuario credenciales) {
        try {
            Usuario usuarioEncontrado = servicioUsuarios.validarLogin(
                    credenciales.getCorreoElectronico(),
                    credenciales.getContrasenaUsuario()
            );
            String tokenGenerado = utilidadesJwt.generarToken(usuarioEncontrado.getCorreoElectronico(), usuarioEncontrado.getRolUsuario().name());

            Map<String, Object> respuesta = new HashMap<>();
            respuesta.put("usuario", usuarioEncontrado);
            respuesta.put("token", tokenGenerado);

            return ResponseEntity.ok(respuesta);
        } catch (RuntimeException excepcionValidacion) {
            Map<String, String> error = new HashMap<>();
            error.put("mensaje", "Credenciales incorrectas");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        } catch (Exception excepcionGeneral) {
            Map<String, String> error = new HashMap<>();
            error.put("mensaje", "Error interno: " + excepcionGeneral.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    @PostMapping("/registrar")
    public ResponseEntity<?> registrarUsuario(@RequestBody Usuario nuevoUsuario) {
        try {
            Usuario usuarioRegistrado = servicioUsuarios.registrarNuevoUsuario(nuevoUsuario);
            return ResponseEntity.status(HttpStatus.CREATED).body(usuarioRegistrado);
        } catch (RuntimeException excepcionValidacion) {
            Map<String, String> error = new HashMap<>();
            error.put("mensaje", excepcionValidacion.getMessage());
            return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
        } catch (Exception excepcionGeneral) {
            Map<String, String> error = new HashMap<>();
            error.put("mensaje", "Error interno al registrar: " + excepcionGeneral.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    @DeleteMapping("/eliminar/{idUsuario}")
    public ResponseEntity<String> eliminarCuenta(@PathVariable Long idUsuario) {
        try {
            servicioUsuarios.eliminarCuentaDeUsuario(idUsuario);
            return ResponseEntity.ok("Cuenta y datos asociados eliminados correctamente");
        } catch (Exception excepcion) {
            return ResponseEntity.badRequest().body("Error al intentar eliminar la cuenta");
        }
    }

    @PostMapping("/solicitar-recuperacion")
    public ResponseEntity<String> solicitarRecuperacionContrasena(@RequestBody Map<String, String> peticion) {
        String correoElectronico = peticion.get("correoElectronico");
        try {
            servicioUsuarios.enviarEmailRecuperacion(correoElectronico);
            return ResponseEntity.ok("Si el correo existe, se enviarán instrucciones.");
        } catch (Exception excepcionCorreo) {
            System.err.println("Error SMTP en recuperación: " + excepcionCorreo.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body("Error interno al intentar enviar el correo.");
        }
    }

    @PostMapping("/confirmar-recuperacion")
    public ResponseEntity<String> confirmarRecuperacionContrasena(@RequestBody Map<String, String> peticion) {
        try {
            String codigoDeRecuperacion = peticion.get("codigo");
            String contrasenaNueva = peticion.get("nuevaContrasena");
            servicioUsuarios.actualizarContrasena(codigoDeRecuperacion, contrasenaNueva);
            return ResponseEntity.ok("Contraseña actualizada correctamente");
        } catch (RuntimeException excepcion) {
            return ResponseEntity.badRequest().body(excepcion.getMessage());
        }
    }

    @PostMapping("/admin/registrar-barbero")
    public ResponseEntity<?> registrarBarbero(
            @AuthenticationPrincipal String correoAdministrador,
            @RequestBody Map<String, Object> datosPeticion) {
        try {
            Usuario administradorVerificado = servicioUsuarios.obtenerUsuarioPorCorreo(correoAdministrador);

            if (!administradorVerificado.getRolUsuario().name().equals("ADMIN")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN)
                        .body("Acceso denegado: Requiere permisos de administrador");
            }

            Usuario nuevoBarbero = new Usuario();
            nuevoBarbero.setNombre(datosPeticion.get("nombreUsuario").toString());
            nuevoBarbero.setCorreoElectronico(datosPeticion.get("correoElectronico").toString());
            nuevoBarbero.setContrasenaUsuario(datosPeticion.get("contrasenaUsuario").toString());
            nuevoBarbero.setTelefono(datosPeticion.get("telefonoUsuario").toString());
            nuevoBarbero.setRolUsuario(RolUsuario.BARBERO);

            Usuario barberoRegistrado = servicioUsuarios.registrarUsuarioDesdeAdmin(nuevoBarbero);

            Long identificadorBarberia = Long.valueOf(datosPeticion.get("idBarberia").toString());
            Barberia barberiaDestino = repositorioBarberias.findById(identificadorBarberia)
                    .orElseThrow(() -> new RuntimeException("La barbería especificada no existe"));

            Barbero nuevoPerfilBarbero = new Barbero();
            nuevoPerfilBarbero.setUsuarioAsignado(barberoRegistrado);
            nuevoPerfilBarbero.setBarberiaAsignada(barberiaDestino);
            repositorioBarberos.save(nuevoPerfilBarbero);

            return ResponseEntity.ok(barberoRegistrado);
        } catch (Exception excepcionRegistro) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error al registrar barbero: " + excepcionRegistro.getMessage());
        }
    }

    @GetMapping("/listar")
    public ResponseEntity<?> listarTodosLosUsuarios(@AuthenticationPrincipal String correoAdministrador) {
        try {
            Usuario administradorVerificado = servicioUsuarios.obtenerUsuarioPorCorreo(correoAdministrador);

            if (!administradorVerificado.getRolUsuario().name().equals("ADMIN")) {
                return ResponseEntity.status(HttpStatus.FORBIDDEN).body("Acceso denegado: Requiere permisos de administrador");
            }

            List<Usuario> listaUsuarios = servicioUsuarios.obtenerTodosLosUsuarios();
            List<Map<String, Object>> respuestaMapeada = new ArrayList<>();

            for (Usuario usuarioActual : listaUsuarios) {
                Map<String, Object> usuarioMap = new HashMap<>();
                usuarioMap.put("idUsuario", usuarioActual.getIdUsuario());
                usuarioMap.put("nombre", usuarioActual.getNombre());
                usuarioMap.put("correoElectronico", usuarioActual.getCorreoElectronico());
                usuarioMap.put("telefono", usuarioActual.getTelefono());
                usuarioMap.put("rolUsuario", usuarioActual.getRolUsuario());

                if (usuarioActual.getRolUsuario() != null && usuarioActual.getRolUsuario().name().equals("BARBERO")) {
                    repositorioBarberos.findByUsuarioAsignadoIdUsuario(usuarioActual.getIdUsuario())
                            .ifPresentOrElse(
                                    barbero -> usuarioMap.put("nombreBarberia", barbero.getBarberiaAsignada().getNombre()),
                                    () -> usuarioMap.put("nombreBarberia", "Sin asignar")
                            );
                } else {
                    usuarioMap.put("nombreBarberia", null);
                }
                respuestaMapeada.add(usuarioMap);
            }

            return ResponseEntity.ok(respuestaMapeada);
        } catch (Exception excepcionListado) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(excepcionListado.getMessage());
        }
    }

    @GetMapping("/perfil/{correo}")
    public ResponseEntity<?> obtenerPerfilUsuario(@PathVariable String correo) {
        return ResponseEntity.ok(servicioUsuarios.obtenerPerfil(correo));
    }

    @PutMapping("/perfil/{correo}")
    public ResponseEntity<?> actualizarPerfilUsuario(@PathVariable String correo, @RequestBody PerfilRequestDTO datosActualizados) {
        return ResponseEntity.ok(servicioUsuarios.actualizarPerfil(correo, datosActualizados));
    }
}