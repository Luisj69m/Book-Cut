package com.darkmatter.bookcut.repository;

import com.darkmatter.bookcut.model.PasswordResetToken;
import com.darkmatter.bookcut.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

/**
 * Interfaz de acceso a datos para la gestión de tokens de recuperación.
 * Permite la validación de códigos de seguridad y la limpieza de tokens antiguos
 * para garantizar que un usuario solo tenga un flujo de recuperación activo.
 */
@Repository
public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, Long> {

    /**
     * Localiza un registro de recuperación mediante el código alfanumérico enviado al usuario.
     * @param codigoToken El token de seguridad recibido por correo.
     * @return Un Optional con la información del token y su expiración.
     */
    Optional<PasswordResetToken> findByCodigoToken(String codigoToken);

    /**
     * Elimina cualquier token previo asociado a un usuario.
     * Se utiliza antes de generar uno nuevo para evitar duplicidad y mejorar la seguridad.
     */
    @Modifying
    @Transactional
    void deleteByUsuarioVinculado(Usuario usuario);
}
