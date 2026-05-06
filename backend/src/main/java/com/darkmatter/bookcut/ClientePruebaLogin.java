package com.darkmatter.bookcut;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
public class ClientePruebaLogin {
    public static void main(String[] args) {
        try {
            String credencialesJson = "{\"correoElectronico\": \"luis@bookcut.com\", \"contrasenaUsuario\": \"clave123\"}";
            HttpClient clienteHttp = HttpClient.newHttpClient();
            HttpRequest peticionDeLogin = HttpRequest.newBuilder()
                    .uri(URI.create("http://localhost:8080/api/usuarios/login"))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(credencialesJson))
                    .build();
            HttpResponse<String> respuestaDelServidor = clienteHttp.send(peticionDeLogin, HttpResponse.BodyHandlers.ofString());
            System.out.println("Estado de la peticion: " + respuestaDelServidor.statusCode());
            System.out.println("Respuesta del servidor: " + respuestaDelServidor.body());
        } catch (Exception excepcionCapturada) {
            excepcionCapturada.printStackTrace();
        }
    }
}
