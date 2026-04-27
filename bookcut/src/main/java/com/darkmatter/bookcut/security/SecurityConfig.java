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
                        // 4. Deja pasar las peticiones de comprobación OPTIONS de Flutter
                        .requestMatchers(org.springframework.http.HttpMethod.OPTIONS, "/**").permitAll()

                        // 5. RUTAS REALES: Liberamos exactamente lo que tienes en tu UsuarioController
                        .requestMatchers("/api/usuarios/registrar").permitAll()
                        .requestMatchers("/api/usuarios/login").permitAll()

                        // 6. Todo lo demás requiere token
                        .anyRequest().authenticated()
                );

        // 7. Enganchamos tu filtro JWT a la cadena
        http.addFilterBefore(jwtRequestFilter, org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
