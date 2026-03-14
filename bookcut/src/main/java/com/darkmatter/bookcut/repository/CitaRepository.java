package com.darkmatter.bookcut.repository;
import com.darkmatter.bookcut.model.Cita;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.time.LocalDateTime;
import java.util.List;
@Repository
public interface CitaRepository extends JpaRepository<Cita, Long> {
    List<Cita> findByClienteReserva_IdUsuario(Long idUsuario);
    List<Cita> findByBarberoAsignado_IdPerfilBarbero(Long idBarbero);
    boolean existsByBarberoAsignado_IdPerfilBarberoAndFechaHoraCita(Long idBarbero, LocalDateTime fechaHora);
}

