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
}
