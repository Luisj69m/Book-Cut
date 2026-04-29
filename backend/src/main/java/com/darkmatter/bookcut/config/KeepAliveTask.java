package com.darkmatter.bookcut.config;

import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
public class KeepAliveTask {

    private final RestTemplate restTemplate = new RestTemplate();

    // Se ejecuta cada 12 minutos (720,000 milisegundos)
    @Scheduled(fixedRate = 720000)
    public void pingMyself() {
        try {
            // Sustituye por tu URL real de Render
            String url = "https://book-cut.onrender.com/actuator/health";
            restTemplate.getForObject(url, String.class);
            System.out.println("Keep-Alive: Ping enviado con éxito para mantener el servidor despierto.");
        } catch (Exception e) {
            System.err.println("Keep-Alive: Error al enviar el ping, pero no pasa nada.");
        }
    }
}