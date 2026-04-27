package com.darkmatter.bookcut.config;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
@Configuration
@CrossOrigin
public class ConfiguracionCors implements WebMvcConfigurer {
    @Override
    public void addCorsMappings(CorsRegistry registroCors) {
        registroCors.addMapping("/**")
                .allowedOrigins("*")
                .allowedMethods("GET", "POST", "PUT", "DELETE", "OPTIONS")
                .allowedHeaders("*");
    }
}
