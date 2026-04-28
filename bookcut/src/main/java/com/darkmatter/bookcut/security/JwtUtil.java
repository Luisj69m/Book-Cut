package com.darkmatter.bookcut.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;

@Component
public class JwtUtil {

    // Cambiamos la llave aleatoria por una fija basada en un String secreto
    private final String SEGUNDA_CLAVE_SECRETA = "EstaEsMiClaveSuperSecretaParaElTFGDeBarberia2026";
    private final Key key = Keys.hmacShaKeyFor(SEGUNDA_CLAVE_SECRETA.getBytes());

    private final long jwtExpirationMs = 86400000;

    // MÉTODO 1: Generar el token a partir del nombre de usuario
    public String generarToken(String username, String rol) { // Añadimos el rol aquí
        return Jwts.builder()
                .setSubject(username)
                .claim("rol", rol) // Metemos el rol dentro del token
                .setIssuedAt(new Date())
                .setExpiration(new Date((new Date()).getTime() + jwtExpirationMs))
                .signWith(key)
                .compact();
    }

    // MÉTODO 2: Obtener el nombre de usuario de dentro del token
    public String obtenerUsernameDeToken(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(key)
                .build()
                .parseClaimsJws(token)
                .getBody()
                .getSubject();
    }

    // MÉTODO 3: Validar que el token es correcto y no ha expirado
    public boolean validarToken(String token) {
        try {
            Jwts.parserBuilder().setSigningKey(key).build().parseClaimsJws(token);
            return true;
        } catch (Exception e) {
            System.err.println("Token inválido: " + e.getMessage());
        }
        return false;
    }
}
