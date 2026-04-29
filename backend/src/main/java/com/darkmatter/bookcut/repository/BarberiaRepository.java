package com.darkmatter.bookcut.repository;

import com.darkmatter.bookcut.model.Barberia;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface BarberiaRepository extends JpaRepository<Barberia, Long> {
    Optional<Barberia> findByBarberoPropietario_CorreoElectronico(String correoElectronico);
}