package com.darkmatter.bookcut.service;
import com.darkmatter.bookcut.model.Usuario;
import com.darkmatter.bookcut.repository.UsuarioRepository;
import org.springframework.stereotype.Service;
@Service
public class UsuarioService {
    private final UsuarioRepository repositorioDeUsuarios;
    public UsuarioService(UsuarioRepository repositorioDeUsuarios) {
        this.repositorioDeUsuarios = repositorioDeUsuarios;
    }
    public Usuario registrarNuevoUsuario(Usuario nuevoUsuario) {
        if (repositorioDeUsuarios.findByCorreoElectronico(nuevoUsuario.getCorreoElectronico()).isPresent()) {
            throw new RuntimeException("El correo electronico ya esta registrado");
        }
        return repositorioDeUsuarios.save(nuevoUsuario);
    }
    public Usuario verificarCredenciales(String correo, String contrasena) {
        Usuario usuarioEncontrado = repositorioDeUsuarios.findByCorreoElectronico(correo).orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
        if (!usuarioEncontrado.getContrasenaUsuario().equals(contrasena)) {
            throw new RuntimeException("Contrasena incorrecta");
        }
        return usuarioEncontrado;
    }
}