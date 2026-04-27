package com.darkmatter.bookcut.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "tabla_barberias")
public class Barberia {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_barberia")
    private Long idBarberia;

    @Column(name = "nombre_barberia", nullable = false, length = 100)
    private String nombreBarberia;

    @Column(name = "direccion_fisica", nullable = false, length = 255)
    private String direccionFisica;

    public Barberia() {
    }

    public Barberia(String nombreBarberia, String direccionFisica) {
        this.nombreBarberia = nombreBarberia;
        this.direccionFisica = direccionFisica;
    }

    public Long getIdBarberia() {
        return idBarberia;
    }

    public void setIdBarberia(Long idBarberia) {
        this.idBarberia = idBarberia;
    }

    public String getNombreBarberia() {
        return nombreBarberia;
    }

    public void setNombreBarberia(String nombreBarberia) {
        this.nombreBarberia = nombreBarberia;
    }

    public String getDireccionFisica() {
        return direccionFisica;
    }

    public void setDireccionFisica(String direccionFisica) {
        this.direccionFisica = direccionFisica;
    }
}
