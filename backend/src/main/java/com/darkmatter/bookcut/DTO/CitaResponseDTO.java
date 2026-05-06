package com.darkmatter.bookcut.DTO;

import com.darkmatter.bookcut.model.EstadoCita;
import java.time.LocalDateTime;

public class CitaResponseDTO {
    private Long idCita;
    private LocalDateTime fechaHoraCita;
    private EstadoCita estadoCita;
    private ServicioDTO servicioContratado; // Aquí va el precio y duración
    private String nombreBarberia;

    // Getters y Setters
    public Long getIdCita() { return idCita; }
    public void setIdCita(Long idCita) { this.idCita = idCita; }
    public LocalDateTime getFechaHoraCita() { return fechaHoraCita; }
    public void setFechaHoraCita(LocalDateTime fechaHoraCita) { this.fechaHoraCita = fechaHoraCita; }
    public EstadoCita getEstadoCita() { return estadoCita; }
    public void setEstadoCita(EstadoCita estadoCita) { this.estadoCita = estadoCita; }
    public ServicioDTO getServicioContratado() { return servicioContratado; }
    public void setServicioContratado(ServicioDTO servicioContratado) { this.servicioContratado = servicioContratado; }
    public String getNombreBarberia() { return nombreBarberia; }
    public void setNombreBarberia(String nombreBarberia) { this.nombreBarberia = nombreBarberia; }

}
