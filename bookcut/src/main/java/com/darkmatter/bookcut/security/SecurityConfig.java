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
                .csrf(csrf -> csrf.disable()) // ESTO ES VITAL
                .cors(Customizer.withDefaults()) // Permite que Dani se conecte desde fuera
                .authorizeHttpRequests(auth -> auth
                        // 1. Primero permitimos el "pre-vuelo" de Flutter
                        .requestMatchers(HttpMethod.OPTIONS, "/**").permitAll()

                        // 2. Liberamos las rutas de autenticación (registro, login, pass)
                        // Asegúrate de que las rutas de Dani empiecen por /auth/
                        .requestMatchers("/auth/**").permitAll()
                        .requestMatchers("/api/auth/**").permitAll()

                        // 3. Todo lo demás, bloqueado
                        .anyRequest().authenticated()
                )
                .httpBasic(Customizer.withDefaults()); // O la configuración de JWT que uses

        return http.build();
    }
}
