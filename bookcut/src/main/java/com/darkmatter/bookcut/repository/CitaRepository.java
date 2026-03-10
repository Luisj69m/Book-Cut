package com.darkmatter.bookcut.repository;
import com.darkmatter.bookcut.model.Cita;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
@Repository
public interface CitaRepository extends JpaRepository<Cita, Long> {
    List<Cita> findByClienteReserva_IdUsuario(Long idUsuario);
}

