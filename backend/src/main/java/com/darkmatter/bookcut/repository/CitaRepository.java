package com.darkmatter.bookcut.repository;

import com.darkmatter.bookcut.model.Barbero;
import com.darkmatter.bookcut.model.Cita;
import com.darkmatter.bookcut.model.EstadoCita;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Interfaz de acceso a datos para la entidad Cita.
 * Gestiona el volumen principal de operaciones del sistema, incluyendo
 * validaciones de disponibilidad, reportes de facturación y limpieza de estados.
 */
@Repository
public interface CitaRepository extends JpaRepository<Cita, Long> {

    List<Cita> findByClienteReserva_IdUsuario(Long idUsuario);

    List<Cita> findByBarberoAsignado_IdPerfilBarbero(Long idBarbero);

    List<Cita> findByBarberoAsignadoAndFechaHoraCitaBetween(Barbero barbero, LocalDateTime inicioDia, LocalDateTime finDia);

    /**
     * Recupera citas por estado y rango temporal.
     * Método crítico para el cálculo de ingresos en FacturacionController.
     */
    List<Cita> findByEstadoCitaAndFechaHoraCitaBetween(EstadoCita estadoCita, LocalDateTime fechaInicio, LocalDateTime fechaFin);

    boolean existsByBarberoAsignado_IdPerfilBarberoAndFechaHoraCita(Long idBarbero, LocalDateTime fechaHora);

    boolean existsByBarberoAsignadoAndFechaHoraCita(Barbero barberoAsignado, LocalDateTime fechaHoraCita);

    boolean existsByServicioContratadoIdServicio(Long idServicio);

    /**
     * Actualización atómica de estado.
     * Utilizada para cambios rápidos que no requieren cargar la entidad completa en memoria.
     */
    @Modifying
    @Transactional
    @Query("UPDATE Cita c SET c.estadoCita = :estado WHERE c.idCita = :idCita")
    void actualizarEstadoDirecto(@Param("idCita") Long idCita, @Param("estado") EstadoCita estado);

    List<Cita> findByBarberoAsignadoAndEstadoCita(Barbero barbero, EstadoCita estadoEnum);

    List<Cita> findByEstadoCita(EstadoCita estadoCita);

    @Transactional
    void deleteByClienteReserva_IdUsuario(Long idUsuario);

    List<Cita> findByBarberoAsignado_BarberiaAsignada_IdBarberia(Long idBarberia);

    /**
     * Localiza citas que han superado una fecha límite.
     * Esencial para la tarea programada de gestión de citas VENCIDAS.
     */
    List<Cita> findByEstadoCitaAndFechaHoraCitaBefore(EstadoCita estadoCita, LocalDateTime fechaLimite);
}
