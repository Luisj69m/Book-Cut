package com.darkmatter.bookcut.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
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
                // 1. Desactivamos CSRF porque no lo necesitamos para una API REST
                .csrf(csrf -> csrf.disable())

                // 2. Configuramos el CORS (asegúrate de tener un Bean de CorsConfigurationSource o @CrossOrigin)
                .cors(Customizer.withDefaults())

                .authorizeHttpRequests(auth -> auth
                        // 3. Liberamos las peticiones OPTIONS (el "preflight" de los navegadores/Flutter)
                        .requestMatchers(org.springframework.http.HttpMethod.OPTIONS, "/**").permitAll()

                        // 4. Tus rutas públicas
                        .requestMatchers("/auth/**").permitAll()

                        // 5. El resto requiere estar logueado
                        .anyRequest().authenticated()
                );

        return http.build();
    }
}
