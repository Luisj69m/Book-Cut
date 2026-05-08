package com.darkmatter.bookcut.model;

/**
 * Enumeración que define los niveles de privilegios y acceso dentro de la plataforma.
 * Nota de arquitectura: La base de datos almacena la constante literal (ej. ADMIN).
 * El componente JwtRequestFilter es el responsable de inyectar el prefijo "ROLE_"
 * para construir la autorización estándar de Spring Security.
 */
public enum RolUsuario {
    CLIENTE,
    BARBERO,
    ADMIN
}
