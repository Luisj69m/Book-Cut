package com.darkmatter.bookcut.repository;

import com.darkmatter.bookcut.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Interfaz de acceso a datos para la entidad Usuario.
 * Constituye el núcleo de la seguridad del sistema, permitiendo la localización
 * de cuentas para procesos de autenticación, registro y recuperación.
 */
@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    /**
     * Localiza a un usuario mediante su credencial de correo electrónico.
     * Método fundamental para la carga de detalles de usuario en el flujo de Spring Security.
     *
     * @param correo Correo electrónico único del usuario.
     * @return Un Optional con el Usuario si existe en los registros.
     */
    Optional<Usuario> findByCorreoElectronico(String correo);

    /**
     * Busca un usuario que coincida exactamente con el correo y la contraseña proporcionados.
     * Utilizado en validaciones básicas de acceso.
     */
    Optional<Usuario> findByCorreoElectronicoAndContrasenaUsuario(String correo, String contrasena);
}