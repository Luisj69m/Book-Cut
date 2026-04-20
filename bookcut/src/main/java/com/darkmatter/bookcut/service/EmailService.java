package com.darkmatter.bookcut.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class EmailService {

    @Autowired
    private JavaMailSender enviadorDeCorreos;

    public void enviarCorreo(String to, String subject, String text) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(to);
        message.setSubject(subject);
        message.setText(text);
        enviadorDeCorreos.send(message);
    }

    public void enviarCorreoConfirmacion(String destinatario, String fecha) {
        SimpleMailMessage mensaje = new SimpleMailMessage();
        mensaje.setTo(destinatario);
        mensaje.setSubject("Confirmación de Reserva - Book&Cut");
        mensaje.setText("Hola, tu reserva ha sido realizada con éxito para el día: " + fecha);
        enviadorDeCorreos.send(mensaje);
    }
}

