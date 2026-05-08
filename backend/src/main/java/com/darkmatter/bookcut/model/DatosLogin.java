package com.darkmatter.bookcut.model;

/**
 * Clase auxiliar para encapsular las credenciales de inicio de sesión.
 * Actúa funcionalmente como un DTO para el endpoint de autenticación.
 */
public class DatosLogin {

    private String correoElectronico;
    private String contrasenaUsuario;

    public DatosLogin() {
    }

    public String getCorreoElectronico() {
        return correoElectronico;
    }

    public void setCorreoElectronico(String correoElectronico) {
        this.correoElectronico = correoElectronico;
    }

    public String getContrasenaUsuario() {
        return contrasenaUsuario;
    }

    public void setContrasenaUsuario(String contrasenaUsuario) {
        this.contrasenaUsuario = contrasenaUsuario;
    }
}
