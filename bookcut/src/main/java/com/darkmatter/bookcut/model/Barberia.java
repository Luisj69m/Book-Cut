package com.darkmatter.bookcut.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "tabla_barberias")
public class Barberia {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_barberia")
    private Long idBarberia;

    @Column(name = "nombre", nullable = false)
    private String nombre;

    @Column(name = "direccion", nullable = false)
    private String direccion;

    @Column(name = "descripcion", length = 1000)
    private String descripcion;

    @OneToOne
    @JoinColumn(name = "id_usuario_barbero", referencedColumnName = "id_usuario", unique = true)
    private Usuario barberoPropietario;

    public Barberia() {}

    public Long getIdBarberia() { return idBarberia; }
    public void setIdBarberia(Long idBarberia) { this.idBarberia = idBarberia; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getDireccion() { return direccion; }
    public void setDireccion(String direccion) { this.direccion = direccion; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    public Usuario getBarberoPropietario() { return barberoPropietario; }
    public void setBarberoPropietario(Usuario barberoPropietario) { this.barberoPropietario = barberoPropietario; }
}