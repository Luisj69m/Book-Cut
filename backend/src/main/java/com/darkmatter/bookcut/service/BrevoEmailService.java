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

    public void enviarCorreoRecuperacion(String destinatario, String nombreUsuario, String codigoRecuperacion) throws Exception {
        String asunto = "Recuperación de Contraseña - BookCut";
        String cuerpo = EmailTemplates.plantillaRecuperacion(nombreUsuario, codigoRecuperacion);
        enviarCorreo(destinatario, asunto, cuerpo);
    }

    public void enviarCorreoConfirmacion(String destinatario, String nombreUsuario) throws Exception {
        String asunto = "¡Bienvenido a BookCut! 🎉";
        String cuerpo = EmailTemplates.plantillaBienvenida(nombreUsuario);
        enviarCorreo(destinatario, asunto, cuerpo);
    }

    public void enviarCorreoCitaCreada(String destinatario, String nombreCliente, String nombreBarbero,
                                       String nombreBarberia, String fechaHora, String servicio, String precio) throws Exception {
        String asunto = "Solicitud de Cita Recibida - BookCut";
        String cuerpo = EmailTemplates.plantillaCitaCreada(nombreCliente, nombreBarbero, nombreBarberia,
                fechaHora, servicio, precio);
        enviarCorreo(destinatario, asunto, cuerpo);
    }

    public void enviarCorreoCitaAceptada(String destinatario, String nombreCliente, String nombreBarbero,
                                         String nombreBarberia, String fechaHora, String servicio, String precio) throws Exception {
        String asunto = "¡Cita Confirmada! - BookCut";
        String cuerpo = EmailTemplates.plantillaCitaAceptada(nombreCliente, nombreBarbero, nombreBarberia,
                fechaHora, servicio, precio);
        enviarCorreo(destinatario, asunto, cuerpo);
    }

    public void enviarCorreoCitaRechazada(String destinatario, String nombreCliente, String nombreBarbero,
                                          String nombreBarberia, String fechaHora, String servicio) throws Exception {
        String asunto = "Cita No Disponible - BookCut";
        String cuerpo = EmailTemplates.plantillaCitaRechazada(nombreCliente, nombreBarbero, nombreBarberia,
                fechaHora, servicio);
        enviarCorreo(destinatario, asunto, cuerpo);
    }

    public void enviarCorreoCitaCancelada(String destinatario, String nombreCliente, String nombreBarbero,
                                          String nombreBarberia, String fechaHora, String servicio) throws Exception {
        String asunto = "Cita Cancelada - BookCut";
        String cuerpo = EmailTemplates.plantillaCitaCancelada(nombreCliente, nombreBarbero, nombreBarberia,
                fechaHora, servicio);
        enviarCorreo(destinatario, asunto, cuerpo);
    }

    public void enviarCorreoCitaCompletada(String destinatario, String nombreCliente, String nombreBarbero,
                                           String nombreBarberia, String fechaHora, String servicio, String precio) throws Exception {
        String asunto = "¡Gracias por tu visita! - BookCut";
        String cuerpo = EmailTemplates.plantillaCitaCompletada(nombreCliente, nombreBarbero, nombreBarberia,
                fechaHora, servicio, precio);
        enviarCorreo(destinatario, asunto, cuerpo);
    }

    public void enviarCorreoRecordatorio24h(String destinatario, String nombreCliente, String nombreBarbero,
                                            String nombreBarberia, String fechaHora, String servicio, String direccion) throws Exception {
        String asunto = "⏰ Recordatorio: Cita Mañana - BookCut";
        String cuerpo = EmailTemplates.plantillaRecordatorio24h(nombreCliente, nombreBarbero, nombreBarberia,
                fechaHora, servicio, direccion);
        enviarCorreo(destinatario, asunto, cuerpo);
    }
}