package com.darkmatter.bookcut.config;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

/**
 * Tarea programada para evitar la suspensión de la instancia en Render.
 * Realiza una petición periódica al endpoint de salud para mantener el backend activo.
 */
@Component
public class KeepAliveTask {

    private final RestTemplate plantillaRest = new RestTemplate();
    private final String urlSaludBackend = "https://book-cut.onrender.com/actuator/health";

    /**
     * Ejecuta una petición GET cada 12 minutos.
     * El intervalo de 720,000 milisegundos se elige para anticiparse al tiempo de inactividad de Render.
     */
    @Scheduled(fixedRate = 720000)
    public void mantenerServidorActivo() {
        try {
            plantillaRest.getForObject(urlSaludBackend, String.class);
            System.out.println("Keep-Alive: Señal de actividad enviada correctamente.");
        } catch (Exception excepcion) {
            // Se captura la excepción para evitar trazas innecesarias en el log de Render
            System.err.println("Keep-Alive: El servidor de destino no respondió, se reintentará en el próximo ciclo.");
        }
    }
}