package com.darkmatter.bookcut.service;

import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

/**
 * Servicio encargado de la comunicación con el servidor SMTP.
 * Gestiona el envío de notificaciones de citas y procesos de seguridad del sistema.
 */
@Service
public class EmailService {

    private final JavaMailSender enviadorDeCorreos;

    public EmailService(JavaMailSender enviadorDeCorreos) {
        this.enviadorDeCorreos = enviadorDeCorreos;
    }

    /**
     * Envío genérico de correos electrónicos.
     */
    public void enviarCorreo(String destinatario, String asunto, String cuerpoMensaje) {
        SimpleMailMessage mensaje = new SimpleMailMessage();
        mensaje.setTo(destinatario);
        mensaje.setSubject(asunto);
        mensaje.setText(cuerpoMensaje);
        enviadorDeCorreos.send(mensaje);
    }

    /**
     * Envía una notificación cuando un cliente solicita una nueva cita.
     */
    public void enviarCorreoConfirmacion(String destinatario, String fechaFormateada) {
        SimpleMailMessage mensaje = new SimpleMailMessage();
        mensaje.setTo(destinatario);
        mensaje.setSubject("Confirmación de Reserva - Book&Cut");
        mensaje.setText("Hola,\n\nTu reserva ha sido recibida con éxito para la fecha: " + fechaFormateada +
                ".\nQueda a la espera de que el barbero acepte la solicitud.");
        enviadorDeCorreos.send(mensaje);
    }

    /**
     * Envía el código de seguridad de 6 dígitos para el flujo de recuperación de contraseña.
     */
    public void enviarCorreoRecuperacion(String destinatario, String codigoToken) {
        SimpleMailMessage mensaje = new SimpleMailMessage();
        mensaje.setTo(destinatario);
        mensaje.setSubject("Restablecer Contraseña - Book&Cut");
        mensaje.setText("Hola,\n\nHas solicitado restablecer tu contraseña. Tu código de verificación es: " + codigoToken +
                "\n\nEste código expirará en 15 minutos.");
        enviadorDeCorreos.send(mensaje);
    }
}

