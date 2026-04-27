package com.darkmatter.bookcut.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

@Configuration
@EnableWebSecurity
public class SecurityConfig {

    @Autowired
    private JwtRequestFilter jwtRequestFilter;

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // 1. Permite que el frontend de Dani conecte desde cualquier sitio
                .cors(Customizer.withDefaults())

                // 2. Desactiva la protección CSRF (obligatorio para APIs REST con JWT)
                .csrf(csrf -> csrf.disable())

                // 3. Configura la API como sin estado
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

                .authorizeHttpRequests(auth -> auth
                        .requestMatchers(org.springframework.http.HttpMethod.OPTIONS, "/**").permitAll()
                        .requestMatchers("/api/usuarios/registrar").permitAll()
                        .requestMatchers("/api/usuarios/login").permitAll()
                        .requestMatchers("/error").permitAll()
                        .anyRequest().authenticated()
                );

        // 7. Enganchamos tu filtro JWT a la cadena
        http.addFilterBefore(jwtRequestFilter, org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public org.springframework.web.cors.CorsConfigurationSource corsConfigurationSource() {
        org.springframework.web.cors.CorsConfiguration configuracionCors = new org.springframework.web.cors.CorsConfiguration();
        configuracionCors.setAllowedOriginPatterns(java.util.List.of("*"));
        configuracionCors.setAllowedMethods(java.util.List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        configuracionCors.setAllowedHeaders(java.util.List.of("*"));
        configuracionCors.setAllowCredentials(false);
        org.springframework.web.cors.UrlBasedCorsConfigurationSource fuenteCors = new org.springframework.web.cors.UrlBasedCorsConfigurationSource();
        fuenteCors.registerCorsConfiguration("/**", configuracionCors);
        return fuenteCors;
    }
}
