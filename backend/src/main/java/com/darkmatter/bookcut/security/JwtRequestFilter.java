package com.darkmatter.bookcut.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

/**
 * Filtro de seguridad interceptor para peticiones JWT.
 * Se ejecuta una vez por cada solicitud entrante, extrayendo el token del encabezado Authorization,
 * validándolo e inyectando la identidad y los roles del usuario en el contexto de Spring Security.
 */
@Component
public class JwtRequestFilter extends OncePerRequestFilter {

    private final JwtUtils utilidadesJwt;

    public JwtRequestFilter(JwtUtils utilidadesJwt) {
        this.utilidadesJwt = utilidadesJwt;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest peticion, HttpServletResponse respuesta, FilterChain cadenaDeFiltros)
            throws ServletException, IOException {

        final String encabezadoAutorizacion = peticion.getHeader("Authorization");

        // Si no hay token o no tiene el formato Bearer, delegamos al siguiente filtro inmediatamente
        if (encabezadoAutorizacion == null || !encabezadoAutorizacion.startsWith("Bearer ")) {
            cadenaDeFiltros.doFilter(peticion, respuesta);
            return;
        }

        String tokenJwt = encabezadoAutorizacion.substring(7);
        String correoUsuario = null;

        try {
            correoUsuario = utilidadesJwt.obtenerUsernameDeToken(tokenJwt);
        } catch (Exception excepcionToken) {
            logger.error("Error crítico: No se pudo procesar el contenido del token JWT: " + excepcionToken.getMessage());
        }

        // Si el correo es válido y el usuario no ha sido autenticado todavía en este hilo de ejecución
        if (correoUsuario != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            if (utilidadesJwt.validarToken(tokenJwt)) {

                // Recuperamos el rol almacenado en los claims del token
                String nombreRol = utilidadesJwt.obtenerRolDeToken(tokenJwt);

                // Construimos la autoridad con el prefijo ROLE_ requerido por Spring Security para hasRole()
                List<SimpleGrantedAuthority> autoridades = List.of(new SimpleGrantedAuthority("ROLE_" + nombreRol));

                // Generamos el objeto de autenticación con las credenciales y roles
                UsernamePasswordAuthenticationToken autenticacion = new UsernamePasswordAuthenticationToken(
                        correoUsuario, null, autoridades);

                autenticacion.setDetails(new WebAuthenticationDetailsSource().buildDetails(peticion));

                // Inyectamos el usuario autenticado en el contexto global de seguridad
                SecurityContextHolder.getContext().setAuthentication(autenticacion);
            }
        }

        // Continuamos con la cadena de filtros de seguridad
        cadenaDeFiltros.doFilter(peticion, respuesta);
    }
}