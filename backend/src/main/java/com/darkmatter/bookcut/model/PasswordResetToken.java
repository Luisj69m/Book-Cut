package com.darkmatter.bookcut.model;

import jakarta.persistence.*;
import java.time.LocalDateTime;

/**
 * Entidad JPA para la gestión de recuperación de contraseñas.
 * Genera un código de un solo uso con una vigencia estricta temporal por motivos de seguridad.
 */
@Entity
@Table(name = "tokens_restablecer_contrasena")
public class PasswordResetToken {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_token")
    private Long idToken;

    @Column(name = "codigo_token", nullable = false, unique = true)
    private String codigoToken;

    @OneToOne(targetEntity = Usuario.class, fetch = FetchType.EAGER)
    @JoinColumn(name = "id_usuario", nullable = false)
    private Usuario usuarioVinculado;

    @Column(name = "fecha_expiracion", nullable = false)
    private LocalDateTime fechaExpiracion;

    public PasswordResetToken() {
    }

    public PasswordResetToken(String codigoToken, Usuario usuarioVinculado) {
        this.codigoToken = codigoToken;
        this.usuarioVinculado = usuarioVinculado;
        this.fechaExpiracion = LocalDateTime.now().plusMinutes(15);
    }

    public Long getIdToken() {
        return idToken;
    }

    public void setIdToken(Long idToken) {
        this.idToken = idToken;
    }

    public String getCodigoToken() {
        return codigoToken;
    }

    public void setCodigoToken(String codigoToken) {
        this.codigoToken = codigoToken;
    }

    public Usuario getUsuarioVinculado() {
        return usuarioVinculado;
    }

    public void setUsuarioVinculado(Usuario usuarioVinculado) {
        this.usuarioVinculado = usuarioVinculado;
    }

    public LocalDateTime getFechaExpiracion() {
        return fechaExpiracion;
    }

    public void setFechaExpiracion(LocalDateTime fechaExpiracion) {
        this.fechaExpiracion = fechaExpiracion;
    }

    public boolean estaExpirado() {
        return LocalDateTime.now().isAfter(this.fechaExpiracion);
    }
}