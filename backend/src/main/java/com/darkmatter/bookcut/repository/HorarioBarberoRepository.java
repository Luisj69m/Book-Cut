package com.darkmatter.bookcut.repository;
import com.darkmatter.bookcut.model.HorarioBarbero;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;
public interface HorarioBarberoRepository extends JpaRepository<HorarioBarbero, Long> {
    List<HorarioBarbero> findByBarbero_IdPerfilBarbero(Long idBarbero);
}