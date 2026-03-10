package com.darkmatter.bookcut.repository;
import com.darkmatter.bookcut.model.Barbero;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
@Repository
public interface BarberoRepository extends JpaRepository<Barbero, Long> {
    List<Barbero> findByBarberiaAsignadaIdBarberia(Long idBarberia);
}
