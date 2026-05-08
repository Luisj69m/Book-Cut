package com.darkmatter.bookcut.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;

/**
 * Utilidades para la gestión de JSON Web Tokens (JWT).
 * Se encarga de la generación, cifrado y desglosado de los tokens de acceso,
 * incluyendo la gestión de roles y la validación de tiempos de expiración.
 */
@Component
public class JwtUtils {

    // Clave secreta estática para garantizar que los tokens sobrevivan al reinicio del servidor
    private final String CLAVE_SECRETA_FIRMA = "EstaEsMiClaveSuperSecretaParaElTFGDeBarberia2026";
    private final Key llaveFirma = Keys.hmacShaKeyFor(CLAVE_SECRETA_FIRMA.getBytes());

    // Tiempo de vida del token: 24 horas (en milisegundos)
    private final long TIEMPO_EXPIRACION_MS = 86400000;

    /**
     * Genera un nuevo token firmado que incluye la identidad y el rol del usuario.
     */
    public String generarToken(String correoUsuario, String nombreRol) {
        return Jwts.builder()
                .setSubject(correoUsuario)
                .claim("rol", nombreRol)
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + TIEMPO_EXPIRACION_MS))
                .signWith(llaveFirma)
                .compact();
    }

    /**
     * Extrae el correo electrónico (Subject) almacenado en el token.
     */
    public String obtenerUsernameDeToken(String tokenJwt) {
        return Jwts.parserBuilder()
                .setSigningKey(llaveFirma)
                .build()
                .parseClaimsJws(tokenJwt)
                .getBody()
                .getSubject();
    }

    /**
     * Verifica la integridad y la vigencia temporal del token.
     */
    public boolean validarToken(String tokenJwt) {
        try {
            Jwts.parserBuilder().setSigningKey(llaveFirma).build().parseClaimsJws(tokenJwt);
            return true;
        } catch (Exception excepcionValidacion) {
            // El token puede ser inválido por expiración, firma corrupta o formato erróneo
            return false;
        }
    }

    /**
     * Recupera el rol del usuario desde los claims personalizados del payload.
     */
    public String obtenerRolDeToken(String tokenJwt) {
        return Jwts.parserBuilder()
                .setSigningKey(llaveFirma)
                .build()
                .parseClaimsJws(tokenJwt)
                .getBody()
                .get("rol", String.class);
    }
}