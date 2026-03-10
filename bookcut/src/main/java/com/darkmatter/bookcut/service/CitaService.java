package com.darkmatter.bookcut.service;
import com.darkmatter.bookcut.model.Cita;
import com.darkmatter.bookcut.repository.CitaRepository;
import org.springframework.stereotype.Service;
@Service
public class CitaService {
    private final CitaRepository repositorioDeCitas;
    public CitaService(CitaRepository repositorioDeCitas) {
        this.repositorioDeCitas = repositorioDeCitas;
    }
    public Cita crearNuevaCita(Cita nuevaCita) {
        return repositorioDeCitas.save(nuevaCita);
    }
}
