package com.darkmatter.bookcut.config;

import jakarta.annotation.PostConstruct;
import org.springframework.context.annotation.Configuration;
import java.util.TimeZone;

/**
 * Configuración de la zona horaria global de la aplicación.
 * Asegura que todas las operaciones con fechas y horas utilicen el estándar de Madrid,
 * evitando discrepancias entre el servidor de despliegue y la base de datos.
 */
@Configuration
public class ConfiguracionZonaHoraria {

    /**
     * Establece la zona horaria por defecto inmediatamente después de que
     * el contexto de Spring haya inicializado el bean.
     */
    @PostConstruct
    public void establecerConfiguracionHoraria() {
        TimeZone.setDefault(TimeZone.getTimeZone("Europe/Madrid"));
    }
}
