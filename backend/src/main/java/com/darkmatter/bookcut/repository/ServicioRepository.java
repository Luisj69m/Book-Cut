package com.darkmatter.bookcut.repository;

import com.darkmatter.bookcut.model.Servicio;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

/**
 * Interfaz de acceso a datos para la entidad Servicio.
 * Permite gestionar el catálogo de prestaciones disponibles en cada establecimiento.
 */
@Repository
public interface ServicioRepository extends JpaRepository<Servicio, Long> {

    /**
     * Recupera todos los servicios vinculados a un local específico.
     * Utilizado para desglosar la oferta comercial en la vista de selección de servicios.
     *
     * @param idBarberia Identificador único del establecimiento.
     * @return Lista de servicios asociados a dicha barbería.
     */
    List<Servicio> findByBarberiaAsignada_IdBarberia(Long idBarberia);
}