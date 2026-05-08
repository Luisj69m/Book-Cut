package com.darkmatter.bookcut.repository;

import com.darkmatter.bookcut.model.Barbero;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/**
 * Interfaz de acceso a datos para la entidad Barbero.
 * Actúa como nexo entre los usuarios con rol profesional y las barberías donde operan.
 */
@Repository
public interface BarberoRepository extends JpaRepository<Barbero, Long> {

    /**
     * Recupera la lista completa de trabajadores vinculados a un local.
     */
    List<Barbero> findByBarberiaAsignadaIdBarberia(Long idBarberia);

    /**
     * Localiza el perfil profesional a partir del identificador de usuario único.
     */
    Optional<Barbero> findByUsuarioAsignadoIdUsuario(Long idUsuario);

    /**
     * Obtiene el primer barbero disponible de una barbería.
     * Utilizado principalmente en el flujo de creación de citas automáticas.
     */
    Optional<Barbero> findFirstByBarberiaAsignadaIdBarberia(Long idBarberia);

    /**
     * Busca el perfil profesional mediante el correo electrónico del usuario.
     * Crucial para validaciones de seguridad basadas en el token JWT.
     */
    Optional<Barbero> findByUsuarioAsignado_CorreoElectronico(String correoElectronico);
}
