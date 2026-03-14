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
}
