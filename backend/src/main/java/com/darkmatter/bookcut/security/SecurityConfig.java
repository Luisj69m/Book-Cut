package com.darkmatter.bookcut.security;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

/**
 * Configuración central de seguridad de la aplicación.
 * Define las reglas de acceso por endpoint, la política de sesiones sin estado (Stateless),
 * la integración del filtro JWT y la configuración de CORS para clientes externos.
 */
@Configuration
@EnableWebSecurity
public class SecurityConfig {

    private final JwtRequestFilter filtroPeticionesJwt;

    public SecurityConfig(JwtRequestFilter filtroPeticionesJwt) {
        this.filtroPeticionesJwt = filtroPeticionesJwt;
    }

    @Bean
    public SecurityFilterChain filtrarSeguridad(HttpSecurity comunicacion) throws Exception {
        comunicacion
                // Configuración de CORS basada en el bean definido abajo
                .cors(Customizer.withDefaults())

                // Desactivación de CSRF por ser una API REST basada en tokens
                .csrf(csrf -> csrf.disable())

                // Definición de política de sesión sin estado
                .sessionManagement(sesion -> sesion.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

                .authorizeHttpRequests(autorizacion -> autorizacion
                        // Endpoints de acceso público total
                        .requestMatchers("/api/usuarios/registrar", "/api/usuarios/login").permitAll()
                        .requestMatchers("/api/usuarios/solicitar-recuperacion", "/api/usuarios/confirmar-recuperacion").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/barberias/**").permitAll()
                        .requestMatchers("/error").permitAll()

                        // Restricciones de nivel de acceso profesional
                        .requestMatchers(HttpMethod.PUT, "/api/barberias/mi-barberia/**").hasAnyRole("BARBERO", "ADMIN")

                        // Garantía de autenticación para el resto de recursos
                        .anyRequest().authenticated()
                );

        // Integración del interceptor JWT antes del filtro de autenticación estándar
        comunicacion.addFilterBefore(filtroPeticionesJwt, UsernamePasswordAuthenticationFilter.class);

        return comunicacion.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuracion = new CorsConfiguration();

        // Orígenes autorizados (Producción en Netlify y entornos de desarrollo)
        configuracion.setAllowedOrigins(List.of(
                "https://bookandcut.netlify.app",
                "http://localhost:3000",
                "http://localhost:19006"
        ));

        configuracion.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuracion.setAllowedHeaders(List.of("Authorization", "Content-Type", "X-Requested-With", "Accept"));

        // Permitir envío de credenciales (Bearer Tokens) desde el cliente
        configuracion.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource fuente = new UrlBasedCorsConfigurationSource();
        fuente.registerCorsConfiguration("/**", configuracion);
        return fuente;
    }
}