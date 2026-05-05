package com.darkmatter.bookcut.model;

import jakarta.persistence.*;

import java.math.BigDecimal;

@Entity
@Table(name = "tabla_servicios")
public class Servicio {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_servicio")
    private Long idServicio;

    @Column(name = "nombre_servicio", nullable = false, length = 100)
    private String nombreServicio;

    @Column(name = "precio_servicio", nullable = false, precision = 10, scale = 2)
    private BigDecimal precioServicio;

    @Column(name = "duracion_minutos")
    private Integer duracionMinutos;

    @ManyToOne
    @JoinColumn(name = "id_barberia", nullable = false)
    private Barberia barberia;

    public Servicio() {
    }

    public Servicio(String nombreServicio, BigDecimal precioServicio) {
        this.nombreServicio = nombreServicio;
        this.precioServicio = precioServicio;
    }

    public Long getIdServicio() {
        return idServicio;
    }

    public void setIdServicio(Long idServicio) {
        this.idServicio = idServicio;
    }

    public String getNombreServicio() {
        return nombreServicio;
    }

    public void setNombreServicio(String nombreServicio) {
        this.nombreServicio = nombreServicio;
    }

    public BigDecimal getPrecioServicio() {
        return precioServicio;
    }

    public void setPrecioServicio(BigDecimal precioServicio) {
        this.precioServicio = precioServicio;
    }

    public Integer getDuracionMinutos() {
        return duracionMinutos;
    }

    public void setDuracionMinutos(Integer duracionMinutos) {
        this.duracionMinutos = duracionMinutos;
    }

    public Barberia getBarberia() {
        return barberia;
    }

    public void setBarberia(Barberia barberia) {
        this.barberia = barberia;
    }
}