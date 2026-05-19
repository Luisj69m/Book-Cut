package com.darkmatter.bookcut.repository;
import com.darkmatter.bookcut.model.Barbero;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface BarberoRepository extends JpaRepository<Barbero, Long> {
    List<Barbero> findByBarberiaAsignada_IdBarberia(Long idBarberia);
    Optional<Barbero> findByUsuarioAsignadoIdUsuario(Long idUsuario);
    Optional<Barbero> findFirstByBarberiaAsignadaIdBarberia(Long idBarberia);
    Optional<Barbero> findByUsuarioAsignado_CorreoElectronico(String correoElectronico);
}
