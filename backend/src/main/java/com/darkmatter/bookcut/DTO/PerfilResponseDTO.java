package com.darkmatter.bookcut.DTO;

/**
 * Objeto de Transferencia de Datos (DTO) para la respuesta del perfil.
 * Encapsula los datos del usuario que se envían de vuelta al cliente,
 * asegurando que no se expongan campos sensibles como la contraseña o el ID interno.
 */
public class PerfilResponseDTO {

    private String nombre;
    private String apellidos;
    private String correoElectronico;
    private String telefono;

    public PerfilResponseDTO() {
    }

    public PerfilResponseDTO(String nombre, String apellidos, String correoElectronico, String telefono) {
        this.nombre = nombre;
        this.apellidos = apellidos;
        this.correoElectronico = correoElectronico;
        this.telefono = telefono;
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

    public String getCorreoElectronico() {
        return correoElectronico;
    }

    public void setCorreoElectronico(String correoElectronico) {
        this.correoElectronico = correoElectronico;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String telefono) {
        this.telefono = telefono;
    }
}