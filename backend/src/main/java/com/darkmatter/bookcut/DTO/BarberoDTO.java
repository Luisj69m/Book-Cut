package com.darkmatter.bookcut.DTO;

public class BarberoDTO {
    private Long idPerfilBarbero;
    private String nombreBarbero;
    private String apellidosBarbero;
    private String especialidadCorte;
    private String urlFotoPerfil;
    private Long idBarberia;

    public BarberoDTO() {}

    public BarberoDTO(Long idPerfilBarbero, String nombreBarbero, String apellidosBarbero,
                      String especialidadCorte, String urlFotoPerfil, Long idBarberia) {
        this.idPerfilBarbero = idPerfilBarbero;
        this.nombreBarbero = nombreBarbero;
        this.apellidosBarbero = apellidosBarbero;
        this.especialidadCorte = especialidadCorte;
        this.urlFotoPerfil = urlFotoPerfil;
        this.idBarberia = idBarberia;
    }

    // Getters y Setters
    public Long getIdPerfilBarbero() { return idPerfilBarbero; }
    public void setIdPerfilBarbero(Long idPerfilBarbero) { this.idPerfilBarbero = idPerfilBarbero; }

    public String getNombreBarbero() { return nombreBarbero; }
    public void setNombreBarbero(String nombreBarbero) { this.nombreBarbero = nombreBarbero; }

    public String getApellidosBarbero() { return apellidosBarbero; }
    public void setApellidosBarbero(String apellidosBarbero) { this.apellidosBarbero = apellidosBarbero; }

    public String getEspecialidadCorte() { return especialidadCorte; }
    public void setEspecialidadCorte(String especialidadCorte) { this.especialidadCorte = especialidadCorte; }

    public String getUrlFotoPerfil() { return urlFotoPerfil; }
    public void setUrlFotoPerfil(String urlFotoPerfil) { this.urlFotoPerfil = urlFotoPerfil; }

    public Long getIdBarberia() { return idBarberia; }
    public void setIdBarberia(Long idBarberia) { this.idBarberia = idBarberia; }
}
