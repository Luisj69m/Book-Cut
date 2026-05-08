package com.darkmatter.bookcut.DTO;

/**
 * Objeto de Transferencia de Datos (DTO) para la petición de actualización de perfil.
 * Encapsula los datos que el cliente envía para modificar su información básica,
 * separando la capa de presentación de la entidad Usuario.
 */
public class PerfilRequestDTO {

    private String nombre;
    private String apellidos;
    private String telefono;

    public PerfilRequestDTO() {
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getApellidos() {
        return apellidos;
    }

    public void setApellidos(String apellidos) {
        this.apellidos = apellidos;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }
}
