package com.darkmatter.bookcut.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;

/**
 * Entidad JPA que representa un establecimiento.
 * Mantiene la relación con el propietario, protegiendo la serialización mediante JsonIgnore.
 */
@Entity
@Table(name = "tabla_barberias")
public class Barberia {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_barberia")
    private Long idBarberia;

    @Column(name = "nombre", nullable = false)
    private String nombre;

    @Column(name = "direccion_completa", nullable = false)
    private String direccionCompleta;

    @Column(name = "zona")
    private String zona;

    @Column(name = "horario")
    private String horario;

    @Column(name = "descripcion", columnDefinition = "TEXT")
    private String descripcion;

    @OneToOne
    @JoinColumn(name = "id_usuario_barbero", referencedColumnName = "id_usuario", unique = true)
    @JsonIgnore
    private Usuario barberoPropietario;

    public Barberia() {
    }

    public Long getIdBarberia() { return idBarberia; }
    public void setIdBarberia(Long idBarberia) { this.idBarberia = idBarberia; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getDireccionCompleta() { return direccionCompleta; }
    public void setDireccionCompleta(String direccionCompleta) { this.direccionCompleta = direccionCompleta; }

    public String getZona() { return zona; }
    public void setZona(String zona) { this.zona = zona; }

    public String getHorario() { return horario; }
    public void setHorario(String horario) { this.horario = horario; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public Usuario getBarberoPropietario() { return barberoPropietario; }
    public void setBarberoPropietario(Usuario barberoPropietario) { this.barberoPropietario = barberoPropietario; }
}