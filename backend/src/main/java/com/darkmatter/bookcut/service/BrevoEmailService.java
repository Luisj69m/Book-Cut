package com.darkmatter.bookcut.service;

import okhttp3.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.Map;
import java.util.HashMap;

@Service
public class BrevoEmailService {

    @Value("${brevo.api.key}")
    private String apiKey;

    private final OkHttpClient client = new OkHttpClient();
    private final ObjectMapper objectMapper = new ObjectMapper();

    public void enviarCorreo(String destinatario, String asunto, String cuerpoHtml) throws Exception {
        String url = "https://api.brevo.com/v3/smtp/email";

        Map<String, Object> emailData = new HashMap<>();
        emailData.put("sender", Map.of("email", "bookcut2026@gmail.com", "name", "BookCut"));
        emailData.put("to", new Object[]{Map.of("email", destinatario)});
        emailData.put("subject", asunto);
        emailData.put("htmlContent", cuerpoHtml);

        String json = objectMapper.writeValueAsString(emailData);

        RequestBody body = RequestBody.create(json, MediaType.parse("application/json"));

        Request request = new Request.Builder()
                .url(url)
                .header("api-key", apiKey)
                .header("Content-Type", "application/json")
                .post(body)
                .build();

        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) {
                throw new RuntimeException("Error enviando correo: " + response.code() + " - " + response.body().string());
            }
        }
    }

    public void enviarCorreoConfirmacion(String destinatario, String nombreUsuario) throws Exception {
        String asunto = "Bienvenido a BookCut";
        String cuerpoHtml = "<html><body>" +
                "<h2>¡Bienvenido a BookCut, " + nombreUsuario + "!</h2>" +
                "<p>Tu cuenta ha sido creada exitosamente.</p>" +
                "<p>Ya puedes comenzar a usar nuestra plataforma.</p>" +
                "</body></html>";

        enviarCorreo(destinatario, asunto, cuerpoHtml);
    }

    public void enviarCorreoCitaCreada(String destinatario, String nombreCliente, String fechaHora, String nombreBarberia) throws Exception {
        String asunto = "Cita solicitada - BookCut";
        String cuerpoHtml = "<html><body>" +
                "<h2>Hola " + nombreCliente + "</h2>" +
                "<p>Tu solicitud de cita ha sido registrada correctamente.</p>" +
                "<p><strong>Fecha y hora:</strong> " + fechaHora + "</p>" +
                "<p><strong>Barbería:</strong> " + nombreBarberia + "</p>" +
                "<p>Recibirás una notificación cuando tu cita sea confirmada.</p>" +
                "</body></html>";

        enviarCorreo(destinatario, asunto, cuerpoHtml);
    }

    public void enviarCorreoCitaAceptada(String destinatario, String nombreCliente, String fechaHora, String nombreBarberia) throws Exception {
        String asunto = "Cita confirmada - BookCut";
        String cuerpoHtml = "<html><body>" +
                "<h2>¡Tu cita ha sido confirmada!</h2>" +
                "<p>Hola " + nombreCliente + ",</p>" +
                "<p>Tu cita ha sido aceptada.</p>" +
                "<p><strong>Fecha y hora:</strong> " + fechaHora + "</p>" +
                "<p><strong>Barbería:</strong> " + nombreBarberia + "</p>" +
                "<p>Te esperamos.</p>" +
                "</body></html>";

        enviarCorreo(destinatario, asunto, cuerpoHtml);
    }

    public void enviarCorreoCitaRechazada(String destinatario, String nombreCliente, String fechaHora, String nombreBarberia) throws Exception {
        String asunto = "Cita rechazada - BookCut";
        String cuerpoHtml = "<html><body>" +
                "<h2>Información sobre tu cita</h2>" +
                "<p>Hola " + nombreCliente + ",</p>" +
                "<p>Lamentamos informarte que tu cita no ha podido ser confirmada.</p>" +
                "<p><strong>Fecha y hora solicitada:</strong> " + fechaHora + "</p>" +
                "<p><strong>Barbería:</strong> " + nombreBarberia + "</p>" +
                "<p>Te invitamos a solicitar una nueva cita en otro horario.</p>" +
                "</body></html>";

        enviarCorreo(destinatario, asunto, cuerpoHtml);
    }

    public void enviarCorreoCitaCancelada(String destinatario, String nombreCliente, String fechaHora, String nombreBarberia) throws Exception {
        String asunto = "Cita cancelada - BookCut";
        String cuerpoHtml = "<html><body>" +
                "<h2>Cita cancelada</h2>" +
                "<p>Hola " + nombreCliente + ",</p>" +
                "<p>Tu cita ha sido cancelada.</p>" +
                "<p><strong>Fecha y hora:</strong> " + fechaHora + "</p>" +
                "<p><strong>Barbería:</strong> " + nombreBarberia + "</p>" +
                "</body></html>";

        enviarCorreo(destinatario, asunto, cuerpoHtml);
    }

    public void enviarCorreoCitaCompletada(String destinatario, String nombreCliente, String fechaHora, String nombreBarberia) throws Exception {
        String asunto = "Cita completada - BookCut";
        String cuerpoHtml = "<html><body>" +
                "<h2>¡Gracias por tu visita!</h2>" +
                "<p>Hola " + nombreCliente + ",</p>" +
                "<p>Tu cita ha sido completada correctamente.</p>" +
                "<p><strong>Fecha y hora:</strong> " + fechaHora + "</p>" +
                "<p><strong>Barbería:</strong> " + nombreBarberia + "</p>" +
                "<p>Esperamos verte pronto.</p>" +
                "</body></html>";

        enviarCorreo(destinatario, asunto, cuerpoHtml);
    }
}
