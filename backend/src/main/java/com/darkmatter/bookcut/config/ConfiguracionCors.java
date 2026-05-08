package com.darkmatter.bookcut.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

/**
 * Configuración global de CORS para el proyecto BookCut.
 * Define los permisos de acceso cruzado entre el backend y los distintos frontends
 * (Panel Admin, App Móvil y entorno de desarrollo).
 */
@Configuration
public class ConfiguracionCors implements WebMvcConfigurer {

    @Override
    public void addCorsMappings(CorsRegistry registroCors) {
        registroCors.addMapping("/**")
                // Orígenes permitidos según el Documento Maestro de Arquitectura
                .allowedOrigins(
                        "https://bookandcut.netlify.app",
                        "http://localhost:3000",
                        "http://localhost:19006"
                )
                // Métodos HTTP autorizados para la API
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                // Se permite cualquier cabecera (necesario para el Authorization header del JWT)
                .allowedHeaders("*")
                // Permitir el envío de credenciales (Bearer Token / Cookies)
                .allowCredentials(true);
    }
}
