package com.darkmatter.bookcut;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class PruebaFinalBackend {

    private static final String BASE_URL = "http://localhost:8080/api";

    public static void main(String[] args) throws Exception {
        System.out.println("--- INICIANDO AUDITORIA FINAL DEL BACKEND ---");

        // 1. Probar Listado de Servicios
        probarGet("/servicios", "LISTAR SERVICIOS");

        // 2. Probar Listado de Barberos
        probarGet("/barberos/todos", "LISTAR BARBEROS");

        // 3. Intentar Reserva Exitosa
        String jsonCita = """
            {
              "clienteReserva": { "idUsuario": 1 },
              "barberoAsignado": { "idPerfilBarbero": 1 },
              "servicioContratado": { "idServicio": 1 },
              "fechaHoraCita": "2026-06-20T12:00:00",
              "estadoCita": "PENDIENTE"
            }
            """;
        probarPost("/citas/reservar", jsonCita, "RESERVA EXITOSA (12:00h)");

        // 4. Probar Bloqueo de Cita Duplicada (Misma hora, mismo barbero)
        probarPost("/citas/reservar", jsonCita, "BLOQUEO DUPLICADO (Debe dar 500)");

        // 5. Ver Historial del Cliente
        probarGet("/citas/historial/1", "HISTORIAL CLIENTE ID:1");
    }

    private static void probarGet(String endpoint, String nombrePrueba) throws Exception {
        HttpClient cliente = HttpClient.newHttpClient();
        HttpRequest peticion = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + endpoint))
                .GET()
                .build();
        HttpResponse<String> respuesta = cliente.send(peticion, HttpResponse.BodyHandlers.ofString());
        System.out.println("[" + nombrePrueba + "] Status: " + respuesta.statusCode());
        System.out.println("Respuesta: " + respuesta.body());
        System.out.println("--------------------------------------------");
    }

    private static void probarPost(String endpoint, String json, String nombrePrueba) throws Exception {
        HttpClient cliente = HttpClient.newHttpClient();
        HttpRequest peticion = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + endpoint))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(json))
                .build();
        HttpResponse<String> respuesta = cliente.send(peticion, HttpResponse.BodyHandlers.ofString());
        System.out.println("[" + nombrePrueba + "] Status: " + respuesta.statusCode());
        System.out.println("Respuesta: " + respuesta.body());
        System.out.println("--------------------------------------------");
    }
}