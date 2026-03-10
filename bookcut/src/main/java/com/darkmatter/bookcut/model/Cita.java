package com.darkmatter.bookcut.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import java.time.LocalDateTime;

@Entity
@Table(name = "tabla_citas")
public class Cita {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_cita")
    private Long idCita;

    @ManyToOne
    @JoinColumn(name = "identificador_cliente", referencedColumnName = "id_usuario", nullable = false)
    private Usuario clienteReserva;

    @ManyToOne
    @JoinColumn(name = "identificador_barbero", referencedColumnName = "id_perfil_barbero", nullable = false)
    private Barbero barberoAsignado;

    @ManyToOne
    @JoinColumn(name = "identificador_servicio", referencedColumnName = "id_servicio", nullable = false)
    private Servicio servicioContratado;

    @Column(name = "fecha_hora_cita", nullable = false)
    private LocalDateTime fechaHoraCita;

    @Enumerated(EnumType.STRING)
    @Column(name = "estado_cita", nullable = false)
    private EstadoCita estadoCita;

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
}