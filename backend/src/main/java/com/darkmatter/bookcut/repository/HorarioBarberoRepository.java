package com.darkmatter.bookcut.repository;

import com.darkmatter.bookcut.model.HorarioBarbero;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Interfaz de acceso a datos para la entidad HorarioBarbero.
 * Proporciona los métodos necesarios para consultar la disponibilidad de los empleados.
 * Nota: Se accede directamente desde el controlador para operaciones de lectura simple.
 */
@Repository
public interface HorarioBarberoRepository extends JpaRepository<HorarioBarbero, Long> {

    /**
     * Recupera la lista de horarios configurados para un barbero específico.
     * * @param idBarbero Identificador del perfil profesional del barbero.
     * @return Lista de franjas horarias asignadas.
     */
    List<HorarioBarbero> findByBarbero_IdPerfilBarbero(Long idBarbero);
}