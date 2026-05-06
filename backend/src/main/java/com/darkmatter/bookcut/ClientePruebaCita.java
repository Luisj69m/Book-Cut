package com.darkmatter.bookcut;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
public class ClientePruebaCita {
    public static void main(String[] args) {
        try {
            // Este JSON intenta reservar la misma fecha que ya existe: 2026-03-15T10:30:00
            String jsonReservaRepetida = "{\"clienteReserva\": {\"idUsuario\": 1}, \"barberoAsignado\": {\"idPerfilBarbero\": 1}, \"servicioContratado\": {\"idServicio\": 1}, \"fechaHoraCita\": \"2026-03-15T10:30:00\", \"estadoCita\": \"PENDIENTE\"}";
            HttpClient clienteHttp = HttpClient.newHttpClient();
            HttpRequest peticionDeReserva = HttpRequest.newBuilder()
                    .uri(URI.create("http://localhost:8080/api/citas/reservar"))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(jsonReservaRepetida))
                    .build();
            HttpResponse<String> respuestaDelServidor = clienteHttp.send(peticionDeReserva, HttpResponse.BodyHandlers.ofString());
            System.out.println("Estado de la peticion: " + respuestaDelServidor.statusCode());
            System.out.println("Respuesta del servidor: " + respuestaDelServidor.body());
        } catch (Exception excepcionCapturada) {
            excepcionCapturada.printStackTrace();
        }
    }
}
