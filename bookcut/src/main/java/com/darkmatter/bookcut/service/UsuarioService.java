package com.darkmatter.bookcut.service;

import com.darkmatter.bookcut.DTO.PerfilRequestDTO;
import com.darkmatter.bookcut.DTO.PerfilResponseDTO;
import com.darkmatter.bookcut.model.Usuario;
import com.darkmatter.bookcut.repository.UsuarioRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Optional;
import java.util.UUID;

@Service
public class UsuarioService {

    private final UsuarioRepository repositorioDeUsuarios;
    @Autowired
    private UsuarioRepository usuarioRepository;

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

    public PerfilResponseDTO obtenerPerfil(String correo) {
        Usuario usuario = usuarioRepository.findByCorreoElectronico(correo)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        // Usamos el constructor manual que definimos arriba
        return new PerfilResponseDTO(
                usuario.getNombre(),
                usuario.getApellidos(),
                usuario.getCorreoElectronico(),
                usuario.getTelefono(),
                usuario.getUrlFotoPerfil()
        );
    }

    @Transactional
    public PerfilResponseDTO actualizarPerfil(String correo, PerfilRequestDTO dto) {
        Usuario usuario = usuarioRepository.findByCorreoElectronico(correo)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        usuario.setNombre(dto.getNombre());
        usuario.setApellidos(dto.getApellidos());
        usuario.setTelefono(dto.getTelefono());

        usuarioRepository.save(usuario);
        return obtenerPerfil(correo);
    }

    @Transactional
    public String guardarImagenPerfil(String correo, MultipartFile archivo) throws Exception {
        // 1. DEBUG: Vamos a ver qué correo está llegando del token
        System.out.println("DEBUG - Intentando subir foto para el correo: [" + correo + "]");

        // 2. Buscamos al usuario
        Usuario usuario = usuarioRepository.findByCorreoElectronico(correo)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado (Correo: " + correo + ")"));

        // Definir ruta donde se guardarán las fotos (asegúrate de crear la carpeta 'uploads')
        String nombreArchivo = UUID.randomUUID().toString() + "_" + archivo.getOriginalFilename();
        Path ruta = Paths.get("uploads").resolve(nombreArchivo);

        if (!Files.exists(Paths.get("uploads"))) {
            Files.createDirectories(Paths.get("uploads"));
        }

        Files.copy(archivo.getInputStream(), ruta, StandardCopyOption.REPLACE_EXISTING);

        usuario.setUrlFotoPerfil(nombreArchivo); // O la ruta completa
        usuarioRepository.save(usuario);

        return nombreArchivo;
    }
}