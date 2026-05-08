package com.darkmatter.bookcut.repository;

import com.darkmatter.bookcut.model.Barberia;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Interfaz de acceso a datos para la entidad Barberia.
 * Gestiona las operaciones de persistencia y consultas personalizadas sobre la base de datos.
 */
@Repository
public interface BarberiaRepository extends JpaRepository<Barberia, Long> {

    /**
     * Busca un local comercial utilizando el correo electrónico de su propietario.
     * Este método es vital para la validación de seguridad en el BarberiaController.
     *
     * @param correoElectronico El correo del usuario asociado como propietario.
     * @return Un Optional con la Barberia encontrada, o vacío si no existe.
     */
    Optional<Barberia> findByBarberoPropietario_CorreoElectronico(String correoElectronico);
}