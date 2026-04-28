package com.darkmatter.bookcut.DTO;

public class PerfilResponseDTO {
    private String nombre;
    private String apellidos;
    private String correoElectronico;
    private String telefono;

    public PerfilResponseDTO() {}

    public PerfilResponseDTO(String nombre, String apellidos, String correoElectronico, String telefono) {
        this.nombre = nombre;
        this.apellidos = apellidos;
        this.correoElectronico = correoElectronico;
        this.telefono = telefono;
    }

    // Getters y Setters
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getApellidos() { return apellidos; }
    public void setApellidos(String apellidos) { this.apellidos = apellidos; }

    public String getCorreoElectronico() { return correoElectronico; }
    public void setCorreoElectronico(String correoElectronico) { this.correoElectronico = correoElectronico; }

    public String getTelefono() { return telefono; }
    public void setTelefono(String telefono) { this.telefono = telefono; }

    }