package com.darkmatter.bookcut.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;
import java.util.List;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtRequestFilter jwtRequestFilter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // 1. CORS configurado con el Bean de abajo
                .cors(Customizer.withDefaults())

                // 2. Desactivar CSRF para APIs REST
                .csrf(csrf -> csrf.disable())

                // 3. Política sin estado (JWT)
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

                .authorizeHttpRequests(auth -> auth
                        // Rutas abiertas para todo el mundo
                        .requestMatchers("/api/usuarios/registrar", "/api/usuarios/login").permitAll()
                        .requestMatchers("/api/usuarios/solicitar-recuperacion", "/api/usuarios/confirmar-recuperacion").permitAll()
                        .requestMatchers(org.springframework.http.HttpMethod.GET, "/api/barberias/**").permitAll()
                        .requestMatchers("/error").permitAll()

                        // Solo BARBEROS o ADMIN pueden crear o editar barberías
                        .requestMatchers(org.springframework.http.HttpMethod.PUT, "/api/barberias/mi-barberia/**").hasAnyRole("BARBERO", "ADMIN")

                        // El resto de la API requiere estar autenticado
                        .anyRequest().authenticated()
                );

        // 4. Tu filtro JWT
        http.addFilterBefore(jwtRequestFilter, org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuracion = new CorsConfiguration();

        // Añadimos el dominio de Netlify de Luis explícitamente
        configuracion.setAllowedOrigins(List.of(
                "https://bookandcut.netlify.app",
                "http://localhost:3000",
                "http://localhost:19006" // Para Dani con Expo
        ));

        configuracion.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuracion.setAllowedHeaders(List.of("Authorization", "Content-Type", "X-Requested-With", "Accept"));
        configuracion.setAllowCredentials(true); // Cambiado a true para que Axios pueda enviar el Bearer Token

        UrlBasedCorsConfigurationSource fuente = new UrlBasedCorsConfigurationSource();
        fuente.registerCorsConfiguration("/**", configuracion);
        return fuente;
    }
}
