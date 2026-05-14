package com.darkmatter.bookcut.service;

import com.darkmatter.bookcut.DTO.PerfilRequestDTO;
import com.darkmatter.bookcut.DTO.PerfilResponseDTO;
import com.darkmatter.bookcut.model.PasswordResetToken;
import com.darkmatter.bookcut.model.RolUsuario;
import com.darkmatter.bookcut.model.Usuario;
import com.darkmatter.bookcut.repository.BarberoRepository;
import com.darkmatter.bookcut.repository.CitaRepository;
import com.darkmatter.bookcut.repository.PasswordResetTokenRepository;
import com.darkmatter.bookcut.repository.UsuarioRepository;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

@Service
public class UsuarioService {

    @Autowired
    private final UsuarioRepository usuarioRepository;
    private final CitaRepository citaRepository;
    @Autowired
    private BrevoEmailService brevoEmailService;
    @Autowired
    private AuthService authService;
    private final JdbcTemplate baseDeDatosDirecta;
    @Autowired
    private BarberoRepository barberoRepository;
    @Autowired
    private PasswordResetTokenRepository tokenRepository;
    @Autowired
    private PasswordEncoder passwordEncoder;


    @Autowired
    public UsuarioService(UsuarioRepository usuarioRepository,
                          CitaRepository citaRepository,
                          JavaMailSender enviadorDeCorreos,
                          JdbcTemplate baseDeDatosDirecta) {
        this.usuarioRepository = usuarioRepository;
        this.citaRepository = citaRepository;
        this.baseDeDatosDirecta = baseDeDatosDirecta;
    }

    public Usuario registrarNuevoUsuario(Usuario nuevoUsuario) {
        if (usuarioRepository.findByCorreoElectronico(nuevoUsuario.getCorreoElectronico()).isPresent()) {
            throw new RuntimeException("El correo ya está registrado");
        }

        // Encriptar contraseña
        nuevoUsuario.setContrasenaUsuario(passwordEncoder.encode(nuevoUsuario.getContrasenaUsuario()));

        return usuarioRepository.save(nuevoUsuario);
    }

    public Usuario validarLogin(String correo, String contrasena) {
        Usuario usuario = usuarioRepository.findByCorreoElectronico(correo)
                .orElseThrow(() -> new RuntimeException("Credenciales incorrectas"));

        // Validar contraseña encriptada
        if (!passwordEncoder.matches(contrasena, usuario.getContrasenaUsuario())) {
            throw new RuntimeException("Credenciales incorrectas");
        }

        return usuario;
    }

    public PerfilResponseDTO obtenerPerfil(String correo) {
        Usuario usuario = usuarioRepository.findByCorreoElectronico(correo)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        return new PerfilResponseDTO(
                usuario.getNombre(),
                usuario.getApellidos(),
                usuario.getCorreoElectronico(),
                usuario.getTelefono()
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
    public void eliminarCuentaDeUsuario(Long idUsuario) {
        Usuario usuario = usuarioRepository.findById(idUsuario)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        // Si es BARBERO, eliminar primero su perfil de barbero
        if (usuario.getRolUsuario() == RolUsuario.BARBERO) {
            barberoRepository.findByUsuarioAsignadoIdUsuario(idUsuario)
                    .ifPresent(barbero -> barberoRepository.delete(barbero));
        }

        // Ahora sí eliminar el usuario
        usuarioRepository.delete(usuario);
    }

    public void enviarEmailRecuperacion(String correoDestino) throws Exception {
        // Buscar usuario
        Usuario usuario = usuarioRepository.findByCorreoElectronico(correoDestino)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        // Generar código
        String codigoRecuperacion = authService.crearTokenRecuperacion(correoDestino);

        // Enviar correo
        String asunto = "Recuperación de contraseña - BookCut";
        String cuerpoHtml = "<html><body>" +
                "<h2>Recuperación de contraseña</h2>" +
                "<p>Tu código de recuperación es: <strong>" + codigoRecuperacion + "</strong></p>" +
                "<p>Este código expira en 15 minutos.</p>" +
                "</body></html>";

        brevoEmailService.enviarCorreo(correoDestino, asunto, cuerpoHtml);
    }

    @Transactional
    public void actualizarContrasena(String codigo, String nuevaContrasena) {
        PasswordResetToken token = tokenRepository.findByToken(codigo)
                .orElseThrow(() -> new RuntimeException("Código inválido o expirado"));

        if (token.getFechaExpiracion().isBefore(LocalDateTime.now())) {
            throw new RuntimeException("El código ha expirado");
        }

        Usuario usuario = token.getUsuario();

        // Encriptar nueva contraseña
        usuario.setContrasenaUsuario(passwordEncoder.encode(nuevaContrasena));

        usuarioRepository.save(usuario);
        tokenRepository.delete(token);
    }

    public Usuario registrarUsuarioDesdeAdmin(Usuario nuevoUsuario) {
        if (usuarioRepository.findByCorreoElectronico(nuevoUsuario.getCorreoElectronico()).isPresent()) {
            throw new RuntimeException("El correo ya está registrado");
        }

        // Encriptar contraseña
        nuevoUsuario.setContrasenaUsuario(passwordEncoder.encode(nuevoUsuario.getContrasenaUsuario()));

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