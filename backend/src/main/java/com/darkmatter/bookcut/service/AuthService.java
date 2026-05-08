package com.darkmatter.bookcut.service;

import com.darkmatter.bookcut.model.PasswordResetToken;
import com.darkmatter.bookcut.model.Usuario;
import com.darkmatter.bookcut.repository.PasswordResetTokenRepository;
import com.darkmatter.bookcut.repository.UsuarioRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Random;

/**
 * Servicio encargado de la lógica de autenticación extendida.
 * Gestiona el flujo de recuperación de contraseñas mediante tokens temporales
 * y la comunicación con el servicio de mensajería.
 */
@Service
public class AuthService {

    private final UsuarioRepository repositorioUsuario;
    private final PasswordResetTokenRepository repositorioToken;
    private final EmailService servicioEmail;

    public AuthService(UsuarioRepository repositorioUsuario,
                       PasswordResetTokenRepository repositorioToken,
                       EmailService servicioEmail) {
        this.repositorioUsuario = repositorioUsuario;
        this.repositorioToken = repositorioToken;
        this.servicioEmail = servicioEmail;
    }

    /**
     * Genera un código de verificación de 6 dígitos, invalida tokens previos
     * y dispara el envío del correo electrónico de recuperación.
     *
     * @param correo Correo electrónico del usuario que solicita el cambio.
     */
    @Transactional
    public void crearTokenRecuperacion(String correo) {
        Usuario usuario = repositorioUsuario.findByCorreoElectronico(correo)
                .orElseThrow(() -> new RuntimeException("No existe ningún usuario con el correo: " + correo));

        // Limpieza de intentos previos para evitar colisiones
        repositorioToken.deleteByUsuarioVinculado(usuario);
        repositorioToken.flush();

        // Generación de código numérico de 6 cifras
        String codigoGenerado = String.format("%06d", new Random().nextInt(999999));

        PasswordResetToken tokenSeguridad = new PasswordResetToken(codigoGenerado, usuario);
        repositorioToken.save(tokenSeguridad);

        // Notificación al usuario vía EmailService
        servicioEmail.enviarCorreoRecuperacion(correo, codigoGenerado);
    }

    /**
     * Valida la vigencia y veracidad del token proporcionado para actualizar
     * las credenciales de acceso del usuario.
     *
     * @param codigoToken Código de 6 dígitos enviado al usuario.
     * @param nuevaContrasena Nueva clave de acceso en texto plano (procesada antes de persistir).
     */
    @Transactional
    public void cambiarContrasenaConToken(String codigoToken, String nuevaContrasena) {
        PasswordResetToken tokenEncontrado = repositorioToken.findByCodigoToken(codigoToken)
                .orElseThrow(() -> new RuntimeException("El código introducido no es válido"));

        // Verificación de la ventana temporal de 15 minutos
        if (tokenEncontrado.estaExpirado()) {
            repositorioToken.delete(tokenEncontrado);
            throw new RuntimeException("El código ha caducado. Solicita uno nuevo");
        }

        Usuario usuario = tokenEncontrado.getUsuarioVinculado();

        // Actualización de credenciales
        usuario.setContrasenaUsuario(nuevaContrasena);
        repositorioUsuario.save(usuario);

        // Consumo del token para evitar reutilización malintencionada
        repositorioToken.delete(tokenEncontrado);
    }
}