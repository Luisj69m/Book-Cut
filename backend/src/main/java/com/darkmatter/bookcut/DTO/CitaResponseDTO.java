package com.darkmatter.bookcut.DTO;

import com.darkmatter.bookcut.model.EstadoCita;
import java.math.BigDecimal;
import java.time.LocalDateTime;

public class CitaResponseDTO {

    private Long idCita;
    private LocalDateTime fechaHoraCita;
    private EstadoCita estadoCita;
    private BigDecimal precioFinal;

    // Cliente
    private Long idCliente;
    private String nombreCliente;
    private String correoCliente;

    // Barbero
    private Long idPerfilBarbero;
    private String nombreBarbero;

    // Barbería
    private Long idBarberia;
    private String nombreBarberia;

    // Servicio
    private Long idServicio;
    private String nombreServicio;
    private BigDecimal precioServicio;
    private Integer duracionMinutos;

    // Constructor vacío
    public CitaResponseDTO() {}

    // Constructor completo
    public CitaResponseDTO(Long idCita, LocalDateTime fechaHoraCita, EstadoCita estadoCita,
                           BigDecimal precioFinal, Long idCliente, String nombreCliente,
                           String correoCliente, Long idPerfilBarbero, String nombreBarbero,
                           Long idBarberia, String nombreBarberia, Long idServicio,
                           String nombreServicio, BigDecimal precioServicio, Integer duracionMinutos) {
        this.idCita = idCita;
        this.fechaHoraCita = fechaHoraCita;
        this.estadoCita = estadoCita;
        this.precioFinal = precioFinal;
        this.idCliente = idCliente;
        this.nombreCliente = nombreCliente;
        this.correoCliente = correoCliente;
        this.idPerfilBarbero = idPerfilBarbero;
        this.nombreBarbero = nombreBarbero;
        this.idBarberia = idBarberia;
        this.nombreBarberia = nombreBarberia;
        this.idServicio = idServicio;
        this.nombreServicio = nombreServicio;
        this.precioServicio = precioServicio;
        this.duracionMinutos = duracionMinutos;
    }

    // Getters y Setters
    public Long getIdCita() { return idCita; }
    public void setIdCita(Long idCita) { this.idCita = idCita; }

    public LocalDateTime getFechaHoraCita() { return fechaHoraCita; }
    public void setFechaHoraCita(LocalDateTime fechaHoraCita) { this.fechaHoraCita = fechaHoraCita; }

    public EstadoCita getEstadoCita() { return estadoCita; }
    public void setEstadoCita(EstadoCita estadoCita) { this.estadoCita = estadoCita; }

    public BigDecimal getPrecioFinal() { return precioFinal; }
    public void setPrecioFinal(BigDecimal precioFinal) { this.precioFinal = precioFinal; }

    public Long getIdCliente() { return idCliente; }
    public void setIdCliente(Long idCliente) { this.idCliente = idCliente; }

    public String getNombreCliente() { return nombreCliente; }
    public void setNombreCliente(String nombreCliente) { this.nombreCliente = nombreCliente; }

    public String getCorreoCliente() { return correoCliente; }
    public void setCorreoCliente(String correoCliente) { this.correoCliente = correoCliente; }

    public Long getIdPerfilBarbero() { return idPerfilBarbero; }
    public void setIdPerfilBarbero(Long idPerfilBarbero) { this.idPerfilBarbero = idPerfilBarbero; }

    public String getNombreBarbero() { return nombreBarbero; }
    public void setNombreBarbero(String nombreBarbero) { this.nombreBarbero = nombreBarbero; }

    public Long getIdBarberia() { return idBarberia; }
    public void setIdBarberia(Long idBarberia) { this.idBarberia = idBarberia; }

    public String getNombreBarberia() { return nombreBarberia; }
    public void setNombreBarberia(String nombreBarberia) { this.nombreBarberia = nombreBarberia; }

    public Long getIdServicio() { return idServicio; }
    public void setIdServicio(Long idServicio) { this.idServicio = idServicio; }

    public String getNombreServicio() { return nombreServicio; }
    public void setNombreServicio(String nombreServicio) { this.nombreServicio = nombreServicio; }

    public BigDecimal getPrecioServicio() { return precioServicio; }
    public void setPrecioServicio(BigDecimal precioServicio) { this.precioServicio = precioServicio; }

    public Integer getDuracionMinutos() { return duracionMinutos; }
    public void setDuracionMinutos(Integer duracionMinutos) { this.duracionMinutos = duracionMinutos; }
}
