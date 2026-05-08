package com.darkmatter.bookcut.DTO;

public class ServicioDTO {

    private String nombre;
    private Double precio;
    private Integer duracionMinutos;

    // Constructor vacío necesario para la deserialización
    public ServicioDTO() {
    }

    // Constructor con campos
    public ServicioDTO(String nombre, Double precio, Integer duracionMinutos) {
        this.nombre = nombre;
        this.precio = precio;
        this.duracionMinutos = duracionMinutos;
    }

    // Getters y Setters
    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public Double getPrecio() {
        return precio;
    }

    public void setPrecio(Double precio) {
        this.precio = precio;
    }

    public Integer getDuracionMinutos() {
        return duracionMinutos;
    }

    public void setDuracionMinutos(Integer duracionMinutos) {
        this.duracionMinutos = duracionMinutos;
    }
}