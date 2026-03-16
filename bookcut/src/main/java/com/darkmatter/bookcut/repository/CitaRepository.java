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
@Repository
public interface CitaRepository extends JpaRepository<Cita, Long> {
    List<Cita> findByClienteReserva_IdUsuario(Long idUsuario);
    List<Cita> findByBarberoAsignado_IdPerfilBarbero(Long idBarbero);
    boolean existsByBarberoAsignado_IdPerfilBarberoAndFechaHoraCita(Long idBarbero, LocalDateTime fechaHora);
    List<Cita> findByBarberoAsignadoAndEstadoCita(Barbero barbero, EstadoCita estadoCita);
    @Modifying
    @Transactional
    @Query("UPDATE Cita c SET c.estadoCita = :estado WHERE c.idCita = :idCita")
    void actualizarEstadoDirecto(@Param("idCita") Long idCita, @Param("estado") EstadoCita estado);
}

