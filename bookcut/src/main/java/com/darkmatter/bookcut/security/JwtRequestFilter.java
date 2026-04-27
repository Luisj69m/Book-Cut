package com.darkmatter.bookcut.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.apache.catalina.core.ApplicationFilterChain;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.ArrayList;

@Component
public class JwtRequestFilter extends OncePerRequestFilter {

    @Autowired
    private JwtUtils jwtUtils;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain chain)
            throws ServletException, IOException {

        final String authorizationHeader = request.getHeader("Authorization");

        // Si no hay token, dejamos pasar la petición directamente al siguiente filtro (permitAll)
        if (authorizationHeader == null || !authorizationHeader.startsWith("Bearer ")) {
            chain.doFilter(request, response);
            return; // IMPORTANTE: Salir para no ejecutar el resto de validaciones
        }

        String username = null;
        String jwt = null;

        // 1. Verificamos si existe el header y tiene el formato correcto
        if (authorizationHeader != null && authorizationHeader.startsWith("Bearer ")) {
            jwt = authorizationHeader.substring(7);
            try {
                username = jwtUtils.obtenerUsernameDeToken(jwt);
            } catch (Exception e) {
                logger.error("No se pudo extraer el username del token: " + e.getMessage());
            }
        }

        // 2. Si tenemos username y no hay autenticación previa, validamos
        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            if (jwtUtils.validarToken(jwt)) {
                // Creamos el objeto de autenticación
                UsernamePasswordAuthenticationToken authentication = new UsernamePasswordAuthenticationToken(
                        username, null, new ArrayList<>());

                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

                // Establecemos la autenticación en el contexto de seguridad
                SecurityContextHolder.getContext().setAuthentication(authentication);

                System.out.println("DEBUG: Usuario autenticado correctamente: " + username);
            }
        }

        // 3. ¡IMPORTANTE! Solo un doFilter al final para que la petición siga su curso
        chain.doFilter(request, response);
    }
}
