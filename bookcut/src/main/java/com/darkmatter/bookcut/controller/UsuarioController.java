package com.darkmatter.bookcut.controller;
import com.darkmatter.bookcut.model.DatosLogin;
import com.darkmatter.bookcut.model.Usuario;
import com.darkmatter.bookcut.service.UsuarioService;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
@RestController
@RequestMapping("/api/usuarios")
public class UsuarioController {
    private final UsuarioService servicioDeUsuarios;
    public UsuarioController(UsuarioService servicioDeUsuarios) {
        this.servicioDeUsuarios = servicioDeUsuarios;
    }
    @PostMapping("/registro")
    public Usuario registrarUsuario(@RequestBody Usuario datosDelNuevoUsuario) {
        return servicioDeUsuarios.registrarNuevoUsuario(datosDelNuevoUsuario);
    }
    @PostMapping("/login")
    public Usuario iniciarSesion(@RequestBody DatosLogin datosDeAcceso) {
        return servicioDeUsuarios.verificarCredenciales(datosDeAcceso.getCorreoElectronico(), datosDeAcceso.getContrasenaUsuario());
    }
}
