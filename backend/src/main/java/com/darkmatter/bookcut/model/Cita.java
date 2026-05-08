package com.darkmatter.bookcut.model;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Entidad JPA que representa una reserva en el sistema.
 * El campo precioFinal es crítico: congela el precio del servicio en el momento
 * en que la cita es aceptada para proteger la coherencia de la facturación.
 */
@Entity
@Table(name = "tabla_citas")
public class Cita {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_cita")
    private Long idCita;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "identificador_cliente")
    @JsonIgnoreProperties({"contrasenaUsuario", "listaCitas"})
    private Usuario clienteReserva;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "identificador_barbero")
    @JsonIgnoreProperties({"usuarioAsignado", "barberiaAsignada"})
    private Barbero barberoAsignado;

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "identificador_servicio")
    private Servicio servicioContratado;

    @Column(name = "fecha_hora_cita", nullable = false)
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss[.SSS]", timezone = "Europe/Madrid")
    private LocalDateTime fechaHoraCita;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado_cita", nullable = false)
    private EstadoCita estadoCita;

    @Column(name = "precio_final", precision = 10, scale = 2)
    private BigDecimal precioFinal;

    public Cita() {
    }

    public Cita(Usuario clienteReserva, Barbero barberoAsignado, Servicio servicioContratado, LocalDateTime fechaHoraCita, EstadoCita estadoCita) {
        this.clienteReserva = clienteReserva;
        this.barberoAsignado = barberoAsignado;
        this.servicioContratado = servicioContratado;
        this.fechaHoraCita = fechaHoraCita;
        this.estadoCita = estadoCita;
    }

    public Long getIdCita() {
        return idCita;
    }

    public void setIdCita(Long idCita) {
        this.idCita = idCita;
    }

    public Usuario getClienteReserva() {
        return clienteReserva;
    }

    public void setClienteReserva(Usuario clienteReserva) {
        this.clienteReserva = clienteReserva;
    }

    public Barbero getBarberoAsignado() {
        return barberoAsignado;
    }

    public void setBarberoAsignado(Barbero barberoAsignado) {
        this.barberoAsignado = barberoAsignado;
    }

    public Servicio getServicioContratado() {
        return servicioContratado;
    }

    public void setServicioContratado(Servicio servicioContratado) {
        this.servicioContratado = servicioContratado;
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

    public BigDecimal getPrecioFinal() {
        return precioFinal;
    }

    public void setPrecioFinal(BigDecimal precioFinal) {
        this.precioFinal = precioFinal;
    }
}