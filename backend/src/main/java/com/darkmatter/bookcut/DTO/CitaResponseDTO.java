package com.darkmatter.bookcut.DTO;

import com.darkmatter.bookcut.model.EstadoCita;
import java.time.LocalDateTime;

/**
 * Objeto de Transferencia de Datos (DTO) para las citas.
 * Acepta la información estructurada desde la base de datos y la aplana para el frontend,
 * evitando exponer entidades complejas y previniendo bucles de serialización infinita.
 */
public class CitaResponseDTO {

    private Long idCita;
    private LocalDateTime fechaHoraCita;
    private EstadoCita estadoCita;
    private ServicioDTO servicioContratado;
    private String nombreBarberia;

    public Long getIdCita() {
        return idCita;
    }

    public void setIdCita(Long idCita) {
        this.idCita = idCita;
    }

    public LocalDateTime getFechaHoraCita() {
        return fechaHoraCita;
    }

    public void setFechaHoraCita(LocalDateTime fechaHoraCita) {
        this.fechaHoraCita = fechaHoraCita;
    }

    public EstadoCita getEstadoCita() {
        return estadoCita;
    }

    public void setEstadoCita(EstadoCita estadoCita) {
        this.estadoCita = estadoCita;
    }

    public ServicioDTO getServicioContratado() {
        return servicioContratado;
    }

    public void setServicioContratado(ServicioDTO servicioContratado) {
        this.servicioContratado = servicioContratado;
    }

    public String getNombreBarberia() {
        return nombreBarberia;
    }

    public void setNombreBarberia(String nombreBarberia) {
        this.nombreBarberia = nombreBarberia;
    }
}
