package com.darkmatter.bookcut.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "tabla_barberos")
public class Barbero {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_perfil_barbero")
    private Long idPerfilBarbero;

    @OneToOne
    @JoinColumn(name = "identificador_usuario", referencedColumnName = "id_usuario", nullable = false)
    private Usuario usuarioAsignado;

    @ManyToOne
    @JoinColumn(name = "identificador_barberia", referencedColumnName = "id_barberia", nullable = false)
    private Barberia barberiaAsignada;

    @Column(name = "especialidad_corte", length = 100)
    private String especialidadCorte;

    public Barbero() {
    }

    public Barbero(Usuario usuarioAsignado, Barberia barberiaAsignada, String especialidadCorte) {
        this.usuarioAsignado = usuarioAsignado;
        this.barberiaAsignada = barberiaAsignada;
        this.especialidadCorte = especialidadCorte;
    }

    public Long getIdPerfilBarbero() {
        return idPerfilBarbero;
    }

    public void setIdPerfilBarbero(Long idPerfilBarbero) {
        this.idPerfilBarbero = idPerfilBarbero;
    }

    public Usuario getUsuarioAsignado() {
        return usuarioAsignado;
    }

    public void setUsuarioAsignado(Usuario usuarioAsignado) {
        this.usuarioAsignado = usuarioAsignado;
    }

    public Barberia getBarberiaAsignada() {
        return barberiaAsignada;
    }

    public void setBarberiaAsignada(Barberia barberiaAsignada) {
        this.barberiaAsignada = barberiaAsignada;
    }

    public String getEspecialidadCorte() {
        return especialidadCorte;
    }

    public void setEspecialidadCorte(String especialidadCorte) {
        this.especialidadCorte = especialidadCorte;
    }
}
