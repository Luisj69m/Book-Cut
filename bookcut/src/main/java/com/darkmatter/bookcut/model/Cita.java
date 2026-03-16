package com.darkmatter.bookcut.model;

import com.fasterxml.jackson.annotation.JsonFormat;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

import java.time.LocalDateTime;

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
    private Servicio servicioContratado;;

    @Column(name = "fecha_hora_cita", nullable = false)
    @JsonFormat(pattern = "yyyy-MM-dd'T'HH:mm:ss", timezone = "Europe/Madrid")
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