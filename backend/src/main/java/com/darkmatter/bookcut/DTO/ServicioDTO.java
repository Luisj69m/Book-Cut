package com.darkmatter.bookcut.DTO;

/**
 * Objeto de Transferencia de Datos (DTO) para la entidad Servicio.
 * Facilita el envío de datos al frontend, transformando tipos numéricos complejos
 * (como BigDecimal) a Double para simplificar su consumo en la capa de presentación.
 */
public class ServicioDTO {

    private String nombre;
    private Double precio;
    private Integer duracionMinutos;

    public ServicioDTO() {
    }

    public ServicioDTO(String nombre, Double precio, Integer duracionMinutos) {
        this.nombre = nombre;
        this.precio = precio;
        this.duracionMinutos = duracionMinutos;
    }

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