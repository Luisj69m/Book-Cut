package com.darkmatter.bookcut.service;

import com.darkmatter.bookcut.model.Usuario;
import com.darkmatter.bookcut.repository.UsuarioRepository;
import org.springframework.stereotype.Service;
import java.util.Optional;

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

    public Usuario validarLogin(String correo, String contrasena) {
        return repositorioDeUsuarios.findByCorreoElectronicoAndContrasenaUsuario(correo, contrasena)
                .orElseThrow(() -> new RuntimeException("Credenciales incorrectas"));
    }
}