package com.darkmatter.bookcut.service;

import com.darkmatter.bookcut.model.PasswordResetToken;
import com.darkmatter.bookcut.model.Usuario;
import com.darkmatter.bookcut.repository.PasswordResetTokenRepository;
import com.darkmatter.bookcut.repository.UsuarioRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Random;

@Service
public class AuthService {

    @Autowired
    private UsuarioRepository usuarioRepository;

    @Autowired
    private PasswordResetTokenRepository tokenRepository;
    @Autowired
    private BrevoEmailService emailService;

    // Aquí inyectarás tu servicio de email cuando lo tengas listo
    // @Autowired
    // private EmailService emailService;

    /**
     * Paso 1: Generar el token de 6 dígitos y guardarlo asociado al usuario.
     */
    @Transactional
    public String crearTokenRecuperacion(String correo) {
        Usuario usuario = usuarioRepository.findByCorreoElectronico(correo)
                .orElseThrow(() -> new RuntimeException("No existe ningún usuario con el correo: " + correo));

        tokenRepository.deleteByUsuario(usuario);
        tokenRepository.flush();

        String token = String.format("%06d", new Random().nextInt(999999));

        PasswordResetToken resetToken = new PasswordResetToken(token, usuario);
        tokenRepository.save(resetToken);

        System.out.println("DEBUG: El código para " + correo + " es: " + token);

        return token;
    }

    /**
     * Paso 2: Validar el token y cambiar la contraseña.
     */
    @Transactional
    public void cambiarContrasenaConToken(String token, String nuevaContrasena) {
        // Buscamos si el código existe
        PasswordResetToken resetToken = tokenRepository.findByToken(token)
                .orElseThrow(() -> new RuntimeException("El código introducido no es válido"));

        // Comprobamos si han pasado los 15 minutos
        if (resetToken.estaExpirado()) {
            tokenRepository.delete(resetToken);
            throw new RuntimeException("El código ha caducado. Solicita uno nuevo");
        }

        // Obtenemos al usuario y actualizamos su contraseña
        Usuario usuario = resetToken.getUsuario();

        // Si más adelante usas BCrypt, aquí pondrías:
        // usuario.setContrasenaUsuario(passwordEncoder.encode(nuevaContrasena));
        usuario.setContrasenaUsuario(nuevaContrasena);

        usuarioRepository.save(usuario);

        // Una vez usada, borramos el token por seguridad
        tokenRepository.delete(resetToken);
    }
}