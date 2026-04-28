package com.darkmatter.bookcut.service;

import com.darkmatter.bookcut.DTO.PerfilRequestDTO;
import com.darkmatter.bookcut.DTO.PerfilResponseDTO;
import com.darkmatter.bookcut.model.Usuario;
import com.darkmatter.bookcut.repository.CitaRepository;
import com.darkmatter.bookcut.repository.UsuarioRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final CitaRepository citaRepository;
    private final org.springframework.mail.javamail.JavaMailSender enviadorDeCorreos;
    private final JdbcTemplate baseDeDatosDirecta;

    @Autowired
    public UsuarioService(UsuarioRepository usuarioRepository,
                          CitaRepository citaRepository,
                          org.springframework.mail.javamail.JavaMailSender enviadorDeCorreos,
                          JdbcTemplate baseDeDatosDirecta) {
        this.usuarioRepository = usuarioRepository;
        this.citaRepository = citaRepository;
        this.enviadorDeCorreos = enviadorDeCorreos;
        this.baseDeDatosDirecta = baseDeDatosDirecta;
    }

    public Usuario registrarNuevoUsuario(Usuario nuevoUsuario) {
        if (usuarioRepository.findByCorreoElectronico(nuevoUsuario.getCorreoElectronico()).isPresent()) {
            throw new RuntimeException("El correo electronico ya esta registrado");
        }
        nuevoUsuario.setRolUsuario(com.darkmatter.bookcut.model.RolUsuario.CLIENTE);
        return usuarioRepository.save(nuevoUsuario);
    }

    public Usuario validarLogin(String correo, String contrasena) {
        return usuarioRepository.findByCorreoElectronicoAndContrasenaUsuario(correo, contrasena)
                .orElseThrow(() -> new RuntimeException("Credenciales incorrectas"));
    }

    public PerfilResponseDTO obtenerPerfil(String correo) {
        Usuario usuario = usuarioRepository.findByCorreoElectronico(correo)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

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

        // Si Dani nos manda una URL de Cloudinary, la guardamos directamente
        if (dto.getUrlFotoPerfil() != null && !dto.getUrlFotoPerfil().isEmpty()) {
            usuario.setUrlFotoPerfil(dto.getUrlFotoPerfil());
        }

        usuarioRepository.save(usuario);
        return obtenerPerfil(correo);
    }

    @Transactional
    public String guardarImagenPerfil(String correo, MultipartFile archivo) throws Exception {
        System.out.println("DEBUG - Intentando subir foto para el correo: [" + correo + "]");

        Usuario usuario = usuarioRepository.findByCorreoElectronico(correo)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado (Correo: " + correo + ")"));

        String nombreArchivo = UUID.randomUUID().toString() + "_" + archivo.getOriginalFilename();
        Path ruta = Paths.get("uploads").resolve(nombreArchivo);

        if (!Files.exists(Paths.get("uploads"))) {
            Files.createDirectories(Paths.get("uploads"));
        }

        Files.copy(archivo.getInputStream(), ruta, StandardCopyOption.REPLACE_EXISTING);

        usuario.setUrlFotoPerfil(nombreArchivo);
        usuarioRepository.save(usuario);

        return nombreArchivo;
    }

    @Transactional
    public void eliminarCuentaDeUsuario(Long idUsuario) {
        citaRepository.deleteByClienteReserva_IdUsuario(idUsuario);
        usuarioRepository.deleteById(idUsuario);
    }

    public void actualizarUrlImagen(String correoElectronico, String urlImagenNube) {
        Usuario usuarioEncontrado = usuarioRepository.findByCorreoElectronico(correoElectronico)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado en la base de datos"));

        usuarioEncontrado.setUrlFotoPerfil(urlImagenNube);
        usuarioRepository.save(usuarioEncontrado);
    }

    public void enviarEmailRecuperacion(String correoDestino) {
        Usuario usuario = usuarioRepository.findByCorreoElectronico(correoDestino)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        String codigoRecuperacion = UUID.randomUUID().toString().substring(0, 6).toUpperCase();

        String instruccionSql = "INSERT INTO tokens_restablecer_contrasena (id_usuario, token, fecha_expiracion) " +
                "VALUES (?, ?, ?) ON CONFLICT (id_usuario) DO UPDATE SET token = EXCLUDED.token, fecha_expiracion = EXCLUDED.fecha_expiracion";

        baseDeDatosDirecta.update(instruccionSql, usuario.getIdUsuario(), codigoRecuperacion, LocalDateTime.now().plusMinutes(15));

        org.springframework.mail.SimpleMailMessage mensaje = new org.springframework.mail.SimpleMailMessage();
        mensaje.setFrom("soporte@bookcut.com");
        mensaje.setTo(correoDestino);
        mensaje.setSubject("Código de recuperación de contraseña");
        mensaje.setText("Tu código para recuperar la contraseña es: " + codigoRecuperacion);

        enviadorDeCorreos.send(mensaje);
    }

    @Transactional
    public void actualizarContrasena(String codigo, String nuevaContrasena) {
        String consultaSql = "SELECT id_usuario FROM tokens_restablecer_contrasena WHERE token = ? AND fecha_expiracion > ?";

        List<Long> listaIdentificadores = baseDeDatosDirecta.queryForList(consultaSql, Long.class, codigo, LocalDateTime.now());

        if (listaIdentificadores.isEmpty()) {
            throw new RuntimeException("El código es inválido o ha caducado");
        }

        Long identificadorUsuario = listaIdentificadores.get(0);

        Usuario usuario = usuarioRepository.findById(identificadorUsuario)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        usuario.setContrasenaUsuario(nuevaContrasena);
        usuarioRepository.save(usuario);

        String borradoSql = "DELETE FROM tokens_restablecer_contrasena WHERE id_usuario = ?";
        baseDeDatosDirecta.update(borradoSql, identificadorUsuario);
    }

    public Usuario registrarUsuarioDesdeAdmin(Usuario nuevoUsuario) {
        if (usuarioRepository.findByCorreoElectronico(nuevoUsuario.getCorreoElectronico()).isPresent()) {
            throw new RuntimeException("El correo electronico ya esta registrado");
        }
        return usuarioRepository.save(nuevoUsuario);
    }

    public Usuario obtenerUsuarioPorCorreo(String correo) {
        return usuarioRepository.findByCorreoElectronico(correo)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));
    }

    public List<Usuario> obtenerTodosLosUsuarios() {
        return usuarioRepository.findAll();
    }
}