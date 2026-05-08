package com.darkmatter.bookcut.service;

import com.darkmatter.bookcut.DTO.PerfilRequestDTO;
import com.darkmatter.bookcut.DTO.PerfilResponseDTO;
import com.darkmatter.bookcut.model.RolUsuario;
import com.darkmatter.bookcut.model.Usuario;
import com.darkmatter.bookcut.repository.CitaRepository;
import com.darkmatter.bookcut.repository.UsuarioRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class UsuarioService {

    private final UsuarioRepository repositorioUsuario;
    private final CitaRepository repositorioCitas;
    private final AuthService servicioAutenticacion;

    public UsuarioService(UsuarioRepository repositorioUsuario,
                          CitaRepository repositorioCitas,
                          AuthService servicioAutenticacion) {
        this.repositorioUsuario = repositorioUsuario;
        this.repositorioCitas = repositorioCitas;
        this.servicioAutenticacion = servicioAutenticacion;
    }

    @Transactional
    public Usuario registrarNuevoUsuario(Usuario nuevoUsuario) {
        if (repositorioUsuario.findByCorreoElectronico(nuevoUsuario.getCorreoElectronico()).isPresent()) {
            throw new RuntimeException("El correo electrónico ya está registrado");
        }
        nuevoUsuario.setRolUsuario(RolUsuario.CLIENTE);
        return repositorioUsuario.save(nuevoUsuario);
    }

    public Usuario validarLogin(String correo, String contrasena) {
        return repositorioUsuario.findByCorreoElectronicoAndContrasenaUsuario(correo, contrasena)
                .orElseThrow(() -> new RuntimeException("Credenciales incorrectas"));
    }

    public PerfilResponseDTO obtenerPerfil(String correo) {
        Usuario usuario = repositorioUsuario.findByCorreoElectronico(correo)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        return new PerfilResponseDTO(
                usuario.getNombre(),
                usuario.getApellidos(),
                usuario.getCorreoElectronico(),
                usuario.getTelefono()
        );
    }

    @Transactional
    public PerfilResponseDTO actualizarPerfil(String correo, PerfilRequestDTO datosActualizados) {
        Usuario usuario = repositorioUsuario.findByCorreoElectronico(correo)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        usuario.setNombre(datosActualizados.getNombre());
        usuario.setApellidos(datosActualizados.getApellidos());
        usuario.setTelefono(datosActualizados.getTelefono());

        repositorioUsuario.save(usuario);
        return obtenerPerfil(correo);
    }

    @Transactional
    public void eliminarCuentaDeUsuario(Long idUsuario) {
        repositorioCitas.deleteByClienteReserva_IdUsuario(idUsuario);
        repositorioUsuario.deleteById(idUsuario);
    }

    // MÉTODOS REINTEGRADOS PARA COMPATIBILIDAD CON EL CONTROLLER

    /**
     * Delega la creación del token y envío de email al servicio especializado.
     */
    public void enviarEmailRecuperacion(String correoDestino) {
        servicioAutenticacion.crearTokenRecuperacion(correoDestino);
    }

    /**
     * Delega la validación del código y cambio de clave al servicio especializado.
     */
    @Transactional
    public void actualizarContrasena(String codigo, String nuevaContrasena) {
        servicioAutenticacion.cambiarContrasenaConToken(codigo, nuevaContrasena);
    }

    @Transactional
    public Usuario registrarUsuarioDesdeAdmin(Usuario nuevoUsuario) {
        if (repositorioUsuario.findByCorreoElectronico(nuevoUsuario.getCorreoElectronico()).isPresent()) {
            throw new RuntimeException("El correo electrónico ya está registrado");
        }
        return repositorioUsuario.save(nuevoUsuario);
    }

    public Usuario obtenerUsuarioPorCorreo(String correo) {
        return repositorioUsuario.findByCorreoElectronico(correo)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
    }

    public List<Usuario> obtenerTodosLosUsuarios() {
        return repositorioUsuario.findAll();
    }
}